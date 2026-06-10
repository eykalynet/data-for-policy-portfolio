# DLP Assessment Data Cleaning and Descriptive Statistics

This folder contains the reproducible R and Stata workflow for the DLP school-level assessment descriptive statistics requested for PI review. Raw files stay untouched; generated analytic files are written to `data/`, and PI-facing tables, figures, logs, and validation files are written to `outputs/`.

## Folder Structure

```text
raw/                              # Original input files. Do not edit.
scripts/                          # Numbered R and Stata scripts.
data/                             # Final analytic datasets for R/Stata handoff.
outputs/tables/                   # Numbered CSV/XLSX summary tables.
outputs/figures/                  # Numbered Stata figures using IPA graph scheme.
outputs/logs/                     # Numbered R/Stata logs.
outputs/validation_na_schools/    # Rows with missing key school fields.
docs/                             # Data dictionary and cleaning notes.
```

## Raw Input Files

1. `Final_DLP_Dataset_for_Randomization.csv`
2. `DLP_randomized_schools_eval.csv`
3. `Phil-IRI KS3 National Dashboard_Secondary - BoSY 2025-26_Table.csv`
4. `Phil-IRI KS3 National Dashboard_Secondary - EoSY  2025-26_Table.csv`
5. `RMA (KS3) National Dashboard_BoSY 2025-26 Assessment Results_Table.csv`
6. `RMA (KS3) National Dashboard_EoSY 2025-26 Assessment Results_Table.csv`

## Scripts

Run scripts from:

```text
ipa-deped-education-analytics/deped-dlp-assessment-data-cleaning/
```

The main scripts are:

```text
scripts/00_setup.R
scripts/01_clean_merge_data.R
scripts/02_create_scores_and_checks.R
scripts/03_export_stata_dataset.R
scripts/04_descriptive_stats.do
scripts/05_compliance_checks.do
scripts/06_visualizations.do
scripts/99_run_all.R
```

`scripts/99_run_all.R` runs the R portion through the Stata export. Then run the Stata do-files in order:

```stata
do scripts/04_descriptive_stats.do
do scripts/05_compliance_checks.do
do scripts/06_visualizations.do
```

The Stata visualization script installs/uses the IPA graph scheme and sets the print font to Georgia:

```stata
net install github, from("https://haghish.github.io/github/")
github install PovertyAction/ipaplots, replace
set scheme ipaplots, perm
graph set print fontface "Georgia"
```

## Final Data Outputs

```text
data/01_dlp_rma_philiri_school_level_full.csv
data/02_dlp_rma_philiri_school_level_percentages.csv
data/03_dlp_rma_philiri_school_level_for_stata.dta
data/03_dlp_rma_philiri_school_level_for_stata.csv
```

## PI-Facing Outputs

The Stata scripts generate:

- `outputs/tables/04_*`: overall dataset snapshot, `rev_status` subgroup counts, enrollment/assessment totals, and proficiency summaries.
- `outputs/tables/05_*`: school, municipality, division, region, and assignment-group compliance summaries.
- `outputs/figures/06_*`: IPA-themed PNG figures for `rev_status`, enrollment vs assessed counts, proficiency distributions, assessed counts, Phil-IRI reading categories, and compliance rates.
- `outputs/logs/04_descriptive_stats.log`, `05_compliance_checks.log`, and `06_visualizations.log`.

## Compliance Definition

Compliance is coded in `scripts/03_export_stata_dataset.R` before export to Stata:

- Assigned `control` and `rev_status == 0`: compliant.
- Assigned `mainstream`, `shifting`, or `emergency` and `rev_status == 1`: compliant.
- Otherwise: non-compliant.

Assignment group is derived from the randomization fields `pilot_ratio`, `pilot_shift`, and `pilot_cancel`.

## Validation

Rows with true `NA`, blank, or literal `"NA"` values in key school fields are excluded from the analytic file and saved to:

```text
outputs/validation_na_schools/01_schools_with_missing_key_fields.csv
```

Merge diagnostics and score checks are saved as numbered files in `outputs/tables/`.
