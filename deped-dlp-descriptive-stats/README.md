# DLP Descriptive Statistics

This folder contains the school-level descriptive statistics workflow for the DepEd Dynamic Learning Program pilot. The scripts clean the randomized school file, merge Phil-IRI and RMA assessment summaries, create school-level indicators, and export tables, figures, and a short results brief.

## Run Order

Run scripts from `deped-dlp-descriptive-stats/`.

```text
scripts/00_setup.R
scripts/01_clean_merge_data.R
scripts/02_create_scores_and_checks.R
scripts/03_export_stata_dataset.R
scripts/04_descriptive_stats.do
scripts/05_compliance_checks.do
scripts/06_visualizations.do
scripts/07_geographic_summaries.do
scripts/12_create_results_brief.py
```

`scripts/99_run_all.R` runs the R portion through the Stata export. The Stata scripts use paths relative to the project folder and can also use a `DLP_PROJECT_DIR` global.

## Main Outputs

```text
data/01_dlp_rma_philiri_school_level_full.csv
data/02_dlp_rma_philiri_school_level_percentages.csv
data/03_dlp_rma_philiri_school_level_for_stata.dta
outputs/descriptive_results_brief.docx
outputs/descriptive_results_brief.pdf
outputs/tables/
outputs/figures/individual_figures/
```

## Notes

Compliance is coded in `scripts/03_export_stata_dataset.R` by comparing treatment assignment to observed treatment status. Rows with missing key school fields are excluded from the analytic file and written to `outputs/validation_na_schools/`.
