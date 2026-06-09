# 02_clean_philiri.R
# Clean Phil-IRI BoSY and EoSY school-level assessment data.

source("scripts/00_setup.R")

philiri_bosy_file <- list.files(raw_dir, pattern = "Phil-IRI.*BoSY.*\\.csv$", full.names = TRUE)
philiri_eosy_file <- list.files(raw_dir, pattern = "Phil-IRI.*EoSY.*\\.csv$", full.names = TRUE)

philiri_bosy_raw <- read_csv(
  philiri_bosy_file,
  col_types = cols(.default = col_character()),
  na = c("", "NA", "N/A", "na", "n/a", "null", "NULL")
) |>
  clean_names()

philiri_eosy_raw <- read_csv(
  philiri_eosy_file,
  col_types = cols(.default = col_character()),
  na = c("", "NA", "N/A", "na", "n/a", "null", "NULL")
) |>
  clean_names()

philiri_bosy_clean <- philiri_bosy_raw |>
  mutate(across(everything(), str_squish)) |>
  mutate(
    school_id = as.character(school_id),
    across(!any_of(c("region", "division", "district", "school_id", "school_name")), parse_number),
    region = as.factor(region),
    division = as.factor(division),
    district = as.factor(district),
    school_name = as.factor(school_name)
  )

philiri_eosy_clean <- philiri_eosy_raw |>
  mutate(across(everything(), str_squish)) |>
  mutate(
    school_id = as.character(school_id),
    across(!any_of(c("region", "division", "district", "school_id", "school_name")), parse_number),
    region = as.factor(region),
    division = as.factor(division),
    district = as.factor(district),
    school_name = as.factor(school_name)
  )

philiri_bosy_missing_key <- philiri_bosy_clean |>
  mutate(
    missing_school_id = is.na(school_id) | str_squish(school_id) == "" | str_to_upper(school_id) == "NA",
    missing_school_name = is.na(as.character(school_name)) | str_squish(as.character(school_name)) == "" | str_to_upper(as.character(school_name)) == "NA",
    missing_division = is.na(as.character(division)) | str_squish(as.character(division)) == "" | str_to_upper(as.character(division)) == "NA",
    missing_region = is.na(as.character(region)) | str_squish(as.character(region)) == "" | str_to_upper(as.character(region)) == "NA",
    has_missing_key_school_field = missing_school_id | missing_school_name | missing_division | missing_region
  ) |>
  filter(has_missing_key_school_field)

philiri_eosy_missing_key <- philiri_eosy_clean |>
  mutate(
    missing_school_id = is.na(school_id) | str_squish(school_id) == "" | str_to_upper(school_id) == "NA",
    missing_school_name = is.na(as.character(school_name)) | str_squish(as.character(school_name)) == "" | str_to_upper(as.character(school_name)) == "NA",
    missing_division = is.na(as.character(division)) | str_squish(as.character(division)) == "" | str_to_upper(as.character(division)) == "NA",
    missing_region = is.na(as.character(region)) | str_squish(as.character(region)) == "" | str_to_upper(as.character(region)) == "NA",
    has_missing_key_school_field = missing_school_id | missing_school_name | missing_division | missing_region
  ) |>
  filter(has_missing_key_school_field)

philiri_bosy_main <- philiri_bosy_clean |>
  anti_join(philiri_bosy_missing_key |> select(school_id), by = "school_id")

philiri_eosy_main <- philiri_eosy_clean |>
  anti_join(philiri_eosy_missing_key |> select(school_id), by = "school_id")

philiri_cleaning_summary <- tibble(
  dataset = c("Phil-IRI BoSY", "Phil-IRI EoSY"),
  raw_rows = c(nrow(philiri_bosy_raw), nrow(philiri_eosy_raw)),
  rows_missing_key_school_fields = c(nrow(philiri_bosy_missing_key), nrow(philiri_eosy_missing_key)),
  rows_kept_for_merging = c(nrow(philiri_bosy_main), nrow(philiri_eosy_main)),
  unique_school_ids_kept = c(n_distinct(philiri_bosy_main$school_id), n_distinct(philiri_eosy_main$school_id))
)

philiri_bosy_duplicate_school_ids <- philiri_bosy_main |>
  count(school_id, name = "rows_with_same_school_id") |>
  filter(rows_with_same_school_id > 1)

philiri_eosy_duplicate_school_ids <- philiri_eosy_main |>
  count(school_id, name = "rows_with_same_school_id") |>
  filter(rows_with_same_school_id > 1)

write_rds(philiri_bosy_main, file.path(processed_dir, "philiri_bosy_clean.rds"))
write_rds(philiri_eosy_main, file.path(processed_dir, "philiri_eosy_clean.rds"))
write_csv(philiri_bosy_main, file.path(processed_dir, "philiri_bosy_clean.csv"))
write_csv(philiri_eosy_main, file.path(processed_dir, "philiri_eosy_clean.csv"))
write_csv(philiri_bosy_missing_key, file.path(validation_na_dir, "philiri_bosy_rows_missing_key_school_fields.csv"))
write_csv(philiri_eosy_missing_key, file.path(validation_na_dir, "philiri_eosy_rows_missing_key_school_fields.csv"))
write_csv(philiri_cleaning_summary, file.path(tables_dir, "philiri_cleaning_summary.csv"))
write_csv(philiri_bosy_duplicate_school_ids, file.path(tables_dir, "philiri_bosy_duplicate_school_ids.csv"))
write_csv(philiri_eosy_duplicate_school_ids, file.path(tables_dir, "philiri_eosy_duplicate_school_ids.csv"))
