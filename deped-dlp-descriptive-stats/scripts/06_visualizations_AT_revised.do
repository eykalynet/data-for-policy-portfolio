********************************************************************************
** TITLE   : 06_visualizations.do
** PURPOSE : Create dataset, proficiency, and compliance figures.
** PROJECT : Dynamic Learning Program descriptive results
** AUTHOR  : Erika Salvador
** REVIEWER: Alec Torralba
** DATE    : June 11, 2026
********************************************************************************
	
	******************Reviewer Note below***********************
// Note below: (AT) change to global for more freedom on directory use/section runs

	cls
	clear 			all
	macro drop 		_all 		//<-------------Since using globals
	version 		19 			//<-------------Change to your STATA version
	set min_memory 	1g
	set maxvar 		32767, permanently
	set more 		off


* Resolve paths relative to the project folder, with optional override.
local project_dir "`c(pwd)'"
if "$DLP_PROJECT_DIR" != "" local project_dir "$DLP_PROJECT_DIR"
capture confirm file "`project_dir'/data/03_dlp_rma_philiri_school_level_for_stata.dta"
if _rc {
    cd ..
    local project_dir "`c(pwd)'"
}

* Promote to global so downstream do-files can access it
gl project_dir "`project_dir'"

display "$project_dir"

******************Reviewer Note below***********************
// Note below: (AT) change to global for more freedom on directory use/section runs

gl data_dir "$project_dir/data"
gl output_dir "$project_dir/outputs"
gl table_dir "$output_dir/tables"
gl figure_dir "$output_dir/figures"
gl individual_figure_dir "$figure_dir/individual_figures"
gl log_dir "$output_dir/logs"

cap mkdir "$figure_dir"
cap mkdir "$individual_figure_dir"


cap log close
log using "$log_dir/06_visualizations.log", replace text

* Use IPA's Stata graph scheme when available.
cap which github
if _rc {
    net install github, from("https://haghish.github.io/github/")
}
cap github install PovertyAction/ipaplots, replace
set scheme ipaplots, perm

use "$data_dir/03_dlp_rma_philiri_school_level_for_stata.dta", clear

* Prepare common counts used across the snapshot figures.
gen byte school_row = 1
egen philiri_bosy_assessed = rowtotal(ph_b_g7_eng_assessed ph_b_g8_eng_assessed ph_b_g9_eng_assessed ph_b_g10_eng_assessed), missing
egen philiri_eosy_assessed = rowtotal(ph_e_g7_eng_assessed ph_e_g8_eng_assessed ph_e_g9_eng_assessed ph_e_g10_eng_assessed), missing
egen rma_bosy_assessed = rowtotal(rma_b_g7_assessed rma_b_g8_assessed rma_b_g9_assessed rma_b_g10_assessed), missing
egen rma_eosy_assessed = rowtotal(rma_e_g7_assessed rma_e_g8_assessed rma_e_g9_assessed rma_e_g10_assessed), missing

gen treatment_status_order = .
replace treatment_status_order = 1 if treatment_status == "Control"
replace treatment_status_order = 2 if treatment_status == "Treatment"
replace treatment_status_order = 3 if treatment_status == "Missing Evaluation Status"
label define treatment_status_order 1 "Control" 2 "Treatment" 3 "Missing Evaluation Status"
label values treatment_status_order treatment_status_order

graph hbar (sum) school_row, over(treatment_status_order, label(labsize(small))) asyvars ///
    title("Randomized DLP Schools by Treatment Status") ///
    subtitle("Dataset Snapshot") ///
    ytitle("Number of Schools", size(*.8)) ///
    yscale(range(0 250)) ///
    ylabel(0(50)250, angle(horizontal)) ///
    legend(rows(3) size(small)) ///
    blabel(bar, format(%12.0fc)) ///
    note("Treatment status is based on rev_status in the randomized evaluation file.", size(*.7) span)
graph export "$individual_figure_dir/06_dataset_snapshot_treatment_status.png", replace width(2400)

******************Reviewer Note below***********************
// Note below: (AT) Changes include using abbreviation
preserve
* Combine enrollment and assessed-student counts for BoSY/EoSY comparison.
quietly summarize enroll_total_jhs_all, meanonly
local enrolled_students = r(sum)
quietly summarize philiri_bosy_assessed, meanonly
local reading_bosy = r(sum)
quietly summarize philiri_eosy_assessed, meanonly
local reading_eosy = r(sum)
quietly summarize rma_bosy_assessed, meanonly
local mathematics_bosy = r(sum)
quietly summarize rma_eosy_assessed, meanonly
local mathematics_eosy = r(sum)
clear
set obs 6
gen period_order = cond(_n <= 3, 1, 2)
gen metric_order = mod(_n - 1, 3) + 1
gen student_count = .
replace student_count = `enrolled_students' if metric_order == 1
replace student_count = `reading_bosy' if period_order == 1 & metric_order == 2
replace student_count = `mathematics_bosy' if period_order == 1 & metric_order == 3
replace student_count = `reading_eosy' if period_order == 2 & metric_order == 2
replace student_count = `mathematics_eosy' if period_order == 2 & metric_order == 3
*label define period_order 1 "Beginning of School Year" 2 "End of School Year", replace
label define period_order 1 "Beginning of S.Y." 2 "End of S.Y.", replace
label values period_order period_order
label define metric_order 1 "Enrolled Students" 2 "Reading Assessment" 3 "Mathematics Assessment", replace
label values metric_order metric_order

graph hbar student_count, over(metric_order, label(labsize(small))) over(period_order, label(labsize(small))) asyvars ///
    title("Enrolled and Assessed Students") ///
    subtitle("BoSY and EoSY Counts Across Randomized DLP Schools") ///
    ytitle("Number of Students", size(*.8)) ///
    yscale(range(0 350000)) ///
    ylabel(0(50000)350000, angle(horizontal)) ///
    legend(rows(3) size(small)) ///
    blabel(bar, format(%12.0fc)) ///
    note("Reading Assessment is Philippine Informal Reading Inventory." "Mathematics Assessment is Rapid Mathematics Assessment.", size(*.7) span)
graph export "$individual_figure_dir/06_dataset_snapshot_enrolled_assessed_bosy_eosy.png", replace width(2800)
cap erase "$individual_figure_dir/06_dataset_snapshot_enrolled_assessed_bosy.png"
cap erase "$individual_figure_dir/06_dataset_snapshot_enrolled_assessed_eosy.png"
restore

******************Reviewer Note below***********************
*** RMA Proficiency by grade level, BOSY and EOSY

import delimited using "$table_dir/02_rma_scores_long.csv", clear varnames(1) bindquote(strict)
destring _all, replace ignore("NA")
* RMA proficiency shares by grade, faceted by beginning/end of school year.
collapse (sum) student_count assessed_count, by(time_point grade proficiency_group)
gen percent_of_assessed = 100 * student_count / assessed_count if assessed_count > 0
gen grade_order = .
replace grade_order = 7 if grade == "Grade 7"
replace grade_order = 8 if grade == "Grade 8"
replace grade_order = 9 if grade == "Grade 9"
replace grade_order = 10 if grade == "Grade 10"
label define grade_order 7 "Grade 7" 8 "Grade 8" 9 "Grade 9" 10 "Grade 10"
label values grade_order grade_order
gen proficiency_order = .
replace proficiency_order = 1 if proficiency_group == "not proficient"
replace proficiency_order = 2 if proficiency_group == "low proficient"
replace proficiency_order = 3 if proficiency_group == "nearly proficient"
replace proficiency_order = 4 if proficiency_group == "proficient"
replace proficiency_order = 5 if proficiency_group == "high proficient"
label define proficiency_order 1 "Not Proficient" 2 "Low Proficient" 3 "Nearly Proficient" 4 "Proficient" 5 "High Proficient"
label values proficiency_order proficiency_order

gen time_order = .
replace time_order = 1 if time_point == "BoSY"
replace time_order = 2 if time_point == "EoSY"
label define time_order 1 "Beginning of School Year" 2 "End of School Year", replace
label values time_order time_order

graph bar percent_of_assessed, over(proficiency_order, label(angle(30) labsize(vsmall))) ///
    over(grade_order, label(labsize(small))) asyvars ///
    by(time_order, cols(2) title("Rapid Mathematics Assessment Proficiency") subtitle("Beginning and End of School Year Percentages by Grade Level") note("")) ///
    subtitle(, nobox fcolor(none) lcolor(none)) ///
    b1title("Grade and Proficiency Group", size(*.8)) ///
    ytitle("Percent of Assessed Students (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    legend(rows(1) size(vsmall))
graph export "$individual_figure_dir/06_rma_proficiency_bosy_eosy_by_grade.png", replace width(3600)
cap erase "$individual_figure_dir/06_rma_proficiency_bosy_by_grade.png"
cap erase "$individual_figure_dir/06_rma_proficiency_eosy_by_grade.png"

******************Reviewer Note below***********************
*** Assessed counts comparison on BOSY and EOSY proxy for grade ready
*** Note: Make sure that levels are consistent: 1 independent, 2 instructional, 3 frustration for consistent reporting

import delimited using "$table_dir/02_philiri_scores_long.csv", clear varnames(1) bindquote(strict)
destring _all, replace ignore("NA")
* Phil-IRI uses BoSY 2-/3-level groupings and EoSY independent as proxy for grade ready.
keep if inlist(reading_category, "frustration", "instructional", "independent")
gen comparison_group = ""
replace comparison_group = "BoSY 2-Level" if time_point == "BoSY" & level_group == "2-level"
replace comparison_group = "BoSY 3-Level" if time_point == "BoSY" & level_group == "3-level"
replace comparison_group = "EoSY Proxy" if time_point == "EoSY" & level_group == "eosy"
keep if comparison_group != ""
collapse (sum) student_count, by(grade comparison_group reading_category)
bysort grade comparison_group: egen total_classified = total(student_count)
gen percent_of_classified = 100 * student_count / total_classified if total_classified > 0
gen grade_order = .
replace grade_order = 7 if grade == "Grade 7"
replace grade_order = 8 if grade == "Grade 8"
replace grade_order = 9 if grade == "Grade 9"
replace grade_order = 10 if grade == "Grade 10"
label define grade_order 7 "Grade 7" 8 "Grade 8" 9 "Grade 9" 10 "Grade 10"
label values grade_order grade_order
gen category_order = .
replace category_order = 1 if reading_category == "independent"
replace category_order = 2 if reading_category == "instructional"
replace category_order = 3 if reading_category == "frustration"
label define category_order 1 "Grade Ready" 2 "Instructional" 3 "Frustration", replace
label values category_order category_order

foreach bosy_group in "2-Level" "3-Level" {
    preserve
    keep if comparison_group == "BoSY `bosy_group'" | comparison_group == "EoSY Proxy"
    gen comparison_order = .
    replace comparison_order = 1 if comparison_group == "BoSY `bosy_group'"
    replace comparison_order = 2 if comparison_group == "EoSY Proxy"
    label define comparison_order 1 "Beginning of School Year `bosy_group'" 2 "End of School Year Proxy", replace
    label values comparison_order comparison_order
    local group_file = lower(subinstr("`bosy_group'", "-", "", .))

    graph bar percent_of_classified, over(category_order, label(angle(30) labsize(vsmall))) ///
        over(grade_order, label(labsize(small))) asyvars ///
        by(comparison_order, cols(2) title("Philippine Informal Reading Inventory Reading Categories") subtitle("Beginning of School Year `bosy_group' Grouping and End of School Year Proxy") note("2-level and 3-level grade-ready fields, similar to BoSY, are not available for EoSY. Only used Independent as Proxy..", size(*.65))) ///
        subtitle(, nobox fcolor(none) lcolor(none)) ///
        b1title("Grade and Reading Category", size(*.8)) ///
        ytitle("Percent of Classified Students (%)", size(*.8)) ///
        ylabel(0(10)100, angle(horizontal)) ///
        legend(rows(1) size(vsmall))
    graph export "$individual_figure_dir/06_philiri_reading_categories_bosy_`group_file'_eosy_proxy_by_grade.png", replace width(3000)
    restore
}

cap erase "$individual_figure_dir/06_philiri_reading_readiness_bosy_eosy_by_grade.png"
cap erase "$individual_figure_dir/06_philiri_classification_groups_bosy_by_grade.png"
cap erase "$individual_figure_dir/06_philiri_reading_categories_bosy_eosy_by_grade.png"
cap erase "$individual_figure_dir/06_philiri_reading_categories_bosy_by_grade.png"
cap erase "$individual_figure_dir/06_philiri_reading_categories_eosy_by_grade.png"

******************Reviewer Note below***********************
*** Not proficient share by treatment (comparing treatment and control)

import excel using "$table_dir/04_rma_proficiency_by_treatment_status.xlsx", firstrow clear
* Compact RMA subgroup figure: not proficient share by treatment status.
keep if proficiency_group == "not proficient"
collapse (sum) student_count assessed_count, by(treatment_status time_point)
gen percent_of_assessed = 100 * student_count / assessed_count if assessed_count > 0
gen time_order = .
replace time_order = 1 if time_point == "BoSY"
replace time_order = 2 if time_point == "EoSY"
label define time_order 1 "Beginning of School Year" 2 "End of School Year", replace
label values time_order time_order
keep treatment_status time_order percent_of_assessed
reshape wide percent_of_assessed, i(treatment_status) j(time_order)
graph hbar percent_of_assessed1 percent_of_assessed2, over(treatment_status, label(labsize(small))) ///
    title("RMA Not Proficient Share by Treatment Status") ///
    subtitle("Beginning and End of School Year") ///
    ytitle("Percent of Assessed Students (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    legend(order(1 "Beginning of School Year" 2 "End of School Year") rows(2) size(small)) ///
    blabel(bar, format(%9.1f))
graph export "$individual_figure_dir/06_subgroup_rma_not_proficient_by_treatment_status.png", replace width(2600)

******************Reviewer Note below***********************
// Note below: (AT) Only generate EOSY BOSY, by treatment only

import excel using "$table_dir/04_rma_proficiency_by_treatment_status.xlsx", firstrow clear
* Compact RMA subgroup figure: not proficient share by treatment status.
keep if proficiency_group == "not proficient"
keep if treatment_status == "Treatment"
collapse (sum) student_count assessed_count, by(treatment_status time_point)
gen percent_of_assessed = 100 * student_count / assessed_count if assessed_count > 0
gen time_order = .
replace time_order = 1 if time_point == "BoSY"
replace time_order = 2 if time_point == "EoSY"
label define time_order 1 "Beginning of School Year" 2 "End of School Year", replace
label values time_order time_order
keep treatment_status time_order percent_of_assessed
reshape wide percent_of_assessed, i(treatment_status) j(time_order)
graph hbar percent_of_assessed1 percent_of_assessed2, over(treatment_status, label(labsize(small))) ///
    title("RMA Not Proficiency Shares: BoSY and EoSY, by Treatment") ///
    subtitle("Beginning and End of School Year") ///
    ytitle("Percent of Assessed Students (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    legend(order(1 "Beginning of S.Y." 2 "End of S.Y.") rows(2) size(small)) ///
    blabel(bar, format(%9.1f))
graph export "$individual_figure_dir/06_subgroup_rma_not_proficient_treatment_only.png", replace width(2600)



******************Reviewer Note below***********************
// Note below: (AT) Only generate EOSY BOSY, by treatment group

import excel using "$table_dir/04_philiri_reading_by_treatment_status.xlsx", firstrow clear
* Compact Phil-IRI subgroup figure: grade-ready/proxy share by treatment status.
keep if reading_category == "independent"
keep if (time_point == "BoSY" & inlist(level_group, "2-level", "3-level")) | time_point == "EoSY"
gen reading_measure = ""
replace reading_measure = "BoSY 2-Level" if time_point == "BoSY" & level_group == "2-level"
replace reading_measure = "BoSY 3-Level" if time_point == "BoSY" & level_group == "3-level"
replace reading_measure = "EoSY Proxy" if time_point == "EoSY"
collapse (sum) student_count total_classified, by(treatment_status reading_measure)
gen percent_of_classified = 100 * student_count / total_classified if total_classified > 0
graph hbar percent_of_classified, over(reading_measure, label(labsize(small))) over(treatment_status, label(labsize(small))) asyvars ///
    title("Phil-IRI Grade Ready Share by Treatment Status") ///
    subtitle("Beginning of School Year Measures and End of School Year Proxy") ///
    ytitle("Percent of Classified Students (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    legend(rows(3) size(small)) ///
    blabel(bar, format(%9.1f))
graph export "$individual_figure_dir/06_subgroup_philiri_grade_ready_by_treatment_status.png", replace width(2800)

******************Reviewer Note below***********************
// Note below: (AT) Only generate EOSY BOSY, by treatment only

import excel using "$table_dir/04_philiri_reading_by_treatment_status.xlsx", firstrow clear
* Compact Phil-IRI subgroup figure: grade-ready/proxy share by treatment status.
keep if reading_category == "independent"
keep if treatment_status == "Treatment"
keep if (time_point == "BoSY" & inlist(level_group, "2-level", "3-level")) | time_point == "EoSY"
gen reading_measure = ""
replace reading_measure = "BoSY 2-Level" if time_point == "BoSY" & level_group == "2-level"
replace reading_measure = "BoSY 3-Level" if time_point == "BoSY" & level_group == "3-level"
replace reading_measure = "EoSY Proxy" if time_point == "EoSY"
collapse (sum) student_count total_classified, by(treatment_status reading_measure)
gen percent_of_classified = 100 * student_count / total_classified if total_classified > 0
graph hbar percent_of_classified, over(reading_measure, label(labsize(small))) over(treatment_status, label(labsize(small))) asyvars ///
    title("Phil-IRI Grade Ready Share of Treatment Group") ///
    subtitle("Beginning of School Year Measures and End of School Year Proxy") ///
    ytitle("Percent of Classified Students (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    legend(rows(3) size(small)) ///
    blabel(bar, format(%9.1f))
graph export "$individual_figure_dir/06_subgroup_philiri_grade_ready_treatment_only.png", replace width(2800)

******************Reviewer Note below***********************
// Note below: (AT) Compliance rates by treatment assignment, added disclaimer


use "$data_dir/03_dlp_rma_philiri_school_level_for_stata.dta", clear
preserve
* Compliance figure by assigned randomization group.
keep if !missing(compliance)
collapse (count) n_schools=compliance (sum) n_compliant=compliance, by(assignment_group)
gen compliance_rate = 100 * n_compliant / n_schools if n_schools > 0
gen assignment_group_label = proper(subinstr(assignment_group, "_", " ", .))
graph bar compliance_rate, over(assignment_group_label, label(angle(30) labsize(small))) asyvars ///
    title("Implementation Rates by Treatment Assignment") ///
    subtitle("Alignment Between Assignment and Observed Treatment Status") ///
    b1title("Assignment Group", size(*.8)) ///
    ytitle("Implementation rates (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    blabel(bar, format(%9.1f)) ///
    legend(rows(4) size(vsmall)) ///
    note("Compliance is based on assignment group and implementation tag, regardless of DLP model.", size(*.7) span)
graph export "$individual_figure_dir/06_compliance_by_assignment_group.png", replace width(2400)
restore

di as text "06_visualizations.do completed: `c(current_date)' `c(current_time)'"
log close
