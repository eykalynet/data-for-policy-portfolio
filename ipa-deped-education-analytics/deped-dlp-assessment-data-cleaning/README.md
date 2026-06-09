# DLP Assessment Data Cleaning Workflow

This folder contains a reproducible R workflow for cleaning and merging the DLP school-level randomization dataset with Philippine Informal Reading Inventory (Phil-IRI) and Rapid Mathematics Assessment (RMA) school-level assessment datasets.

## Folder Structure

``` text
raw/                              # Original input files. Do not edit.
scripts/                          # R scripts, run in numbered order.
processed/                        # Cleaned and merged datasets.
outputs/tables/                   # CSV summaries, merge diagnostics, score checks.
outputs/figures/                  # PNG graphs.
outputs/validation_na_schools/    # Rows removed from analytic files because key school fields are missing.
outputs/logs/                     # Setup and run logs.
docs/                             # Data dictionary and cleaning notes.
```

## Raw Input Files

1.  `Final_DLP_Dataset_for_Randomization.csv`
2.  `DLP_randomized_schools_eval.csv`
3.  `Phil-IRI KS3 National Dashboard_Secondary - BoSY 2025-26_Table.csv`
4.  `Phil-IRI KS3 National Dashboard_Secondary - EoSY  2025-26_Table.csv`
5.  `RMA (KS3) National Dashboard_BoSY 2025-26 Assessment Results_Table.csv`
6.  `RMA (KS3) National Dashboard_EoSY 2025-26 Assessment Results_Table.csv`

## Cleaning Workflow

This workflow uses the following packages: `tidyverse`, `janitor`, `readr`, `stringr`, `dplyr`, and `ggplot2`.

Run scripts from the folder:

``` text
ipa-deped-education-analytics/deped-dlp-assessment-data-cleaning/
```

The scripts are:

``` text
scripts/00_setup.R
scripts/01_clean_dlp_randomization.R
scripts/02_clean_philiri.R
scripts/03_merge_philiri_to_dlp.R
scripts/04_clean_rma.R
scripts/05_merge_rma_to_dlp.R
scripts/06_create_scores_and_checks.R
scripts/07_create_graphs.R
scripts/99_run_all.R
```

## Merge Workflow

The DLP randomization file is the base school-level dataset. The main merge key is, for DLP, the `beis_school_id` variable, while for Phil-IRI/RMA, it is `school_id.` Merge diagnostics are saved in `outputs/tables/` and show matched records, unmatched records from DLP, and unmatched records from each assessment file.

## Score Creation Workflow

Phil-IRI score tables calculate Grade 7 to Grade 10 English reading category percentages against English assessed counts. The BoSY, or beginning-of-school-year, file uses 2-level and 3-level reading category columns. The EoSY, or end-of-school-year, file does not include 2-level or 3-level suffixes, so those counts are saved under both labels for consistency across outputs.

RMA score tables calculate Grade 7 to Grade 10 percentages for the not proficient, low proficient, nearly proficient, proficient, and high proficient groups.

## Validation and Discrepancy Checks

Rows with true `NA`, blank, or literal `"NA"` values in key school fields are removed from the main files and saved in `outputs/validation_na_schools/`.

Discrepancy checks compare summed category or proficiency counts against assessed counts. These checks are saved in `outputs/tables/`.

## Graphs

The graph script saves PNG files in `outputs/figures/`, including:

## How to Run in RStudio

1.  Open `deped-dlp-assessment-data-cleaning.Rproj` in RStudio.
2.  Confirm the working directory is `ipa-deped-education-analytics/deped-dlp-assessment-data-cleaning/`.
3.  Open `scripts/99_run_all.R`.
4.  Click **Source** to run the full workflow.

You can also run scripts one at a time in numbered order.

## Data Privacy Note

Raw and internal data is not committed publicly. Please contact DepEd.
