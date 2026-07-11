################################################################################
## TITLE   : 00_master.R
## PURPOSE : Configure paths and run the ESC-SHS-VP targeting workflow.
## PROJECT : ESC-SHS-VP targeting descriptive statistics
## AUTHOR  : Erika Salvador
## DATE    : July 10, 2026
################################################################################

## HANDOFF NOTES FOR THE NEXT ANALYST:
## This workflow is set up so the code structure can stay fixed while file
## paths and survey assumptions are adjusted here. Because the real data may
## not be available to the person preparing the portfolio, the analyst with
## data access should first review the config block below.
##
## Usually change these values:
## - config$input_file: path to the real Google Form or survey export.
## - config$sheet: sheet name or number that contains the response data.
## - config$ppi_scorecard_file: local path to the Philippines 2023 PPI workbook.
## - config$school_column: school field used for school-level aggregation.
##
## Then review these scripts if the form or raw responses changed:
## - 02_hfc_checks.R: expected columns, required fields, validation thresholds,
##   and yes/no checks.
## - 03_ppi_school_append.R: PPI input mapping, response recodes, and school ID
##   parsing.
##
## Run this script from the project folder or from scripts/. The project folder
## is inferred automatically, so the config block is usually the only place
## where folder locations need to be edited.
project_dir <- normalizePath(getwd(), mustWork = FALSE)
project_dir <- sub("/scripts$", "", project_dir)

## CHANGE HERE WHEN USING REAL DATA:
## - input_file: point to the actual Google Form or survey export.
## - sheet: use the sheet name or number that contains the response data.
## - ppi_scorecard_file: point to the local Philippines 2023 PPI workbook.
## - school_column: update only if the school identifier question changes.
## The data_dir and output_dir can usually stay as-is.
config <- list(
  input_file = file.path(project_dir, "raw", "dummy_esc_shs_vp_targeting_responses.xlsx"),
  data_dir = file.path(project_dir, "data"),
  output_dir = file.path(project_dir, "outputs"),
  sheet = 1,
  export_prefix = "esc_shs_vp_targeting",
  ppi_scorecard_file = "/Users/esalvador/Downloads/Philippines 2023 PPI Scorecard and LookUp Tables - Income Lines - Final Version-2.xlsx",
  school_column = "School ID and School Name of Learner for SY 2026 - 2027"
)

## Source scripts in order. These scripts use objects created earlier in the
## workflow, so run the master script rather than running individual files first.
source(file.path(project_dir, "scripts", "01_setup_and_load.R"))
source(file.path(project_dir, "scripts", "02_hfc_checks.R"))
source(file.path(project_dir, "scripts", "03_ppi_school_append.R"))

## Create output folders if they do not already exist.
dir.create(config$data_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(config$output_dir, recursive = TRUE, showWarnings = FALSE)

## Export cleaned learner-level data, row-level issue logs, summary counts,
## and school-level PPI aggregates. These CSVs are safe handoff files for review.
write.csv(
  hfc_results$clean_data,
  file = file.path(config$data_dir, paste0(config$export_prefix, "_clean_data.csv")),
  row.names = FALSE,
  na = ""
)

write.csv(
  hfc_results$issue_log,
  file = file.path(config$output_dir, paste0(config$export_prefix, "_issue_log.csv")),
  row.names = FALSE,
  na = ""
)

write.csv(
  hfc_results$summary,
  file = file.path(config$output_dir, paste0(config$export_prefix, "_summary.csv")),
  row.names = FALSE,
  na = ""
)

write.csv(
  ppi_results$school_ppi,
  file = file.path(config$data_dir, paste0(config$export_prefix, "_school_ppi.csv")),
  row.names = FALSE,
  na = ""
)

message("High-frequency checks complete.")
message("Clean data: ", file.path(config$data_dir, paste0(config$export_prefix, "_clean_data.csv")))
message("Issue log: ", file.path(config$output_dir, paste0(config$export_prefix, "_issue_log.csv")))
message("Summary: ", file.path(config$output_dir, paste0(config$export_prefix, "_summary.csv")))
message("School-level PPI: ", file.path(config$data_dir, paste0(config$export_prefix, "_school_ppi.csv")))
