# 01_clean_dlp_randomization.R
# Clean the DLP school-level randomization data.

source("scripts/00_setup.R")

dlp_file <- file.path(raw_dir, "Final_DLP_Dataset_for_Randomization.csv")
dlp_eval_file <- file.path(raw_dir, "DLP_randomized_schools_eval.csv")

dlp_raw <- read_csv(
  dlp_file,
  col_types = cols(.default = col_character()),
  na = c("", "NA", "N/A", "na", "n/a")
) |>
  clean_names()

dlp_eval_raw <- read_csv(
  dlp_eval_file,
  col_types = cols(.default = col_character()),
  na = c("", "NA", "N/A", "na", "n/a")
) |>
  clean_names()

dlp_clean_step_1 <- dlp_raw |>
  rename(row_number_from_source_file = x1) |>
  mutate(
    across(everything(), str_squish),
    beis_school_id = as.character(beis_school_id),
    region_code = as.character(region_code),
    division_code = as.character(division_code),
    municipality_code = as.character(municipality_code),
    full_division_code = as.character(full_division_code),
    full_municipality_code = as.character(full_municipality_code)
  )

dlp_eval_clean <- dlp_eval_raw |>
  mutate(
    across(everything(), str_squish),
    beis_school_id = as.character(beis_school_id),
    region_code = as.character(region_code),
    division_code = as.character(division_code),
    municipality_code = as.character(municipality_code),
    full_division_code = as.character(full_division_code),
    full_municipality_code = as.character(full_municipality_code)
  ) |>
  select(beis_school_id, randomized_eval_id = id, rev_status)

dlp_clean_step_2 <- dlp_clean_step_1 |>
  left_join(dlp_eval_clean, by = "beis_school_id") |>
  mutate(
    across(
      matches("enroll|dropout|room|classroom|seat|toilet|computer|teacher|cancel|pilot"),
      parse_number
    )
  )

key_school_fields <- c(
  "beis_school_id",
  "region_code",
  "division_code",
  "full_division_code"
)

dlp_with_key_flags <- dlp_clean_step_2 |>
  mutate(
    missing_beis_school_id = is.na(beis_school_id) | str_squish(beis_school_id) == "" | str_to_upper(beis_school_id) == "NA",
    missing_region_code = is.na(region_code) | str_squish(region_code) == "" | str_to_upper(region_code) == "NA",
    missing_division_code = is.na(division_code) | str_squish(division_code) == "" | str_to_upper(division_code) == "NA",
    missing_full_division_code = is.na(full_division_code) | str_squish(full_division_code) == "" | str_to_upper(full_division_code) == "NA",
    has_missing_key_school_field = missing_beis_school_id | missing_region_code | missing_division_code | missing_full_division_code
  )

dlp_na_schools <- dlp_with_key_flags |>
  filter(has_missing_key_school_field)

dlp_main <- dlp_with_key_flags |>
  filter(!has_missing_key_school_field) |>
  select(-missing_beis_school_id, -missing_region_code, -missing_division_code, -missing_full_division_code, -has_missing_key_school_field)

id_variables <- c(
  "row_number_from_source_file",
  "beis_school_id",
  "region_code",
  "division_code",
  "municipality_code",
  "full_division_code",
  "full_municipality_code",
  "randomized_eval_id"
)

dlp_main <- dlp_main |>
  mutate(across(where(is.character) & !any_of(id_variables), as.factor))

dlp_na_schools <- dlp_na_schools |>
  mutate(across(where(is.character) & !any_of(id_variables), as.factor))

dlp_clean_summary <- tibble(
  file = "Final_DLP_Dataset_for_Randomization.csv",
  total_rows_raw = nrow(dlp_raw),
  rows_missing_key_school_fields = nrow(dlp_na_schools),
  rows_kept_for_main_analysis = nrow(dlp_main),
  unique_beis_school_id_kept = n_distinct(dlp_main$beis_school_id)
)

dlp_duplicate_school_ids <- dlp_main |>
  count(beis_school_id, name = "rows_with_same_beis_school_id") |>
  filter(rows_with_same_beis_school_id > 1)

write_rds(dlp_main, file.path(processed_dir, "dlp_randomization_clean.rds"))
write_csv(dlp_main, file.path(processed_dir, "dlp_randomization_clean.csv"))
write_csv(dlp_na_schools, file.path(validation_na_dir, "dlp_rows_missing_key_school_fields.csv"))
write_csv(dlp_clean_summary, file.path(tables_dir, "dlp_cleaning_summary.csv"))
write_csv(dlp_duplicate_school_ids, file.path(tables_dir, "dlp_duplicate_beis_school_ids.csv"))

