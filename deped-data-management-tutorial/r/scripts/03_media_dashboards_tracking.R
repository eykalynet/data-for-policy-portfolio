################################################################################
## TITLE   : 03_media_dashboards_tracking.R
## PURPOSE : Create R media outputs, dashboards, and tracking outputs
## PROJECT : PPI DMS training demo
## AUTHOR  : Erika Salvador
## DATE    : June 29, 2026
################################################################################

# This is file 3 of 4 in the R DMS analogue.
#
# First, we export field comments.
# Then, we summarize text-audit timing and active survey hours.
# Next, we create survey and enumerator dashboards.
# Finally, we create a simple progress tracking output.

# First, we export field comments. This mirrors `ipacheckcomments`.
field_comments <- checked |>
  select(household_id, key, barangay, enumerator, field_comments_id) |>
  inner_join(comments_data, by = "field_comments_id")

write_csv(field_comments, "r/outputs/12_field_comments.csv")

# Then, we summarize text audit timing. This mirrors `ipachecktextaudit`.
textaudit_joined <- checked |>
  select(household_id, key, enumerator, textaudit_id, starttime) |>
  inner_join(textaudit_data, by = "textaudit_id")

textaudit_field_stats <- textaudit_joined |>
  group_by(fieldname) |>
  summarise(
    count = n(),
    mean_duration = mean(totalduration, na.rm = TRUE),
    min_duration = min(totalduration, na.rm = TRUE),
    max_duration = max(totalduration, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(textaudit_field_stats, "r/outputs/13_textaudit_field_stats.csv")

# Next, we summarize active survey hours. This mirrors `ipachecktimeuse`.
timeuse <- textaudit_joined |>
  mutate(
    active_time = as.POSIXct(starttime) + firstappeared / 1000,
    active_date = as.Date(active_time),
    active_hour = as.integer(format(active_time, "%H"))
  ) |>
  distinct(textaudit_id, active_date, active_hour, enumerator) |>
  count(active_date, active_hour, name = "active_interviews")

write_csv(timeuse, "r/outputs/14_timeuse_by_hour.csv")

# Then, we create a survey dashboard. This mirrors `ipachecksurveydb`.
survey_dashboard <- checked |>
  group_by(barangay) |>
  summarise(
    submissions = n(),
    consent_rate = mean(consent == 1, na.rm = TRUE),
    average_duration = mean(duration_minutes, na.rm = TRUE),
    latest_form_rate = mean(form_version == latest_form_version, na.rm = TRUE),
    missing_ppi_records = sum(if_any(all_of(ppi_vars), is.na)),
    other_specify_records = sum(asset_other != "", na.rm = TRUE),
    .groups = "drop"
  )

write_csv(survey_dashboard, "r/outputs/15_survey_dashboard.csv")

# Next, we create an enumerator dashboard. This mirrors `ipacheckenumdb`.
enumerator_dashboard <- checked |>
  group_by(enumerator, enum_team_id) |>
  summarise(
    submissions = n(),
    consent_rate = mean(consent == 1, na.rm = TRUE),
    average_duration = mean(duration_minutes, na.rm = TRUE),
    median_duration = median(duration_minutes, na.rm = TRUE),
    missing_ppi_records = sum(if_any(all_of(ppi_vars), is.na)),
    duration_flags = sum(duration_minutes < 8 | duration_minutes > 90),
    average_ppi_score = mean(ppi_score, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(enumerator_dashboard, "r/outputs/16_enumerator_dashboard.csv")

# Finally, we track survey progress against barangay targets. This mirrors
# `ipatracksurvey`.
tracking <- checked |>
  count(barangay, name = "submitted") |>
  right_join(tracking_targets, by = "barangay") |>
  mutate(
    submitted = if_else(is.na(submitted), 0L, submitted),
    percent_submitted = submitted / target
  )

write_csv(tracking, "r/outputs/17_tracking.csv")
