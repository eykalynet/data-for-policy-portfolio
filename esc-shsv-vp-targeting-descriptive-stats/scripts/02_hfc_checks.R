################################################################################
## TITLE   : 02_hfc_checks.R
## PURPOSE : Run high-frequency checks on the ESC-SHSV-VP survey export.
## PROJECT : ESC-SHSV-VP targeting descriptive statistics
## AUTHOR  : Erika Salvador
## DATE    : July 10, 2026
################################################################################

## EXPECTED FORM STRUCTURE:
## Update this list if the Google Form changes. The labels should match the
## export headers as closely as possible; janitor converts them to snake_case.
## Labels ending in " 2", " 3", etc. are branch-specific repeats from the form.
expected_columns <- janitor::make_clean_names(gsub(intToUtf8(8217), "'", trimws(c(
  "Timestamp",
  "Email Address",
  "By filling up this form, you are giving permission to DepEd to collect and process all data in this form for research purposes.\n\nFurther, you are giving permission to be contacted by DepEd in the future to collect additional information.",
  "LAST NAME",
  "FIRST NAME",
  "MIDDLE NAME",
  "Relationship with Learner",
  "Contact Details",
  "Are you the household head?",
  "How many members are there in the household?",
  "How many members are under 18 years of age?",
  "What is the highest level of education completed by the household head?",
  "What is the primary occupation of the household head during the past six months?",
  "How many members are there in the household? 2",
  "How many members are under 18 years of age?  2",
  "LAST NAME 2",
  "FIRST NAME 2",
  "MIDDLE NAME 2",
  "Relationship with Learner 2",
  "What is the highest level of education completed by the household head? 2",
  "What is the primary occupation of the household head during the past six months? 2",
  "LAST NAME of Learner",
  "FIRST NAME of Learner",
  "MIDDLE NAME of Learner",
  "Learner Reference Number",
  "Grade Level for SY 2026 - 2027",
  "Region of School of Learner for SY 2026 - 2027",
  "Schools DIvision Office of School of Learner for SY 2026 - 2027",
  "School ID and School Name of Learner for SY 2026 - 2027",
  "School ID and School Name of Learner for SY 2025 - 2026",
  "School ID and School Name of Learner for SY 2026 - 2027 2",
  "School ID and School Name of Learner for SY 2025 - 2026 2",
  "Schools DIvision Office of school of Learner for SY 2026 - 2027",
  "School ID and School Name of Learner for SY 2026 - 2027 3",
  "School ID and School Name of Learner for SY 2025 - 2026 3",
  "School ID and School Name of Learner for SY 2026 - 2027 4",
  "School ID and School Name of Learner for SY 2025 - 2026 4",
  "Schools DIvision Office of school of Learner for SY 2026 - 2027 2",
  "School ID and School Name of Learner for SY 2026 - 2027 5",
  "School ID and School Name of Learner for SY 2025 - 2026 5",
  "School ID and School Name of Learner for SY 2026 - 2027 6",
  "School ID and School Name of Learner for SY 2025 - 2026 6",
  "Schools DIvision Office of school of Learner for SY 2026 - 2027 3",
  "School ID and School Name of Learner for SY 2026 - 2027 7",
  "School ID and School Name of Learner for SY 2025 - 2026 7",
  "School ID and School Name of Learner for SY 2026 - 2027 8",
  "School ID and School Name of Learner for SY 2025 - 2026 8",
  "Schools DIvision Office of school of Learner for SY 2026 - 2027 4",
  "School ID and School Name of Learner for SY 2026 - 2027 9",
  "School ID and School Name of Learner for SY 2025 - 2026 9",
  "School ID and School Name of Learner for SY 2026 - 2027 10",
  "School ID and School Name of Learner for SY 2025 - 2026 10",
  "In which region does the household currently live?",
  "In which province does the household currently live?",
  "In which city/municipality does the household currently live?",
  "What language is primarily spoken by the household?",
  "What is the main material of the dwelling's external walls?",
  "Where does the learner usually study at home?",
  "What is the household's main source of water supply for general activities (e.g. bathing, washing of dishes)?",
  "What is the main source of drinking water for the household?",
  "Where does the household often purchase food ingredients or ready-to-eat food?",
  "How often does the learner consume home-cooked meals?",
  "How often does the learner consume vegetables?",
  "What type of cooking fuel does the household mainly use?",
  "Does the household own a refrigerator?",
  "Does the household own a rice cooker?",
  "What program did your child apply for in SY 2026 - 2027",
  "How did you learn about the Education Service Contracting (ESC)?",
  "Why did you apply to the ESC?",
  "Is your child a previous recipient of the Education Service Contracting (ESC)?",
  "If answered no in previous question,  what are the reason/s why your child is not a previous recipient of the ESC?",
  "How did you learn about the  Senior High School Voucher Program (SHS VP)?",
  "Why did you apply to the SHS VP?",
  "Which section/s and/or question/s were difficult to understand?",
  "Kindly let us know below if you have any question or feedback regarding the questionnaire or the Education Service Contracting (ESC) and Senior High School Voucher Program (SHS VP) .",
  "This survey is open to participants aged 18 years or older. In compliance with the Data Privacy Act of 2012, personal data collected from minors shall be handled with additional safeguards and parental consent. \n\nBy filling up this form, I confirm that I am 18 years or older.",
  "Date of Birth (MM/DD/YYYY)"
)), fixed = TRUE))

## REQUIRED FIELDS:
## Tighten or relax this list depending on what the program team considers
## necessary for targeting, PPI scoring, and respondent follow-up.
core_required_columns <- janitor::make_clean_names(gsub(intToUtf8(8217), "'", trimws(c(
  "LAST NAME",
  "FIRST NAME",
  "Relationship with Learner",
  "Contact Details",
  "Are you the household head?",
  "How many members are there in the household?",
  "How many members are under 18 years of age?",
  "LAST NAME of Learner",
  "FIRST NAME of Learner",
  "Learner Reference Number",
  "Grade Level for SY 2026 - 2027",
  "Region of School of Learner for SY 2026 - 2027",
  "In which region does the household currently live?",
  "In which province does the household currently live?",
  "In which city/municipality does the household currently live?",
  "Date of Birth (MM/DD/YYYY)"
)), fixed = TRUE))

## Start from the loaded data and add a row_id so every issue can be traced
## back to the original row in the export.
hfc_data <- raw_data
names(hfc_data) <- janitor::make_clean_names(
  gsub(intToUtf8(8217), "'", trimws(names(hfc_data)), fixed = TRUE)
)
hfc_data$row_id <- seq_len(nrow(hfc_data))

## Trim blank strings before checking missingness. This prevents spaces from
## being treated as valid responses.
character_columns <- names(hfc_data)[vapply(hfc_data, is.character, logical(1))]
for (column_name in character_columns) {
  hfc_data[[column_name]] <- trimws(as.character(hfc_data[[column_name]]))
  hfc_data[[column_name]][hfc_data[[column_name]] == ""] <- NA_character_
}

## Schema checks: missing columns usually require follow-up; extra columns may
## be harmless if the form changed intentionally.
missing_columns <- setdiff(expected_columns, names(hfc_data))
extra_columns <- setdiff(names(hfc_data), c(expected_columns, "row_id"))

for (column_name in missing_columns) {
  hfc_data[[column_name]] <- NA_character_
}

issue_log <- data.frame(
  row_id = integer(),
  check_name = character(),
  issue = character(),
  severity = character(),
  stringsAsFactors = FALSE
)

issue_log <- rbind(
  issue_log,
  data.frame(
    row_id = rep(NA_integer_, length(missing_columns)),
    check_name = rep("schema_missing_column", length(missing_columns)),
    issue = paste(rep("Missing expected column:", length(missing_columns)), missing_columns),
    severity = rep("fix", length(missing_columns)),
    stringsAsFactors = FALSE
  )
)

issue_log <- rbind(
  issue_log,
  data.frame(
    row_id = rep(NA_integer_, length(extra_columns)),
    check_name = rep("schema_extra_column", length(extra_columns)),
    issue = paste(rep("Column not listed in template:", length(extra_columns)), extra_columns),
    severity = rep("review", length(extra_columns)),
    stringsAsFactors = FALSE
  )
)

for (column_name in intersect(core_required_columns, names(hfc_data))) {
  rows <- which(is.na(hfc_data[[column_name]]) | trimws(as.character(hfc_data[[column_name]])) == "")
  issue_log <- rbind(
    issue_log,
    data.frame(
      row_id = hfc_data$row_id[rows],
      check_name = rep("missing_required_value", length(rows)),
      issue = rep(paste("Missing value in", column_name), length(rows)),
      severity = rep("fix", length(rows)),
      stringsAsFactors = FALSE
    )
  )
}

## Core cleaning/check variables. Change these labels only if the form labels
## change in the raw export.
household_size_col <- janitor::make_clean_names("How many members are there in the household?")
minors_col <- janitor::make_clean_names("How many members are under 18 years of age?")
dob_col <- janitor::make_clean_names("Date of Birth (MM/DD/YYYY)")
age_consent_col <- janitor::make_clean_names("This survey is open to participants aged 18 years or older. In compliance with the Data Privacy Act of 2012, personal data collected from minors shall be handled with additional safeguards and parental consent. \n\nBy filling up this form, I confirm that I am 18 years or older.")
email_col <- janitor::make_clean_names("Email Address")
lrn_col <- janitor::make_clean_names("Learner Reference Number")
last_name_col <- janitor::make_clean_names("LAST NAME")
first_name_col <- janitor::make_clean_names("FIRST NAME")

## Numeric range checks. Thresholds are intentionally conservative; adjust
## them if the project team expects larger household sizes.
hfc_data$household_members_clean <- suppressWarnings(
  as.numeric(gsub("[^0-9.-]", "", as.character(hfc_data[[household_size_col]])))
)
hfc_data$members_under_18_clean <- suppressWarnings(
  as.numeric(gsub("[^0-9.-]", "", as.character(hfc_data[[minors_col]])))
)

rows <- which(is.na(hfc_data$household_members_clean) & !is.na(hfc_data[[household_size_col]]))
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("invalid_household_size", length(rows)), issue = rep("Household size is not numeric.", length(rows)), severity = rep("fix", length(rows)), stringsAsFactors = FALSE))

rows <- which(hfc_data$household_members_clean < 1 | hfc_data$household_members_clean > 30)
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("unlikely_household_size", length(rows)), issue = rep("Household size is outside the expected range of 1 to 30.", length(rows)), severity = rep("review", length(rows)), stringsAsFactors = FALSE))

rows <- which(is.na(hfc_data$members_under_18_clean) & !is.na(hfc_data[[minors_col]]))
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("invalid_under_18_count", length(rows)), issue = rep("Number of members under 18 is not numeric.", length(rows)), severity = rep("fix", length(rows)), stringsAsFactors = FALSE))

rows <- which(hfc_data$members_under_18_clean < 0 | hfc_data$members_under_18_clean > 20)
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("unlikely_under_18_count", length(rows)), issue = rep("Number of members under 18 is outside the expected range of 0 to 20.", length(rows)), severity = rep("review", length(rows)), stringsAsFactors = FALSE))

rows <- which(hfc_data$members_under_18_clean > hfc_data$household_members_clean)
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("under_18_exceeds_household_size", length(rows)), issue = rep("Members under 18 is greater than total household members.", length(rows)), severity = rep("fix", length(rows)), stringsAsFactors = FALSE))

## Date-of-birth parsing accepts the expected MM/DD/YYYY format and a fallback
## YYYY-MM-DD format, which sometimes appears after spreadsheet conversion.
hfc_data$date_of_birth_clean <- suppressWarnings(as.Date(as.character(hfc_data[[dob_col]]), format = "%m/%d/%Y"))
missing_birth_date <- is.na(hfc_data$date_of_birth_clean)
hfc_data$date_of_birth_clean[missing_birth_date] <- suppressWarnings(
  as.Date(as.character(hfc_data[[dob_col]][missing_birth_date]), format = "%Y-%m-%d")
)

hfc_data$respondent_age_clean <- as.integer(format(Sys.Date(), "%Y")) -
  as.integer(format(hfc_data$date_of_birth_clean, "%Y"))
birthday_passed <- format(Sys.Date(), "%m%d") >= format(hfc_data$date_of_birth_clean, "%m%d")
hfc_data$respondent_age_clean[!birthday_passed] <- hfc_data$respondent_age_clean[!birthday_passed] - 1L

rows <- which(is.na(hfc_data$date_of_birth_clean) & !is.na(hfc_data[[dob_col]]))
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("invalid_birth_date", length(rows)), issue = rep("Date of birth does not match MM/DD/YYYY or YYYY-MM-DD.", length(rows)), severity = rep("fix", length(rows)), stringsAsFactors = FALSE))

rows <- which(!is.na(hfc_data$respondent_age_clean) & hfc_data$respondent_age_clean < 18)
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("respondent_under_18", length(rows)), issue = rep("Respondent appears to be under 18.", length(rows)), severity = rep("fix", length(rows)), stringsAsFactors = FALSE))

rows <- which(!is.na(hfc_data$respondent_age_clean) & hfc_data$respondent_age_clean > 100)
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("unlikely_respondent_age", length(rows)), issue = rep("Respondent age is greater than 100.", length(rows)), severity = rep("review", length(rows)), stringsAsFactors = FALSE))

## Under-18 exclusion rule. Rows are excluded only when the respondent appears
## to be under 18 and did not provide the age confirmation/consent response.
age_consent_value <- tolower(trimws(as.character(hfc_data[[age_consent_col]])))
hfc_data$age_consent_clean <- age_consent_value %in% c("yes", "y", "oo", "i confirm", "confirm", "true", "1") |
  grepl("confirm", age_consent_value, fixed = TRUE) |
  grepl("18 years or older", age_consent_value, fixed = TRUE)
hfc_data$hfc_exclude_under_18_no_consent <- !is.na(hfc_data$respondent_age_clean) &
  hfc_data$respondent_age_clean < 18 &
  !hfc_data$age_consent_clean

rows <- which(hfc_data$hfc_exclude_under_18_no_consent)
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("excluded_under_18_no_consent", length(rows)), issue = rep("Row excluded because respondent appears under 18 and did not confirm age/consent.", length(rows)), severity = rep("exclude", length(rows)), stringsAsFactors = FALSE))

## Basic contact and duplicate checks. These are review flags, not automatic
## exclusions, unless the row also meets the under-18 no-confirmation rule above.
email_value <- as.character(hfc_data[[email_col]])
rows <- which(!is.na(email_value) & !grepl("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", email_value))
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("invalid_email", length(rows)), issue = rep("Email address does not appear valid.", length(rows)), severity = rep("review", length(rows)), stringsAsFactors = FALSE))

hfc_data$learner_reference_number_clean <- gsub("[^0-9]", "", as.character(hfc_data[[lrn_col]]))
hfc_data$learner_reference_number_clean[hfc_data$learner_reference_number_clean == ""] <- NA_character_

rows <- which(!is.na(hfc_data$learner_reference_number_clean) & nchar(hfc_data$learner_reference_number_clean) != 12)
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("invalid_lrn_length", length(rows)), issue = rep("Learner Reference Number is not 12 digits after removing non-numeric characters.", length(rows)), severity = rep("fix", length(rows)), stringsAsFactors = FALSE))

rows <- which(!is.na(hfc_data$learner_reference_number_clean) & (duplicated(hfc_data$learner_reference_number_clean) | duplicated(hfc_data$learner_reference_number_clean, fromLast = TRUE)))
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("duplicate_lrn", length(rows)), issue = rep("Learner Reference Number appears in more than one row.", length(rows)), severity = rep("review", length(rows)), stringsAsFactors = FALSE))

applicant_key <- paste(toupper(hfc_data[[last_name_col]]), toupper(hfc_data[[first_name_col]]), hfc_data[[dob_col]], sep = "|")
rows <- which(!is.na(hfc_data[[last_name_col]]) & !is.na(hfc_data[[first_name_col]]) & (duplicated(applicant_key) | duplicated(applicant_key, fromLast = TRUE)))
issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("possible_duplicate_applicant", length(rows)), issue = rep("Same respondent first name, last name, and birth date appears in more than one row.", length(rows)), severity = rep("review", length(rows)), stringsAsFactors = FALSE))

## Yes/no checks. Add columns here if new binary form questions should be
## reviewed for unexpected values.
yes_no_columns <- janitor::make_clean_names(c(
  "Are you the household head?",
  "Does the household own a refrigerator?",
  "Does the household own a rice cooker?",
  "Is your child a previous recipient of the Education Service Contracting (ESC)?"
))

for (column_name in yes_no_columns) {
  values <- tolower(trimws(as.character(hfc_data[[column_name]])))
  rows <- which(!is.na(values) & !values %in% c("yes", "no", "y", "n"))
  issue_log <- rbind(issue_log, data.frame(row_id = hfc_data$row_id[rows], check_name = rep("unexpected_yes_no_value", length(rows)), issue = rep(paste("Unexpected yes/no value in", column_name), length(rows)), severity = rep("review", length(rows)), stringsAsFactors = FALSE))
}

## Build row-level flags and a compact summary for quick review.
fix_rows <- unique(issue_log$row_id[issue_log$severity == "fix" & !is.na(issue_log$row_id)])
review_rows <- unique(issue_log$row_id[issue_log$severity == "review" & !is.na(issue_log$row_id)])

hfc_data$hfc_has_fix_issue <- hfc_data$row_id %in% fix_rows
hfc_data$hfc_has_review_issue <- hfc_data$row_id %in% review_rows
hfc_data$hfc_issue_count <- tabulate(
  match(issue_log$row_id[!is.na(issue_log$row_id)], hfc_data$row_id),
  nbins = nrow(hfc_data)
)

hfc_summary <- data.frame(
  metric = c(
    "rows_checked",
    "columns_in_input",
    "expected_columns",
    "missing_expected_columns",
    "extra_columns",
    "rows_with_fix_issues",
    "rows_with_review_issues",
    "rows_excluded_under_18_no_consent",
    "total_logged_issues"
  ),
  value = c(
    nrow(hfc_data),
    ncol(raw_data),
    length(expected_columns),
    length(missing_columns),
    length(extra_columns),
    length(fix_rows),
    length(review_rows),
    sum(hfc_data$hfc_exclude_under_18_no_consent, na.rm = TRUE),
    nrow(issue_log)
  ),
  stringsAsFactors = FALSE
)

hfc_results <- list(
  clean_data = hfc_data[!hfc_data$hfc_exclude_under_18_no_consent, ],
  issue_log = issue_log,
  summary = hfc_summary
)
