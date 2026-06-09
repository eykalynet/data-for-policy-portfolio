# 00_setup.R
# Project setup for the DLP assessment data cleaning workflow.

library(tidyverse)
library(janitor)
library(readr)
library(stringr)
library(dplyr)
library(ggplot2)

project_root <- getwd()

raw_dir <- file.path(project_root, "raw")
scripts_dir <- file.path(project_root, "scripts")
processed_dir <- file.path(project_root, "processed")
outputs_dir <- file.path(project_root, "outputs")
tables_dir <- file.path(outputs_dir, "tables")
figures_dir <- file.path(outputs_dir, "figures")
validation_na_dir <- file.path(outputs_dir, "validation_na_schools")
logs_dir <- file.path(outputs_dir, "logs")
docs_dir <- file.path(project_root, "docs")

dir.create(scripts_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(processed_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(outputs_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(validation_na_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(logs_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(docs_dir, showWarnings = FALSE, recursive = TRUE)

raw_files <- tibble(
  raw_file_name = basename(list.files(raw_dir, full.names = TRUE)),
  raw_file_path = list.files(raw_dir, full.names = TRUE)
)

write_csv(raw_files, file.path(logs_dir, "raw_files_found.csv"))

setup_log <- tibble(
  item = c(
    "project_root",
    "raw_dir",
    "processed_dir",
    "tables_dir",
    "figures_dir",
    "validation_na_dir",
    "logs_dir"
  ),
  path = c(
    project_root,
    raw_dir,
    processed_dir,
    tables_dir,
    figures_dir,
    validation_na_dir,
    logs_dir
  )
)

write_csv(setup_log, file.path(logs_dir, "setup_paths.csv"))

