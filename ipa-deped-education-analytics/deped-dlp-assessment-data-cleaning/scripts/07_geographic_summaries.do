*******************************************************
* 07_geographic_summaries.do
* Region, division, and municipality summaries.
*******************************************************

version 17
clear all
set more off

local project_dir "/Users/esalvador/Documents/GitHub/data-for-policy-portfolio/ipa-deped-education-analytics/deped-dlp-assessment-data-cleaning"
local data_dir "`project_dir'/data"
local output_dir "`project_dir'/outputs"
local table_dir "`output_dir'/tables"
local figure_dir "`output_dir'/figures"
local log_dir "`output_dir'/logs"

cap log close
log using "`log_dir'/07_geographic_summaries.log", replace text

cap which github
if _rc {
    net install github, from("https://haghish.github.io/github/")
}
cap github install PovertyAction/ipaplots, replace
set scheme ipaplots, perm
graph set window fontface "Georgia"
graph set print fontface "Georgia"

use "`data_dir'/03_dlp_rma_philiri_school_level_for_stata.dta", clear

gen byte school_row = 1
gen byte control_school = treatment_status == "control"
gen byte treatment_school = treatment_status == "treatment"
gen byte missing_treatment_status = treatment_status == "missing treatment status"

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
label var missing_treatment_status "Missing treatment status"
label var enroll_total_jhs_all "Enrolled JHS students"
label var philiri_bosy_assessed "Phil-IRI BoSY assessed"
label var philiri_eosy_assessed "Phil-IRI EoSY assessed"
label var rma_bosy_assessed "RMA BoSY assessed"
label var rma_eosy_assessed "RMA EoSY assessed"
label var compliance "Compliant schools"

tempfile base
save `base', replace

foreach level in region division municipality {
    use `base', clear

    if "`level'" == "region" {
        local geo_var region_code
        local geo_label "Region"
    }
    if "`level'" == "division" {
        local geo_var full_division_code
        local geo_label "Division"
    }
    if "`level'" == "municipality" {
        local geo_var full_municipality_code
        local geo_label "City/municipality"
    }

    keep if !missing(`geo_var')
    collapse ///
        (sum) n_schools=school_row control_schools=control_school treatment_schools=treatment_school missing_treatment_status ///
              enrolled_jhs=enroll_total_jhs_all philiri_bosy_assessed philiri_eosy_assessed rma_bosy_assessed rma_eosy_assessed ///
              n_compliant=compliance ///
        (count) compliance_denominator=compliance, ///
        by(`geo_var')

    gen pct_control = 100 * control_schools / n_schools if n_schools > 0
    gen pct_treatment = 100 * treatment_schools / n_schools if n_schools > 0
    gen compliance_rate = 100 * n_compliant / compliance_denominator if compliance_denominator > 0
    gen philiri_bosy_assessment_rate = 100 * philiri_bosy_assessed / enrolled_jhs if enrolled_jhs > 0
    gen rma_bosy_assessment_rate = 100 * rma_bosy_assessed / enrolled_jhs if enrolled_jhs > 0

    order `geo_var' n_schools control_schools treatment_schools missing_treatment_status pct_control pct_treatment ///
        enrolled_jhs philiri_bosy_assessed philiri_bosy_assessment_rate rma_bosy_assessed rma_bosy_assessment_rate ///
        compliance_denominator n_compliant compliance_rate

    export excel using "`table_dir'/07_geographic_summary_`level'.xlsx", firstrow(variables) replace
    export delimited using "`table_dir'/07_geographic_summary_`level'_map_ready.csv", replace
}

use `base', clear
collapse (sum) n_schools=school_row control_schools=control_school treatment_schools=treatment_school, by(region_code)
gen pct_treatment = 100 * treatment_schools / n_schools if n_schools > 0
graph hbar control_schools treatment_schools, over(region_code, sort(n_schools) descending label(labsize(small))) stack ///
    title("DLP Evaluation - Schools by Region") ///
    subtitle("Control and treatment status") ///
    ytitle("Number of schools", size(*.8)) ///
    legend(order(1 "Control" 2 "Treatment") rows(1)) ///
    note("Note: Treatment status is derived from the raw rev_status field.", size(*.7) span)
graph export "`figure_dir'/07_schools_by_region_treatment_status.png", replace width(2200)

use `base', clear
keep if !missing(compliance)
collapse (count) n_schools=compliance (sum) n_compliant=compliance, by(region_code)
gen compliance_rate = 100 * n_compliant / n_schools if n_schools > 0
graph hbar compliance_rate, over(region_code, sort(compliance_rate) descending label(labsize(small))) ///
    title("DLP Evaluation - Regional Compliance Rates") ///
    subtitle("Share of schools compliant with assigned treatment status") ///
    ytitle("Compliance rate (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    blabel(bar, format(%9.1f)) ///
    note("Note: Compliance uses assignment group and treatment status.", size(*.7) span)
graph export "`figure_dir'/07_compliance_rate_by_region.png", replace width(2200)

use `base', clear
keep if !missing(compliance)
collapse (count) n_schools=compliance (sum) n_compliant=compliance, by(full_division_code)
gen compliance_rate = 100 * n_compliant / n_schools if n_schools > 0
gsort -n_schools
keep in 1/25
graph hbar compliance_rate, over(full_division_code, sort(compliance_rate) descending label(labsize(vsmall))) ///
    title("DLP Evaluation - Compliance Rates in Largest Divisions") ///
    subtitle("Top 25 divisions by number of schools") ///
    ytitle("Compliance rate (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    blabel(bar, format(%9.1f)) ///
    note("Note: Limited to the largest divisions for readability.", size(*.7) span)
graph export "`figure_dir'/07_compliance_rate_largest_divisions.png", replace width(2400)

use `base', clear
collapse (sum) enrolled_jhs=enroll_total_jhs_all philiri_bosy_assessed rma_bosy_assessed, by(region_code)
gen philiri_bosy_assessment_rate = 100 * philiri_bosy_assessed / enrolled_jhs if enrolled_jhs > 0
gen rma_bosy_assessment_rate = 100 * rma_bosy_assessed / enrolled_jhs if enrolled_jhs > 0
graph hbar philiri_bosy_assessment_rate rma_bosy_assessment_rate, over(region_code, sort(enrolled_jhs) descending label(labsize(small))) ///
    title("DLP Evaluation - Assessment Coverage by Region") ///
    subtitle("BoSY assessed students as a share of enrolled JHS students") ///
    ytitle("Assessment rate (%)", size(*.8)) ///
    legend(order(1 "Phil-IRI" 2 "RMA") rows(1)) ///
    note("Note: Denominator is total JHS enrollment in the cleaned school-level file.", size(*.7) span)
graph export "`figure_dir'/07_assessment_coverage_by_region.png", replace width(2200)

di as text "07_geographic_summaries.do completed: `c(current_date)' `c(current_time)'"
log close
