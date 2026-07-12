################################################################################
## TITLE   : 04_backcheck_and_codebook.R
## PURPOSE : Create R codebook and backcheck comparison outputs
## PROJECT : PPI DMS training demo
## AUTHOR  : Erika Salvador
## DATE    : June 29, 2026
################################################################################

# This is file 4 of 4 in the R DMS analogue.
#
# First, we export a simple codebook.
# Then, we create dummy backcheck data.
# Finally, we compare survey and backcheck data.

# First, we export a simple codebook. This mirrors `ipacodebook`.
codebook <- tibble(
  variable = names(checked),
  type = vapply(checked, function(x) paste(class(x), collapse = "/"), character(1)),
  number_missing = vapply(checked, function(x) sum(is.na(x)), integer(1)),
  percent_missing = number_missing / nrow(checked),
  number_unique = vapply(checked, function(x) n_distinct(x, na.rm = TRUE), integer(1))
)

write_csv(codebook, "r/outputs/18_codebook.csv")

# Then, we create dummy backcheck data. This mirrors the Stata demo's training
# backcheck setup.
backcheck <- checked |>
  slice(1:20) |>
  mutate(
    backchecker_id = row_number() %% 2 + 1,
    bc_team_id = if_else(backchecker_id == 1, 1L, 2L),
    bcdate = interview_date + 1,
    ppi_q2_has_toilet = if_else(row_number() %in% c(3, 9, 15) & ppi_q2_has_toilet %in% c(0, 1),
                                1 - ppi_q2_has_toilet,
                                ppi_q2_has_toilet),
    hh_size = if_else(row_number() %in% c(4, 12), hh_size + 1, hh_size)
  )

write_dta(backcheck, "r/outputs/ppi_backcheck_dummy_r.dta")

# Finally, we compare survey and backcheck data. This mirrors `ipabcstats`.
compare_vars <- c("hh_size", "children_under_15", "ppi_q1_floor_solid", "ppi_q2_has_toilet", "ppi_q3_has_electricity")

backcheck_comparison <- bind_rows(lapply(compare_vars, function(var) {
  checked |>
    select(household_id, enumerator, enum_team_id, survey_value = all_of(var), interview_date) |>
    inner_join(
      backcheck |>
        select(household_id, backchecker_id, bc_team_id, backcheck_value = all_of(var), bcdate),
      by = "household_id"
    ) |>
    mutate(
      variable = var,
      different = survey_value != backcheck_value
    ) |>
    select(household_id, enumerator, enum_team_id, backchecker_id, bc_team_id,
           variable, survey_value, backcheck_value, different, interview_date, bcdate)
}))

write_csv(backcheck_comparison, "r/outputs/19_backcheck_comparison.csv")
