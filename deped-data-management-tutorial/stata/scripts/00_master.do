********************************************************************************
*** TITLE   : 00_master.do
*** PURPOSE : Run the full PPI DMS training workflow in sequence
*** PROJECT : PPI DMS training demo
*** AUTHOR  : Erika Salvador
*** DATE    : June 29, 2026
********************************************************************************

* Run this file from the project folder:
*
*     do "stata/scripts/00_master.do"
*
* First, this master file sets up shared paths and output names.
* Then, it calls each smaller do-file in order:
*
*   File 1: 01_setup_and_prep.do
*       First we prepare the training data and helper files.
*
*   File 2: 02_survey_hfc_checks.do
*       Then we run the core high-frequency checks on the survey data.
*
*   File 3: 03_media_dashboards_tracking.do
*       Next we run comments/text-audit examples, dashboards, and tracking.
*
*   File 4: 04_backcheck_and_codebook.do
*       Finally we export a codebook and compare survey vs. backcheck data.

version 17
clear all
set more off

* These globals are shared by all four do-files. Defining them once here means
* the smaller files can refer to the same folders and output filenames.
global root "`c(pwd)'"
global data "$root/data/ppi_dummy_raw.dta"
global input_dir "$root/inputs"
global inputs "$input_dir/ipacheck_inputs.xlsx"
global outputs "$root/stata/outputs"

cap mkdir "$outputs"

global hfc_output       "$outputs/ipacheck_hfc_output.xlsx"
global corr_log         "$outputs/ipacheck_corrections_log.xlsx"
global recode_log       "$outputs/ipacheck_specify_recode_log.xlsx"
global survey_db        "$outputs/ipacheck_survey_dashboard.xlsx"
global enum_db          "$outputs/ipacheck_enumerator_dashboard.xlsx"
global textaudit_output "$outputs/ipacheck_textaudit.xlsx"
global timeuse_output   "$outputs/ipacheck_timeuse.xlsx"
global tracking_output  "$outputs/ipacheck_tracking.xlsx"
global bc_output        "$outputs/ipacheck_backcheck.xlsx"
global codebook_output  "$outputs/ipacheck_codebook.xlsx"

* This is the list of PPI variables used throughout the demo. In a real project,
* the team would replace this list with the actual PPI survey variables.
global ppi_vars ///
    ppi_q1_floor_solid ///
    ppi_q2_has_toilet ///
    ppi_q3_has_electricity ///
    ppi_q4_has_tv ///
    ppi_q5_has_fridge ///
    ppi_q6_head_completed_primary ///
    ppi_q7_roof_durable ///
    ppi_q8_has_mobile_phone ///
    ppi_q9_owns_livestock ///
    ppi_q10_has_savings

* Before running the workflow, we remove old output workbooks. This helps us
* know that any files in stata/outputs came from the current run.
foreach file in "$hfc_output" "$corr_log" "$recode_log" "$survey_db" ///
    "$enum_db" "$textaudit_output" "$timeuse_output" "$tracking_output" ///
    "$bc_output" "$codebook_output" {
    cap erase `"`file'"'
}

* These four do-files are the full workflow. Running the master file is easier
* than asking someone to run each piece by hand.
display as text "File 1 of 4: preparing data and helper files..."
do "$root/stata/scripts/01_setup_and_prep.do"

display as text "File 2 of 4: running survey high-frequency checks..."
do "$root/stata/scripts/02_survey_hfc_checks.do"

display as text "File 3 of 4: creating media reports, dashboards, and tracking..."
do "$root/stata/scripts/03_media_dashboards_tracking.do"

display as text "File 4 of 4: creating codebook and backcheck comparison..."
do "$root/stata/scripts/04_backcheck_and_codebook.do"
