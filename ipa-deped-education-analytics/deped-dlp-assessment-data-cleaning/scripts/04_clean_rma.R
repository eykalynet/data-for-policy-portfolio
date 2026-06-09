# 04_clean_rma.R
# Clean RMA BoSY and EoSY school-level assessment data.

source("scripts/00_setup.R")

rma_bosy_file <- list.files(raw_dir, pattern = "RMA.*BoSY.*\\.csv$", full.names = TRUE)
rma_eosy_file <- list.files(raw_dir, pattern = "RMA.*EoSY.*\\.csv$", full.names = TRUE)

rma_bosy_raw <- read_csv(
  rma_bosy_file,
  col_types = cols(.default = col_character()),
  na = c("", "NA", "N/A", "na", "n/a", "null", "NULL")
) |>
  clean_names()

rma_eosy_raw <- read_csv(
  rma_eosy_file,
  col_types = cols(.default = col_character()),
  na = c("", "NA", "N/A", "na", "n/a", "null", "NULL")
) |>
  clean_names()

rma_bosy_clean <- rma_bosy_raw |>
  mutate(across(everything(), str_squish)) |>
  mutate(
    school_id = as.character(school_id),
    across(!any_of(c("region", "division", "municipality", "school_id", "school_name")), parse_number),
    region = as.factor(region),
    division = as.factor(division),
    municipality = as.factor(municipality),
    school_name = as.factor(school_name)
  )

rma_eosy_clean <- rma_eosy_raw |>
  mutate(across(everything(), str_squish)) |>
  mutate(
    school_id = as.character(school_id),
    across(!any_of(c("region", "division", "municipality", "school_id", "school_name")), parse_number),
    region = as.factor(region),
    division = as.factor(division),
    municipality = as.factor(municipality),
    school_name = as.factor(school_name)
  )

rma_bosy_missing_key <- rma_bosy_clean |>
  mutate(
    missing_school_id = is.na(school_id) | str_squish(school_id) == "" | str_to_upper(school_id) == "NA",
    missing_school_name = is.na(as.character(school_name)) | str_squish(as.character(school_name)) == "" | str_to_upper(as.character(school_name)) == "NA",
    missing_division = is.na(as.character(division)) | str_squish(as.character(division)) == "" | str_to_upper(as.character(division)) == "NA",
    missing_region = is.na(as.character(region)) | str_squish(as.character(region)) == "" | str_to_upper(as.character(region)) == "NA",
    has_missing_key_school_field = missing_school_id | missing_school_name | missing_division | missing_region
  ) |>
  filter(has_missing_key_school_field)

rma_eosy_missing_key <- rma_eosy_clean |>
  mutate(
    missing_school_id = is.na(school_id) | str_squish(school_id) == "" | str_to_upper(school_id) == "NA",
    missing_school_name = is.na(as.character(school_name)) | str_squish(as.character(school_name)) == "" | str_to_upper(as.character(school_name)) == "NA",
    missing_division = is.na(as.character(division)) | str_squish(as.character(division)) == "" | str_to_upper(as.character(division)) == "NA",
    missing_region = is.na(as.character(region)) | str_squish(as.character(region)) == "" | str_to_upper(as.character(region)) == "NA",
    has_missing_key_school_field = missing_school_id | missing_school_name | missing_division | missing_region
  ) |>
  filter(has_missing_key_school_field)

rma_bosy_main <- rma_bosy_clean |>
  anti_join(rma_bosy_missing_key |> select(school_id), by = "school_id")

rma_eosy_main <- rma_eosy_clean |>
  anti_join(rma_eosy_missing_key |> select(school_id), by = "school_id")

rma_cleaning_summary <- tibble(
  dataset = c("RMA BoSY", "RMA EoSY"),
  raw_rows = c(nrow(rma_bosy_raw), nrow(rma_eosy_raw)),
  rows_missing_key_school_fields = c(nrow(rma_bosy_missing_key), nrow(rma_eosy_missing_key)),
  rows_kept_for_merging = c(nrow(rma_bosy_main), nrow(rma_eosy_main)),
  unique_school_ids_kept = c(n_distinct(rma_bosy_main$school_id), n_distinct(rma_eosy_main$school_id))
)

rma_bosy_duplicate_school_ids <- rma_bosy_main |>
  count(school_id, name = "rows_with_same_school_id") |>
  filter(rows_with_same_school_id > 1)

rma_eosy_duplicate_school_ids <- rma_eosy_main |>
  count(school_id, name = "rows_with_same_school_id") |>
  filter(rows_with_same_school_id > 1)

write_rds(rma_bosy_main, file.path(processed_dir, "rma_bosy_clean.rds"))
write_rds(rma_eosy_main, file.path(processed_dir, "rma_eosy_clean.rds"))
write_csv(rma_bosy_main, file.path(processed_dir, "rma_bosy_clean.csv"))
write_csv(rma_eosy_main, file.path(processed_dir, "rma_eosy_clean.csv"))
write_csv(rma_bosy_missing_key, file.path(validation_na_dir, "rma_bosy_rows_missing_key_school_fields.csv"))
write_csv(rma_eosy_missing_key, file.path(validation_na_dir, "rma_eosy_rows_missing_key_school_fields.csv"))
write_csv(rma_cleaning_summary, file.path(tables_dir, "rma_cleaning_summary.csv"))
write_csv(rma_bosy_duplicate_school_ids, file.path(tables_dir, "rma_bosy_duplicate_school_ids.csv"))
write_csv(rma_eosy_duplicate_school_ids, file.path(tables_dir, "rma_eosy_duplicate_school_ids.csv"))
