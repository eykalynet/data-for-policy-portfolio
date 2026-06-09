# 07_create_graphs.R
# Create graphs from graph-ready CSV tables.

source("scripts/00_setup.R")

all_merge_diagnostics <- read_csv(file.path(tables_dir, "all_merge_diagnostics.csv"), show_col_types = FALSE)
philiri_assessed_coverage <- read_csv(file.path(tables_dir, "philiri_assessed_coverage_by_grade.csv"), show_col_types = FALSE)
philiri_level_distribution_summary <- read_csv(file.path(tables_dir, "philiri_level_distribution_summary.csv"), show_col_types = FALSE)
philiri_discrepancy_summary <- read_csv(file.path(tables_dir, "philiri_discrepancy_summary.csv"), show_col_types = FALSE)
rma_distribution_summary <- read_csv(file.path(tables_dir, "rma_proficiency_distribution_summary.csv"), show_col_types = FALSE)
rma_discrepancy_summary <- read_csv(file.path(tables_dir, "rma_discrepancy_summary.csv"), show_col_types = FALSE)
dlp_clean <- read_rds(file.path(processed_dir, "dlp_randomization_clean.rds"))
philiri_scores_long <- read_csv(file.path(tables_dir, "philiri_school_level_scores_long.csv"), show_col_types = FALSE)
philiri_discrepancy_checks <- read_csv(file.path(tables_dir, "philiri_school_level_discrepancy_checks.csv"), show_col_types = FALSE)
rma_scores_long <- read_csv(file.path(tables_dir, "rma_school_level_scores_long.csv"), show_col_types = FALSE)
rma_discrepancy_checks <- read_csv(file.path(tables_dir, "rma_school_level_discrepancy_checks.csv"), show_col_types = FALSE)

merge_graph_data <- all_merge_diagnostics |>
  select(dataset, matched_records, unmatched_records_from_dlp, unmatched_records_from_assessment) |>
  pivot_longer(
    cols = c(matched_records, unmatched_records_from_dlp, unmatched_records_from_assessment),
    names_to = "merge_status",
    values_to = "records"
  ) |>
  mutate(
    merge_status = case_when(
      merge_status == "matched_records" ~ "Matched",
      merge_status == "unmatched_records_from_dlp" ~ "Unmatched from DLP",
      merge_status == "unmatched_records_from_assessment" ~ "Unmatched from assessment",
      TRUE ~ merge_status
    )
  )

merge_diagnostics_graph <- ggplot(merge_graph_data, aes(x = dataset, y = records, fill = merge_status)) +
  geom_col(position = "dodge") +
  labs(x = NULL, y = "Records", fill = NULL, title = "Merge Diagnostics") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave(file.path(figures_dir, "merge_diagnostics.png"), merge_diagnostics_graph, width = 9, height = 5, dpi = 300)

philiri_assessed_bosy_graph <- philiri_assessed_coverage |>
  filter(time_point == "BoSY") |>
  ggplot(aes(x = grade, y = total_english_assessed, fill = grade)) +
  geom_col(show.legend = FALSE) +
  labs(x = NULL, y = "English assessed count", title = "Phil-IRI BoSY English Assessed by Grade") +
  theme_minimal(base_size = 12)

ggsave(file.path(figures_dir, "philiri_assessed_by_grade_bosy.png"), philiri_assessed_bosy_graph, width = 7, height = 5, dpi = 300)

philiri_assessed_eosy_graph <- philiri_assessed_coverage |>
  filter(time_point == "EoSY") |>
  ggplot(aes(x = grade, y = total_english_assessed, fill = grade)) +
  geom_col(show.legend = FALSE) +
  labs(x = NULL, y = "English assessed count", title = "Phil-IRI EoSY English Assessed by Grade") +
  theme_minimal(base_size = 12)

ggsave(file.path(figures_dir, "philiri_assessed_by_grade_eosy.png"), philiri_assessed_eosy_graph, width = 7, height = 5, dpi = 300)

philiri_2level_bosy_graph <- philiri_level_distribution_summary |>
  filter(time_point == "BoSY", level_group == "2-level") |>
  ggplot(aes(x = grade, y = percent_of_english_assessed, fill = reading_category)) +
  geom_col() +
  labs(x = NULL, y = "Percent of English assessed", fill = NULL, title = "Phil-IRI BoSY 2-Level Distribution") +
  theme_minimal(base_size = 12)

ggsave(file.path(figures_dir, "philiri_2level_distribution_bosy.png"), philiri_2level_bosy_graph, width = 8, height = 5, dpi = 300)

philiri_2level_eosy_graph <- philiri_level_distribution_summary |>
  filter(time_point == "EoSY", level_group == "2-level") |>
  ggplot(aes(x = grade, y = percent_of_english_assessed, fill = reading_category)) +
  geom_col() +
  labs(x = NULL, y = "Percent of English assessed", fill = NULL, title = "Phil-IRI EoSY 2-Level Distribution") +
  theme_minimal(base_size = 12)

ggsave(file.path(figures_dir, "philiri_2level_distribution_eosy.png"), philiri_2level_eosy_graph, width = 8, height = 5, dpi = 300)

philiri_3level_bosy_graph <- philiri_level_distribution_summary |>
  filter(time_point == "BoSY", level_group == "3-level") |>
  ggplot(aes(x = grade, y = percent_of_english_assessed, fill = reading_category)) +
  geom_col() +
  labs(x = NULL, y = "Percent of English assessed", fill = NULL, title = "Phil-IRI BoSY 3-Level Distribution") +
  theme_minimal(base_size = 12)

ggsave(file.path(figures_dir, "philiri_3level_distribution_bosy.png"), philiri_3level_bosy_graph, width = 8, height = 5, dpi = 300)

philiri_3level_eosy_graph <- philiri_level_distribution_summary |>
  filter(time_point == "EoSY", level_group == "3-level") |>
  ggplot(aes(x = grade, y = percent_of_english_assessed, fill = reading_category)) +
  geom_col() +
  labs(x = NULL, y = "Percent of English assessed", fill = NULL, title = "Phil-IRI EoSY 3-Level Distribution") +
  theme_minimal(base_size = 12)

ggsave(file.path(figures_dir, "philiri_3level_distribution_eosy.png"), philiri_3level_eosy_graph, width = 8, height = 5, dpi = 300)

philiri_discrepancy_graph <- philiri_discrepancy_summary |>
  ggplot(aes(x = grade, y = schools_with_discrepancy, fill = level_group)) +
  geom_col(position = "dodge") +
  facet_wrap(~ time_point) +
  labs(x = NULL, y = "Schools with discrepancies", fill = NULL, title = "Phil-IRI Discrepancy Flags") +
  theme_minimal(base_size = 12)

ggsave(file.path(figures_dir, "philiri_discrepancy_flags.png"), philiri_discrepancy_graph, width = 8, height = 5, dpi = 300)

rma_bosy_graph <- rma_distribution_summary |>
  filter(time_point == "BoSY") |>
  ggplot(aes(x = grade, y = percent_of_assessed, fill = proficiency_group)) +
  geom_col() +
  labs(x = NULL, y = "Percent of assessed", fill = NULL, title = "RMA BoSY Proficiency Distribution") +
  theme_minimal(base_size = 12)

ggsave(file.path(figures_dir, "rma_proficiency_distribution_bosy.png"), rma_bosy_graph, width = 8, height = 5, dpi = 300)

rma_eosy_graph <- rma_distribution_summary |>
  filter(time_point == "EoSY") |>
  ggplot(aes(x = grade, y = percent_of_assessed, fill = proficiency_group)) +
  geom_col() +
  labs(x = NULL, y = "Percent of assessed", fill = NULL, title = "RMA EoSY Proficiency Distribution") +
  theme_minimal(base_size = 12)

ggsave(file.path(figures_dir, "rma_proficiency_distribution_eosy.png"), rma_eosy_graph, width = 8, height = 5, dpi = 300)

rma_discrepancy_graph <- rma_discrepancy_summary |>
  ggplot(aes(x = grade, y = schools_with_discrepancy, fill = time_point)) +
  geom_col(position = "dodge") +
  labs(x = NULL, y = "Schools with discrepancies", fill = NULL, title = "RMA Discrepancy Flags") +
  theme_minimal(base_size = 12)

ggsave(file.path(figures_dir, "rma_discrepancy_flags.png"), rma_discrepancy_graph, width = 8, height = 5, dpi = 300)

# Line graphs comparing beginning of school year and end of school year.
philiri_assessed_line_data <- philiri_assessed_coverage |>
  mutate(
    school_year_point = case_when(
      time_point == "BoSY" ~ "Start of SY",
      time_point == "EoSY" ~ "End of SY",
      TRUE ~ time_point
    ),
    school_year_point = factor(school_year_point, levels = c("Start of SY", "End of SY")),
    grade = factor(grade, levels = c("Grade 7", "Grade 8", "Grade 9", "Grade 10"))
  )

philiri_assessed_line_graph <- philiri_assessed_line_data |>
  ggplot(aes(x = school_year_point, y = total_english_assessed, group = grade, color = grade)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  facet_wrap(~ grade) +
  labs(x = NULL, y = "English assessed count", color = NULL, title = "Phil-IRI English Assessed from Start to End of SY") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave(file.path(figures_dir, "philiri_assessed_start_end_sy_lines.png"), philiri_assessed_line_graph, width = 8, height = 5, dpi = 300)

philiri_distribution_line_data <- philiri_level_distribution_summary |>
  mutate(
    school_year_point = case_when(
      time_point == "BoSY" ~ "Start of SY",
      time_point == "EoSY" ~ "End of SY",
      TRUE ~ time_point
    ),
    school_year_point = factor(school_year_point, levels = c("Start of SY", "End of SY")),
    grade = factor(grade, levels = c("Grade 7", "Grade 8", "Grade 9", "Grade 10")),
    level_group = factor(level_group, levels = c("2-level", "3-level"))
  )

philiri_distribution_line_graph <- philiri_distribution_line_data |>
  ggplot(aes(x = school_year_point, y = percent_of_english_assessed, group = reading_category, color = reading_category)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  facet_grid(level_group ~ grade) +
  labs(x = NULL, y = "Percent of English assessed", color = NULL, title = "Phil-IRI Reading Categories from Start to End of SY") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave(file.path(figures_dir, "philiri_reading_categories_start_end_sy_lines_faceted.png"), philiri_distribution_line_graph, width = 11, height = 6, dpi = 300)

rma_distribution_line_data <- rma_distribution_summary |>
  mutate(
    school_year_point = case_when(
      time_point == "BoSY" ~ "Start of SY",
      time_point == "EoSY" ~ "End of SY",
      TRUE ~ time_point
    ),
    school_year_point = factor(school_year_point, levels = c("Start of SY", "End of SY")),
    grade = factor(grade, levels = c("Grade 7", "Grade 8", "Grade 9", "Grade 10"))
  )

rma_distribution_line_graph <- rma_distribution_line_data |>
  ggplot(aes(x = school_year_point, y = percent_of_assessed, group = proficiency_group, color = proficiency_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  facet_wrap(~ grade) +
  labs(x = NULL, y = "Percent of assessed", color = NULL, title = "RMA Proficiency Groups from Start to End of SY") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave(file.path(figures_dir, "rma_proficiency_start_end_sy_lines_faceted.png"), rma_distribution_line_graph, width = 10, height = 6, dpi = 300)

# Graphs by DLP rev_status.
rev_status_lookup <- dlp_clean |>
  transmute(
    school_id = as.character(beis_school_id),
    rev_status = as.character(rev_status),
    rev_status_label = case_when(
      rev_status == "0" ~ "control",
      rev_status == "1" ~ "treatment",
      is.na(rev_status) ~ "missing rev_status",
      TRUE ~ paste("rev_status", rev_status)
    )
  )

philiri_rev_status_summary <- philiri_scores_long |>
  mutate(school_id = as.character(school_id)) |>
  left_join(rev_status_lookup, by = "school_id") |>
  filter(is_in_dlp_randomization_file, !is.na(rev_status)) |>
  group_by(rev_status_label, time_point, grade, level_group, reading_category) |>
  summarise(
    total_student_count = sum(student_count, na.rm = TRUE),
    total_english_assessed = sum(english_assessed, na.rm = TRUE),
    schools_with_data = n_distinct(school_id),
    .groups = "drop"
  ) |>
  mutate(
    percent_of_english_assessed = case_when(
      total_english_assessed > 0 ~ 100 * total_student_count / total_english_assessed,
      TRUE ~ NA_real_
    ),
    school_year_point = case_when(
      time_point == "BoSY" ~ "Start of SY",
      time_point == "EoSY" ~ "End of SY",
      TRUE ~ time_point
    ),
    school_year_point = factor(school_year_point, levels = c("Start of SY", "End of SY")),
    grade = factor(grade, levels = c("Grade 7", "Grade 8", "Grade 9", "Grade 10")),
    level_group = factor(level_group, levels = c("2-level", "3-level"))
  )

write_csv(philiri_rev_status_summary, file.path(tables_dir, "philiri_distribution_by_rev_status_summary.csv"))

philiri_rev_status_line_graph <- philiri_rev_status_summary |>
  ggplot(aes(x = school_year_point, y = percent_of_english_assessed, group = reading_category, color = reading_category)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  facet_grid(rev_status_label + level_group ~ grade) +
  labs(x = NULL, y = "Percent of English assessed", color = NULL, title = "Phil-IRI Reading Categories by Rev Status") +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave(file.path(figures_dir, "philiri_reading_categories_by_rev_status_lines_faceted.png"), philiri_rev_status_line_graph, width = 12, height = 8, dpi = 300)

philiri_discrepancy_by_rev_status <- philiri_discrepancy_checks |>
  mutate(school_id = as.character(school_id)) |>
  left_join(rev_status_lookup, by = "school_id") |>
  filter(is_in_dlp_randomization_file, !is.na(rev_status)) |>
  group_by(rev_status_label, time_point, grade, level_group) |>
  summarise(
    schools_checked = n(),
    schools_with_discrepancy = sum(has_discrepancy, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    grade = factor(grade, levels = c("Grade 7", "Grade 8", "Grade 9", "Grade 10")),
    level_group = factor(level_group, levels = c("2-level", "3-level"))
  )

write_csv(philiri_discrepancy_by_rev_status, file.path(tables_dir, "philiri_discrepancy_by_rev_status_summary.csv"))

philiri_discrepancy_by_rev_status_graph <- philiri_discrepancy_by_rev_status |>
  ggplot(aes(x = grade, y = schools_with_discrepancy, fill = rev_status_label)) +
  geom_col(position = "dodge") +
  facet_grid(level_group ~ time_point) +
  labs(x = NULL, y = "Schools with discrepancies", fill = NULL, title = "Phil-IRI Discrepancy Flags by Rev Status") +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave(file.path(figures_dir, "philiri_discrepancy_flags_by_rev_status.png"), philiri_discrepancy_by_rev_status_graph, width = 10, height = 6, dpi = 300)

rma_rev_status_summary <- rma_scores_long |>
  mutate(school_id = as.character(school_id)) |>
  left_join(rev_status_lookup, by = "school_id") |>
  filter(is_in_dlp_randomization_file, !is.na(rev_status)) |>
  group_by(rev_status_label, time_point, grade, proficiency_group) |>
  summarise(
    total_student_count = sum(student_count, na.rm = TRUE),
    total_assessed_count = sum(assessed_count, na.rm = TRUE),
    schools_with_data = n_distinct(school_id),
    .groups = "drop"
  ) |>
  mutate(
    percent_of_assessed = case_when(
      total_assessed_count > 0 ~ 100 * total_student_count / total_assessed_count,
      TRUE ~ NA_real_
    ),
    school_year_point = case_when(
      time_point == "BoSY" ~ "Start of SY",
      time_point == "EoSY" ~ "End of SY",
      TRUE ~ time_point
    ),
    school_year_point = factor(school_year_point, levels = c("Start of SY", "End of SY")),
    grade = factor(grade, levels = c("Grade 7", "Grade 8", "Grade 9", "Grade 10"))
  )

write_csv(rma_rev_status_summary, file.path(tables_dir, "rma_distribution_by_rev_status_summary.csv"))

rma_rev_status_line_graph <- rma_rev_status_summary |>
  ggplot(aes(x = school_year_point, y = percent_of_assessed, group = proficiency_group, color = proficiency_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  facet_grid(rev_status_label ~ grade) +
  labs(x = NULL, y = "Percent of assessed", color = NULL, title = "RMA Proficiency Groups by Rev Status") +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave(file.path(figures_dir, "rma_proficiency_by_rev_status_lines_faceted.png"), rma_rev_status_line_graph, width = 12, height = 6, dpi = 300)

rma_rev_status_stacked_bar_graph <- rma_rev_status_summary |>
  mutate(
    proficiency_group = factor(
      proficiency_group,
      levels = c(
        "not proficient",
        "low proficient",
        "nearly proficient",
        "proficient",
        "high proficient"
      )
    )
  ) |>
  ggplot(aes(x = school_year_point, y = percent_of_assessed, fill = proficiency_group)) +
  geom_col(width = 0.7) +
  facet_grid(rev_status_label ~ grade) +
  labs(x = NULL, y = "Percent of assessed", fill = NULL, title = "RMA Proficiency Distribution by Rev Status") +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave(file.path(figures_dir, "rma_proficiency_by_rev_status_stacked_bars.png"), rma_rev_status_stacked_bar_graph, width = 12, height = 6, dpi = 300)

rma_rev_status_change_data <- rma_rev_status_summary |>
  select(rev_status_label, grade, proficiency_group, school_year_point, percent_of_assessed) |>
  pivot_wider(
    names_from = school_year_point,
    values_from = percent_of_assessed
  ) |>
  mutate(
    percentage_point_change = `End of SY` - `Start of SY`,
    proficiency_group = factor(
      proficiency_group,
      levels = c(
        "not proficient",
        "low proficient",
        "nearly proficient",
        "proficient",
        "high proficient"
      )
    )
  )

write_csv(rma_rev_status_change_data, file.path(tables_dir, "rma_change_by_rev_status_summary.csv"))

rma_rev_status_change_graph <- rma_rev_status_change_data |>
  ggplot(aes(x = percentage_point_change, y = proficiency_group, color = rev_status_label)) +
  geom_vline(xintercept = 0, color = "gray70", linewidth = 0.5) +
  geom_point(size = 2.5, position = position_dodge(width = 0.45)) +
  facet_wrap(~ grade) +
  labs(
    x = "Percentage-point change from start to end of SY",
    y = NULL,
    color = NULL,
    title = "RMA Proficiency Change by Rev Status"
  ) +
  theme_minimal(base_size = 11)

ggsave(file.path(figures_dir, "rma_proficiency_change_by_rev_status_points.png"), rma_rev_status_change_graph, width = 10, height = 6, dpi = 300)

rma_discrepancy_by_rev_status <- rma_discrepancy_checks |>
  mutate(school_id = as.character(school_id)) |>
  left_join(rev_status_lookup, by = "school_id") |>
  filter(is_in_dlp_randomization_file, !is.na(rev_status)) |>
  group_by(rev_status_label, time_point, grade) |>
  summarise(
    schools_checked = n(),
    schools_with_discrepancy = sum(has_discrepancy, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(grade = factor(grade, levels = c("Grade 7", "Grade 8", "Grade 9", "Grade 10")))

write_csv(rma_discrepancy_by_rev_status, file.path(tables_dir, "rma_discrepancy_by_rev_status_summary.csv"))

rma_discrepancy_by_rev_status_graph <- rma_discrepancy_by_rev_status |>
  ggplot(aes(x = grade, y = schools_with_discrepancy, fill = rev_status_label)) +
  geom_col(position = "dodge") +
  facet_wrap(~ time_point) +
  labs(x = NULL, y = "Schools with discrepancies", fill = NULL, title = "RMA Discrepancy Flags by Rev Status") +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave(file.path(figures_dir, "rma_discrepancy_flags_by_rev_status.png"), rma_discrepancy_by_rev_status_graph, width = 10, height = 5, dpi = 300)
