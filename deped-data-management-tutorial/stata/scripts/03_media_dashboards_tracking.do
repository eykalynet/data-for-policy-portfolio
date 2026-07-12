********************************************************************************
*** TITLE   : 03_media_dashboards_tracking.do
*** PURPOSE : Create media reports, dashboards, and tracking outputs
*** PROJECT : PPI DMS training demo
*** AUTHOR  : Erika Salvador
*** DATE    : June 29, 2026
********************************************************************************

* This is file 3 of 4 in the DMS walkthrough.
*
* File 2 created the checked survey dataset and the main HFC workbook.
* Now, in file 3, we move from record-level checks to field management outputs.
*
* First, we export field comments.
* Then, we summarize text-audit timing and active survey hours.
* Next, we create survey and enumerator dashboards.
* Finally, we create a simple progress tracking workbook.
*
* After this file finishes, file 4 can create the codebook and backcheck
* comparison outputs.

* First, we load the checked survey dataset created by file 2.
* File 3 starts from the checked survey data so dashboards and management reports
* reflect the corrections and de-duplication from file 2.
use "$outputs/ppi_demo_checked.dta", clear

* First, we export field comments.
* ipacheckcomments joins survey records to the comments dataset created in file 1
* and exports the comment text by field and enumerator.
ipacheckcomments field_comments_id, ///
    enumerator(enumerator) ///
    commentsdata("$input_dir/demo_comments_data.dta") ///
    outfile("$hfc_output") ///
    outsheet("field comments") ///
    keepvars(household_id key barangay) ///
    sheetmodify

* Then, we summarize text audit timing.
* ipachecktextaudit summarizes how long enumerators spent on each field. This can
* help identify rushed sections or confusing questions.
ipachecktextaudit textaudit_id, ///
    enumerator(enumerator) ///
    textauditdata("$input_dir/demo_textaudit_data.dta") ///
    outfile("$textaudit_output") ///
    stats(count mean max min) ///
    sheetreplace

* Next, we summarize active survey hours.
* ipachecktimeuse uses text-audit timing and start times to show when interviews
* were active during the day.
ipachecktimeuse textaudit_id, ///
    enumerator(enumerator) ///
    starttime(starttime) ///
    textauditdata("$input_dir/demo_textaudit_data.dta") ///
    outfile("$timeuse_output") ///
    sheetreplace

* Then, we create the survey dashboard.
* ipachecksurveydb creates overall survey statistics: submissions, consent,
* duration, form versions, missingness, and summaries by barangay.
ipachecksurveydb, ///
    by(barangay) ///
    enumerator(enumerator) ///
    date(interview_date) ///
    period("daily") ///
    consent(consent, 1) ///
    otherspecify(asset_other) ///
    duration(duration_minutes) ///
    formversion(form_version) ///
    outfile("$survey_db") ///
    sheetreplace

* Next, we create the enumerator dashboard.
* ipacheckenumdb creates enumerator-level summaries. This is useful for spotting
* unusual patterns by interviewer or team.
ipacheckenumdb using "$inputs", ///
    sheetname("enumstats") ///
    date(interview_date) ///
    period("daily") ///
    enumerator(enumerator) ///
    team(enum_team_id) ///
    consent(consent, 1) ///
    otherspecify(asset_other) ///
    duration(duration_minutes) ///
    formversion(form_version) ///
    outfile("$enum_db") ///
    sheetreplace

* Finally, we track survey progress against simple barangay targets.
* ipatracksurvey compares survey submissions with target counts. In fieldwork,
* this helps teams monitor whether each area is on pace.
ipatracksurvey, ///
    surveydata("$outputs/ppi_demo_checked.dta") ///
    id(household_id) ///
    date(interview_date) ///
    by(barangay) ///
    trackingdata("$input_dir/demo_tracking_targets.csv") ///
    target(target) ///
    outfile("$tracking_output") ///
    replace

display as text "File 3 complete: dashboards, media outputs, and tracking are ready for file 4."
