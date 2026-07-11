################################################################################
## TITLE   : 03_ppi_school_append.R
## PURPOSE : Append PPI scores and aggregate school-level PPI summaries.
## PROJECT : ESC-SHS-VP targeting descriptive statistics
## AUTHOR  : Erika Salvador
## DATE    : July 10, 2026
################################################################################

## This script starts from the cleaned, non-excluded records produced by
## 02_hfc_checks.R.
ppi_data <- hfc_results$clean_data

## CHANGE HERE THROUGH 00_master.R:
## config$school_column should identify the school field used for aggregation.
school_column_clean <- janitor::make_clean_names(
  gsub(intToUtf8(8217), "'", trimws(config$school_column), fixed = TRUE)
)

## PPI INPUT MAPPING:
## These survey fields are mapped to the Philippines 2023 PPI scorecard items.
## Update this block if the questionnaire labels or response options change.
ppi_input_columns <- setNames(
  as.list(janitor::make_clean_names(gsub(intToUtf8(8217), "'", trimws(c(
    "In which region does the household currently live?",
    "How many members are there in the household?",
    "How many members are under 18 years of age?",
    "What is the highest level of education completed by the household head?",
    "What is the main material of the dwelling's external walls?",
    "What is the household's main source of water supply for general activities (e.g. bathing, washing of dishes)?",
    "What is the main source of drinking water for the household?",
    "What type of cooking fuel does the household mainly use?",
    "Does the household own a refrigerator?",
    "Does the household own a rice cooker?"
  )), fixed = TRUE))),
  c(
    "region",
    "household_size",
    "members_under_18",
    "head_education",
    "wall_material",
    "water_general",
    "drinking_water",
    "cooking_fuel",
    "refrigerator",
    "rice_cooker"
  )
)

## PPI workbook dependency. The local file path is set in 00_master.R as
## config$ppi_scorecard_file. Download source: https://www.povertyindex.org/
scorecard_cells <- readxl::read_excel(
  config$ppi_scorecard_file,
  sheet = "Scorecard",
  col_names = FALSE,
  .name_repair = "minimal"
)

## Read and reshape the scorecard so each response option has a point value.
scorecard_header <- trimws(gsub("\\s+", " ", gsub("\n", " ", as.character(unlist(scorecard_cells[4, ], use.names = FALSE)), fixed = TRUE)))
scorecard_raw <- scorecard_cells[-seq_len(4), ]
names(scorecard_raw) <- scorecard_header
names(scorecard_raw)[1:3] <- c("question_no", "indicator", "response")

question_index <- which(!is.na(scorecard_raw$question_no))
indicator_index <- which(!is.na(scorecard_raw$indicator))
scorecard_raw$question_no <- rep(as.character(scorecard_raw$question_no[question_index]), diff(c(question_index, nrow(scorecard_raw) + 1)))
scorecard_raw$indicator <- rep(as.character(scorecard_raw$indicator[indicator_index]), diff(c(indicator_index, nrow(scorecard_raw) + 1)))
scorecard_raw <- scorecard_raw[!is.na(scorecard_raw$response), ]
scorecard_raw$response_clean <- trimws(gsub("\\s+", " ", gsub("[^a-z0-9]+", " ", tolower(gsub(intToUtf8(8217), "'", sub("^[A-Z]\\.\\s*", "", as.character(scorecard_raw$response)), fixed = TRUE)))))
scorecard_raw$indicator_clean <- trimws(gsub("\\s+", " ", gsub("[^a-z0-9]+", " ", tolower(gsub(intToUtf8(8217), "'", as.character(scorecard_raw$indicator), fixed = TRUE)))))

## Read the look-up table used to convert total PPI scores to poverty
## likelihoods under each income line.
lookup_cells <- readxl::read_excel(
  config$ppi_scorecard_file,
  sheet = "Look-up Table",
  col_names = FALSE,
  .name_repair = "minimal"
)

lookup_header <- trimws(gsub("\\s+", " ", gsub("\n", " ", as.character(unlist(lookup_cells[4, ], use.names = FALSE)), fixed = TRUE)))
lookup_raw <- lookup_cells[-seq_len(4), ]
names(lookup_raw) <- lookup_header
names(lookup_raw)[1] <- "ppi_score"
lookup_raw$ppi_score <- suppressWarnings(as.integer(lookup_raw$ppi_score))
lookup_raw <- lookup_raw[!is.na(lookup_raw$ppi_score), ]

poverty_lines <- setdiff(names(lookup_raw), "ppi_score")

for (line in poverty_lines) {
  lookup_raw[[line]] <- as.numeric(lookup_raw[[line]])
  score_column <- paste0("ppi_score_", make.names(line))
  ppi_data[[score_column]] <- 0
}

ppi_data$ppi_answered_items <- 0L
ppi_data$ppi_missing_items <- 0L
ppi_data$ppi_unmatched_items <- ""

## Normalize survey responses to the closest scorecard response categories.
## These mappings are the main place to tweak if real survey responses use
## different wording from the dummy data or PPI workbook.
region_value <- trimws(gsub("\\s+", " ", gsub("[^a-z0-9]+", " ", tolower(as.character(ppi_data[[ppi_input_columns$region]])))))
ppi_data$ppi_response_region <- NA_character_
ppi_data$ppi_response_region[grepl("region i|ilocos", region_value)] <- "ilocos region"
ppi_data$ppi_response_region[grepl("region ii|cagayan", region_value)] <- "cagayan valley"
ppi_data$ppi_response_region[grepl("region iii|central luzon", region_value)] <- "central luzon"
ppi_data$ppi_response_region[grepl("region iv a|region iva|calabarzon", region_value)] <- "calabarzon"
ppi_data$ppi_response_region[grepl("region v|bicol", region_value)] <- "bicol region"
ppi_data$ppi_response_region[grepl("region vi|western visayas", region_value)] <- "western visayas"
ppi_data$ppi_response_region[grepl("region vii|central visayas", region_value)] <- "central visayas"
ppi_data$ppi_response_region[grepl("region viii|eastern visayas", region_value)] <- "eastern visayas"
ppi_data$ppi_response_region[grepl("region ix|zamboanga", region_value)] <- "western mindanao"
ppi_data$ppi_response_region[grepl("region x|northern mindanao", region_value)] <- "northern mindanao"
ppi_data$ppi_response_region[grepl("region xi|davao", region_value)] <- "southern mindanao"
ppi_data$ppi_response_region[grepl("region xii|soccsksargen", region_value)] <- "central mindanao"
ppi_data$ppi_response_region[grepl("ncr|national capital", region_value)] <- "ncr"
ppi_data$ppi_response_region[grepl("car|cordillera", region_value)] <- "car"
ppi_data$ppi_response_region[grepl("caraga", region_value)] <- "caraga"
ppi_data$ppi_response_region[grepl("mimaropa", region_value)] <- "mimaropa"
ppi_data$ppi_response_region[grepl("barmm|bangsamoro", region_value)] <- "barmm"

household_size <- suppressWarnings(as.numeric(gsub("[^0-9.-]", "", as.character(ppi_data[[ppi_input_columns$household_size]]))))
ppi_data$ppi_response_household_size <- as.character(cut(household_size, breaks = c(-Inf, 2, 4, 7, Inf), labels = c("1 or 2 members", "3 or 4 members", "between 5 or 7 members", "8 or more member"), right = TRUE))

members_under_18 <- suppressWarnings(as.numeric(gsub("[^0-9.-]", "", as.character(ppi_data[[ppi_input_columns$members_under_18]]))))
ppi_data$ppi_response_members_under_18 <- as.character(cut(members_under_18, breaks = c(-Inf, 0, 1, 2, 3, Inf), labels = c("no children", "one children", "two children", "three children", "four or more children"), right = TRUE))

education_value <- trimws(gsub("\\s+", " ", gsub("[^a-z0-9]+", " ", tolower(as.character(ppi_data[[ppi_input_columns$head_education]])))))
ppi_data$ppi_response_head_education <- NA_character_
ppi_data$ppi_response_head_education[grepl("early|primary|elementary", education_value)] <- "early childhood education or primary"
ppi_data$ppi_response_head_education[grepl("secondary|high school|junior|senior", education_value)] <- "lower or upper secondary"
ppi_data$ppi_response_head_education[grepl("post secondary|vocational|short cycle|technical", education_value)] <- "post secondary non tertiary or short cycle tertiary"
ppi_data$ppi_response_head_education[grepl("bachelor|college", education_value)] <- "bachelor"
ppi_data$ppi_response_head_education[grepl("postgraduate|master|ph d|phd|doctor", education_value)] <- "postgraduate master or ph d"

wall_value <- trimws(gsub("\\s+", " ", gsub("[^a-z0-9]+", " ", tolower(as.character(ppi_data[[ppi_input_columns$wall_material]])))))
ppi_data$ppi_response_wall_material <- NA_character_
ppi_data$ppi_response_wall_material[grepl("concrete|brick|stone|glass", wall_value)] <- "concrete brick stone or glass"
ppi_data$ppi_response_wall_material[grepl("half|galvanized|aluminum|iron", wall_value)] <- "half concrete brick stone and half wood materials or galvanized iron aluminum"
ppi_data$ppi_response_wall_material[grepl("wood|bamboo|sawali|cogon|nipa|asbestos", wall_value)] <- "wood bamboo sawali cogon nipa or asbestos"
ppi_data$ppi_response_wall_material[grepl("makeshift|salvaged|improvised|other", wall_value)] <- "makeshift salvaged improvised or other"

water_value <- trimws(gsub("\\s+", " ", gsub("[^a-z0-9]+", " ", tolower(as.character(ppi_data[[ppi_input_columns$water_general]])))))
ppi_data$ppi_response_water_general <- NA_character_
ppi_data$ppi_response_water_general[grepl("dwelling", water_value)] <- "community water system piped into dwelling"
ppi_data$ppi_response_water_general[grepl("yard|plot|protected|well|borehole|spring|tanker|truck|peddler|neighbor", water_value)] <- "community water system piped into yard plot protected well tube well borehole developed spring tanker or truck peddler neighbor"
ppi_data$ppi_response_water_general[grepl("public|standpipe|unprotected|open dug|undeveloped", water_value)] <- "piped into public taps standpipe unprotected open dug well or undeveloped spring"
ppi_data$ppi_response_water_general[grepl("river|stream|pond|lake|dam|rainwater", water_value)] <- "river stream pond lake dam or rainwater"
ppi_data$ppi_response_water_general[grepl("other", water_value)] <- "other"

drink_value <- trimws(gsub("\\s+", " ", gsub("[^a-z0-9]+", " ", tolower(as.character(ppi_data[[ppi_input_columns$drinking_water]])))))
ppi_data$ppi_response_drinking_water <- NA_character_
ppi_data$ppi_response_drinking_water[grepl("dwelling|refilling|bottled", drink_value)] <- "piped into dwelling water refilling station or bottled water"
ppi_data$ppi_response_drinking_water[grepl("yard|plot|tube|borehole|protected|tanker|truck|cart|sachet", drink_value)] <- "piped to yard plot tubed well borehole protected well tanker truck cart with small tank or sachet water"
ppi_data$ppi_response_drinking_water[grepl("neighbor|public|stand|unprotected", drink_value)] <- "piped to neighbor public tap stand pipe unprotected well unprotected spring"
ppi_data$ppi_response_drinking_water[grepl("rainwater|surface|river|dam|lake|pond|stream|canal|irrigation", drink_value)] <- "rainwater or surface water river dam lake pond stream canal irrigation channel"
ppi_data$ppi_response_drinking_water[grepl("other", drink_value)] <- "other"

fuel_value <- trimws(gsub("\\s+", " ", gsub("[^a-z0-9]+", " ", tolower(as.character(ppi_data[[ppi_input_columns$cooking_fuel]])))))
ppi_data$ppi_response_cooking_fuel <- NA_character_
ppi_data$ppi_response_cooking_fuel[grepl("electric|lpg|natural gas|no food", fuel_value)] <- "electricity lpg natural gas or no food cooked in household"
ppi_data$ppi_response_cooking_fuel[grepl("biogas|kerosene", fuel_value)] <- "biogas or kerosene"
ppi_data$ppi_response_cooking_fuel[grepl("coal|lignite|charcoal|wood|straw|shrubs|grass|crop|dung", fuel_value)] <- "coal lignite charcoal wood straw shrubs grass agricultural crop or animal dung"
ppi_data$ppi_response_cooking_fuel[grepl("other", fuel_value)] <- "other"

refrigerator_value <- trimws(gsub("\\s+", " ", gsub("[^a-z0-9]+", " ", tolower(as.character(ppi_data[[ppi_input_columns$refrigerator]])))))
rice_cooker_value <- trimws(gsub("\\s+", " ", gsub("[^a-z0-9]+", " ", tolower(as.character(ppi_data[[ppi_input_columns$rice_cooker]])))))
ppi_data$ppi_response_refrigerator <- NA_character_
ppi_data$ppi_response_rice_cooker <- NA_character_
ppi_data$ppi_response_refrigerator[refrigerator_value %in% c("yes", "y", "oo")] <- "yes"
ppi_data$ppi_response_refrigerator[refrigerator_value %in% c("no", "n", "hindi")] <- "no"
ppi_data$ppi_response_rice_cooker[rice_cooker_value %in% c("yes", "y", "oo")] <- "yes"
ppi_data$ppi_response_rice_cooker[rice_cooker_value %in% c("no", "n", "hindi")] <- "no"

## Score each PPI item. Missing/unmatched item responses are tracked so the
## team can decide whether more response mappings are needed.
ppi_response_columns <- c(
  "ppi_response_region",
  "ppi_response_household_size",
  "ppi_response_members_under_18",
  "ppi_response_head_education",
  "ppi_response_wall_material",
  "ppi_response_water_general",
  "ppi_response_drinking_water",
  "ppi_response_cooking_fuel",
  "ppi_response_refrigerator",
  "ppi_response_rice_cooker"
)

ppi_indicator_patterns <- c(
  "region",
  "how many members are there",
  "under 18 years",
  "highest level of education",
  "external walls",
  "source of water supply",
  "source of drinking water",
  "cooking fuel",
  "refrigerator",
  "rice cooker"
)

ppi_item_names <- c(
  "region",
  "household_size",
  "members_under_18",
  "head_education",
  "wall_material",
  "water_general",
  "drinking_water",
  "cooking_fuel",
  "refrigerator",
  "rice_cooker"
)

for (item_index in seq_along(ppi_response_columns)) {
  response_column <- ppi_response_columns[item_index]
  matched_response <- ppi_data[[response_column]]
  choices <- scorecard_raw[grepl(ppi_indicator_patterns[item_index], scorecard_raw$indicator_clean, fixed = TRUE), ]

  ppi_data$ppi_answered_items <- ppi_data$ppi_answered_items + as.integer(!is.na(matched_response))
  ppi_data$ppi_missing_items <- ppi_data$ppi_missing_items + as.integer(is.na(matched_response))
  rows <- which(is.na(matched_response))
  ppi_data$ppi_unmatched_items[rows] <- paste(ppi_data$ppi_unmatched_items[rows], ppi_item_names[item_index], sep = "; ")

  for (line in poverty_lines) {
    score_column <- paste0("ppi_score_", make.names(line))
    points_by_response <- stats::setNames(as.numeric(choices[[line]]), choices$response_clean)
    points <- as.numeric(points_by_response[matched_response])
    points[is.na(points)] <- 0
    ppi_data[[score_column]] <- ppi_data[[score_column]] + points
  }
}

ppi_data$ppi_unmatched_items <- trimws(gsub("^;\\s*", "", ppi_data$ppi_unmatched_items))
ppi_data$ppi_unmatched_items[ppi_data$ppi_unmatched_items == ""] <- NA_character_
ppi_data$ppi_is_complete <- ppi_data$ppi_missing_items == 0

for (line in poverty_lines) {
  score_column <- paste0("ppi_score_", make.names(line))
  likelihood_column <- paste0("ppi_likelihood_", make.names(line))
  lookup_values <- stats::setNames(lookup_raw[[line]], lookup_raw$ppi_score)
  score <- as.integer(round(ppi_data[[score_column]]))
  ppi_data[[likelihood_column]] <- as.numeric(lookup_values[as.character(score)])
  ppi_data[[likelihood_column]][!ppi_data$ppi_is_complete] <- NA_real_
}

## Create school identifiers and aggregate learner-level PPI results to the
## school level. Change the parsing below if school IDs use a different format.
school_value <- trimws(as.character(ppi_data[[school_column_clean]]))
ppi_data$school_id_clean <- sub("^\\s*([0-9]{4,})\\b.*$", "\\1", school_value)
ppi_data$school_id_clean[ppi_data$school_id_clean == school_value] <- NA_character_
ppi_data$school_name_clean <- trimws(gsub("^\\s*[0-9]{4,}\\s*[-:]*\\s*", "", school_value))
ppi_data$school_name_clean[ppi_data$school_name_clean == ""] <- NA_character_
ppi_data$school_key_clean <- ppi_data$school_id_clean
ppi_data$school_key_clean[is.na(ppi_data$school_key_clean)] <- ppi_data$school_name_clean[is.na(ppi_data$school_key_clean)]

school_keys <- sort(unique(ppi_data$school_key_clean[!is.na(ppi_data$school_key_clean)]))
school_ppi <- data.frame(school_key_clean = school_keys, stringsAsFactors = FALSE)

school_ppi$school_ppi_n_learners <- as.integer(tabulate(match(ppi_data$school_key_clean, school_keys), nbins = length(school_keys)))
school_ppi$school_ppi_n_complete <- as.integer(tabulate(match(ppi_data$school_key_clean[ppi_data$ppi_is_complete], school_keys), nbins = length(school_keys)))

score_columns <- grep("^ppi_score_", names(ppi_data), value = TRUE)
likelihood_columns <- grep("^ppi_likelihood_", names(ppi_data), value = TRUE)

for (column_name in c(score_columns, likelihood_columns)) {
  aggregate_data <- aggregate(
    ppi_data[[column_name]],
    by = list(school_key_clean = ppi_data$school_key_clean),
    FUN = mean,
    na.rm = TRUE
  )
  names(aggregate_data)[2] <- paste0("school_mean_", column_name)
  school_ppi <- merge(school_ppi, aggregate_data, by = "school_key_clean", all.x = TRUE, sort = FALSE)
}

ppi_data <- merge(ppi_data, school_ppi, by = "school_key_clean", all.x = TRUE, sort = FALSE)

hfc_results$clean_data <- ppi_data
ppi_results <- list(
  data = ppi_data,
  school_ppi = school_ppi
)
