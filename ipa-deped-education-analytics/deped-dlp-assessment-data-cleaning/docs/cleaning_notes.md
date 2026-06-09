# Cleaning Notes

## General Standards

- Raw files in `raw/` are never edited.
- All imported datasets use `janitor::clean_names()` so names are lower case with underscores.
- School ID variables are stored as character variables.
- Non-ID character variables are converted to factors in cleaned datasets.
- Rows with true `NA`, blank, or literal `"NA"` values in key school fields are removed from the main analytic files and saved separately in `outputs/validation_na_schools/`.

## DLP Randomization File

The main DLP base file is `Final_DLP_Dataset_for_Randomization.csv`.

The smaller file `DLP_randomized_schools_eval.csv` is read and joined by `beis_school_id` to bring in `randomized_eval_id` and `rev_status` when available.

Rows are dropped from the main DLP analytic file when any of these key fields are missing:

- `beis_school_id`
- `region_code`
- `division_code`
- `full_division_code`

Dropped rows are saved as:

- `outputs/validation_na_schools/dlp_rows_missing_key_school_fields.csv`

## Merge Key

The main merge uses:

- DLP: `beis_school_id`
- Phil-IRI/RMA: `school_id`

The scripts also retain school names, region, division, district, and municipality fields from the assessment files so unmatched records can be reviewed manually.

## Phil-IRI Notes

The BoSY file has explicit English 2-level and 3-level reading category columns.

The EoSY file has English frustration, instructional, and independent columns without 2-level or 3-level suffixes. Based on project guidance, EoSY `frustration` and `instructional` are treated as comparable to the BoSY below-grade reading level categories, while EoSY `independent` is treated as comparable to BoSY `grade_ready`.

The workflow saves the EoSY counts under both `2-level` and `3-level` labels so outputs have consistent structure across time points.

## RMA Notes

RMA scores are calculated for these proficiency groups:

- not proficient
- low proficient
- nearly proficient
- proficient
- high proficient

Percentages use grade-level assessed counts as the denominator.
