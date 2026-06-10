*******************************************************
* 04_descriptive_stats.do
* Overall dataset snapshot and proficiency summaries.
*******************************************************

version 17
clear all
set more off

local project_dir "/Users/esalvador/Documents/GitHub/data-for-policy-portfolio/ipa-deped-education-analytics/deped-dlp-assessment-data-cleaning"
local data_dir "`project_dir'/data"
local output_dir "`project_dir'/outputs"
local table_dir "`output_dir'/tables"
local log_dir "`output_dir'/logs"

cap log close
log using "`log_dir'/04_descriptive_stats.log", replace text

use "`data_dir'/03_dlp_rma_philiri_school_level_for_stata.dta", clear

gen byte school_row = 1
egen philiri_bosy_assessed = rowtotal(ph_b_g7_eng_assessed ph_b_g8_eng_assessed ph_b_g9_eng_assessed ph_b_g10_eng_assessed), missing
egen philiri_eosy_assessed = rowtotal(ph_e_g7_eng_assessed ph_e_g8_eng_assessed ph_e_g9_eng_assessed ph_e_g10_eng_assessed), missing
egen rma_bosy_assessed = rowtotal(rma_b_g7_assessed rma_b_g8_assessed rma_b_g9_assessed rma_b_g10_assessed), missing
egen rma_eosy_assessed = rowtotal(rma_e_g7_assessed rma_e_g8_assessed rma_e_g9_assessed rma_e_g10_assessed), missing

preserve
collapse (sum) n_schools=school_row ///
    (sum) enrolled_jhs=enroll_total_jhs_all philiri_bosy_assessed philiri_eosy_assessed rma_bosy_assessed rma_eosy_assessed
gen metric = "overall"
order metric n_schools enrolled_jhs philiri_bosy_assessed philiri_eosy_assessed rma_bosy_assessed rma_eosy_assessed
export excel using "`table_dir'/04_overall_dataset_snapshot.xlsx", firstrow(variables) replace
restore

preserve
contract rev_status_label, freq(n_schools)
egen total_schools = total(n_schools)
gen pct_schools = 100 * n_schools / total_schools
order rev_status_label n_schools pct_schools total_schools
export excel using "`table_dir'/04_rev_status_summary.xlsx", firstrow(variables) replace
restore

preserve
collapse (sum) n_schools=school_row ///
    (sum) enrolled_jhs=enroll_total_jhs_all philiri_bosy_assessed philiri_eosy_assessed rma_bosy_assessed rma_eosy_assessed, ///
    by(rev_status_label)
export excel using "`table_dir'/04_enrollment_assessment_summary.xlsx", firstrow(variables) replace
restore

import delimited using "`table_dir'/02_rma_scores_long.csv", clear varnames(1) bindquote(strict)
destring _all, replace ignore("NA")
collapse (sum) student_count assessed_count, by(time_point grade proficiency_group)
gen percent_of_assessed = 100 * student_count / assessed_count if assessed_count > 0
export excel using "`table_dir'/04_rma_proficiency_by_grade.xlsx", firstrow(variables) replace

import delimited using "`table_dir'/02_philiri_scores_long.csv", clear varnames(1) bindquote(strict)
destring _all, replace ignore("NA")
collapse (sum) student_count english_assessed, by(time_point grade level_group reading_category)
gen percent_of_english_assessed = 100 * student_count / english_assessed if english_assessed > 0
export excel using "`table_dir'/04_philiri_reading_by_grade.xlsx", firstrow(variables) replace

di as text "04_descriptive_stats.do completed: `c(current_date)' `c(current_time)'"
log close
