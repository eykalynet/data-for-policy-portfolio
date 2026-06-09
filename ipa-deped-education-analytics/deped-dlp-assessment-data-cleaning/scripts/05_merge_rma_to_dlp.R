# 05_merge_rma_to_dlp.R
# Merge RMA BoSY and EoSY assessment data to the DLP randomization file.

source("scripts/00_setup.R")

dlp_with_philiri <- read_rds(file.path(processed_dir, "dlp_with_philiri_merged.rds"))
dlp_clean <- read_rds(file.path(processed_dir, "dlp_randomization_clean.rds"))
rma_bosy_clean <- read_rds(file.path(processed_dir, "rma_bosy_clean.rds"))
rma_eosy_clean <- read_rds(file.path(processed_dir, "rma_eosy_clean.rds"))

rma_bosy_dlp_matches <- dlp_clean |>
  inner_join(rma_bosy_clean, by = c("beis_school_id" = "school_id"))

rma_bosy_unmatched_dlp <- dlp_clean |>
  anti_join(rma_bosy_clean, by = c("beis_school_id" = "school_id"))

rma_bosy_unmatched_assessment <- rma_bosy_clean |>
  anti_join(dlp_clean, by = c("school_id" = "beis_school_id"))

rma_eosy_dlp_matches <- dlp_clean |>
  inner_join(rma_eosy_clean, by = c("beis_school_id" = "school_id"))

rma_eosy_unmatched_dlp <- dlp_clean |>
  anti_join(rma_eosy_clean, by = c("beis_school_id" = "school_id"))

rma_eosy_unmatched_assessment <- rma_eosy_clean |>
  anti_join(dlp_clean, by = c("school_id" = "beis_school_id"))

rma_merge_diagnostics <- tibble(
  dataset = c("RMA BoSY", "RMA EoSY"),
  matched_records = c(nrow(rma_bosy_dlp_matches), nrow(rma_eosy_dlp_matches)),
  unmatched_records_from_dlp = c(nrow(rma_bosy_unmatched_dlp), nrow(rma_eosy_unmatched_dlp)),
  unmatched_records_from_assessment = c(nrow(rma_bosy_unmatched_assessment), nrow(rma_eosy_unmatched_assessment)),
  dlp_rows = c(nrow(dlp_clean), nrow(dlp_clean)),
  assessment_rows = c(nrow(rma_bosy_clean), nrow(rma_eosy_clean))
)

rma_bosy_for_merge <- rma_bosy_clean |>
  rename_with(~ paste0("rma_bosy_", .x), -school_id)

rma_eosy_for_merge <- rma_eosy_clean |>
  rename_with(~ paste0("rma_eosy_", .x), -school_id)

dlp_with_all_assessments <- dlp_with_philiri |>
  left_join(rma_bosy_for_merge, by = c("beis_school_id" = "school_id")) |>
  left_join(rma_eosy_for_merge, by = c("beis_school_id" = "school_id"))

all_merge_diagnostics <- bind_rows(
  read_csv(file.path(tables_dir, "philiri_merge_diagnostics.csv"), show_col_types = FALSE),
  rma_merge_diagnostics
)

write_rds(dlp_with_all_assessments, file.path(processed_dir, "dlp_with_all_assessments_merged.rds"))
write_csv(dlp_with_all_assessments, file.path(processed_dir, "dlp_with_all_assessments_merged.csv"))
write_csv(rma_merge_diagnostics, file.path(tables_dir, "rma_merge_diagnostics.csv"))
write_csv(all_merge_diagnostics, file.path(tables_dir, "all_merge_diagnostics.csv"))
write_csv(rma_bosy_unmatched_dlp, file.path(tables_dir, "rma_bosy_unmatched_from_dlp.csv"))
write_csv(rma_bosy_unmatched_assessment, file.path(tables_dir, "rma_bosy_unmatched_from_assessment.csv"))
write_csv(rma_eosy_unmatched_dlp, file.path(tables_dir, "rma_eosy_unmatched_from_dlp.csv"))
write_csv(rma_eosy_unmatched_assessment, file.path(tables_dir, "rma_eosy_unmatched_from_assessment.csv"))

