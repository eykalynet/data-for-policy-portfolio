################################################################################
## TITLE   : 00_setup.R
## PURPOSE : Set packages, paths, folders, and raw-file logging.
## PROJECT : Dynamic Learning Program descriptive results
## AUTHOR  : Erika Salvador
## DATE    : June 11, 2026
################################################################################

library(tidyverse)
library(janitor)
library(readr)
library(stringr)
library(haven)

# Run this from the project folder.
project_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)

raw_dir <- file.path(project_root, "raw")
scripts_dir <- file.path(project_root, "scripts")
data_dir <- file.path(project_root, "data")
outputs_dir <- file.path(project_root, "outputs")
tables_dir <- file.path(outputs_dir, "tables")
figures_dir <- file.path(outputs_dir, "figures")
logs_dir <- file.path(outputs_dir, "logs")
validation_na_dir <- file.path(outputs_dir, "validation_na_schools")
docs_dir <- file.path(project_root, "docs")

# Make folders if they are not there yet.
dir.create(scripts_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(outputs_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(logs_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(validation_na_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(docs_dir, showWarnings = FALSE, recursive = TRUE)

# Read raw CSVs with the same missing-value rules each time.
standard_na_values <- c("", "NA", "N/A", "na", "n/a", "null", "NULL")
read_raw_csv <- function(path) {
  read_csv(
    path,
    col_types = cols(.default = col_character()),
    na = standard_na_values,
    show_col_types = FALSE
  ) |>
    clean_names() |>
    mutate(across(everything(), ~ str_squish(as.character(.x))))
}

# Save a quick list of raw files found in the folder.
raw_files <- tibble(
  raw_file_name = basename(list.files(raw_dir, full.names = TRUE)),
  raw_file_path = list.files(raw_dir, full.names = TRUE)
)

write_csv(raw_files, file.path(logs_dir, "00_raw_files_found.csv"))

setup_paths <- tibble(
  item = c(
    "project_root",
    "raw_dir",
    "scripts_dir",
    "data_dir",
    "tables_dir",
    "figures_dir",
    "logs_dir",
    "validation_na_dir",
    "docs_dir"
  ),
  path = c(
    project_root,
    raw_dir,
    scripts_dir,
    data_dir,
    tables_dir,
    figures_dir,
    logs_dir,
    validation_na_dir,
    docs_dir
  )
)

write_csv(setup_paths, file.path(logs_dir, "00_setup_paths.csv"))
