# ESC-SHS-VP Targeting Response Coding

This folder stores the standalone workflow for coding open-ended ESC and SHS VP survey responses.
It keeps the response-coding script, raw open-ended workbook, and coding outputs together so the descriptive-stats folder can stay focused on high-frequency checks and PPI summaries.

## Folder Structure

```text
raw/      # open-ended response workbook
scripts/  # standalone response-coding workflow
./        # generated coding CSV outputs
```

## Run Order

Run from this folder:

```r
source("scripts/00_run_response_coding.R")
```

## Outputs

```text
esc_shs_vp_targeting_open_response_codebook.csv
esc_shs_vp_targeting_open_response_coded.csv
esc_shs_vp_targeting_open_response_summary.csv
```

## Numeric Codes

```text
1  cost_financial_assistance
2  distance_transport_proximity
3  school_quality_private_opportunity
4  school_or_person_recommended
5  awareness_or_eligibility
6  learner_choice_or_preference
7  family_vulnerability
8  form_questionnaire_difficulty
9  positive_feedback_or_thanks
90 other_substantive
99 blank_none_or_not_applicable
```

The script assigns a `primary_code` plus `matching_codes`. Rows with multiple matches or code `90` are flagged as `needs_review = TRUE`, because those are the responses most likely to need human judgment.
