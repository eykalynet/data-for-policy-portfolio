# 99_run_all.R
# Run the streamlined R cleaning, scoring, and Stata-export workflow.

source("scripts/00_setup.R")
source("scripts/01_clean_merge_data.R")
source("scripts/02_create_scores_and_checks.R")
source("scripts/03_export_stata_dataset.R")

run_log <- tibble(
  completed_at = as.character(Sys.time()),
  r_outputs_created = c(
    "data/01_dlp_rma_philiri_school_level_full.csv",
    "data/02_dlp_rma_philiri_school_level_percentages.csv",
    "data/03_dlp_rma_philiri_school_level_for_stata.dta",
    "outputs/tables/01_merge_diagnostics.csv",
    "outputs/tables/02_philiri_score_checks.csv",
    "outputs/tables/02_rma_score_checks.csv",
    "outputs/validation_na_schools/01_schools_with_missing_key_fields.csv"
  )
)

write_csv(run_log, file.path(logs_dir, "99_run_all_completed.csv"))

message("R workflow complete.")
message("Next, run these Stata do-files from the project root:")
message("  do scripts/04_descriptive_stats.do")
message("  do scripts/05_compliance_checks.do")
message("  do scripts/06_visualizations.do")
message("  do scripts/07_geographic_summaries.do")
