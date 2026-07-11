# ESC-SHS-VP Targeting Descriptive Statistics

This folder contains a simple R workflow for high-frequency checks and school-level targeting summaries for the ESC and SHS Voucher Program application survey. The scripts clean the survey export, flag records that need review, exclude respondents who appear to be under 18 without age confirmation, and append school-level Poverty Probability Index summaries when the PPI workbook is available.

## Folder Structure

```text
raw/       # original and dummy input files
scripts/   # numbered R scripts
data/      # cleaned learner-level and school-level datasets
outputs/   # issue logs and summary files
docs/      # short notes on form variables and workflow assumptions
```

## Run Order

To regenerate the dummy survey workbook:

```bash
python3 scripts/99_generate_dummy_data.py
```

Run the workflow from the project folder:

```r
source("scripts/00_master.R")
```

The dummy generator reads the expected form labels from `scripts/02_hfc_checks.R`, writes `raw/dummy_esc_shs_vp_targeting_responses.xlsx`, and includes a few intentional issues: an invalid email, an invalid LRN, a household-size inconsistency, an unexpected yes/no value, and one under-18 respondent without age confirmation. The master script reads this dummy workbook by default. Replace `config$input_file` in `scripts/00_master.R` when the real export is ready.

## Main Outputs

```text
data/esc_shs_vp_targeting_clean_data.csv
data/esc_shs_vp_targeting_school_ppi.csv
outputs/esc_shs_vp_targeting_issue_log.csv
outputs/esc_shs_vp_targeting_summary.csv
```

## Notes

Variable names are cleaned with `janitor::make_clean_names()`. Repeated question labels with suffixes such as ` 2`, ` 3`, or ` 4` usually come from Google Form branching logic, where the same question appears under different yes/no paths. See `docs/form_variable_notes.md`.

The PPI append uses the Philippines 2023 PPI scorecard workbook from `https://www.povertyindex.org/`. Update `config$ppi_scorecard_file` if the workbook is saved somewhere else.

Open-ended response coding is kept in the sibling folder `../esc-shs-vp-targeting-response-coding/` so this workflow can stay focused on descriptive stats and high-frequency checks.
