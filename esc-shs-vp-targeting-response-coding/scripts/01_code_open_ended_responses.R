################################################################################
## TITLE   : 04_code_open_ended_responses.R
## PURPOSE : Apply a first-pass numeric coding scheme to open-ended responses.
## PROJECT : ESC-SHS-VP targeting descriptive statistics
## AUTHOR  : Erika Salvador
## DATE    : July 11, 2026
################################################################################

## INPUT DEPENDENCY:
## config$open_ended_file, config$sheet, and config$coding_dir are defined in
## 00_master.R. This script creates review-ready coding outputs; it should not
## be treated as final qualitative coding without human review.
open_response_data <- readxl::read_excel(
  path = config$open_ended_file,
  sheet = config$sheet
)
open_response_data <- as.data.frame(open_response_data, stringsAsFactors = FALSE)
names(open_response_data) <- janitor::make_clean_names(
  gsub(intToUtf8(8217), "'", trimws(names(open_response_data)), fixed = TRUE)
)
open_response_data$response_id <- seq_len(nrow(open_response_data))

codebook <- data.frame(
  code = c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L, 90L, 99L),
  code_label = c(
    "cost_financial_assistance",
    "distance_transport_proximity",
    "school_quality_private_opportunity",
    "school_or_person_recommended",
    "awareness_or_eligibility",
    "learner_choice_or_preference",
    "family_vulnerability",
    "form_questionnaire_difficulty",
    "positive_feedback_or_thanks",
    "other_substantive",
    "blank_none_or_not_applicable"
  ),
  description = c(
    "Mentions tuition, discount, voucher, subsidy, expenses, affordability, or financial burden.",
    "Mentions distance, nearby school, commute, fare, transport, or location convenience.",
    "Mentions private school access, quality education, better learning, opportunities, or future outcomes.",
    "Mentions teacher, school, family, friend, social media, poster, caravan, or other referral source.",
    "Mentions not knowing about the program, not being informed, public-school origin, eligibility, or no previous access.",
    "Mentions that the learner chose the school/program or prefers to join friends/classmates.",
    "Mentions single parent, widow, low income, loans, no work, disability, or similar household vulnerability.",
    "Mentions unclear/difficult form questions, confusing sections, updates, meetings, group chats, or process questions.",
    "Mentions thanks, good, okay, clear, or other positive feedback.",
    "Substantive response that does not match codes 1-9.",
    "Blank, none, n/a, no question, not applicable, punctuation-only, or equivalent non-substantive response."
  ),
  keywords = c(
    "tuition|discount|voucher|subsid|financial|finance|expense|cost|afford|money|budget|bayad|bawas|mura|makamura|tipid|assistance|support|lessen|reduce|aid|grant|libre|libere|tulong|makatulong|malaking tulong|pag.?aaral",
    "distance|near|nearby|malapit|katabi|pamasahe|fare|transport|commute|location|travel|sakay",
    "quality|private|education|learning|opportunit|future|better|grow|succeed|experience|school|guro|pangarap",
    "teacher|school recommend|recommended|suggested|encouraged|family|friend|social media|poster|caravan|told|learn about|heard",
    "not aware|didn't know|did not know|no idea|no one told|didn't hear|did not hear|public school|from public|not previous|not recipient|eligible|eligibility|no esc|not yet needed",
    "child choose|child chose|son choose|daughter choose|learner choose|friends|schoolmates|preference|preferred|choice",
    "single parent|widow|less fortunate|insufficient income|mababang income|no work|unemployed|loan|special child|disability|poor|hirap|naghahanapbuhay",
    "difficult|understand|unclear|confusing|question|feedback|questionnaire|section|updated|meeting|gc|process|how the voucher|what is esc|pagkakaiba|explanation|introduction|intindihan|enlighten|in lighten",
    "thank|good|ok|okay|clear|responded well|all are clear",
    "",
    "none|n/a|na|no|nothing|not applicable|^\\.*$|^-$"
  ),
  stringsAsFactors = FALSE
)

open_response_questions <- c(
  why_did_you_apply_to_the_esc = "why_apply_esc",
  if_answered_no_in_previous_question_what_are_the_reason_s_why_your_child_is_not_a_previous_recipient_of_the_esc = "why_not_previous_esc",
  why_did_you_apply_to_the_shs_vp = "why_apply_shs_vp",
  which_section_s_and_or_question_s_were_difficult_to_understand = "difficult_question_section",
  kindly_let_us_know_below_if_you_have_any_question_or_feedback_regarding_the_questionnaire_or_the_education_service_contracting_esc_and_senior_high_school_voucher_program_shs_vp = "questions_or_feedback"
)

normalize_response <- function(value) {
  value <- tolower(trimws(as.character(value)))
  value <- gsub("[[:space:]]+", " ", value)
  value
}

is_blank_none <- function(value) {
  is.na(value) ||
    value == "" ||
    grepl("^(none|n/a|na|no|nothing|not applicable|wala|\\.*|-)$", value)
}

assign_codes <- function(value) {
  value <- normalize_response(value)

  if (is_blank_none(value)) {
    return(list(primary_code = 99L, matching_codes = "99"))
  }

  matched_codes <- integer()
  for (i in seq_len(nrow(codebook))) {
    code <- codebook$code[i]
    pattern <- codebook$keywords[i]
    if (code %in% c(90L, 99L) || pattern == "") {
      next
    }
    if (grepl(pattern, value, ignore.case = TRUE, perl = TRUE)) {
      matched_codes <- c(matched_codes, code)
    }
  }

  if (length(matched_codes) == 0L) {
    matched_codes <- 90L
  }

  matched_codes <- unique(matched_codes)
  list(
    primary_code = matched_codes[1],
    matching_codes = paste(matched_codes, collapse = ";")
  )
}

coded_response_rows <- vector(
  "list",
  length(intersect(names(open_response_questions), names(open_response_data))) *
    nrow(open_response_data)
)
coded_row_index <- 0L

for (source_column in names(open_response_questions)) {
  if (!source_column %in% names(open_response_data)) {
    next
  }

  question_key <- unname(open_response_questions[source_column])
  responses <- open_response_data[[source_column]]

  for (row_index in seq_along(responses)) {
    assigned <- assign_codes(responses[[row_index]])
    primary_label <- codebook$code_label[match(assigned$primary_code, codebook$code)]
    coded_row_index <- coded_row_index + 1L
    coded_response_rows[[coded_row_index]] <- data.frame(
      response_id = open_response_data$response_id[row_index],
      question_key = question_key,
      raw_response = as.character(responses[[row_index]]),
      primary_code = assigned$primary_code,
      primary_code_label = primary_label,
      matching_codes = assigned$matching_codes,
      needs_review = assigned$primary_code %in% c(90L) || grepl(";", assigned$matching_codes, fixed = TRUE),
      stringsAsFactors = FALSE
    )
  }
}

coded_response_rows <- coded_response_rows[seq_len(coded_row_index)]
coded_responses <- do.call(rbind, coded_response_rows)

summary_counts <- aggregate(
  response_id ~ question_key + primary_code + primary_code_label,
  data = coded_responses,
  FUN = length
)
names(summary_counts)[names(summary_counts) == "response_id"] <- "response_count"

question_totals <- aggregate(
  response_count ~ question_key,
  data = summary_counts,
  FUN = sum
)
names(question_totals)[names(question_totals) == "response_count"] <- "question_total"

summary_counts <- merge(summary_counts, question_totals, by = "question_key", all.x = TRUE)
summary_counts$share_of_question <- summary_counts$response_count / summary_counts$question_total
summary_counts <- summary_counts[order(summary_counts$question_key, summary_counts$primary_code), ]

open_response_results <- list(
  codebook = codebook,
  coded_responses = coded_responses,
  summary = summary_counts
)
