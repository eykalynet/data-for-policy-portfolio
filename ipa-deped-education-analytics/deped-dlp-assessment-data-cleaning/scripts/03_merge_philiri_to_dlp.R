# 03_merge_philiri_to_dlp.R
# Merge Phil-IRI BoSY and EoSY assessment data to the DLP randomization file.

source("scripts/00_setup.R")

dlp_clean <- read_rds(file.path(processed_dir, "dlp_randomization_clean.rds"))
philiri_bosy_clean <- read_rds(file.path(processed_dir, "philiri_bosy_clean.rds"))
philiri_eosy_clean <- read_rds(file.path(processed_dir, "philiri_eosy_clean.rds"))

philiri_bosy_dlp_matches <- dlp_clean %>%
  inner_join(philiri_bosy_clean, by = c("beis_school_id" = "school_id"))

philiri_bosy_unmatched_dlp <- dlp_clean %>%
  anti_join(philiri_bosy_clean, by = c("beis_school_id" = "school_id"))

philiri_bosy_unmatched_assessment <- philiri_bosy_clean %>%
  anti_join(dlp_clean, by = c("school_id" = "beis_school_id"))

philiri_eosy_dlp_matches <- dlp_clean %>%
  inner_join(philiri_eosy_clean, by = c("beis_school_id" = "school_id"))

philiri_eosy_unmatched_dlp <- dlp_clean %>%
  anti_join(philiri_eosy_clean, by = c("beis_school_id" = "school_id"))

philiri_eosy_unmatched_assessment <- philiri_eosy_clean %>%
  anti_join(dlp_clean, by = c("school_id" = "beis_school_id"))

philiri_merge_diagnostics <- tibble(
  dataset = c("Phil-IRI BoSY", "Phil-IRI EoSY"),
  matched_records = c(nrow(philiri_bosy_dlp_matches), nrow(philiri_eosy_dlp_matches)),
  unmatched_records_from_dlp = c(nrow(philiri_bosy_unmatched_dlp), nrow(philiri_eosy_unmatched_dlp)),
  unmatched_records_from_assessment = c(nrow(philiri_bosy_unmatched_assessment), nrow(philiri_eosy_unmatched_assessment)),
  dlp_rows = c(nrow(dlp_clean), nrow(dlp_clean)),
  assessment_rows = c(nrow(philiri_bosy_clean), nrow(philiri_eosy_clean))
)

philiri_bosy_for_merge <- philiri_bosy_clean %>%
  rename_with(~ paste0("philiri_bosy_", .x), -school_id)

philiri_eosy_for_merge <- philiri_eosy_clean %>%
  rename_with(~ paste0("philiri_eosy_", .x), -school_id)

dlp_with_philiri <- dlp_clean %>%
  left_join(philiri_bosy_for_merge, by = c("beis_school_id" = "school_id")) %>%
  left_join(philiri_eosy_for_merge, by = c("beis_school_id" = "school_id"))

write_rds(dlp_with_philiri, file.path(processed_dir, "dlp_with_philiri_merged.rds"))
write_csv(dlp_with_philiri, file.path(processed_dir, "dlp_with_philiri_merged.csv"))
write_csv(philiri_merge_diagnostics, file.path(tables_dir, "philiri_merge_diagnostics.csv"))
write_csv(philiri_bosy_unmatched_dlp, file.path(tables_dir, "philiri_bosy_unmatched_from_dlp.csv"))
write_csv(philiri_bosy_unmatched_assessment, file.path(tables_dir, "philiri_bosy_unmatched_from_assessment.csv"))
write_csv(philiri_eosy_unmatched_dlp, file.path(tables_dir, "philiri_eosy_unmatched_from_dlp.csv"))
write_csv(philiri_eosy_unmatched_assessment, file.path(tables_dir, "philiri_eosy_unmatched_from_assessment.csv"))

