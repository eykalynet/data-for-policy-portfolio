# DLP Assessment Data Cleaning and Descriptive Statistics

This folder contains the R and Stata scripts for the DLP school-level descriptive statistics. Raw files stay untouched; cleaned data is written to `data/`, and tables, figures, logs, and validation files are written to `outputs/`.

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

The R and Stata scripts use paths relative to the folder above. If needed, the Stata scripts also accept a `DLP_PROJECT_DIR` global pointing to this folder.

The main scripts are:

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
scripts/99_run_all.R
```

`scripts/99_run_all.R` runs the R portion through the Stata export. Then run the Stata do-files in order:

```stata
do scripts/04_descriptive_stats.do
do scripts/05_compliance_checks.do
do scripts/06_visualizations.do
do scripts/07_geographic_summaries.do
```

Finally, rebuild the Word results brief:

```bash
python3 scripts/12_create_results_brief.py
```

The two Python document scripts use `pandas`, `openpyxl`, and `python-docx`.

The Stata visualization scripts install/use the IPA graph scheme:

```stata
net install github, from("https://haghish.github.io/github/")
github install PovertyAction/ipaplots, replace
set scheme ipaplots, perm
```

## Final Data Outputs

```text
data/01_dlp_rma_philiri_school_level_full.csv
data/02_dlp_rma_philiri_school_level_percentages.csv
data/03_dlp_rma_philiri_school_level_for_stata.dta
data/03_dlp_rma_philiri_school_level_for_stata.csv
```

## Main Outputs

The Stata scripts generate:

- `outputs/tables/04_*`: overall dataset snapshot, treatment status subgroup counts, enrollment/assessment totals, and proficiency summaries by grade, treatment status, region, and assignment group.
- `outputs/tables/05_*`: school, municipality, division, region, and assignment-group compliance summaries.
- `outputs/descriptive_results_brief.docx`: short Word brief explaining the main descriptive results.
- `outputs/figures/individual_figures/06_*`: individual IPA-themed PNG figures for treatment status, beginning- and end-of-school-year enrollment/assessment counts, Rapid Mathematics Assessment proficiency, Philippine Informal Reading Inventory reading categories, and compliance by assignment group.
- `outputs/tables/07_*`: region, division, and city/municipality summaries, including map-ready CSVs for Google Sheets or GIS joins.
- `outputs/figures/individual_figures/07_*`: individual IPA-themed PNG figures for regional treatment status, regional compliance, division compliance, beginning- and end-of-school-year assessment coverage, and regional assessment coverage balance.
- `outputs/logs/04_descriptive_stats.log`, `05_compliance_checks.log`, `06_visualizations.log`, and `07_geographic_summaries.log`.

The current raw files do not include latitude/longitude or boundary geometry, so the workflow does not generate a choropleth map directly. The `07_*_map_ready.csv` files are structured for joining to PSGC or other administrative boundary data if those files become available. Figures use the installed `ipaplots` Stata scheme and are exported directly as PNG files.

## Compliance Definition

Compliance is coded in `scripts/03_export_stata_dataset.R` before export to Stata:

- Assigned `control` and raw `rev_status == 0`: compliant.
- Assigned `mainstream`, `shifting`, or `emergency` and raw `rev_status == 1`: compliant.
- Otherwise: non-compliant.

Assignment group is derived from the randomization fields `pilot_ratio`, `pilot_shift`, and `pilot_cancel`.

## Validation

Rows with true `NA`, blank, or literal `"NA"` values in key school fields are excluded from the analytic file and saved to:

```text
outputs/validation_na_schools/01_schools_with_missing_key_fields.csv
```

Merge diagnostics and score checks are saved as numbered files in `outputs/tables/`.
