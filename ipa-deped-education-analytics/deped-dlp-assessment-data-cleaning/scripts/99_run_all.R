# 99_run_all.R
# Run the full DLP assessment data cleaning workflow from start to finish.

source("scripts/00_setup.R")
source("scripts/01_clean_dlp_randomization.R")
source("scripts/02_clean_philiri.R")
source("scripts/03_merge_philiri_to_dlp.R")
source("scripts/04_clean_rma.R")
source("scripts/05_merge_rma_to_dlp.R")
source("scripts/06_create_scores_and_checks.R")
source("scripts/07_create_graphs.R")
source("scripts/08_create_codebook.R")
source("scripts/09_create_manual_audit_files.R")
source("scripts/10_create_final_percentage_dataset.R")

run_complete_log <- tibble(
  workflow_step = c(
    "setup",
    "clean_dlp_randomization",
    "clean_philiri",
    "merge_philiri_to_dlp",
    "clean_rma",
    "merge_rma_to_dlp",
    "create_scores_and_checks",
    "create_graphs",
    "create_codebook",
    "create_manual_audit_files",
    "create_final_percentage_dataset"
  ),
  status = "completed",
  completed_at = as.character(Sys.time())
)

write_csv(run_complete_log, file.path(logs_dir, "run_all_completed.csv"))
