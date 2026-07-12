# DepEd Data Management Tutorial

This folder contains a public-safe training workflow for survey data management in a DepEd evaluation context. The tutorial uses dummy PPI-style household survey data to demonstrate common IPA DMS checks, including duplicate IDs, approved corrections, missingness, form versions, constraints, logic checks, outliers, other-specify recodes, text audits, field comments, progress tracking, codebook generation, and backcheck comparisons.

The workflow includes both a Stata implementation that mirrors the official `ipacheck`-style DMS approach and an R teaching analogue that produces comparable CSV outputs for users who want to understand the logic behind each check.

## Folder Structure

```text
data/       # dummy survey data in CSV and Stata formats
inputs/     # demo correction, recode, comment, text-audit, tracking, and ipacheck input files
scripts/    # Python helper for generating the ipacheck input workbook
stata/      # Stata DMS tutorial scripts
r/          # R analogue scripts and generated outputs
```

## Run Order

To rebuild the ipacheck input workbook:

```bash
python3 scripts/build_ipacheck_inputs.py
```

To run the R teaching analogue from the project folder:

```r
source("r/scripts/00_master.R")
```

To run the Stata version from the project folder:

```stata
do stata/scripts/00_master.do
```

## Main Outputs

```text
r/outputs/01_duplicate_household_ids.csv
r/outputs/02_correction_log.csv
r/outputs/04_missing_summary.csv
r/outputs/07_constraint_flags.csv
r/outputs/08_logic_flags.csv
r/outputs/15_survey_dashboard.csv
r/outputs/16_enumerator_dashboard.csv
r/outputs/17_tracking.csv
r/outputs/18_codebook.csv
r/outputs/19_backcheck_comparison.csv
```

## Notes

All included data are dummy or demo files created for training. The R workflow is a teaching analogue and is not a replacement for IPA's official Stata DMS tools; it is included to make the data-quality logic easier to inspect and adapt.
