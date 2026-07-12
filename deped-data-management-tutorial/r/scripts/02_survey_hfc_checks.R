################################################################################
## TITLE   : 02_survey_hfc_checks.R
## PURPOSE : Run survey-level R analogues of IPA DMS checks
## PROJECT : PPI DMS training demo
## AUTHOR  : Erika Salvador
## DATE    : June 29, 2026
################################################################################

# This is file 2 of 4 in the R DMS analogue.
#
# First, we check duplicate IDs.
# Then, we apply corrections.
# Next, we run duplicate-variable, missingness, version, constraint, logic,
# outlier, other-specify, and recode checks.
# Finally, we save the checked dataset for later R scripts.

# First, we check duplicate household IDs. This mirrors `ipacheckids`.
duplicate_ids <- survey |>
  add_count(household_id, name = "duplicate_count") |>
  filter(duplicate_count > 1) |>
  arrange(household_id, key)

write_csv(duplicate_ids, "r/outputs/01_duplicate_household_ids.csv")

# Then, we create a de-duplicated working dataset. This mimics the Stata demo's
# `save()` option in `ipacheckids`, which keeps one record per household ID for
# downstream checks.
checked <- survey |>
  distinct(household_id, .keep_all = TRUE)

# Next, we apply approved corrections. This mirrors `ipacheckcorrections`.
correction_log <- corrections |>
  mutate(status = "not applied")

for (i in seq_len(nrow(corrections))) {
  id_value <- corrections$household_id[i]
  var_name <- corrections$variable[i]
  old_value <- corrections$value[i]
  new_value <- corrections$newvalue[i]
  action <- corrections$action[i]

  row_match <- which(checked$household_id == id_value)
  if (length(row_match) == 1 && var_name %in% names(checked)) {
    current_value <- as.character(checked[[var_name]][row_match])
    if (action == "replace" && identical(current_value, old_value)) {
      checked[[var_name]][row_match] <- type.convert(new_value, as.is = TRUE)
      correction_log$status[i] <- "applied"
    } else if (action == "okay") {
      correction_log$status[i] <- "marked okay"
    } else if (action == "drop") {
      checked <- checked[-row_match, ]
      correction_log$status[i] <- "dropped"
    } else {
      correction_log$status[i] <- paste("not applied; current value is", current_value)
    }
  } else {
    correction_log$status[i] <- "not applied; ID or variable not found"
  }
}

write_csv(correction_log, "r/outputs/02_correction_log.csv")

# Next, we identify duplicate values in non-ID variables. This mirrors
# `ipacheckdups`; here we check phone numbers.
phone_duplicates <- checked |>
  filter(!is.na(phone_number), phone_number != "") |>
  add_count(phone_number, name = "duplicate_count") |>
  filter(duplicate_count > 1) |>
  arrange(phone_number, household_id)

write_csv(phone_duplicates, "r/outputs/03_phone_duplicates.csv")

# Then, we summarize missing values. This mirrors `ipacheckmissing`.
missing_summary <- checked |>
  summarise(across(
    all_of(c(ppi_vars, "consent", "hh_size", "children_under_15", "duration_minutes", "form_version")),
    list(number_missing = ~ sum(is.na(.x)), number_unique = ~ n_distinct(.x, na.rm = TRUE))
  ))

missing_long <- tibble(variable = c(ppi_vars, "consent", "hh_size", "children_under_15", "duration_minutes", "form_version")) |>
  mutate(
    number_missing = as.integer(missing_summary[1, paste0(variable, "_number_missing")]),
    percent_missing = number_missing / nrow(checked),
    number_unique = as.integer(missing_summary[1, paste0(variable, "_number_unique")])
  )

write_csv(missing_long, "r/outputs/04_missing_summary.csv")

# Next, we check old form versions. This mirrors `ipacheckversions`.
latest_form_version <- max(checked$form_version, na.rm = TRUE)
form_versions <- checked |>
  count(form_version, name = "submissions") |>
  mutate(is_latest = form_version == latest_form_version)

outdated_forms <- checked |>
  filter(form_version < latest_form_version) |>
  select(household_id, key, enumerator, interview_date, form_version)

write_csv(form_versions, "r/outputs/05_form_versions.csv")
write_csv(outdated_forms, "r/outputs/06_outdated_forms.csv")

# Then, we check numeric constraints from inputs/ipacheck_inputs.xlsx. This
# mirrors `ipacheckconstraints`.
constraints <- read_excel("inputs/ipacheck_inputs.xlsx", sheet = "constraints")

constraint_flags <- bind_rows(lapply(seq_len(nrow(constraints)), function(i) {
  variable <- constraints$variable[i]
  if (!variable %in% names(checked)) return(tibble())

  values <- checked[[variable]]
  hard_min <- suppressWarnings(as.numeric(constraints$hard_min[i]))
  hard_max <- suppressWarnings(as.numeric(constraints$hard_max[i]))

  checked |>
    mutate(
      variable = variable,
      value = values,
      hard_min = hard_min,
      hard_max = hard_max,
      constraint_issue = (!is.na(hard_min) & value < hard_min) |
        (!is.na(hard_max) & value > hard_max)
    ) |>
    filter(!is.na(value), constraint_issue) |>
    select(household_id, key, enumerator, interview_date, variable, value, hard_min, hard_max)
}))

write_csv(constraint_flags, "r/outputs/07_constraint_flags.csv")

# Next, we check cross-question logic. This mirrors `ipachecklogic`.
logic_flags <- checked |>
  filter(children_under_15 > hh_size) |>
  transmute(
    household_id,
    key,
    enumerator,
    interview_date,
    variable = "children_under_15",
    value = children_under_15,
    logic_rule = "children_under_15 <= hh_size",
    hh_size
  )

write_csv(logic_flags, "r/outputs/08_logic_flags.csv")

# Then, we check numeric outliers. This mirrors `ipacheckoutliers`.
duration_outliers <- checked |>
  group_by(enumerator) |>
  mutate(
    q1 = quantile(duration_minutes, 0.25, na.rm = TRUE),
    q3 = quantile(duration_minutes, 0.75, na.rm = TRUE),
    iqr = q3 - q1,
    lower_bound = q1 - 1.5 * iqr,
    upper_bound = q3 + 1.5 * iqr
  ) |>
  ungroup() |>
  filter(duration_minutes < lower_bound | duration_minutes > upper_bound) |>
  select(household_id, key, enumerator, interview_date, duration_minutes, lower_bound, upper_bound)

write_csv(duration_outliers, "r/outputs/09_duration_outliers.csv")

# Next, we list other-specify responses. This mirrors `ipacheckspecify`.
other_specify <- checked |>
  filter(asset_main == 99 | asset_other != "") |>
  select(household_id, key, enumerator, interview_date, asset_main, asset_other)

write_csv(other_specify, "r/outputs/10_other_specify.csv")

# After that, we recode other-specify responses. This mirrors
# `ipacheckspecifyrecode`.
specify_recode_log <- specify_recode |>
  mutate(records_modified = 0L)

for (i in seq_len(nrow(specify_recode))) {
  parent <- specify_recode$parent[i]
  child <- specify_recode$child[i]
  match_text <- specify_recode$match_text[i]
  recode_from <- suppressWarnings(as.numeric(specify_recode$recode_from[i]))
  recode_to <- suppressWarnings(as.numeric(specify_recode$recode_to[i]))

  recode_rows <- which(checked[[parent]] == recode_from & grepl(match_text, checked[[child]], ignore.case = TRUE))
  if (length(recode_rows) > 0) {
    checked[[parent]][recode_rows] <- recode_to
  }
  specify_recode_log$records_modified[i] <- length(recode_rows)
}

write_csv(specify_recode_log, "r/outputs/11_specify_recode_log.csv")
write_dta(checked, "r/outputs/ppi_demo_checked_r.dta")
