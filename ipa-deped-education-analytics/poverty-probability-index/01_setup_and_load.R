###############################################################################
# Setup and data loading
#
# This script intentionally stays flat and procedural.
# Update config$input_file and config$sheet in 00_master.R.
###############################################################################

library(janitor)
library(readxl)

raw_data <- readxl::read_excel(
  path = config$input_file,
  sheet = config$sheet
)

raw_data <- as.data.frame(raw_data, stringsAsFactors = FALSE)
names(raw_data) <- janitor::make_clean_names(
  gsub(intToUtf8(8217), "'", trimws(names(raw_data)), fixed = TRUE)
)
