################################################################################
## TITLE   : 00_master.R
## PURPOSE : Run the modular R analogue of the IPA DMS workflow
## PROJECT : PPI DMS training demo
## AUTHOR  : Erika Salvador
## DATE    : June 29, 2026
################################################################################

# Unfortunately, IPA only has a Stata version of the official DMS library
# (`ipacheck`). Nonetheless, this R workflow mirrors the same training logic so
# we can understand what each DMS check is doing even when working in R.
#
# Of course, as a caveat, this is not a replacement for the official Stata 
# `ipacheck` package. It is, nonetheless, a lightweight teaching analogue that 
# creates comparable CSV outputs.

library(dplyr)
library(haven)
library(readr)
library(readxl)

dir.create("r/outputs", recursive = TRUE, showWarnings = FALSE)

ppi_vars <- paste0("ppi_q", 1:10, c(
  "_floor_solid",
  "_has_toilet",
  "_has_electricity",
  "_has_tv",
  "_has_fridge",
  "_head_completed_primary",
  "_roof_durable",
  "_has_mobile_phone",
  "_owns_livestock",
  "_has_savings"
))

# First, we load data and helper files.
source("r/scripts/01_setup_and_load.R")

# Then, we run survey-level high-frequency checks.
source("r/scripts/02_survey_hfc_checks.R")

# Next, we create media outputs, dashboards, and tracking outputs.
source("r/scripts/03_media_dashboards_tracking.R")

# Finally, we create a codebook and compare survey vs. backcheck data.
source("r/scripts/04_backcheck_and_codebook.R")
