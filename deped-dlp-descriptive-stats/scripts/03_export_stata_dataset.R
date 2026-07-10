################################################################################
## TITLE   : 03_export_stata_dataset.R
## PURPOSE : Export the school-level file for Stata tables and figures.
## PROJECT : Dynamic Learning Program descriptive results
## AUTHOR  : Erika Salvador
## DATE    : June 11, 2026
################################################################################

source("scripts/00_setup.R")

# Load the full merged data and percentage fields created in prior scripts.
school_level_full <- read_csv(
  file.path(data_dir, "01_dlp_rma_philiri_school_level_full.csv"),
  col_types = cols(.default = col_guess()),
  show_col_types = FALSE
) |>
  mutate(
    beis_school_id = as.character(beis_school_id),
    randomized_eval_id = as.character(randomized_eval_id),
    rev_status = as.character(rev_status),
    region_code = as.character(region_code),
    division_code = as.character(division_code),
    municipality_code = as.character(municipality_code),
    full_division_code = as.character(full_division_code),
    full_municipality_code = as.character(full_municipality_code)
  )

percentage_dataset <- read_csv(
  file.path(data_dir, "02_dlp_rma_philiri_school_level_percentages.csv"),
  col_types = cols(.default = col_guess()),
  show_col_types = FALSE
) |>
  mutate(
    beis_school_id = as.character(beis_school_id),
    randomized_eval_id = as.character(randomized_eval_id),
    rev_status = as.character(rev_status),
    region_code = as.character(region_code),
    division_code = as.character(division_code),
    municipality_code = as.character(municipality_code),
    full_division_code = as.character(full_division_code),
    full_municipality_code = as.character(full_municipality_code)
  )

# Keep fields, derive assignment/compliance, and keep names Stata-safe.
stata_dataset <- school_level_full |>
  select(
    beis_school_id,
    randomized_eval_id,
    rev_status,
    region_code,
    division_code,
    municipality_code,
    full_division_code,
    full_municipality_code,
    starts_with("pilot_"),
    starts_with("enroll_"),
    matches("^(philiri|rma)_(bosy|eosy)_.*_(assessed|total_assessed)$"),
    contains("total_enrolled")
  ) |>
  left_join(
    percentage_dataset |>
      select(beis_school_id, ends_with("_pct_eng_assessed"), ends_with("_pct_assessed")),
    by = "beis_school_id"
  ) |>
  mutate(
    assignment_flag_count = coalesce(pilot_cancel, 0) + coalesce(pilot_ratio, 0) + coalesce(pilot_shift, 0),
    assignment_group = case_when(
      assignment_flag_count == 0 ~ "control",
      pilot_ratio == 1 & assignment_flag_count == 1 ~ "mainstream",
      pilot_shift == 1 & assignment_flag_count == 1 ~ "shifting",
      pilot_cancel == 1 & assignment_flag_count == 1 ~ "emergency",
      assignment_flag_count > 1 ~ "multiple_assignment_flags",
      TRUE ~ "missing_assignment"
    ),
    treatment_status = case_when(
      rev_status == "0" ~ "Control",
      rev_status == "1" ~ "Treatment",
      is.na(rev_status) ~ "Missing Evaluation Status",
      TRUE ~ paste("Other Status:", rev_status)
    ),
    compliance = case_when(
      assignment_group == "control" & rev_status == "0" ~ 1,
      assignment_group %in% c("mainstream", "shifting", "emergency") & rev_status == "1" ~ 1,
      !is.na(rev_status) ~ 0,
      TRUE ~ NA_real_
    )
  )

# Shorten generated variable names to stay under Stata's 32-character limit.
names(stata_dataset) <- names(stata_dataset) |>
  str_replace_all("^philiri_", "ph_") |>
  str_replace_all("^rma_", "rma_") |>
  str_replace_all("_bosy_", "_b_") |>
  str_replace_all("_eosy_", "_e_") |>
  str_replace_all("_grade_", "_g") |>
  str_replace_all("_2level_", "_l2_") |>
  str_replace_all("_3level_", "_l3_") |>
  str_replace_all("_frustration_", "_frust_") |>
  str_replace_all("_instructional_", "_instr_") |>
  str_replace_all("_independent_", "_indep_") |>
  str_replace_all("_grade_ready_", "_ready_") |>
  str_replace_all("_not_proficient_", "_not_") |>
  str_replace_all("_low_proficient_", "_low_") |>
  str_replace_all("_nearly_proficient_", "_near_") |>
  str_replace_all("_high_proficient_", "_high_") |>
  str_replace_all("_proficient_", "_prof_") |>
  str_replace_all("_pct_eng_assessed$", "_pct") |>
  str_replace_all("_pct_assessed$", "_pct") |>
  str_replace_all("_total_enrolled_g7_g10$", "_enrolled") |>
  str_replace_all("_total_enrolled$", "_enrolled")

too_long_for_stata <- names(stata_dataset)[nchar(names(stata_dataset)) > 32]
if (length(too_long_for_stata) > 0) {
  stop(
    "These variables are still too long for Stata: ",
    paste(too_long_for_stata, collapse = ", ")
  )
}

write_dta(
  stata_dataset,
  file.path(data_dir, "03_dlp_rma_philiri_school_level_for_stata.dta")
)

write_csv(
  stata_dataset,
  file.path(data_dir, "03_dlp_rma_philiri_school_level_for_stata.csv")
)
