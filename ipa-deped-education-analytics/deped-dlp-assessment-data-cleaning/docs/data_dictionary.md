# Data Dictionary

This document describes the main cleaned outputs created by the R workflow.

## Key Identifiers

| Variable | Source | Description |
|---|---|---|
| `beis_school_id` | DLP randomization | School identifier used as the main DLP merge key. Stored as character. |
| `school_id` | Phil-IRI and RMA | School identifier in assessment files. Stored as character. |
| `region_code` | DLP randomization | Region code from the DLP school-level file. Stored as character. |
| `division_code` | DLP randomization | Division code from the DLP school-level file. Stored as character. |
| `full_division_code` | DLP randomization | Full division code from the DLP school-level file. Stored as character. |
| `school_name` | Phil-IRI and RMA | School name from assessment files. Converted to factor in cleaned files. |

## Main Processed Files

| File | Description |
|---|---|
| `processed/dlp_randomization_clean.csv` | Clean DLP base school-level file after removing rows with missing key school fields. |
| `processed/philiri_bosy_clean.csv` | Clean Phil-IRI BoSY file. |
| `processed/philiri_eosy_clean.csv` | Clean Phil-IRI EoSY file. |
| `processed/rma_bosy_clean.csv` | Clean RMA BoSY file. |
| `processed/rma_eosy_clean.csv` | Clean RMA EoSY file. |
| `processed/dlp_with_philiri_merged.csv` | DLP file merged with Phil-IRI BoSY and EoSY. |
| `processed/dlp_with_all_assessments_merged.csv` | DLP file merged with Phil-IRI and RMA BoSY/EoSY files. |

## Score Tables

| File | Description |
|---|---|
| `outputs/tables/philiri_school_level_scores_long.csv` | School-grade-category Phil-IRI counts and percentages. |
| `outputs/tables/philiri_school_level_discrepancy_checks.csv` | School-grade Phil-IRI checks comparing summed reading-level counts to English assessed counts. |
| `outputs/tables/philiri_level_distribution_summary.csv` | Grade-level Phil-IRI distribution summary used for graphs. |
| `outputs/tables/rma_school_level_scores_long.csv` | School-grade-proficiency RMA counts and percentages. |
| `outputs/tables/rma_school_level_discrepancy_checks.csv` | School-grade RMA checks comparing summed proficiency counts to assessed counts. |
| `outputs/tables/rma_proficiency_distribution_summary.csv` | Grade-level RMA distribution summary used for graphs. |

## Discrepancy Variables

| Variable | Description |
|---|---|
| `summed_category_count` | Phil-IRI sum of reading category counts for a school, grade, time point, and level grouping. |
| `summed_proficiency_count` | RMA sum of proficiency group counts for a school, grade, and time point. |
| `discrepancy_count` | Difference between summed category/proficiency counts and assessed count. |
| `has_discrepancy` | TRUE when summed counts do not equal the assessed count, or when the assessed count is missing. |

