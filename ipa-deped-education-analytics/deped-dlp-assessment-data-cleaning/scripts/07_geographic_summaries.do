********************************************************************************
** TITLE   : 07_geographic_summaries.do
** PURPOSE : Export regional, division, and city/municipality summaries and figures.
** PROJECT : Dynamic Learning Program descriptive results
** AUTHOR  : Erika Salvador
** DATE    : June 11, 2026
********************************************************************************

version 17
clear all
set more off

* Resolve paths relative to the project folder, with optional override.
local project_dir "`c(pwd)'"
if "$DLP_PROJECT_DIR" != "" local project_dir "$DLP_PROJECT_DIR"
capture confirm file "`project_dir'/data/03_dlp_rma_philiri_school_level_for_stata.dta"
if _rc {
    cd ..
    local project_dir "`c(pwd)'"
}
local data_dir "`project_dir'/data"
local output_dir "`project_dir'/outputs"
local table_dir "`output_dir'/tables"
local figure_dir "`output_dir'/figures"
local individual_figure_dir "`figure_dir'/individual_figures"
local log_dir "`output_dir'/logs"

cap mkdir "`figure_dir'"
cap mkdir "`individual_figure_dir'"

cap log close
log using "`log_dir'/07_geographic_summaries.log", replace text

* Use IPA's Stata graph scheme when available.
cap which github
if _rc {
    net install github, from("https://haghish.github.io/github/")
}
cap github install PovertyAction/ipaplots, replace
set scheme ipaplots, perm

use "`data_dir'/03_dlp_rma_philiri_school_level_for_stata.dta", clear

* Create reusable indicators and assessed counts for geographic summaries.
gen byte school_row = 1
gen byte control_school = treatment_status == "Control"
gen byte treatment_school = treatment_status == "Treatment"

egen philiri_bosy_assessed = rowtotal(ph_b_g7_eng_assessed ph_b_g8_eng_assessed ph_b_g9_eng_assessed ph_b_g10_eng_assessed), missing
egen philiri_eosy_assessed = rowtotal(ph_e_g7_eng_assessed ph_e_g8_eng_assessed ph_e_g9_eng_assessed ph_e_g10_eng_assessed), missing
egen rma_bosy_assessed = rowtotal(rma_b_g7_assessed rma_b_g8_assessed rma_b_g9_assessed rma_b_g10_assessed), missing
egen rma_eosy_assessed = rowtotal(rma_e_g7_assessed rma_e_g8_assessed rma_e_g9_assessed rma_e_g10_assessed), missing

label var region_code "Region"
label var full_division_code "Division"
label var full_municipality_code "City/municipality"
label var school_row "Schools"
label var control_school "Control schools"
label var treatment_school "Treatment schools"
label var enroll_total_jhs_all "Enrolled junior high school students"
label var ph_b_enrolled "Philippine Informal Reading Inventory beginning-of-school-year enrolled"
label var ph_e_enrolled "Philippine Informal Reading Inventory end-of-school-year enrolled"
label var rma_b_enrolled "Rapid Mathematics Assessment beginning-of-school-year enrolled"
label var rma_e_enrolled "Rapid Mathematics Assessment end-of-school-year enrolled"
label var philiri_bosy_assessed "Philippine Informal Reading Inventory beginning-of-school-year assessed"
label var philiri_eosy_assessed "Philippine Informal Reading Inventory end-of-school-year assessed"
label var rma_bosy_assessed "Rapid Mathematics Assessment beginning-of-school-year assessed"
label var rma_eosy_assessed "Rapid Mathematics Assessment end-of-school-year assessed"
label var compliance "Compliant schools"

tempfile base
save `base', replace

foreach level in region division municipality {
    use `base', clear

    * Export one table per geography level, including map-ready CSVs.
    if "`level'" == "region" {
        local geo_var region_code
    }
    if "`level'" == "division" {
        local geo_var full_division_code
    }
    if "`level'" == "municipality" {
        local geo_var full_municipality_code
    }

    keep if !missing(`geo_var')
    collapse ///
        (sum) n_schools=school_row control_schools=control_school treatment_schools=treatment_school ///
              enrolled_jhs=enroll_total_jhs_all philiri_bosy_assessed philiri_eosy_assessed rma_bosy_assessed rma_eosy_assessed ///
              philiri_bosy_enrolled=ph_b_enrolled philiri_eosy_enrolled=ph_e_enrolled rma_bosy_enrolled=rma_b_enrolled rma_eosy_enrolled=rma_e_enrolled ///
              n_compliant=compliance ///
        (count) compliance_denominator=compliance, ///
        by(`geo_var')

    gen pct_control = 100 * control_schools / n_schools if n_schools > 0
    gen pct_treatment = 100 * treatment_schools / n_schools if n_schools > 0
    gen compliance_rate = 100 * n_compliant / compliance_denominator if compliance_denominator > 0
    gen philiri_bosy_assessment_rate = 100 * philiri_bosy_assessed / philiri_bosy_enrolled if philiri_bosy_enrolled > 0
    gen rma_bosy_assessment_rate = 100 * rma_bosy_assessed / rma_bosy_enrolled if rma_bosy_enrolled > 0
    gen philiri_eosy_assessment_rate = 100 * philiri_eosy_assessed / philiri_eosy_enrolled if philiri_eosy_enrolled > 0
    gen rma_eosy_assessment_rate = 100 * rma_eosy_assessed / rma_eosy_enrolled if rma_eosy_enrolled > 0

    order `geo_var' n_schools control_schools treatment_schools pct_control pct_treatment ///
        enrolled_jhs philiri_bosy_enrolled philiri_bosy_assessed philiri_bosy_assessment_rate rma_bosy_enrolled rma_bosy_assessed rma_bosy_assessment_rate ///
        philiri_eosy_enrolled philiri_eosy_assessed philiri_eosy_assessment_rate rma_eosy_enrolled rma_eosy_assessed rma_eosy_assessment_rate ///
        compliance_denominator n_compliant compliance_rate

    export excel using "`table_dir'/07_geographic_summary_`level'.xlsx", firstrow(variables) replace
    export delimited using "`table_dir'/07_geographic_summary_`level'_map_ready.csv", replace
}

use `base', clear
* Regional treatment-status composition.
collapse (sum) n_schools=school_row control_schools=control_school treatment_schools=treatment_school, by(region_code)
gen region_label = "Region " + strtrim(region_code)
gsort -n_schools
graph hbar control_schools treatment_schools, over(region_label, sort(n_schools) descending label(labsize(small))) stack ///
    title("Randomized DLP Schools by Region and Treatment Status") ///
    subtitle("Control and Treatment Schools") ///
    ytitle("Number of Schools", size(*.8)) ///
    legend(order(1 "Control" 2 "Treatment") rows(1) size(vsmall)) ///
    note("Treatment status is based on rev_status in the randomized evaluation file.", size(*.7) span)
graph export "`individual_figure_dir'/07_regional_treatment_status.png", replace width(2800)

use `base', clear
* Regional compliance rates.
keep if !missing(compliance)
collapse (count) n_schools=compliance (sum) n_compliant=compliance, by(region_code)
gen compliance_rate = 100 * n_compliant / n_schools if n_schools > 0
gen region_label = "Region " + strtrim(region_code)
graph hbar compliance_rate, over(region_label, sort(compliance_rate) descending label(labsize(small))) ///
    title("Compliance Rate by Region") ///
    subtitle("Share of Schools Aligned With Assigned Treatment Status") ///
    ytitle("Compliance Rate (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    blabel(bar, format(%9.1f)) ///
    note("Compliance follows assignment-to-treatment-status alignment.", size(*.7) span)
graph export "`individual_figure_dir'/07_regional_compliance_rate.png", replace width(2800)

use `base', clear
* Regional assessment coverage comparing reading and mathematics assessments.
collapse ///
    (sum) enrolled_jhs=enroll_total_jhs_all ///
          reading_enrolled_bosy=ph_b_enrolled reading_enrolled_eosy=ph_e_enrolled ///
          mathematics_enrolled_bosy=rma_b_enrolled mathematics_enrolled_eosy=rma_e_enrolled ///
          reading_assessment_bosy=philiri_bosy_assessed reading_assessment_eosy=philiri_eosy_assessed ///
          mathematics_assessment_bosy=rma_bosy_assessed mathematics_assessment_eosy=rma_eosy_assessed, ///
    by(region_code)
gen region_label = "Region " + strtrim(region_code)
gen reading_assessment_rate_bosy = 100 * reading_assessment_bosy / reading_enrolled_bosy if reading_enrolled_bosy > 0
gen reading_assessment_rate_eosy = 100 * reading_assessment_eosy / reading_enrolled_eosy if reading_enrolled_eosy > 0
gen mathematics_assessment_rate_bosy = 100 * mathematics_assessment_bosy / mathematics_enrolled_bosy if mathematics_enrolled_bosy > 0
gen mathematics_assessment_rate_eosy = 100 * mathematics_assessment_eosy / mathematics_enrolled_eosy if mathematics_enrolled_eosy > 0
reshape long reading_assessment_rate_ mathematics_assessment_rate_, i(region_code) j(period) string
rename reading_assessment_rate_ reading_assessment_rate
rename mathematics_assessment_rate_ mathematics_assessment_rate
gen period_order = .
replace period_order = 1 if period == "bosy"
replace period_order = 2 if period == "eosy"
label define period_order 1 "Beginning of School Year" 2 "End of School Year", replace
label values period_order period_order

graph hbar reading_assessment_rate mathematics_assessment_rate, over(region_label, sort(enrolled_jhs) descending label(labsize(small))) ///
    by(period_order, cols(2) title("Assessment Coverage by Region") subtitle("Assessed Students as a Share of Assessment Dashboard Enrollment") note("Reading Assessment is Philippine Informal Reading Inventory." "Mathematics Assessment is Rapid Mathematics Assessment.", size(*.7))) ///
    subtitle(, nobox fcolor(none) lcolor(none)) ///
    ytitle("Assessment Rate (%)", size(*.8)) ///
    ylabel(0(10)110, angle(horizontal)) ///
    legend(order(1 "Reading Assessment" 2 "Mathematics Assessment") rows(1) size(vsmall))
graph export "`individual_figure_dir'/07_regional_assessment_coverage_bosy_eosy.png", replace width(3600)
cap erase "`individual_figure_dir'/07_regional_assessment_coverage_bosy.png"
cap erase "`individual_figure_dir'/07_regional_assessment_coverage_eosy.png"
cap erase "`individual_figure_dir'/07_regional_assessment_coverage_balance_bosy.png"
cap erase "`individual_figure_dir'/07_regional_assessment_coverage_balance_eosy.png"
cap erase "`individual_figure_dir'/07_regional_assessment_coverage_balance_bosy_eosy.png"

use `base', clear
* Division compliance figure is limited to largest divisions for readability.
keep if !missing(compliance)
collapse (count) n_schools=compliance (sum) n_compliant=compliance, by(full_division_code)
gen compliance_rate = 100 * n_compliant / n_schools if n_schools > 0
gsort -n_schools
keep in 1/25
graph hbar compliance_rate, over(full_division_code, sort(compliance_rate) descending label(labsize(vsmall))) ///
    title("Compliance Rates in the Largest Divisions") ///
    subtitle("Top 25 Divisions by Number of Schools") ///
    ytitle("Compliance Rate (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    blabel(bar, format(%9.1f)) ///
    note("Limited to the largest divisions for readability.", size(*.7) span)
graph export "`individual_figure_dir'/07_division_compliance_rate_largest_divisions.png", replace width(2800)

di as text "07_geographic_summaries.do completed: `c(current_date)' `c(current_time)'"
log close
