# High-Frequency Checks Template

This folder contains a simple R system for high-frequency checks on the DepEd
application survey data.

## Files

- `00_master.R` - update file paths here and run this script.
- `01_setup_and_load.R` - loads `.xlsx`, `.xls`, or `.csv` files.
- `02_hfc_checks.R` - applies schema checks, missing-value checks, duplicate
  checks, range checks, and basic consistency checks.
- `03_ppi_school_append.R` - computes household PPI scores and aggregates
  school-level PPI summaries using the Philippines 2023 PPI workbook.

## How to Run

1. Put the raw response file somewhere accessible.
2. Open `00_master.R`.
3. Update `config$input_file`, `config$output_dir`, and `config$sheet`.
4. Update `config$ppi_scorecard_file` if the PPI workbook is saved elsewhere.
5. Run `00_master.R`.

The system creates three CSV outputs:

- `hfc_checked_data.csv` - cleaned data with added check fields.
- `hfc_checked_issue_log.csv` - one row per issue found.
- `hfc_checked_summary.csv` - summary counts.
- `hfc_checked_school_ppi.csv` - school-level PPI score and likelihood means.

## Notes

- The script does not assume the real dataset is available yet.
- The expected column list comes from the provided Google Form variable names.
- Variable names are cleaned with `janitor::make_clean_names()` at load time.
  The original form labels remain in the scripts only as readable references.
- Edit `core_required_columns` in `02_hfc_checks.R` if the required fields
  should be stricter or more relaxed.
- Edit the validation ranges in `02_hfc_checks.R` if the project team has
  different thresholds.
- Rows where the respondent appears to be under 18 and did not confirm
  age/consent are excluded from the cleaned analytic data and logged in the
  issue log as `excluded_under_18_no_consent`.
- The PPI module uses the Philippines 2023 PPI workbook from
  `https://www.povertyindex.org/`. Update the path in `00_master.R` when
  handing the scripts to someone else.
