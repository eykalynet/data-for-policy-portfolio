################################################################################
## TITLE   : 00_run_response_coding.R
## PURPOSE : Run ESC-SHS-VP open-ended response coding as a standalone workflow.
## PROJECT : ESC-SHS-VP targeting response coding
## AUTHOR  : Erika Salvador
## DATE    : July 11, 2026
################################################################################

library(janitor)
library(readxl)

project_dir <- normalizePath(getwd(), mustWork = FALSE)
project_dir <- sub("/scripts$", "", project_dir)
config <- list(
  open_ended_file = file.path(
    project_dir,
    "raw",
    "Open Ended Question Only - Pilot BIS Form for Private School Learners.xlsx"
  ),
  coding_dir = project_dir,
  sheet = 1,
  export_prefix = "esc_shs_vp_targeting"
)

source(file.path(project_dir, "scripts", "01_code_open_ended_responses.R"))

write.csv(
  open_response_results$codebook,
  file = file.path(config$coding_dir, paste0(config$export_prefix, "_open_response_codebook.csv")),
  row.names = FALSE,
  na = ""
)

write.csv(
  open_response_results$coded_responses,
  file = file.path(config$coding_dir, paste0(config$export_prefix, "_open_response_coded.csv")),
  row.names = FALSE,
  na = ""
)

write.csv(
  open_response_results$summary,
  file = file.path(config$coding_dir, paste0(config$export_prefix, "_open_response_summary.csv")),
  row.names = FALSE,
  na = ""
)

message("Open-response codebook: ", file.path(config$coding_dir, paste0(config$export_prefix, "_open_response_codebook.csv")))
message("Coded open responses: ", file.path(config$coding_dir, paste0(config$export_prefix, "_open_response_coded.csv")))
message("Open-response summary: ", file.path(config$coding_dir, paste0(config$export_prefix, "_open_response_summary.csv")))
