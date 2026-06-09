# 09_create_manual_audit_files.R
# Create compact files for records that need manual review.

source("scripts/00_setup.R")

dlp_missing_key_rows <- read_csv(
  file.path(validation_na_dir, "dlp_rows_missing_key_school_fields.csv"),
  show_col_types = FALSE
) %>%
  transmute(
    audit_type = "missing key school field",
    source_dataset = "DLP randomization",
    source_file = "Final_DLP_Dataset_for_Randomization.csv",
    school_id = as.character(beis_school_id),
    school_name = NA_character_,
    region = region_code,
    division = division_code,
    grade = NA_character_,
    level_group = NA_character_,
    audit_value = NA_character_,
    comparison_value = NA_character_,
    difference = NA_character_,
    audit_note = "DLP row has a missing school identifier, region, division, or full division code."
  )

dlp_duplicate_school_ids <- read_csv(
  file.path(tables_dir, "dlp_duplicate_beis_school_ids.csv"),
  show_col_types = FALSE
) %>%
  transmute(
    audit_type = "duplicate school id",
    source_dataset = "DLP randomization",
    source_file = "Final_DLP_Dataset_for_Randomization.csv",
    school_id = as.character(beis_school_id),
    school_name = NA_character_,
    region = NA_character_,
    division = NA_character_,
    grade = NA_character_,
    level_group = NA_character_,
    audit_value = as.character(rows_with_same_beis_school_id),
    comparison_value = NA_character_,
    difference = NA_character_,
    audit_note = "BEIS school ID appears more than once in the DLP analytic file."
  )

philiri_bosy_unmatched_dlp <- read_csv(
  file.path(tables_dir, "philiri_bosy_unmatched_from_dlp.csv"),
  show_col_types = FALSE
) %>%
  transmute(
    audit_type = "DLP school unmatched to assessment",
    source_dataset = "Phil-IRI BoSY",
    source_file = "Phil-IRI KS3 National Dashboard_Secondary - BoSY 2025-26_Table.csv",
    school_id = as.character(beis_school_id),
    school_name = NA_character_,
    region = region_code,
    division = division_code,
    grade = NA_character_,
    level_group = NA_character_,
    audit_value = NA_character_,
    comparison_value = NA_character_,
    difference = NA_character_,
    audit_note = "DLP school did not match to the Phil-IRI BoSY file by school ID."
  )

philiri_eosy_unmatched_dlp <- read_csv(
  file.path(tables_dir, "philiri_eosy_unmatched_from_dlp.csv"),
  show_col_types = FALSE
) %>%
  transmute(
    audit_type = "DLP school unmatched to assessment",
    source_dataset = "Phil-IRI EoSY",
    source_file = "Phil-IRI KS3 National Dashboard_Secondary - EoSY 2025-26_Table.csv",
    school_id = as.character(beis_school_id),
    school_name = NA_character_,
    region = region_code,
    division = division_code,
    grade = NA_character_,
    level_group = NA_character_,
    audit_value = NA_character_,
    comparison_value = NA_character_,
    difference = NA_character_,
    audit_note = "DLP school did not match to the Phil-IRI EoSY file by school ID."
  )

rma_bosy_unmatched_dlp <- read_csv(
  file.path(tables_dir, "rma_bosy_unmatched_from_dlp.csv"),
  show_col_types = FALSE
) %>%
  transmute(
    audit_type = "DLP school unmatched to assessment",
    source_dataset = "RMA BoSY",
    source_file = "RMA (KS3) National Dashboard_BoSY 2025-26 Assessment Results_Table.csv",
    school_id = as.character(beis_school_id),
    school_name = NA_character_,
    region = region_code,
    division = division_code,
    grade = NA_character_,
    level_group = NA_character_,
    audit_value = NA_character_,
    comparison_value = NA_character_,
    difference = NA_character_,
    audit_note = "DLP school did not match to the RMA BoSY file by school ID."
  )

rma_eosy_unmatched_dlp <- read_csv(
  file.path(tables_dir, "rma_eosy_unmatched_from_dlp.csv"),
  show_col_types = FALSE
) %>%
  transmute(
    audit_type = "DLP school unmatched to assessment",
    source_dataset = "RMA EoSY",
    source_file = "RMA (KS3) National Dashboard_EoSY 2025-26 Assessment Results_Table.csv",
    school_id = as.character(beis_school_id),
    school_name = NA_character_,
    region = region_code,
    division = division_code,
    grade = NA_character_,
    level_group = NA_character_,
    audit_value = NA_character_,
    comparison_value = NA_character_,
    difference = NA_character_,
    audit_note = "DLP school did not match to the RMA EoSY file by school ID."
  )

philiri_discrepancy_audit <- read_csv(
  file.path(tables_dir, "philiri_school_level_discrepancy_checks.csv"),
  show_col_types = FALSE
) %>%
  filter(has_discrepancy, is_in_dlp_randomization_file) %>%
  transmute(
    audit_type = "assessment count discrepancy",
    source_dataset = paste("Phil-IRI", time_point),
    source_file = case_when(
      time_point == "BoSY" ~ "Phil-IRI KS3 National Dashboard_Secondary - BoSY 2025-26_Table.csv",
      time_point == "EoSY" ~ "Phil-IRI KS3 National Dashboard_Secondary - EoSY 2025-26_Table.csv",
      TRUE ~ "Phil-IRI assessment file"
    ),
    school_id = as.character(school_id),
    school_name = NA_character_,
    region = NA_character_,
    division = NA_character_,
    grade = grade,
    level_group = level_group,
    audit_value = as.character(summed_category_count),
    comparison_value = as.character(english_assessed),
    difference = as.character(discrepancy_count),
    audit_note = "Summed Phil-IRI reading category counts do not equal English assessed count."
  )

rma_discrepancy_audit <- read_csv(
  file.path(tables_dir, "rma_school_level_discrepancy_checks.csv"),
  show_col_types = FALSE
) %>%
  filter(has_discrepancy, is_in_dlp_randomization_file) %>%
  transmute(
    audit_type = "assessment count discrepancy",
    source_dataset = paste("RMA", time_point),
    source_file = case_when(
      time_point == "BoSY" ~ "RMA (KS3) National Dashboard_BoSY 2025-26 Assessment Results_Table.csv",
      time_point == "EoSY" ~ "RMA (KS3) National Dashboard_EoSY 2025-26 Assessment Results_Table.csv",
      TRUE ~ "RMA assessment file"
    ),
    school_id = as.character(school_id),
    school_name = NA_character_,
    region = NA_character_,
    division = NA_character_,
    grade = grade,
    level_group = NA_character_,
    audit_value = as.character(summed_proficiency_count),
    comparison_value = as.character(assessed_count),
    difference = as.character(discrepancy_count),
    audit_note = "Summed RMA proficiency counts do not equal assessed count."
  )

manual_audit_records <- bind_rows(
  dlp_missing_key_rows %>% mutate(across(everything(), as.character)),
  dlp_duplicate_school_ids %>% mutate(across(everything(), as.character)),
  philiri_bosy_unmatched_dlp %>% mutate(across(everything(), as.character)),
  philiri_eosy_unmatched_dlp %>% mutate(across(everything(), as.character)),
  rma_bosy_unmatched_dlp %>% mutate(across(everything(), as.character)),
  rma_eosy_unmatched_dlp %>% mutate(across(everything(), as.character)),
  philiri_discrepancy_audit %>% mutate(across(everything(), as.character)),
  rma_discrepancy_audit %>% mutate(across(everything(), as.character))
) %>%
  arrange(audit_type, source_dataset, school_id, grade, level_group)

manual_audit_summary <- manual_audit_records %>%
  count(audit_type, source_dataset, audit_note, name = "records_to_review") %>%
  arrange(audit_type, source_dataset)

write_csv(manual_audit_records, file.path(processed_dir, "manual_audit_records.csv"))
write_csv(manual_audit_summary, file.path(processed_dir, "manual_audit_summary.csv"))
