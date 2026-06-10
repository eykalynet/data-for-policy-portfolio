*******************************************************
* 06_visualizations.do
* PI-facing Stata visualizations using IPA graph style.
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
log using "`log_dir'/06_visualizations.log", replace text

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
egen philiri_bosy_assessed = rowtotal(ph_b_g7_eng_assessed ph_b_g8_eng_assessed ph_b_g9_eng_assessed ph_b_g10_eng_assessed), missing
egen rma_bosy_assessed = rowtotal(rma_b_g7_assessed rma_b_g8_assessed rma_b_g9_assessed rma_b_g10_assessed), missing

graph bar (sum) school_row, over(rev_status_label, label(angle(30))) ///
    title("DLP Evaluation - rev_status Distribution") ///
    subtitle("Control, treatment, and missing evaluation status") ///
    b1title("rev_status", size(*.8)) ///
    ytitle("Number of schools", size(*.8)) ///
    ylabel(, angle(horizontal)) ///
    blabel(bar, format(%9.0f)) ///
    note("Note: Uses the cleaned school-level DLP analytic file.", size(*.7) span)
graph export "`figure_dir'/06_rev_status_distribution.png", replace width(1800)

preserve
collapse (sum) enrolled_jhs=enroll_total_jhs_all philiri_bosy_assessed rma_bosy_assessed
xpose, clear varname
rename _varname metric
rename v1 student_count
replace metric = "Enrolled JHS" if metric == "enrolled_jhs"
replace metric = "Phil-IRI BoSY assessed" if metric == "philiri_bosy_assessed"
replace metric = "RMA BoSY assessed" if metric == "rma_bosy_assessed"
graph bar student_count, over(metric, label(angle(30))) ///
    title("DLP Evaluation - Enrolled vs Assessed Students") ///
    subtitle("Overall counts across cleaned schools") ///
    b1title("Metric", size(*.8)) ///
    ytitle("Number of students", size(*.8)) ///
    ylabel(, angle(horizontal)) ///
    blabel(bar, format(%12.0fc)) ///
    note("Note: BoSY assessed totals are summed across Grades 7-10.", size(*.7) span)
graph export "`figure_dir'/06_enrolled_vs_assessed.png", replace width(1800)
restore

import delimited using "`table_dir'/02_rma_scores_long.csv", clear varnames(1) bindquote(strict)
destring _all, replace ignore("NA")
preserve
collapse (sum) student_count assessed_count, by(time_point grade proficiency_group)
gen percent_of_assessed = 100 * student_count / assessed_count if assessed_count > 0
keep if time_point == "BoSY"
graph bar percent_of_assessed, over(proficiency_group, label(angle(35))) over(grade) ///
    title("DLP Evaluation - RMA BoSY Proficiency") ///
    subtitle("Proficiency percentages by grade level") ///
    b1title("Grade and proficiency group", size(*.8)) ///
    ytitle("Percent of assessed students (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    blabel(bar, format(%9.1f)) ///
    note("Note: Denominator is assessed RMA students.", size(*.7) span)
graph export "`figure_dir'/06_rma_proficiency_distribution.png", replace width(2200)
restore

preserve
collapse (sum) assessed_count, by(time_point grade)
keep if time_point == "BoSY"
graph bar assessed_count, over(grade) ///
    title("DLP Evaluation - Assessed Students by Grade") ///
    subtitle("RMA BoSY assessed counts") ///
    b1title("Grade level", size(*.8)) ///
    ytitle("Number of assessed students", size(*.8)) ///
    ylabel(, angle(horizontal)) ///
    blabel(bar, format(%12.0fc))
graph export "`figure_dir'/06_assessed_by_grade_level.png", replace width(1800)
restore

import delimited using "`table_dir'/02_philiri_scores_long.csv", clear varnames(1) bindquote(strict)
destring _all, replace ignore("NA")
collapse (sum) student_count english_assessed, by(time_point grade level_group reading_category)
gen percent_of_english_assessed = 100 * student_count / english_assessed if english_assessed > 0
keep if time_point == "BoSY" & level_group == "2-level"
graph bar percent_of_english_assessed, over(reading_category, label(angle(30))) over(grade) ///
    title("DLP Evaluation - Phil-IRI BoSY Reading Categories") ///
    subtitle("2-level English reading category percentages by grade") ///
    b1title("Grade and reading category", size(*.8)) ///
    ytitle("Percent of English assessed students (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    blabel(bar, format(%9.1f)) ///
    note("Note: Denominator is English assessed students.", size(*.7) span)
graph export "`figure_dir'/06_philiri_reading_categories.png", replace width(2200)

use "`data_dir'/03_dlp_rma_philiri_school_level_for_stata.dta", clear
preserve
keep if !missing(compliance)
collapse (count) n_schools=compliance (sum) n_compliant=compliance, by(assignment_group)
gen compliance_rate = 100 * n_compliant / n_schools if n_schools > 0
graph bar compliance_rate, over(assignment_group, label(angle(30))) ///
    title("DLP Evaluation - Compliance Rates") ///
    subtitle("By assigned randomization group") ///
    b1title("Assignment group", size(*.8)) ///
    ytitle("Compliance rate (%)", size(*.8)) ///
    ylabel(0(10)100, angle(horizontal)) ///
    blabel(bar, format(%9.1f)) ///
    note("Note: Compliance uses assignment group and rev_status.", size(*.7) span)
graph export "`figure_dir'/06_compliance_rates_by_level.png", replace width(1800)
restore

di as text "06_visualizations.do completed: `c(current_date)' `c(current_time)'"
log close
