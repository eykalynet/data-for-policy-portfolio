################################################################################
## TITLE   : 02_create_scores_and_checks.R
## PURPOSE : Create Phil-IRI and RMA long files, percentages, and score checks.
## PROJECT : Dynamic Learning Program descriptive results
## AUTHOR  : Erika Salvador
## DATE    : June 11, 2026
################################################################################

source("scripts/00_setup.R")

# Start from the merged randomized-school file.
school_level_full <- read_csv(
  file.path(data_dir, "01_dlp_rma_philiri_school_level_full.csv"),
  col_types = cols(.default = col_guess()),
  show_col_types = FALSE
) |>
  mutate(
    beis_school_id = as.character(beis_school_id),
    randomized_eval_id = as.character(randomized_eval_id),
    rev_status = as.character(rev_status),
    treatment_status = case_when(
      rev_status == "0" ~ "Control",
      rev_status == "1" ~ "Treatment",
      is.na(rev_status) ~ "Missing Evaluation Status",
      TRUE ~ paste("Other Status:", rev_status)
    )
  )

grades <- c("7", "8", "9", "10")

# Phil-IRI uses BoSY 2-level and 3-level grouping fields. EoSY has one set of
# reading categories; independent is later used as a grade-ready proxy in figures.
make_philiri_scores <- function(data, time_point) {
  prefix <- paste0("philiri_", str_to_lower(time_point))

  if (time_point == "BoSY") {
    map_dfr(grades, function(grade_number) {
      assessed_var <- paste0(prefix, "_g", grade_number, "_eng_assessed")
      category_vars <- c(
        paste0(prefix, "_g", grade_number, "_eng_frustration_2level"),
        paste0(prefix, "_g", grade_number, "_eng_instructional_2level"),
        paste0(prefix, "_g", grade_number, "_eng_independent_2level"),
        paste0(prefix, "_g", grade_number, "_eng_frustration_3level"),
        paste0(prefix, "_g", grade_number, "_eng_instructional_3level"),
        paste0(prefix, "_g", grade_number, "_eng_independent_3level")
      )
      level_groups <- c("2-level", "2-level", "2-level", "3-level", "3-level", "3-level")
      reading_categories <- c("frustration", "instructional", "independent", "frustration", "instructional", "independent")

      map2_dfr(category_vars, seq_along(category_vars), function(category_var, index_number) {
        tibble(
          school_id = data$beis_school_id,
          region_code = data$region_code,
          full_division_code = data$full_division_code,
          full_municipality_code = data$full_municipality_code,
          treatment_status = data$treatment_status,
          time_point = time_point,
          grade = paste("Grade", grade_number),
          level_group = level_groups[index_number],
          reading_category = reading_categories[index_number],
          student_count = data[[category_var]],
          english_assessed = data[[assessed_var]]
        )
      })
    })
  } else {
    map_dfr(grades, function(grade_number) {
      assessed_var <- paste0(prefix, "_g", grade_number, "_eng_assessed")
      category_vars <- c(
        paste0(prefix, "_g", grade_number, "_eng_frustration"),
        paste0(prefix, "_g", grade_number, "_eng_instructional"),
        paste0(prefix, "_g", grade_number, "_eng_independent")
      )
      reading_categories <- c("frustration", "instructional", "independent")

      map2_dfr(category_vars, reading_categories, function(category_var, reading_category_name) {
        tibble(
          school_id = data$beis_school_id,
          region_code = data$region_code,
          full_division_code = data$full_division_code,
          full_municipality_code = data$full_municipality_code,
          treatment_status = data$treatment_status,
          time_point = time_point,
          grade = paste("Grade", grade_number),
          level_group = "eosy",
          reading_category = reading_category_name,
          student_count = data[[category_var]],
          english_assessed = data[[assessed_var]]
        )
      })
    })
  }
}

# Stack Phil-IRI category counts for grade-level summaries and checks.
philiri_scores_long <- bind_rows(
  make_philiri_scores(school_level_full, "BoSY"),
  make_philiri_scores(school_level_full, "EoSY")
) |>
  mutate(
    percent_of_english_assessed = if_else(
      english_assessed > 0,
      100 * student_count / english_assessed,
      NA_real_
    )
  )

# Check whether grouped category counts reconcile with assessed counts.
philiri_score_checks <- philiri_scores_long |>
  group_by(school_id, time_point, grade, level_group, english_assessed) |>
  summarise(
    summed_category_count = sum(student_count, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    discrepancy_count = summed_category_count - english_assessed,
    has_discrepancy = is.na(english_assessed) | summed_category_count != english_assessed
  )

write_csv(philiri_scores_long, file.path(tables_dir, "02_philiri_scores_long.csv"))
write_csv(philiri_score_checks, file.path(tables_dir, "02_philiri_score_checks.csv"))

# RMA proficiency counts are mapped to proficiency labels.
make_rma_scores <- function(data, time_point) {
  prefix <- paste0("rma_", str_to_lower(time_point))
  proficiency_map <- tibble(
    rma_measure = c(
      "emerging_not_proficient",
      "emerging_low_proficient",
      "developing_nearly_proficient",
      "transitioning_proficient",
      "at_grade_level_highly_proficient"
    ),
    proficiency_group = c(
      "not proficient",
      "low proficient",
      "nearly proficient",
      "proficient",
      "high proficient"
    )
  )

  map_dfr(grades, function(grade_number) {
    assessed_var <- paste0(prefix, "_g", grade_number, "_assessed")

    map2_dfr(proficiency_map$rma_measure, proficiency_map$proficiency_group, function(measure_name, proficiency_name) {
      count_var <- paste0(prefix, "_g", grade_number, "_", measure_name)
      tibble(
        school_id = data$beis_school_id,
        region_code = data$region_code,
        full_division_code = data$full_division_code,
        full_municipality_code = data$full_municipality_code,
        treatment_status = data$treatment_status,
        time_point = time_point,
        grade = paste("Grade", grade_number),
        proficiency_group = proficiency_name,
        student_count = data[[count_var]],
        assessed_count = data[[assessed_var]]
      )
    })
  })
}

rma_scores_long <- bind_rows(
  make_rma_scores(school_level_full, "BoSY"),
  make_rma_scores(school_level_full, "EoSY")
) |>
  mutate(
    percent_of_assessed = if_else(
      assessed_count > 0,
      100 * student_count / assessed_count,
      NA_real_
    )
  )

# Check whether RMA proficiency counts reconcile with assessed counts.
rma_score_checks <- rma_scores_long |>
  group_by(school_id, time_point, grade, assessed_count) |>
  summarise(
    summed_proficiency_count = sum(student_count, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    discrepancy_count = summed_proficiency_count - assessed_count,
    has_discrepancy = is.na(assessed_count) | summed_proficiency_count != assessed_count
  )

write_csv(rma_scores_long, file.path(tables_dir, "02_rma_scores_long.csv"))
write_csv(rma_score_checks, file.path(tables_dir, "02_rma_score_checks.csv"))

# Build wide percentage fields
philiri_percentage_wide <- philiri_scores_long |>
  mutate(
    time_label = str_to_lower(time_point),
    grade_label = str_to_lower(str_replace_all(grade, " ", "_")),
    level_label = str_replace_all(level_group, "-", ""),
    reading_label = str_replace_all(reading_category, " ", "_"),
    variable_name = paste(
      "philiri",
      time_label,
      grade_label,
      level_label,
      reading_label,
      "pct_eng_assessed",
      sep = "_"
    )
  ) |>
  select(school_id, variable_name, percent_of_english_assessed) |>
  pivot_wider(names_from = variable_name, values_from = percent_of_english_assessed)

rma_percentage_wide <- rma_scores_long |>
  mutate(
    time_label = str_to_lower(time_point),
    grade_label = str_to_lower(str_replace_all(grade, " ", "_")),
    proficiency_label = str_replace_all(proficiency_group, " ", "_"),
    variable_name = paste(
      "rma",
      time_label,
      grade_label,
      proficiency_label,
      "pct_assessed",
      sep = "_"
    )
  ) |>
  select(school_id, variable_name, percent_of_assessed) |>
  pivot_wider(names_from = variable_name, values_from = percent_of_assessed)

# Add total assessed counts across Grades 7 to 10 for each assessment period.
assessed_summary_wide <- school_level_full |>
  transmute(
    beis_school_id,
    philiri_bosy_total_assessed = rowSums(across(matches("^philiri_bosy_g(7|8|9|10)_eng_assessed$")), na.rm = TRUE),
    philiri_eosy_total_assessed = rowSums(across(matches("^philiri_eosy_g(7|8|9|10)_eng_assessed$")), na.rm = TRUE),
    rma_bosy_total_assessed_calc = rowSums(across(matches("^rma_bosy_g(7|8|9|10)_assessed$")), na.rm = TRUE),
    rma_eosy_total_assessed_calc = rowSums(across(matches("^rma_eosy_g(7|8|9|10)_assessed$")), na.rm = TRUE)
  )

percentage_dataset <- school_level_full |>
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
    starts_with("enroll_")
  ) |>
  left_join(assessed_summary_wide, by = "beis_school_id") |>
  left_join(philiri_percentage_wide, by = c("beis_school_id" = "school_id")) |>
  left_join(rma_percentage_wide, by = c("beis_school_id" = "school_id"))

write_csv(
  percentage_dataset,
  file.path(data_dir, "02_dlp_rma_philiri_school_level_percentages.csv")
)
