# Investment Fraud in the Philippines Descriptive Statistics

This folder contains a portfolio-safe descriptive statistics workflow for the Investment Fraud in the Philippines survey. The respondent-level data are encrypted and restricted, so they are not included in this repository. This folder only contains reproducible analysis code and aggregate, non-identifying descriptive outputs.

## Run Order

Run the workflow from `investment-fraud-philippines-descriptive-stats/`.

```text
1_code/descriptive.do
```

Before rerunning the script, authorized users should place the encrypted local Stata file here:

```text
0_encrypted_data/investment_preferences_deidsurvey.dta
```

The script exports descriptive tables to:

```text
2_outputs/2026-07-07/descriptive.xlsx
```

## Main Outputs

```text
2_outputs/2026-07-07/descriptive.xlsx
```

The workbook contains aggregate descriptive summaries for respondent profile variables, financial literacy and risk items, investment products, information sources, fraud exposure, and image-task ratings.

## Notes

The encrypted survey file and any respondent-level raw or intermediate data should stay outside GitHub. The included workbook is intended as a non-identifying portfolio artifact, while the do-file shows the analysis structure used to generate it.
