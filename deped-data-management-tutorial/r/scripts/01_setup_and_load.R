################################################################################
## TITLE   : 01_setup_and_load.R
## PURPOSE : Load dummy PPI data and helper files for the R DMS analogue
## PROJECT : PPI DMS training demo
## AUTHOR  : Erika Salvador
## DATE    : June 29, 2026
################################################################################

# This is file 1 of 4 in the R DMS analogue.
#
# First, we load the R-created dummy data.
# Then, we load the small helper files used by the Stata DMS demo.
# After this file finishes, file 2 can run survey high-frequency checks.

# This mirrors the setup stage of the Stata workflow. The dummy data and helper
# files are created by r/scripts/99_make_dummy_ppi_data.R.
survey <- read_dta("data/ppi_dummy_raw.dta") |>
  mutate(interview_date = as.Date(interview_date))

# These helper files feed the R analogues of corrections, recodes, comments,
# text audits, and tracking.
corrections <- read_csv("inputs/demo_corrections.csv", show_col_types = FALSE)
specify_recode <- read_csv("inputs/demo_specify_recode.csv", show_col_types = FALSE)
tracking_targets <- read_csv("inputs/demo_tracking_targets.csv", show_col_types = FALSE)
comments_data <- read_dta("inputs/demo_comments_data.dta")
textaudit_data <- read_dta("inputs/demo_textaudit_data.dta")
