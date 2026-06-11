################################################################################
## TITLE   : 99_run_all.R
## PURPOSE : Run the R cleaning, scoring, validation, and Stata export.
## PROJECT : Dynamic Learning Program descriptive results
## AUTHOR  : Erika Salvador
## DATE    : June 11, 2026
################################################################################

# Run the R-side pipeline in dependency order. Stata scripts are run separately.
source("scripts/00_setup.R")
source("scripts/01_clean_merge_data.R")
source("scripts/02_create_scores_and_checks.R")
source("scripts/03_export_stata_dataset.R")

# Write a small completion log so reruns leave a visible timestamp.
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
