###############################################################################
# High-Frequency Checks Master Script
#
# How to use:
# 1. Update the paths below.
# 2. Run this file.
# 3. Review the files written to output_dir.
###############################################################################

config <- list(
  input_file = "data/raw/hfc_responses.xlsx",
  output_dir = "data/processed",
  sheet = 1,
  export_prefix = "hfc_checked",
  ppi_scorecard_file = "/Users/esalvador/Downloads/Philippines 2023 PPI Scorecard and LookUp Tables - Income Lines - Final Version-2.xlsx",
  school_column = "School ID and School Name of Learner for SY 2026 - 2027"
)

source("01_setup_and_load.R")
source("02_hfc_checks.R")
source("03_ppi_school_append.R")

dir.create(config$output_dir, recursive = TRUE, showWarnings = FALSE)

write.csv(
  hfc_results$clean_data,
  file = file.path(config$output_dir, paste0(config$export_prefix, "_data.csv")),
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
  file = file.path(config$output_dir, paste0(config$export_prefix, "_school_ppi.csv")),
  row.names = FALSE,
  na = ""
)

message("High-frequency checks complete.")
message("Clean data: ", file.path(config$output_dir, paste0(config$export_prefix, "_data.csv")))
message("Issue log: ", file.path(config$output_dir, paste0(config$export_prefix, "_issue_log.csv")))
message("Summary: ", file.path(config$output_dir, paste0(config$export_prefix, "_summary.csv")))
message("School-level PPI: ", file.path(config$output_dir, paste0(config$export_prefix, "_school_ppi.csv")))
