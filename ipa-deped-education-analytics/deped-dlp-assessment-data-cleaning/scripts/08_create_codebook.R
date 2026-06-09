# 08_create_codebook.R
# Create a codebook for the final merged school-level analytic dataset.

source("scripts/00_setup.R")

final_dataset <- read_rds(file.path(processed_dir, "dlp_with_all_assessments_merged.rds"))

codebook <- tibble(
  variable_name = names(final_dataset),
  r_class = map_chr(final_dataset, ~ class(.x)[1])
) %>%
  mutate(
    source_dataset = case_when(
      str_starts(variable_name, "philiri_bosy_") ~ "Phil-IRI BoSY",
      str_starts(variable_name, "philiri_eosy_") ~ "Phil-IRI EoSY",
      str_starts(variable_name, "rma_bosy_") ~ "RMA BoSY",
      str_starts(variable_name, "rma_eosy_") ~ "RMA EoSY",
      variable_name %in% c("randomized_eval_id", "rev_status") ~ "DLP randomized schools eval",
      TRUE ~ "DLP randomization"
    ),
    source_file = case_when(
      str_starts(variable_name, "philiri_bosy_") ~ "Phil-IRI KS3 National Dashboard_Secondary - BoSY 2025-26_Table.csv",
      str_starts(variable_name, "philiri_eosy_") ~ "Phil-IRI KS3 National Dashboard_Secondary - EoSY 2025-26_Table.csv",
      str_starts(variable_name, "rma_bosy_") ~ "RMA (KS3) National Dashboard_BoSY 2025-26 Assessment Results_Table.csv",
      str_starts(variable_name, "rma_eosy_") ~ "RMA (KS3) National Dashboard_EoSY 2025-26 Assessment Results_Table.csv",
      variable_name %in% c("randomized_eval_id", "rev_status") ~ "DLP_randomized_schools_eval.csv",
      TRUE ~ "Final_DLP_Dataset_for_Randomization.csv"
    ),
    time_point = case_when(
      str_detect(variable_name, "_bosy_") ~ "BoSY",
      str_detect(variable_name, "_eosy_") ~ "EoSY",
      TRUE ~ NA_character_
    ),
    assessment = case_when(
      str_starts(variable_name, "philiri_") ~ "Phil-IRI",
      str_starts(variable_name, "rma_") ~ "RMA",
      TRUE ~ NA_character_
    ),
    grade_level = str_extract(variable_name, "g10|g7|g8|g9"),
    grade_level = case_when(
      grade_level == "g7" ~ "Grade 7",
      grade_level == "g8" ~ "Grade 8",
      grade_level == "g9" ~ "Grade 9",
      grade_level == "g10" ~ "Grade 10",
      TRUE ~ NA_character_
    ),
    language = case_when(
      str_detect(variable_name, "_fil_") | str_detect(variable_name, "total_fil_") ~ "Filipino",
      str_detect(variable_name, "_eng_") | str_detect(variable_name, "total_eng_") ~ "English",
      TRUE ~ NA_character_
    ),
    sex = case_when(
      str_ends(variable_name, "_m") ~ "Male",
      str_ends(variable_name, "_f") ~ "Female",
      TRUE ~ NA_character_
    ),
    measure_group = case_when(
      str_detect(variable_name, "school_id|beis_school_id|region|division|district|municipality|school_name") ~ "school identifier or location",
      str_detect(variable_name, "^enroll|total_enrolled") ~ "enrollment",
      str_detect(variable_name, "assessed|total_assessed") ~ "assessment coverage",
      str_detect(variable_name, "grade_ready|frustration|instructional|independent") ~ "Phil-IRI reading category",
      str_detect(variable_name, "emerging|developing|transitioning|at_grade_level|proficient") ~ "RMA proficiency category",
      str_detect(variable_name, "^dropout") ~ "dropout rate",
      str_detect(variable_name, "^jhs_") ~ "JHS school resources",
      str_detect(variable_name, "^cancel") ~ "class cancellation history",
      str_detect(variable_name, "^pilot") ~ "pilot cancellation variables",
      str_detect(variable_name, "randomized_eval_id|rev_status") ~ "randomization evaluation metadata",
      TRUE ~ "school characteristic"
    ),
    data_type = case_when(
      str_detect(variable_name, "school_id|beis_school_id|region_code|division_code|municipality_code|full_division_code|full_municipality_code|randomized_eval_id") ~ "school id or code",
      r_class %in% c("numeric", "integer", "double") ~ "numeric",
      r_class == "factor" ~ "categorical",
      r_class == "character" ~ "text",
      TRUE ~ r_class
    ),
    description = case_when(
      variable_name == "row_number_from_source_file" ~ "Original row number or unnamed index column from the DLP randomization source file.",
      variable_name == "region_code" ~ "Region code from the DLP randomization file.",
      variable_name == "division_code" ~ "Division code from the DLP randomization file.",
      variable_name == "municipality_code" ~ "Municipality code from the DLP randomization file.",
      variable_name == "full_division_code" ~ "Full division code from the DLP randomization file.",
      variable_name == "full_municipality_code" ~ "Full municipality code from the DLP randomization file.",
      variable_name == "beis_school_id" ~ "BEIS school ID. This is the main school-level merge key used to attach Phil-IRI and RMA records.",
      variable_name == "implementing_unit" ~ "Implementing unit classification from the DLP randomization file.",
      variable_name == "modified_coc" ~ "Modified curriculum or class organization classification from the DLP randomization file.",
      variable_name == "school_type" ~ "School type from the DLP randomization file.",
      variable_name == "randomized_eval_id" ~ "School ID from the DLP randomized schools evaluation file, joined by BEIS school ID.",
      variable_name == "rev_status" ~ "Randomization evaluation status from the DLP randomized schools evaluation file. This indicates whether the school is in the control group or not.",
      str_detect(variable_name, "^enroll_g(7|8|9|10)_[mf]$") ~ paste0("DLP enrollment count for ", grade_level, ", ", str_to_lower(sex), " students."),
      str_detect(variable_name, "^enroll_sn_ed_ngjhs_[mf]$") ~ paste0("DLP enrollment count for SNEd non-graded junior high school, ", str_to_lower(sex), " students."),
      variable_name == "enroll_total_jhs_m" ~ "Total DLP junior high school enrollment count for male students.",
      variable_name == "enroll_total_jhs_f" ~ "Total DLP junior high school enrollment count for female students.",
      variable_name == "enroll_total_jhs_all" ~ "Total DLP junior high school enrollment count for all students.",
      str_detect(variable_name, "^dropout_rate_g(7|8|9|10)_[mf]$") ~ paste0("DLP dropout rate for ", grade_level, ", ", str_to_lower(sex), " students."),
      str_detect(variable_name, "^dropout_rate_sn_ed_ngjhs_[mf]$") ~ paste0("DLP dropout rate for SNEd non-graded junior high school, ", str_to_lower(sex), " students."),
      variable_name == "dropout_rate_total_jhs_m" ~ "Total junior high school dropout rate for male students.",
      variable_name == "dropout_rate_total_jhs_f" ~ "Total junior high school dropout rate for female students.",
      variable_name == "dropout_rate_total_jhs_all" ~ "Total junior high school dropout rate for all students.",
      variable_name == "jhs_instructional_rooms" ~ "Number of junior high school instructional rooms.",
      variable_name == "jhs_classroom_ratio" ~ "Junior high school classroom ratio.",
      variable_name == "jhs_seats" ~ "Number of junior high school seats.",
      variable_name == "jhs_seat_ratio" ~ "Junior high school seat ratio.",
      variable_name == "jhs_toilet" ~ "Number of junior high school toilets.",
      variable_name == "jhs_toilet_ratio" ~ "Junior high school toilet ratio.",
      variable_name == "jhs_computer" ~ "Number of junior high school computers.",
      variable_name == "jhs_computer_ratio" ~ "Junior high school computer ratio.",
      variable_name == "jhs_teacher" ~ "Number of junior high school teachers.",
      variable_name == "jhs_teacher_ratio" ~ "Junior high school teacher ratio.",
      str_detect(variable_name, "^cancel_[0-9]{4}$") ~ paste0("Class cancellation count or indicator for ", str_extract(variable_name, "[0-9]{4}"), "."),
      variable_name == "cancel_total_20162023" ~ "Total class cancellations from 2016 to 2023.",
      variable_name == "cancel_average_20162023" ~ "Average class cancellations from 2016 to 2023.",
      variable_name == "pilot_cancel" ~ "Pilot cancellation measure from the DLP randomization file.",
      variable_name == "pilot_ratio" ~ "Pilot cancellation ratio from the DLP randomization file.",
      variable_name == "pilot_shift" ~ "Pilot shift measure from the DLP randomization file.",
      str_detect(variable_name, "^(philiri|rma)_(bosy|eosy)_region$") ~ paste0(source_dataset, " region name from the assessment dashboard."),
      str_detect(variable_name, "^(philiri|rma)_(bosy|eosy)_division$") ~ paste0(source_dataset, " division name from the assessment dashboard."),
      str_detect(variable_name, "^philiri_(bosy|eosy)_district$") ~ paste0(source_dataset, " district name from the Phil-IRI dashboard."),
      str_detect(variable_name, "^rma_(bosy|eosy)_municipality$") ~ paste0(source_dataset, " municipality name from the RMA dashboard."),
      str_detect(variable_name, "^(philiri|rma)_(bosy|eosy)_school_name$") ~ paste0(source_dataset, " school name from the assessment dashboard."),
      str_detect(variable_name, "^philiri_(bosy|eosy)_total_enrolled_g7_g10$") ~ paste0(source_dataset, " total enrolled count for Grades 7 to 10."),
      str_detect(variable_name, "^philiri_(bosy|eosy)_total_assessed_g7_g10$") ~ paste0(source_dataset, " total assessed count for Grades 7 to 10."),
      str_detect(variable_name, "^philiri_eosy_total_(fil|eng)_frustration$") ~ paste0(source_dataset, " total ", str_to_lower(language), " count in the frustration reading category."),
      str_detect(variable_name, "^philiri_eosy_total_(fil|eng)_instructional$") ~ paste0(source_dataset, " total ", str_to_lower(language), " count in the instructional reading category."),
      str_detect(variable_name, "^philiri_eosy_total_(fil|eng)_independent$") ~ paste0(source_dataset, " total ", str_to_lower(language), " count in the independent category. Project guidance treats EoSY independent as comparable to BoSY grade_ready."),
      str_detect(variable_name, "^philiri_(bosy|eosy)_g(7|8|9|10)_(fil|eng)_assessed$") ~ paste0(source_dataset, " ", language, " assessed count for ", grade_level, "."),
      str_detect(variable_name, "^philiri_bosy_g(7|8|9|10)_(fil|eng)_grade_ready$") ~ paste0(source_dataset, " ", language, " grade-ready count for ", grade_level, "."),
      str_detect(variable_name, "^philiri_bosy_g(7|8|9|10)_(fil|eng)_(frustration|instructional|independent)_2level$") ~ paste0(source_dataset, " ", language, " ", str_extract(variable_name, "frustration|instructional|independent"), " count for ", grade_level, " using the 2-level grouping."),
      str_detect(variable_name, "^philiri_bosy_g(7|8|9|10)_(fil|eng)_(frustration|instructional|independent)_3level$") ~ paste0(source_dataset, " ", language, " ", str_extract(variable_name, "frustration|instructional|independent"), " count for ", grade_level, " using the 3-level grouping."),
      str_detect(variable_name, "^philiri_eosy_g(7|8|9|10)_(fil|eng)_frustration$") ~ paste0(source_dataset, " ", language, " frustration count for ", grade_level, "."),
      str_detect(variable_name, "^philiri_eosy_g(7|8|9|10)_(fil|eng)_instructional$") ~ paste0(source_dataset, " ", language, " instructional count for ", grade_level, "."),
      str_detect(variable_name, "^philiri_eosy_g(7|8|9|10)_(fil|eng)_independent$") ~ paste0(source_dataset, " ", language, " independent count for ", grade_level, ". Project guidance treats EoSY independent as comparable to BoSY grade_ready."),
      str_detect(variable_name, "^rma_(bosy|eosy)_total_enrolled$") ~ paste0(source_dataset, " total enrolled count."),
      str_detect(variable_name, "^rma_(bosy|eosy)_total_assessed$") ~ paste0(source_dataset, " total assessed count."),
      str_detect(variable_name, "^rma_(bosy|eosy)_(emerging|developing|transitioning|at_grade_level)") ~ paste0(source_dataset, " overall proficiency category count."),
      str_detect(variable_name, "^rma_(bosy|eosy)_total_(emerging|developing|transitioning|at_grade_level)") ~ paste0(source_dataset, " total proficiency category count."),
      str_detect(variable_name, "^rma_(bosy|eosy)_g(7|8|9|10)_assessed$") ~ paste0(source_dataset, " assessed count for ", grade_level, "."),
      str_detect(variable_name, "^rma_(bosy|eosy)_g(7|8|9|10)_emerging_not_proficient$") ~ paste0(source_dataset, " not proficient count for ", grade_level, "."),
      str_detect(variable_name, "^rma_(bosy|eosy)_g(7|8|9|10)_emerging_low_proficient$") ~ paste0(source_dataset, " low proficient count for ", grade_level, "."),
      str_detect(variable_name, "^rma_(bosy|eosy)_g(7|8|9|10)_developing_nearly_proficient$") ~ paste0(source_dataset, " nearly proficient count for ", grade_level, "."),
      str_detect(variable_name, "^rma_(bosy|eosy)_g(7|8|9|10)_transitioning_proficient$") ~ paste0(source_dataset, " proficient count for ", grade_level, "."),
      str_detect(variable_name, "^rma_(bosy|eosy)_g(7|8|9|10)_at_grade_level_highly_proficient$") ~ paste0(source_dataset, " high proficient count for ", grade_level, "."),
      TRUE ~ "Variable retained from the source file. Review source documentation for an official definition."
    )
  ) %>%
  select(
    variable_name,
    source_dataset,
    source_file,
    measure_group,
    data_type,
    r_class,
    description
  )

codebook_markdown <- codebook %>%
  mutate(across(everything(), ~ replace_na(as.character(.x), "")))

write_csv(codebook, file.path(docs_dir, "codebook.csv"))

write_lines(
  c(
    "# Codebook",
    "",
    "This codebook describes the variables in `processed/dlp_with_all_assessments_merged.csv`, the main merged school-level analytic dataset.",
    "",
    "The codebook is generated by `scripts/08_create_codebook.R` from the final merged `.rds` file so variable names stay aligned with the analytic dataset.",
    "",
    "| Variable | Source Dataset | Source File | Group | Data Type | R Class | Description |",
    "|---|---|---|---|---|---|---|",
    paste0(
      "| `", codebook_markdown$variable_name, "` | ",
      codebook_markdown$source_dataset, " | ",
      codebook_markdown$source_file, " | ",
      codebook_markdown$measure_group, " | ",
      codebook_markdown$data_type, " | ",
      codebook_markdown$r_class, " | ",
      codebook_markdown$description, " |"
    )
  ),
  file.path(docs_dir, "codebook.md")
)
