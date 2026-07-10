################################################################################
## TITLE   : 01_clean_merge_data.R
## PURPOSE : Clean raw DLP, Phil-IRI, and RMA files and merge to school level.
## PROJECT : Dynamic Learning Program descriptive results
## AUTHOR  : Erika Salvador
## DATE    : June 11, 2026
################################################################################

source("scripts/00_setup.R")

# Locate expected raw files. Assessment files are matched by assessment type and
# school-year period so minor filename spacing differences do not break the run.
dlp_file <- file.path(raw_dir, "Final_DLP_Dataset_for_Randomization.csv")
dlp_eval_file <- file.path(raw_dir, "DLP_randomized_schools_eval.csv")
philiri_bosy_file <- list.files(raw_dir, pattern = "Phil-IRI.*BoSY.*\\.csv$", full.names = TRUE)
philiri_eosy_file <- list.files(raw_dir, pattern = "Phil-IRI.*EoSY.*\\.csv$", full.names = TRUE)
rma_bosy_file <- list.files(raw_dir, pattern = "RMA.*BoSY.*\\.csv$", full.names = TRUE)
rma_eosy_file <- list.files(raw_dir, pattern = "RMA.*EoSY.*\\.csv$", full.names = TRUE)

dlp_raw <- read_raw_csv(dlp_file)
dlp_eval_raw <- read_raw_csv(dlp_eval_file)
philiri_bosy_raw <- read_raw_csv(philiri_bosy_file)
philiri_eosy_raw <- read_raw_csv(philiri_eosy_file)
rma_bosy_raw <- read_raw_csv(rma_bosy_file)
rma_eosy_raw <- read_raw_csv(rma_eosy_file)

is_missing_key <- function(x) {
  is.na(x) | str_squish(as.character(x)) == "" | str_to_upper(str_squish(as.character(x))) == "NA"
}

# Use the randomized schools file as the base. The bigger DLP file only adds
# school details, so the final data stays limited to randomized schools.
clean_dlp <- function(dlp_raw, dlp_eval_raw) {
  dlp_clean <- dlp_raw |>
    rename(row_number_from_source_file = any_of("x1")) |>
    mutate(
      across(
        any_of(c(
          "beis_school_id",
          "region_code",
          "division_code",
          "municipality_code",
          "full_division_code",
          "full_municipality_code"
        )),
        as.character
      )
    )

  dlp_eval_clean <- dlp_eval_raw |>
    mutate(
      beis_school_id = as.character(beis_school_id),
      randomized_eval_id = as.character(id),
      rev_status = as.character(rev_status),
      across(
        any_of(c(
          "region_code",
          "division_code",
          "municipality_code",
          "full_division_code",
          "full_municipality_code"
        )),
        as.character
      )
    ) |>
    select(
      beis_school_id,
      randomized_eval_id,
      rev_status,
      region_code,
      division_code,
      municipality_code,
      full_division_code,
      full_municipality_code
    )

  dlp_covariates <- dlp_clean |>
    select(
      -any_of(c(
        "region_code",
        "division_code",
        "municipality_code",
        "full_division_code",
        "full_municipality_code"
      ))
    )

  dlp_joined <- dlp_eval_clean |>
    left_join(dlp_covariates, by = "beis_school_id") |>
    mutate(
      across(
        matches("enroll|dropout|room|classroom|seat|toilet|computer|teacher|cancel|pilot"),
        parse_number
      )
    )

  dlp_with_flags <- dlp_joined |>
    mutate(
      missing_beis_school_id = is_missing_key(beis_school_id),
      missing_region_code = is_missing_key(region_code),
      missing_division_code = is_missing_key(division_code),
      missing_full_division_code = is_missing_key(full_division_code),
      has_missing_key_school_field = missing_beis_school_id |
        missing_region_code |
        missing_division_code |
        missing_full_division_code
    )

  list(
    main = dlp_with_flags |>
      filter(!has_missing_key_school_field) |>
      select(
        -missing_beis_school_id,
        -missing_region_code,
        -missing_division_code,
        -missing_full_division_code,
        -has_missing_key_school_field
    ),
    missing = dlp_with_flags |>
      filter(has_missing_key_school_field) |>
      mutate(source_dataset = "DLP randomized schools evaluation")
  )
}

# Standardize assessment files and separate rows with unusable school keys.
clean_assessment <- function(raw_data, dataset_name, geography_type) {
  id_cols <- if (geography_type == "district") {
    c("region", "division", "district", "school_id", "school_name")
  } else {
    c("region", "division", "municipality", "school_id", "school_name")
  }

  cleaned <- raw_data |>
    mutate(
      school_id = as.character(school_id),
      across(!any_of(id_cols), parse_number)
    )

  missing <- cleaned |>
    mutate(
      missing_school_id = is_missing_key(school_id),
      missing_school_name = is_missing_key(school_name),
      missing_division = is_missing_key(division),
      missing_region = is_missing_key(region),
      has_missing_key_school_field = missing_school_id |
        missing_school_name |
        missing_division |
        missing_region
    ) |>
    filter(has_missing_key_school_field) |>
    mutate(source_dataset = dataset_name)

  main <- cleaned |>
    anti_join(missing |> select(school_id), by = "school_id")

  list(main = main, missing = missing)
}

dlp <- clean_dlp(dlp_raw, dlp_eval_raw)
philiri_bosy <- clean_assessment(philiri_bosy_raw, "Phil-IRI BoSY", "district")
philiri_eosy <- clean_assessment(philiri_eosy_raw, "Phil-IRI EoSY", "district")
rma_bosy <- clean_assessment(rma_bosy_raw, "RMA BoSY", "municipality")
rma_eosy <- clean_assessment(rma_eosy_raw, "RMA EoSY", "municipality")

# Save excluded rows so they can be checked later.
missing_key_rows <- bind_rows(
  dlp$missing |> mutate(across(everything(), as.character)),
  philiri_bosy$missing |> mutate(across(everything(), as.character)),
  philiri_eosy$missing |> mutate(across(everything(), as.character)),
  rma_bosy$missing |> mutate(across(everything(), as.character)),
  rma_eosy$missing |> mutate(across(everything(), as.character))
)

write_csv(
  missing_key_rows,
  file.path(validation_na_dir, "01_schools_with_missing_key_fields.csv")
)

# Count matched and unmatched schools before merging the assessment data.
create_merge_diagnostic <- function(dlp_data, assessment_data, dataset_name) {
  tibble(
    dataset = dataset_name,
    merge_key = "DLP beis_school_id = assessment school_id",
    dlp_rows = nrow(dlp_data),
    assessment_rows = nrow(assessment_data),
    matched_records = nrow(inner_join(dlp_data, assessment_data, by = c("beis_school_id" = "school_id"))),
    unmatched_records_from_dlp = nrow(anti_join(dlp_data, assessment_data, by = c("beis_school_id" = "school_id"))),
    unmatched_records_from_assessment = nrow(anti_join(assessment_data, dlp_data, by = c("school_id" = "beis_school_id")))
  )
}

merge_diagnostics <- bind_rows(
  create_merge_diagnostic(dlp$main, philiri_bosy$main, "Phil-IRI BoSY"),
  create_merge_diagnostic(dlp$main, philiri_eosy$main, "Phil-IRI EoSY"),
  create_merge_diagnostic(dlp$main, rma_bosy$main, "RMA BoSY"),
  create_merge_diagnostic(dlp$main, rma_eosy$main, "RMA EoSY")
)

write_csv(merge_diagnostics, file.path(tables_dir, "01_merge_diagnostics.csv"))

philiri_bosy_for_merge <- philiri_bosy$main |>
  rename_with(~ paste0("philiri_bosy_", .x), -school_id)

philiri_eosy_for_merge <- philiri_eosy$main |>
  rename_with(~ paste0("philiri_eosy_", .x), -school_id)

rma_bosy_for_merge <- rma_bosy$main |>
  rename_with(~ paste0("rma_bosy_", .x), -school_id)

rma_eosy_for_merge <- rma_eosy$main |>
  rename_with(~ paste0("rma_eosy_", .x), -school_id)

# Keep randomized schools and attach assessment records by BEIS ID.
school_level_full <- dlp$main |>
  left_join(philiri_bosy_for_merge, by = c("beis_school_id" = "school_id")) |>
  left_join(philiri_eosy_for_merge, by = c("beis_school_id" = "school_id")) |>
  left_join(rma_bosy_for_merge, by = c("beis_school_id" = "school_id")) |>
  left_join(rma_eosy_for_merge, by = c("beis_school_id" = "school_id"))

write_csv(
  school_level_full,
  file.path(data_dir, "01_dlp_rma_philiri_school_level_full.csv")
)
