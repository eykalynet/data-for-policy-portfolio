# 10_create_final_percentage_dataset.R
# Create a final school-level dataset with score percentages and validation checks.

source("scripts/00_setup.R")

dlp_clean <- read_rds(file.path(processed_dir, "dlp_randomization_clean.rds"))

philiri_scores_long <- read_csv(
  file.path(tables_dir, "philiri_school_level_scores_long.csv"),
  show_col_types = FALSE
)

philiri_discrepancy_checks <- read_csv(
  file.path(tables_dir, "philiri_school_level_discrepancy_checks.csv"),
  show_col_types = FALSE
)

rma_scores_long <- read_csv(
  file.path(tables_dir, "rma_school_level_scores_long.csv"),
  show_col_types = FALSE
)

rma_discrepancy_checks <- read_csv(
  file.path(tables_dir, "rma_school_level_discrepancy_checks.csv"),
  show_col_types = FALSE
)

school_base <- dlp_clean %>%
  transmute(
    beis_school_id = as.character(beis_school_id),
    randomized_eval_id = as.character(randomized_eval_id),
    rev_status = as.character(rev_status)
  )

philiri_percentage_wide <- philiri_scores_long %>%
  filter(is_in_dlp_randomization_file) %>%
  mutate(
    school_id = as.character(school_id),
    time_point_label = case_when(
      time_point == "BoSY" ~ "bosy",
      time_point == "EoSY" ~ "eosy",
      TRUE ~ str_to_lower(time_point)
    ),
    grade_label = str_to_lower(str_replace_all(grade, " ", "_")),
    level_group_label = str_replace_all(level_group, "-", ""),
    reading_category_label = str_replace_all(reading_category, " ", "_"),
    percentage_variable = paste(
      "philiri",
      time_point_label,
      grade_label,
      level_group_label,
      reading_category_label,
      "pct_eng_assessed",
      sep = "_"
    )
  ) %>%
  select(school_id, percentage_variable, percent_of_english_assessed) %>%
  pivot_wider(
    names_from = percentage_variable,
    values_from = percent_of_english_assessed
  )

philiri_check_wide <- philiri_discrepancy_checks %>%
  mutate(
    school_id = as.character(school_id),
    time_point_label = case_when(
      time_point == "BoSY" ~ "bosy",
      time_point == "EoSY" ~ "eosy",
      TRUE ~ str_to_lower(time_point)
    ),
    grade_label = str_to_lower(str_replace_all(grade, " ", "_")),
    level_group_label = str_replace_all(level_group, "-", ""),
    english_assessed_variable = paste(
      "philiri",
      time_point_label,
      grade_label,
      level_group_label,
      "eng_assessed",
      sep = "_"
    ),
    summed_count_variable = paste(
      "philiri",
      time_point_label,
      grade_label,
      level_group_label,
      "summed_category_count",
      sep = "_"
    ),
    discrepancy_count_variable = paste(
      "philiri",
      time_point_label,
      grade_label,
      level_group_label,
      "discrepancy_count",
      sep = "_"
    ),
    discrepancy_flag_variable = paste(
      "philiri",
      time_point_label,
      grade_label,
      level_group_label,
      "has_discrepancy",
      sep = "_"
    )
  )

philiri_eng_assessed_wide <- philiri_check_wide %>%
  select(school_id, english_assessed_variable, english_assessed) %>%
  pivot_wider(
    names_from = english_assessed_variable,
    values_from = english_assessed
  )

philiri_summed_count_wide <- philiri_check_wide %>%
  select(school_id, summed_count_variable, summed_category_count) %>%
  pivot_wider(
    names_from = summed_count_variable,
    values_from = summed_category_count
  )

philiri_discrepancy_count_wide <- philiri_check_wide %>%
  select(school_id, discrepancy_count_variable, discrepancy_count) %>%
  pivot_wider(
    names_from = discrepancy_count_variable,
    values_from = discrepancy_count
  )

philiri_discrepancy_flag_wide <- philiri_check_wide %>%
  select(school_id, discrepancy_flag_variable, has_discrepancy) %>%
  pivot_wider(
    names_from = discrepancy_flag_variable,
    values_from = has_discrepancy
  )

rma_percentage_wide <- rma_scores_long %>%
  filter(is_in_dlp_randomization_file) %>%
  mutate(
    school_id = as.character(school_id),
    time_point_label = case_when(
      time_point == "BoSY" ~ "bosy",
      time_point == "EoSY" ~ "eosy",
      TRUE ~ str_to_lower(time_point)
    ),
    grade_label = str_to_lower(str_replace_all(grade, " ", "_")),
    proficiency_group_label = str_replace_all(proficiency_group, " ", "_"),
    percentage_variable = paste(
      "rma",
      time_point_label,
      grade_label,
      proficiency_group_label,
      "pct_assessed",
      sep = "_"
    )
  ) %>%
  select(school_id, percentage_variable, percent_of_assessed) %>%
  pivot_wider(
    names_from = percentage_variable,
    values_from = percent_of_assessed
  )

rma_check_wide <- rma_discrepancy_checks %>%
  mutate(
    school_id = as.character(school_id),
    time_point_label = case_when(
      time_point == "BoSY" ~ "bosy",
      time_point == "EoSY" ~ "eosy",
      TRUE ~ str_to_lower(time_point)
    ),
    grade_label = str_to_lower(str_replace_all(grade, " ", "_")),
    assessed_variable = paste(
      "rma",
      time_point_label,
      grade_label,
      "assessed",
      sep = "_"
    ),
    summed_count_variable = paste(
      "rma",
      time_point_label,
      grade_label,
      "summed_proficiency_count",
      sep = "_"
    ),
    discrepancy_count_variable = paste(
      "rma",
      time_point_label,
      grade_label,
      "discrepancy_count",
      sep = "_"
    ),
    discrepancy_flag_variable = paste(
      "rma",
      time_point_label,
      grade_label,
      "has_discrepancy",
      sep = "_"
    )
  )

rma_assessed_wide <- rma_check_wide %>%
  select(school_id, assessed_variable, assessed_count) %>%
  pivot_wider(
    names_from = assessed_variable,
    values_from = assessed_count
  )

rma_summed_count_wide <- rma_check_wide %>%
  select(school_id, summed_count_variable, summed_proficiency_count) %>%
  pivot_wider(
    names_from = summed_count_variable,
    values_from = summed_proficiency_count
  )

rma_discrepancy_count_wide <- rma_check_wide %>%
  select(school_id, discrepancy_count_variable, discrepancy_count) %>%
  pivot_wider(
    names_from = discrepancy_count_variable,
    values_from = discrepancy_count
  )

rma_discrepancy_flag_wide <- rma_check_wide %>%
  select(school_id, discrepancy_flag_variable, has_discrepancy) %>%
  pivot_wider(
    names_from = discrepancy_flag_variable,
    values_from = has_discrepancy
  )

final_percentage_dataset <- school_base %>%
  left_join(philiri_percentage_wide, by = c("beis_school_id" = "school_id")) %>%
  left_join(philiri_eng_assessed_wide, by = c("beis_school_id" = "school_id")) %>%
  left_join(philiri_summed_count_wide, by = c("beis_school_id" = "school_id")) %>%
  left_join(philiri_discrepancy_count_wide, by = c("beis_school_id" = "school_id")) %>%
  left_join(philiri_discrepancy_flag_wide, by = c("beis_school_id" = "school_id")) %>%
  left_join(rma_percentage_wide, by = c("beis_school_id" = "school_id")) %>%
  left_join(rma_assessed_wide, by = c("beis_school_id" = "school_id")) %>%
  left_join(rma_summed_count_wide, by = c("beis_school_id" = "school_id")) %>%
  left_join(rma_discrepancy_count_wide, by = c("beis_school_id" = "school_id")) %>%
  left_join(rma_discrepancy_flag_wide, by = c("beis_school_id" = "school_id"))

final_percentage_codebook <- tibble(
  variable_name = names(final_percentage_dataset)
) %>%
  mutate(
    variable_type = case_when(
      variable_name %in% c("beis_school_id", "randomized_eval_id", "rev_status") ~ "school identifier or evaluation metadata",
      str_detect(variable_name, "^philiri_.*_pct_eng_assessed$") ~ "Phil-IRI percentage score",
      str_detect(variable_name, "^philiri_.*_eng_assessed$") ~ "Phil-IRI denominator",
      str_detect(variable_name, "^philiri_.*_summed_category_count$") ~ "Phil-IRI summed category count",
      str_detect(variable_name, "^philiri_.*_discrepancy_count$") ~ "Phil-IRI discrepancy count",
      str_detect(variable_name, "^philiri_.*_has_discrepancy$") ~ "Phil-IRI discrepancy flag",
      str_detect(variable_name, "^rma_.*_pct_assessed$") ~ "RMA percentage score",
      str_detect(variable_name, "^rma_.*_assessed$") ~ "RMA denominator",
      str_detect(variable_name, "^rma_.*_summed_proficiency_count$") ~ "RMA summed proficiency count",
      str_detect(variable_name, "^rma_.*_discrepancy_count$") ~ "RMA discrepancy count",
      str_detect(variable_name, "^rma_.*_has_discrepancy$") ~ "RMA discrepancy flag",
      TRUE ~ "other"
    ),
    description = case_when(
      variable_name == "beis_school_id" ~ "BEIS school ID. Main school-level merge key from the DLP school dataset.",
      variable_name == "randomized_eval_id" ~ "Evaluation ID from the DLP randomized schools evaluation file.",
      variable_name == "rev_status" ~ "Randomization evaluation status from the DLP randomized schools evaluation file. This indicates whether the school is in the control group or not.",
      str_detect(variable_name, "^philiri_.*_pct_eng_assessed$") ~ "Phil-IRI percentage score against English assessed count. EoSY independent is treated as comparable to BoSY grade_ready based on project guidance.",
      str_detect(variable_name, "^philiri_.*_eng_assessed$") ~ "Phil-IRI English assessed count used as denominator for the percentage and comparison checks.",
      str_detect(variable_name, "^philiri_.*_summed_category_count$") ~ "Sum of Phil-IRI category counts for the school, grade, time point, and 2-level or 3-level grouping.",
      str_detect(variable_name, "^philiri_.*_discrepancy_count$") ~ "Difference between summed Phil-IRI category count and English assessed count.",
      str_detect(variable_name, "^philiri_.*_has_discrepancy$") ~ "TRUE when summed Phil-IRI category count does not equal English assessed count.",
      str_detect(variable_name, "^rma_.*_pct_assessed$") ~ "RMA percentage score against assessed count for the school, grade, time point, and proficiency group.",
      str_detect(variable_name, "^rma_.*_assessed$") ~ "RMA assessed count used as denominator for percentage and comparison checks.",
      str_detect(variable_name, "^rma_.*_summed_proficiency_count$") ~ "Sum of RMA proficiency counts for the school, grade, and time point.",
      str_detect(variable_name, "^rma_.*_discrepancy_count$") ~ "Difference between summed RMA proficiency count and assessed count.",
      str_detect(variable_name, "^rma_.*_has_discrepancy$") ~ "TRUE when summed RMA proficiency count does not equal assessed count.",
      TRUE ~ "Variable included for identifying or documenting the school-level record."
    )
  )

write_csv(final_percentage_dataset, file.path(processed_dir, "final_school_percentage_dataset.csv"), quote = "all")
write_rds(final_percentage_dataset, file.path(processed_dir, "final_school_percentage_dataset.rds"))
write_csv(final_percentage_codebook, file.path(processed_dir, "final_school_percentage_dataset_codebook.csv"), quote = "all")
