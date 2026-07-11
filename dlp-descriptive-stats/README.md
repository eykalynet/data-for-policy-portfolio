# DLP Descriptive Statistics

This folder contains the analysis workflow for school-level descriptive statistics from the DepEd Dynamic Learning Program pilot. The scripts prepare the randomized school file, merge Phil-IRI and RMA assessment summaries, construct school-level indicators, and produce the tables, figures, and results brief used for reporting.

## Run Order

Run the workflow from `dlp-descriptive-stats/`.

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

`scripts/99_run_all.R` runs the R scripts through the Stata export. The Stata scripts use paths relative to the project folder; `DLP_PROJECT_DIR` can be set when running the do-files from another working directory.

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

Compliance is defined in `scripts/03_export_stata_dataset.R` by comparing treatment assignment with observed implementation status. Schools with missing key identifiers are excluded from the analytic file and logged in `outputs/validation_na_schools/`.
