********************************************************************************
*** TITLE   : 04_backcheck_and_codebook.do
*** PURPOSE : Export codebook and compare survey data with dummy backcheck data
*** PROJECT : PPI DMS training demo
*** AUTHOR  : Erika Salvador
*** DATE    : June 29, 2026
********************************************************************************

* This is file 4 of 4 in the DMS walkthrough.
*
* File 3 created management outputs: comments, text audits, dashboards, and
* tracking. Now, in file 4, we finish with documentation and backchecks.
*
* First, we export a codebook for the checked survey data.
* Then, we create a small dummy backcheck dataset.
* Finally, we compare survey and backcheck data with ipabcstats.
*
* After this file finishes, the full demo is complete.

* First, we load the checked survey dataset created by file 2.
* File 4 returns to the checked survey dataset because the codebook and
* backcheck comparison should reflect the cleaned survey structure.
use "$outputs/ppi_demo_checked.dta", clear

* First, we export a codebook.
* ipacodebook documents variables, labels, types, value labels, missingness, and
* uniqueness. This is useful for training and project handover.
ipacodebook using "$codebook_output", replace

* Then, we create dummy backcheck data for training.
* ipabcstats expects numeric enumerator and backchecker IDs, so we use enum_id
* and create numeric backchecker/team IDs for the demo.
* This block creates a fake backcheck dataset from the survey data, then changes
* a few answers so ipabcstats has differences to report.
save "$outputs/ppi_demo_checked.dta", replace

preserve
keep in 1/20
gen backchecker_id = mod(_n, 2) + 1
gen bc_team_id = cond(backchecker_id == 1, 1, 2)
gen bcdate = interview_date + 1
format %td bcdate
replace ppi_q2_has_toilet = 1 - ppi_q2_has_toilet if inlist(_n, 3, 9, 15) & inlist(ppi_q2_has_toilet, 0, 1)
replace hh_size = hh_size + 1 if inlist(_n, 4, 12)
save "$outputs/ppi_backcheck_dummy.dta", replace
restore

* Finally, we compare survey and backcheck data.
* ipabcstats compares original survey answers against backcheck answers. It
* reports differences by variable, enumerator, and backchecker.
ipabcstats, ///
    surveydata("$outputs/ppi_demo_checked.dta") ///
    bcdata("$outputs/ppi_backcheck_dummy.dta") ///
    id(household_id) ///
    enumerator(enum_id) ///
    enumteam(enum_team_id) ///
    backchecker(backchecker_id) ///
    bcteam(bc_team_id) ///
    t1vars(hh_size children_under_15) ///
    t2vars(ppi_q1_floor_solid ppi_q2_has_toilet ppi_q3_has_electricity) ///
    surveydate(interview_date) ///
    bcdate(bcdate) ///
    filename("$bc_output") ///
    replace

display as text "File 4 complete: codebook and backcheck comparison are done."
