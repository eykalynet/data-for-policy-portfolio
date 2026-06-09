# 07_create_graphs.R
# Create graphs from graph-ready CSV tables.

source("scripts/00_setup.R")

all_merge_diagnostics <- read_csv(file.path(tables_dir, "all_merge_diagnostics.csv"), show_col_types = FALSE)
philiri_assessed_coverage <- read_csv(file.path(tables_dir, "philiri_assessed_coverage_by_grade.csv"), show_col_types = FALSE)
philiri_level_distribution_summary <- read_csv(file.path(tables_dir, "philiri_level_distribution_summary.csv"), show_col_types = FALSE)
philiri_discrepancy_summary <- read_csv(file.path(tables_dir, "philiri_discrepancy_summary.csv"), show_col_types = FALSE)
rma_distribution_summary <- read_csv(file.path(tables_dir, "rma_proficiency_distribution_summary.csv"), show_col_types = FALSE)
rma_discrepancy_summary <- read_csv(file.path(tables_dir, "rma_discrepancy_summary.csv"), show_col_types = FALSE)

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
