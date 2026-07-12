################################################################################
## TITLE   : 99_make_dummy_ppi_data.R
## PURPOSE : Generate dummy PPI data and helper files for DMS training
## PROJECT : PPI DMS training demo
## AUTHOR  : Erika Salvador
## DATE    : June 29, 2026
################################################################################

library(dplyr)
library(haven)
library(readr)

set.seed(20260629)

dir.create("data", showWarnings = FALSE)
dir.create("inputs", showWarnings = FALSE)
dir.create("r/outputs", recursive = TRUE, showWarnings = FALSE)
dir.create("stata/outputs", recursive = TRUE, showWarnings = FALSE)

n <- 60

ppi <- tibble(
  key = sprintf("uuid:%012d", seq_len(n)),
  household_id = sprintf("HH%03d", seq_len(n)),
  enumerator = sample(c("Ana", "Ben", "Carlo", "Dina"), n, replace = TRUE),
  barangay = sample(c("North", "South", "East", "West"), n, replace = TRUE),
  interview_date = as.Date("2026-06-01") + sample(0:10, n, replace = TRUE),
  form_version = sample(c(1, 2), n, replace = TRUE, prob = c(0.15, 0.85)),
  duration_minutes = round(rlnorm(n, log(24), 0.35)),
  consent = sample(c(1, 1, 1, 0), n, replace = TRUE),
  hh_size = sample(1:9, n, replace = TRUE),
  children_under_15 = sample(0:5, n, replace = TRUE),
  ppi_q1_floor_solid = sample(c(0, 1), n, replace = TRUE),
  ppi_q2_has_toilet = sample(c(0, 1), n, replace = TRUE),
  ppi_q3_has_electricity = sample(c(0, 1), n, replace = TRUE),
  ppi_q4_has_tv = sample(c(0, 1), n, replace = TRUE),
  ppi_q5_has_fridge = sample(c(0, 1), n, replace = TRUE),
  ppi_q6_head_completed_primary = sample(c(0, 1), n, replace = TRUE),
  ppi_q7_roof_durable = sample(c(0, 1), n, replace = TRUE),
  ppi_q8_has_mobile_phone = sample(c(0, 1), n, replace = TRUE),
  ppi_q9_owns_livestock = sample(c(0, 1), n, replace = TRUE),
  ppi_q10_has_savings = sample(c(0, 1), n, replace = TRUE)
) |>
  mutate(
    ppi_score = rowSums(across(starts_with("ppi_q")), na.rm = TRUE) * 10,
    poverty_likelihood = round(100 - ppi_score + rnorm(n, 0, 5), 1),
    enum_id = as.integer(factor(enumerator, levels = c("Ana", "Ben", "Carlo", "Dina"))),
    enum_team_id = if_else(enumerator %in% c("Ana", "Ben"), 1L, 2L),
    phone_number = paste0("09", sprintf("%09.0f", 100000000 + row_number() %% 20)),
    asset_main = if_else(row_number() %% 7 == 0, 99, 1),
    asset_other = if_else(asset_main == 99, "solar lamp", ""),
    field_comments_id = paste0("Comments-", sub("^uuid:", "", key)),
    textaudit_id = paste0("TA_", sub("^uuid:", "", key)),
    starttime = as.POSIXct(interview_date, tz = "UTC") + (8 * 60 * 60) + (row_number() * 5 * 60),
    endtime = starttime + (duration_minutes * 60)
  )

# Intentional data-quality issues for training.
ppi$household_id[8] <- ppi$household_id[7]
ppi$ppi_q3_has_electricity[12] <- NA
ppi$ppi_q5_has_fridge[18] <- 9
ppi$children_under_15[25] <- ppi$hh_size[25] + 2
ppi$duration_minutes[31] <- 3
ppi$duration_minutes[41] <- 125
ppi$form_version[44] <- 1
ppi$consent[50] <- NA
ppi$phone_number[10:11] <- "09123456789"

comments_data <- ppi |>
  slice(1:5) |>
  transmute(
    field_comments_id,
    fieldname = "ppi_section/ppi_q3_has_electricity",
    comment = "Enumerator left a training comment for review."
  )

textaudit_ids <- ppi$textaudit_id[1:12]
textaudit_data <- tibble(
  textaudit_id = rep(textaudit_ids, each = 3),
  field_order = rep(1:3, times = length(textaudit_ids))
) |>
  mutate(
    fieldname = case_when(
      field_order == 1 ~ "intro/consent",
      field_order == 2 ~ "ppi_section/ppi_q1_floor_solid",
      TRUE ~ "ppi_section/ppi_q2_has_toilet"
    ),
    totalduration = 2500 + field_order * 900 + row_number() * 10,
    firstappeared = field_order * 60000
  )

corrections <- tibble(
  household_id = "HH018",
  variable = "ppi_q5_has_fridge",
  value = "9",
  newvalue = "1",
  action = "replace",
  comments = "Training example: replace impossible PPI value."
)

specify_recode <- tibble(
  parent = "asset_main",
  child = "asset_other",
  match_type = "exact",
  match_text = "solar lamp",
  recode_from = "99",
  recode_to = "8",
  new_label = "Solar lamp"
)

tracking_targets <- tibble(
  barangay = c("North", "South", "East", "West"),
  target = c(20, 20, 20, 20)
)

write_csv(ppi, "data/ppi_dummy_raw.csv")
write_dta(ppi, "data/ppi_dummy_raw.dta")
write_csv(corrections, "inputs/demo_corrections.csv")
write_csv(specify_recode, "inputs/demo_specify_recode.csv")
write_csv(tracking_targets, "inputs/demo_tracking_targets.csv")
write_dta(comments_data, "inputs/demo_comments_data.dta")
write_dta(textaudit_data, "inputs/demo_textaudit_data.dta")
