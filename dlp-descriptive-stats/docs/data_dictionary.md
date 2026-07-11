# Data Dictionary

This document describes the main generated outputs in the cleaned DLP assessment workflow.

## Final Analytic Data

| File | Description |
|---|---|
| `data/01_dlp_rma_philiri_school_level_full.csv` | Full school-level DLP dataset merged with Phil-IRI and RMA BoSY/EoSY assessment columns. |
| `data/02_dlp_rma_philiri_school_level_percentages.csv` | School-level percentage dataset with Phil-IRI reading category percentages and RMA proficiency percentages. |
| `data/03_dlp_rma_philiri_school_level_for_stata.dta` | Stata-ready school-level file used by `04_descriptive_stats.do`, `05_compliance_checks.do`, and `06_visualizations.do`. |
| `data/03_dlp_rma_philiri_school_level_for_stata.csv` | CSV mirror of the Stata-ready file for quick inspection. |

## Key Identifiers and Grouping Variables

| Variable | Source | Description |
|---|---|---|
| `beis_school_id` | DLP randomization | School identifier used as the main DLP merge key. |
| `randomized_eval_id` | DLP evaluation file | Evaluation/randomization identifier when available. |
| `rev_status` | DLP evaluation file | Raw evaluation status from the source file. |
| `treatment_status` | Derived | Treatment status label from `rev_status`: `Control` when `rev_status == 0` and `Treatment` when `rev_status == 1`. |
| `region_code` | DLP randomization | Region grouping. |
| `division_code` | DLP randomization | Division grouping. |
| `municipality_code` | DLP randomization | Municipality grouping. |
| `full_division_code` | DLP randomization | Full division grouping used in Stata compliance outputs. |
| `full_municipality_code` | DLP randomization | Full municipality grouping used in Stata compliance outputs. |

## Assignment and Compliance Variables

| Variable | Description |
|---|---|
| `pilot_cancel` | Randomization flag used to identify emergency assignment. |
| `pilot_ratio` | Randomization flag used to identify mainstream assignment. |
| `pilot_shift` | Randomization flag used to identify shifting assignment. |
| `assignment_flag_count` | Number of assignment flags equal to 1. |
| `assignment_group` | Derived group: `control`, `mainstream`, `shifting`, `emergency`, or `multiple flags`. |
| `compliance` | Equals 1 when assignment and raw `rev_status` align with the compliance rule; equals 0 otherwise. |

## Assessment Count Variables

Stata variable names are compacted to fit Stata naming limits.

| Pattern | Description |
|---|---|
| `enroll_g*_m`, `enroll_g*_f`, `enroll_g*_all` | Enrollment counts by grade and sex. |
| `enroll_total_jhs_all` | Total junior high school enrollment. |
| `ph_b_g*_eng_assessed` | Phil-IRI BoSY English assessed count by grade. |
| `ph_e_g*_eng_assessed` | Phil-IRI EoSY English assessed count by grade. |
| `rma_b_g*_assessed` | RMA BoSY assessed count by grade. |
| `rma_e_g*_assessed` | RMA EoSY assessed count by grade. |

## Score Tables

| File | Description |
|---|---|
| `outputs/tables/02_philiri_scores_long.csv` | School-grade-time-point Phil-IRI reading counts and percentages. |
| `outputs/tables/02_philiri_score_checks.csv` | School-grade Phil-IRI checks comparing summed reading counts to assessed counts. |
| `outputs/tables/02_rma_scores_long.csv` | School-grade-time-point RMA proficiency counts and percentages. |
| `outputs/tables/02_rma_score_checks.csv` | School-grade RMA checks comparing summed proficiency counts to assessed counts. |

## Stata Tables

| File Pattern | Description |
|---|---|
| `outputs/tables/04_*` | Dataset snapshot, treatment status counts, enrollment/assessment totals, and proficiency summaries. |
| `outputs/tables/05_*` | Compliance summaries at school, municipality, division, region, and assignment-group levels. |
| `outputs/tables/07_geographic_summary_region.*` | Region-level school, treatment status, enrollment, assessment coverage, and compliance summaries. |
| `outputs/tables/07_geographic_summary_division.*` | Division-level school, treatment status, enrollment, assessment coverage, and compliance summaries. |
| `outputs/tables/07_geographic_summary_municipality.*` | City/municipality-level school, treatment status, enrollment, assessment coverage, and compliance summaries. |

The `07_*_map_ready.csv` files are CSV versions intended for Google Sheets, Google Docs tables, or joining to administrative boundary data for mapping.

Figure exports are saved as PNG files.

## Validation

| File | Description |
|---|---|
| `outputs/validation_na_schools/01_schools_with_missing_key_fields.csv` | Raw rows excluded from the analytic data because one or more key school fields were missing. |
