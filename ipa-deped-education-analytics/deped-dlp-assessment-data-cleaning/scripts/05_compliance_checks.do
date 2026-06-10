*******************************************************
* 05_compliance_checks.do
* Compliance checks using assignment group and treatment status.
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
log using "`log_dir'/05_compliance_checks.log", replace text

use "`data_dir'/03_dlp_rma_philiri_school_level_for_stata.dta", clear

preserve
keep beis_school_id region_code full_division_code full_municipality_code assignment_group rev_status treatment_status compliance
export excel using "`table_dir'/05_compliance_summary_school.xlsx", firstrow(variables) replace
restore

preserve
keep if !missing(compliance)
collapse (count) n_schools=compliance (sum) n_compliant=compliance, by(full_municipality_code)
gen compliance_rate = 100 * n_compliant / n_schools if n_schools > 0
order full_municipality_code n_schools n_compliant compliance_rate
export excel using "`table_dir'/05_compliance_summary_municipality.xlsx", firstrow(variables) replace
restore

preserve
keep if !missing(compliance)
collapse (count) n_schools=compliance (sum) n_compliant=compliance, by(full_division_code)
gen compliance_rate = 100 * n_compliant / n_schools if n_schools > 0
order full_division_code n_schools n_compliant compliance_rate
export excel using "`table_dir'/05_compliance_summary_division.xlsx", firstrow(variables) replace
restore

preserve
keep if !missing(compliance)
collapse (count) n_schools=compliance (sum) n_compliant=compliance, by(region_code)
gen compliance_rate = 100 * n_compliant / n_schools if n_schools > 0
order region_code n_schools n_compliant compliance_rate
export excel using "`table_dir'/05_compliance_summary_region.xlsx", firstrow(variables) replace
restore

preserve
keep if !missing(compliance)
collapse (count) n_schools=compliance (sum) n_compliant=compliance, by(assignment_group)
gen compliance_rate = 100 * n_compliant / n_schools if n_schools > 0
export excel using "`table_dir'/05_compliance_summary_assignment_group.xlsx", firstrow(variables) replace
restore

di as text "05_compliance_checks.do completed: `c(current_date)' `c(current_time)'"
log close
