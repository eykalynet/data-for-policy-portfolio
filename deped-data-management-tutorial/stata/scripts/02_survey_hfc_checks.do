********************************************************************************
*** TITLE   : 02_survey_hfc_checks.do
*** PURPOSE : Run core survey high-frequency checks with ipacheck
*** PROJECT : PPI DMS training demo
*** AUTHOR  : Erika Salvador
*** DATE    : June 29, 2026
********************************************************************************

* This is file 2 of 4 in the DMS walkthrough.
*
* File 1 prepared the dummy survey data and helper files.
* Now, in file 2, we run the core high-frequency checks on the survey data.
*
* First, we check duplicate household IDs.
* Then, we apply a sample correction.
* Next, we run duplicate-variable, missingness, form-version, constraint,
* logic, outlier, other-specify, and other-specify recode checks.
* Finally, we save the checked survey dataset for files 3 and 4.
*
* After this file finishes, file 3 can create comments/text-audit outputs,
* dashboards, and tracking reports.

* First, we load the prepped survey dataset created by file 1.
* This file starts from the prepared dataset, not the raw dataset, because file 1
* added the extra variables needed for DMS checks.
use "$outputs/ppi_demo_prepped.dta", clear

* First, we check duplicate survey IDs.
* ipacheckids checks whether two submissions have the same household ID. It also
* saves a de-duplicated dataset for the rest of the checks.
ipacheckids household_id, ///
    key(key) ///
    enumerator(enumerator) ///
    date(interview_date) ///
    outfile("$hfc_output") ///
    outsheet("id duplicates") ///
    dupfile("$outputs/ipacheck_duplicate_records.dta") ///
    save("$outputs/ppi_demo_checked.dta") ///
    force ///
    sheetreplace

* Then, we switch to the de-duplicated dataset created by ipacheckids.
* From here onward, checks use one record per household ID, so duplicate
* submissions do not distort missingness, dashboards, or other outputs.
use "$outputs/ppi_demo_checked.dta", clear

* Then, we apply approved corrections.
* ipacheckcorrections applies changes listed in the corrections CSV created in
* file 1. In real life, corrections should come from an agreed review process.
ipacheckcorrections using "$input_dir/demo_corrections.csv", ///
    id(household_id) ///
    logfile("$corr_log") ///
    logsheet("corrections") ///
    ignore

* After the correction step, we save the checked dataset so the next checks use
* the corrected values.
* This save makes the correction permanent for the rest of this demo run.
save "$outputs/ppi_demo_checked.dta", replace

* Next, we identify duplicate values in non-ID variables.
* ipacheckdups is useful for fields that should usually be unique, such as phone
* numbers, national IDs, GPS points, or respondent names.
ipacheckdups phone_number, ///
    id(household_id) ///
    enumerator(enumerator) ///
    date(interview_date) ///
    outfile("$hfc_output") ///
    outsheet("phone duplicates") ///
    keep(key barangay) ///
    sheetmodify

* Then, we summarize missing values.
* ipacheckmissing does not list every respondent. Instead, it summarizes missing
* rates by variable so the team can quickly spot weak survey sections.
ipacheckmissing $ppi_vars consent hh_size children_under_15 duration_minutes form_version, ///
    priority(household_id key enumerator consent $ppi_vars) ///
    outfile("$hfc_output") ///
    outsheet("missing") ///
    sheetmodify

* Next, we check survey form versions.
* ipacheckversions helps catch old SurveyCTO form versions still being used
* after an update. This is common during live data collection.
ipacheckversions form_version, ///
    enumerator(enumerator) ///
    date(interview_date) ///
    outfile("$hfc_output") ///
    outsheet1("form versions") ///
    outsheet2("outdated forms") ///
    keep(key barangay) ///
    sheetmodify

* Then, we check numeric constraints from inputs/ipacheck_inputs.xlsx.
* ipacheckconstraints reads min/max rules from the constraints sheet. Here, PPI
* binary questions should be 0/1 and duration should be in a plausible range.
ipacheckconstraints using "$inputs", ///
    sheet("constraints") ///
    id(household_id) ///
    enumerator(enumerator) ///
    date(interview_date) ///
    outfile("$hfc_output") ///
    outsheet("constraints") ///
    sheetmodify

* Next, we check cross-question logic.
* ipachecklogic checks relationships across variables. Here, the number of
* children under 15 should not exceed total household size.
ipachecklogic using "$inputs", ///
    sheet("logic") ///
    id(household_id) ///
    enumerator(enumerator) ///
    date(interview_date) ///
    outfile("$hfc_output") ///
    outsheet("logic") ///
    sheetmodify

* Then, we check numeric outliers.
* ipacheckoutliers flags unusual numeric values using the setup in the outliers
* sheet. This is helpful for duration, income, consumption, and count variables.
ipacheckoutliers using "$inputs", ///
    sheet("outliers") ///
    id(household_id) ///
    enumerator(enumerator) ///
    date(interview_date) ///
    outfile("$hfc_output") ///
    outsheet("outliers") ///
    sheetmodify

* Next, we list other-specify responses.
* ipacheckspecify exports the open-text "other specify" answers so the team can
* decide whether common answers deserve new coded categories.
ipacheckspecify using "$inputs", ///
    sheet("other specify") ///
    id(household_id) ///
    enumerator(enumerator) ///
    date(interview_date) ///
    outfile("$hfc_output") ///
    outsheet1("other specify") ///
    outsheet2("other specify choices") ///
    sheetmodify

* After that, we recode other-specify responses.
* ipacheckspecifyrecode applies the recode instructions created in file 1. This
* shows how the DMS can standardize common "other" responses after review.
ipacheckspecifyrecode using "$input_dir/demo_specify_recode.csv", ///
    id(household_id) ///
    keep(key barangay asset_other) ///
    logfile("$recode_log") ///
    logsheet("specify recode") ///
    sheetreplace

* Finally, we save the checked dataset. Files 3 and 4 both use this file.
* This is the main handoff file for the rest of the workflow.
save "$outputs/ppi_demo_checked.dta", replace

display as text "File 2 complete: survey HFC outputs and checked data are ready for file 3."
