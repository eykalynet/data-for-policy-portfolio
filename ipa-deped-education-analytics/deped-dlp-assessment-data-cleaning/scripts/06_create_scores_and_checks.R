# 06_create_scores_and_checks.R
# Create Phil-IRI and RMA percentages, summaries, and discrepancy checks.

source("scripts/00_setup.R")

dlp_clean <- read_rds(file.path(processed_dir, "dlp_randomization_clean.rds"))
philiri_bosy_clean <- read_rds(file.path(processed_dir, "philiri_bosy_clean.rds"))
philiri_eosy_clean <- read_rds(file.path(processed_dir, "philiri_eosy_clean.rds"))
rma_bosy_clean <- read_rds(file.path(processed_dir, "rma_bosy_clean.rds"))
rma_eosy_clean <- read_rds(file.path(processed_dir, "rma_eosy_clean.rds"))

# Phil-IRI BoSY has explicit 2-level and 3-level English columns.
philiri_bosy_long <- philiri_bosy_clean |>
  select(
    school_id,
    region,
    division,
    district,
    school_name,
    matches("^g(7|8|9|10)_eng_(assessed|grade_ready|frustration_2level|instructional_2level|independent_2level|frustration_3level|instructional_3level|independent_3level)$")
  ) |>
  pivot_longer(
    cols = matches("^g(7|8|9|10)_eng_"),
    names_to = c("grade", "philiri_measure"),
    names_pattern = "^g(7|8|9|10)_eng_(.*)$",
    values_to = "student_count"
  ) |>
  mutate(
    time_point = "BoSY",
    grade = paste0("Grade ", grade),
    level_group = case_when(
      str_detect(philiri_measure, "2level") ~ "2-level",
      str_detect(philiri_measure, "3level") ~ "3-level",
      philiri_measure == "assessed" ~ "assessed",
      TRUE ~ "other"
    ),
    reading_category = case_when(
      philiri_measure == "grade_ready" ~ "grade_ready",
      str_detect(philiri_measure, "frustration") ~ "frustration",
      str_detect(philiri_measure, "instructional") ~ "instructional",
      str_detect(philiri_measure, "independent") ~ "independent",
      philiri_measure == "assessed" ~ "english_assessed",
      TRUE ~ philiri_measure
    )
  )

philiri_bosy_assessed <- philiri_bosy_long |>
  filter(level_group == "assessed") |>
  select(school_id, grade, english_assessed = student_count)

philiri_bosy_level_scores <- philiri_bosy_long |>
  filter(level_group %in% c("2-level", "3-level")) |>
  left_join(philiri_bosy_assessed, by = c("school_id", "grade"))

philiri_bosy_grade_ready_2level <- philiri_bosy_long |>
  filter(reading_category == "grade_ready") |>
  mutate(level_group = "2-level") |>
  left_join(philiri_bosy_assessed, by = c("school_id", "grade"))

philiri_bosy_grade_ready_3level <- philiri_bosy_long |>
  filter(reading_category == "grade_ready") |>
  mutate(level_group = "3-level") |>
  left_join(philiri_bosy_assessed, by = c("school_id", "grade")) |>
  select(names(philiri_bosy_grade_ready_2level))

philiri_bosy_scores <- bind_rows(
  philiri_bosy_level_scores,
  philiri_bosy_grade_ready_2level,
  philiri_bosy_grade_ready_3level
) |>
  mutate(
    percent_of_english_assessed = case_when(
      english_assessed > 0 ~ 100 * student_count / english_assessed,
      TRUE ~ NA_real_
    )
  )

philiri_bosy_checks <- philiri_bosy_scores |>
  group_by(time_point, school_id, grade, level_group, english_assessed) |>
  summarise(
    summed_category_count = sum(student_count, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    discrepancy_count = summed_category_count - english_assessed,
    has_discrepancy = case_when(
      is.na(english_assessed) ~ TRUE,
      summed_category_count != english_assessed ~ TRUE,
      TRUE ~ FALSE
    )
  )

# Phil-IRI EoSY has one English frustration/instructional/independent set.
# Based on project guidance, EoSY frustration and instructional are comparable
# to the BoSY below-grade reading level categories, while EoSY independent is
# comparable to BoSY grade_ready.
# The EoSY counts are saved under both 2-level and 3-level group labels so
# downstream checks and graphs have the same shape as BoSY.
philiri_eosy_base_long <- philiri_eosy_clean |>
  select(
    school_id,
    region,
    division,
    district,
    school_name,
    matches("^g(7|8|9|10)_eng_(assessed|frustration|instructional|independent)$")
  ) |>
  pivot_longer(
    cols = matches("^g(7|8|9|10)_eng_"),
    names_to = c("grade", "philiri_measure"),
    names_pattern = "^g(7|8|9|10)_eng_(.*)$",
    values_to = "student_count"
  ) |>
  mutate(
    time_point = "EoSY",
    grade = paste0("Grade ", grade),
    reading_category = case_when(
      philiri_measure == "frustration" ~ "frustration",
      philiri_measure == "instructional" ~ "instructional",
      philiri_measure == "independent" ~ "grade_ready",
      philiri_measure == "assessed" ~ "english_assessed",
      TRUE ~ philiri_measure
    )
  )

philiri_eosy_assessed <- philiri_eosy_base_long |>
  filter(reading_category == "english_assessed") |>
  select(school_id, grade, english_assessed = student_count)

philiri_eosy_scores_2level <- philiri_eosy_base_long |>
  filter(reading_category != "english_assessed") |>
  mutate(level_group = "2-level")

philiri_eosy_scores_3level <- philiri_eosy_base_long |>
  filter(reading_category != "english_assessed") |>
  mutate(level_group = "3-level")

philiri_eosy_scores <- bind_rows(philiri_eosy_scores_2level, philiri_eosy_scores_3level) |>
  left_join(philiri_eosy_assessed, by = c("school_id", "grade")) |>
  mutate(
    percent_of_english_assessed = case_when(
      english_assessed > 0 ~ 100 * student_count / english_assessed,
      TRUE ~ NA_real_
    )
  )

philiri_eosy_checks <- philiri_eosy_scores |>
  group_by(time_point, school_id, grade, level_group, english_assessed) |>
  summarise(
    summed_category_count = sum(student_count, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    discrepancy_count = summed_category_count - english_assessed,
    has_discrepancy = case_when(
      is.na(english_assessed) ~ TRUE,
      summed_category_count != english_assessed ~ TRUE,
      TRUE ~ FALSE
    )
  )

philiri_scores_long <- bind_rows(philiri_bosy_scores, philiri_eosy_scores) |>
  mutate(is_in_dlp_randomization_file = school_id %in% dlp_clean$beis_school_id)

philiri_discrepancy_checks <- bind_rows(philiri_bosy_checks, philiri_eosy_checks) |>
  mutate(is_in_dlp_randomization_file = school_id %in% dlp_clean$beis_school_id)

philiri_assessed_coverage <- bind_rows(
  philiri_bosy_assessed |> mutate(time_point = "BoSY"),
  philiri_eosy_assessed |> mutate(time_point = "EoSY")
) |>
  mutate(is_in_dlp_randomization_file = school_id %in% dlp_clean$beis_school_id) |>
  group_by(time_point, grade) |>
  summarise(
    schools_with_assessed_count = sum(!is.na(english_assessed)),
    total_english_assessed = sum(english_assessed, na.rm = TRUE),
    .groups = "drop"
  )

philiri_level_distribution_summary <- philiri_scores_long |>
  group_by(time_point, grade, level_group, reading_category) |>
  summarise(
    total_student_count = sum(student_count, na.rm = TRUE),
    total_english_assessed = sum(english_assessed, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    percent_of_english_assessed = case_when(
      total_english_assessed > 0 ~ 100 * total_student_count / total_english_assessed,
      TRUE ~ NA_real_
    )
  )

philiri_discrepancy_summary <- philiri_discrepancy_checks |>
  group_by(time_point, grade, level_group) |>
  summarise(
    schools_checked = n(),
    schools_with_discrepancy = sum(has_discrepancy, na.rm = TRUE),
    .groups = "drop"
  )

# RMA proficiency percentages and discrepancy checks.
rma_bosy_long <- rma_bosy_clean |>
  select(
    school_id,
    region,
    division,
    municipality,
    school_name,
    matches("^g(7|8|9|10)_(assessed|emerging_not_proficient|emerging_low_proficient|developing_nearly_proficient|transitioning_proficient|at_grade_level_highly_proficient)$")
  ) |>
  pivot_longer(
    cols = matches("^g(7|8|9|10)_"),
    names_to = c("grade", "rma_measure"),
    names_pattern = "^g(7|8|9|10)_(.*)$",
    values_to = "student_count"
  ) |>
  mutate(
    time_point = "BoSY",
    grade = paste0("Grade ", grade),
    proficiency_group = case_when(
      rma_measure == "assessed" ~ "assessed",
      rma_measure == "emerging_not_proficient" ~ "not proficient",
      rma_measure == "emerging_low_proficient" ~ "low proficient",
      rma_measure == "developing_nearly_proficient" ~ "nearly proficient",
      rma_measure == "transitioning_proficient" ~ "proficient",
      rma_measure == "at_grade_level_highly_proficient" ~ "high proficient",
      TRUE ~ rma_measure
    )
  )

rma_eosy_long <- rma_eosy_clean |>
  select(
    school_id,
    region,
    division,
    municipality,
    school_name,
    matches("^g(7|8|9|10)_(assessed|emerging_not_proficient|emerging_low_proficient|developing_nearly_proficient|transitioning_proficient|at_grade_level_highly_proficient)$")
  ) |>
  pivot_longer(
    cols = matches("^g(7|8|9|10)_"),
    names_to = c("grade", "rma_measure"),
    names_pattern = "^g(7|8|9|10)_(.*)$",
    values_to = "student_count"
  ) |>
  mutate(
    time_point = "EoSY",
    grade = paste0("Grade ", grade),
    proficiency_group = case_when(
      rma_measure == "assessed" ~ "assessed",
      rma_measure == "emerging_not_proficient" ~ "not proficient",
      rma_measure == "emerging_low_proficient" ~ "low proficient",
      rma_measure == "developing_nearly_proficient" ~ "nearly proficient",
      rma_measure == "transitioning_proficient" ~ "proficient",
      rma_measure == "at_grade_level_highly_proficient" ~ "high proficient",
      TRUE ~ rma_measure
    )
  )

rma_long <- bind_rows(rma_bosy_long, rma_eosy_long)

rma_assessed <- rma_long |>
  filter(proficiency_group == "assessed") |>
  select(time_point, school_id, grade, assessed_count = student_count)

rma_scores_long <- rma_long |>
  filter(proficiency_group != "assessed") |>
  left_join(rma_assessed, by = c("time_point", "school_id", "grade")) |>
  mutate(
    is_in_dlp_randomization_file = school_id %in% dlp_clean$beis_school_id,
    percent_of_assessed = case_when(
      assessed_count > 0 ~ 100 * student_count / assessed_count,
      TRUE ~ NA_real_
    )
  )

rma_discrepancy_checks <- rma_scores_long |>
  group_by(time_point, school_id, grade, assessed_count) |>
  summarise(
    summed_proficiency_count = sum(student_count, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    discrepancy_count = summed_proficiency_count - assessed_count,
    has_discrepancy = case_when(
      is.na(assessed_count) ~ TRUE,
      summed_proficiency_count != assessed_count ~ TRUE,
      TRUE ~ FALSE
    ),
    is_in_dlp_randomization_file = school_id %in% dlp_clean$beis_school_id
  )

rma_distribution_summary <- rma_scores_long |>
  group_by(time_point, grade, proficiency_group) |>
  summarise(
    total_student_count = sum(student_count, na.rm = TRUE),
    total_assessed_count = sum(assessed_count, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    percent_of_assessed = case_when(
      total_assessed_count > 0 ~ 100 * total_student_count / total_assessed_count,
      TRUE ~ NA_real_
    )
  )

rma_discrepancy_summary <- rma_discrepancy_checks |>
  group_by(time_point, grade) |>
  summarise(
    schools_checked = n(),
    schools_with_discrepancy = sum(has_discrepancy, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(philiri_scores_long, file.path(tables_dir, "philiri_school_level_scores_long.csv"))
write_csv(philiri_discrepancy_checks, file.path(tables_dir, "philiri_school_level_discrepancy_checks.csv"))
write_csv(philiri_assessed_coverage, file.path(tables_dir, "philiri_assessed_coverage_by_grade.csv"))
write_csv(philiri_level_distribution_summary, file.path(tables_dir, "philiri_level_distribution_summary.csv"))
write_csv(philiri_discrepancy_summary, file.path(tables_dir, "philiri_discrepancy_summary.csv"))

write_csv(rma_scores_long, file.path(tables_dir, "rma_school_level_scores_long.csv"))
write_csv(rma_discrepancy_checks, file.path(tables_dir, "rma_school_level_discrepancy_checks.csv"))
write_csv(rma_distribution_summary, file.path(tables_dir, "rma_proficiency_distribution_summary.csv"))
write_csv(rma_discrepancy_summary, file.path(tables_dir, "rma_discrepancy_summary.csv"))

write_rds(philiri_scores_long, file.path(processed_dir, "philiri_school_level_scores_long.rds"))
write_rds(rma_scores_long, file.path(processed_dir, "rma_school_level_scores_long.rds"))
