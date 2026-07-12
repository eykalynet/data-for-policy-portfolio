********************************************************************************
*** TITLE   : 01_setup_and_prep.do
*** PURPOSE : Verify R-created dummy data and prepare Stata handoff file
*** PROJECT : PPI DMS training demo
*** AUTHOR  : Erika Salvador
*** DATE    : June 29, 2026
********************************************************************************

* This is file 1 of 4 in the DMS walkthrough.
*
* In the master file, we already defined the project paths and output names.
* Now, in file 1, we check that the R-generated dummy data is ready for Stata.
*
* First, we check that IPA's ipacheck package is installed.
* Then, we load the dummy PPI data created by r/scripts/99_make_dummy_ppi_data.R.
* Next, we confirm that the R-created helper variables exist.
* Finally, we apply Stata display labels/formats and save the handoff file.
*
* After this file finishes, file 2 can run the main survey HFC checks.

* We first check that ipacheck is available. If not, we stop early and tell the
* user exactly what to install, instead of failing halfway through the workflow.
cap which ipacheckids
if _rc {
    display as error "The IPA ipacheck package is not installed."
    display as text `"Run this once in Stata:"'
    display as text `"net install ipacheck, all replace from("https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master")"'
    display as text `"ipacheck update"'
    exit 199
}

* First, we load the dummy dataset created in R.
use "$data", clear

* Then, we confirm the expected R-created variables exist.
* These variables let later ipacheck commands demonstrate enumerator dashboards,
* duplicate phone checks, comments, text audits, other-specify workflows, and
* backcheck comparisons.
foreach var in enum_id enum_team_id phone_number asset_main asset_other ///
    field_comments_id textaudit_id starttime endtime {
    confirm variable `var'
}

* Next, we apply Stata display labels and formats.
* These labels are not creating new data. We just want to make Stata and Excel 
* outputs easier to read.
label define enumteam 1 "Team A" 2 "Team B", replace
label values enum_team_id enumteam

label define asset 1 "Mobile phone" 8 "Solar lamp" 99 "Other", replace
label values asset_main asset

format %tc starttime endtime

label define yesno 0 "No" 1 "Yes", replace
foreach var of global ppi_vars {
    label values `var' yesno
}

label var household_id "Household ID"
label var key "Unique submission key"
label var enum_id "Enumerator ID"
label var enum_team_id "Enumerator team"
label var interview_date "Interview date"
label var duration_minutes "Survey duration in minutes"
label var ppi_score "PPI score"

* Finally, we save the prepped dataset. File 2 starts from this file.
save "$outputs/ppi_demo_prepped.dta", replace

display as text "File 1 complete: R-created dummy data is ready for file 2."
