################################################################################
## TITLE   : 01_setup_and_load.R
## PURPOSE : Load the survey export and standardize variable names.
## PROJECT : ESC-SHS-VP targeting descriptive statistics
## AUTHOR  : Erika Salvador
## DATE    : July 10, 2026
################################################################################

## Required packages:
## - readxl reads the Excel survey export.
## - janitor converts long Google Form labels into stable snake_case names.
library(janitor)
library(readxl)

## INPUT DEPENDENCY:
## config$input_file and config$sheet are defined in 00_master.R.
## Change those values there when the real export is available.
raw_data <- readxl::read_excel(
  path = config$input_file,
  sheet = config$sheet
)

## Keep a plain data frame for simple base R checks downstream.
raw_data <- as.data.frame(raw_data, stringsAsFactors = FALSE)

## Standardize names once at load time. The original labels remain in the
## expected column list in 02_hfc_checks.R for readability and maintenance.
names(raw_data) <- janitor::make_clean_names(
  gsub(intToUtf8(8217), "'", trimws(names(raw_data)), fixed = TRUE)
)
