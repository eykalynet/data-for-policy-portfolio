################################################################################
## TITLE   : 99_generate_dummy_data.py
## PURPOSE : Generate a dummy ESC-SHSV-VP survey workbook for workflow testing.
## PROJECT : ESC-SHSV-VP targeting descriptive statistics
## AUTHOR  : Erika Salvador
## DATE    : July 10, 2026
################################################################################

import re
from pathlib import Path

from openpyxl import Workbook

# The generator is portable: it locates the project folder based on this file.
# Run it from the project root with:
# python3 scripts/99_generate_dummy_data.py
project = Path(__file__).resolve().parents[1]
script = project / "scripts" / "02_hfc_checks.R"
raw_dir = project / "raw"
raw_dir.mkdir(parents=True, exist_ok=True)

# Pull the expected export headers from the HFC script so the dummy workbook
# stays aligned when the expected column list changes.
text = script.read_text()
block = text.split("expected_columns <- janitor::make_clean_names", 1)[1]
block = block.split(")), fixed = TRUE))", 1)[0]
columns = re.findall(r'"((?:[^"\\]|\\.)*)"', block)
columns = [bytes(col, "utf-8").decode("unicode_escape") for col in columns]
columns = [column for column in columns if column not in ("x", "'")]

# The rows below include one clean record and a few records with intentional
# issues, so the issue log has examples to review after a test run.
rows = []
base = {column: "" for column in columns}

row = base.copy()
row.update({
    "Timestamp": "2026-07-10 09:00:00",
    "Email Address": "ana.santos@example.com",
    "By filling up this form, you are giving permission to DepEd to collect and process all data in this form for research purposes.\n\nFurther, you are giving permission to be contacted by DepEd in the future to collect additional information.": "Yes",
    "LAST NAME": "Santos",
    "FIRST NAME": "Ana",
    "MIDDLE NAME": "Reyes",
    "Relationship with Learner": "Mother",
    "Contact Details": "09171234567",
    "Are you the household head?": "Yes",
    "How many members are there in the household?": "5",
    "How many members are under 18 years of age?": "2",
    "What is the highest level of education completed by the household head?": "Secondary / high school",
    "What is the primary occupation of the household head during the past six months?": "Service worker",
    "LAST NAME of Learner": "Santos",
    "FIRST NAME of Learner": "Miguel",
    "MIDDLE NAME of Learner": "Reyes",
    "Learner Reference Number": "123456789012",
    "Grade Level for SY 2026 - 2027": "Grade 7",
    "Region of School of Learner for SY 2026 - 2027": "NCR",
    "Schools DIvision Office of School of Learner for SY 2026 - 2027": "Manila",
    "School ID and School Name of Learner for SY 2026 - 2027": "305001 - Sample National High School",
    "School ID and School Name of Learner for SY 2025 - 2026": "305001 - Sample National High School",
    "In which region does the household currently live?": "NCR",
    "In which province does the household currently live?": "Metro Manila",
    "In which city/municipality does the household currently live?": "Manila",
    "What language is primarily spoken by the household?": "Filipino",
    "What is the main material of the dwelling's external walls?": "Concrete, brick, stone or glass",
    "Where does the learner usually study at home?": "Shared table",
    "What is the household's main source of water supply for general activities (e.g. bathing, washing of dishes)?": "Community water system piped into dwelling",
    "What is the main source of drinking water for the household?": "Water refilling station",
    "Where does the household often purchase food ingredients or ready-to-eat food?": "Public market",
    "How often does the learner consume home-cooked meals?": "Daily",
    "How often does the learner consume vegetables?": "Several times a week",
    "What type of cooking fuel does the household mainly use?": "LPG",
    "Does the household own a refrigerator?": "Yes",
    "Does the household own a rice cooker?": "Yes",
    "What program did your child apply for in SY 2026 - 2027": "ESC",
    "How did you learn about the Education Service Contracting (ESC)?": "School announcement",
    "Why did you apply to the ESC?": "To help with school expenses",
    "Is your child a previous recipient of the Education Service Contracting (ESC)?": "No",
    "If answered no in previous question,  what are the reason/s why your child is not a previous recipient of the ESC?": "First time applicant",
    "Which section/s and/or question/s were difficult to understand?": "None",
    "Kindly let us know below if you have any question or feedback regarding the questionnaire or the Education Service Contracting (ESC) and Senior High School Voucher Program (SHS VP) .": "No questions",
    "This survey is open to participants aged 18 years or older. In compliance with the Data Privacy Act of 2012, personal data collected from minors shall be handled with additional safeguards and parental consent. \n\nBy filling up this form, I confirm that I am 18 years or older.": "I confirm that I am 18 years or older.",
    "Date of Birth (MM/DD/YYYY)": "05/14/1985",
})
rows.append(row)

row = base.copy()
row.update({
    "Timestamp": "2026-07-10 10:15:00",
    "Email Address": "bad-email",
    "LAST NAME": "Dela Cruz",
    "FIRST NAME": "Jose",
    "Relationship with Learner": "Father",
    "Contact Details": "09175550111",
    "Are you the household head?": "Maybe",
    "How many members are there in the household?": "4",
    "How many members are under 18 years of age?": "5",
    "What is the highest level of education completed by the household head?": "Elementary",
    "LAST NAME of Learner": "Dela Cruz",
    "FIRST NAME of Learner": "Luis",
    "Learner Reference Number": "12345",
    "Grade Level for SY 2026 - 2027": "Grade 8",
    "Region of School of Learner for SY 2026 - 2027": "Region V",
    "Schools DIvision Office of School of Learner for SY 2026 - 2027": "Naga City",
    "School ID and School Name of Learner for SY 2026 - 2027": "305002 - Demo Integrated School",
    "In which region does the household currently live?": "Bicol Region",
    "In which province does the household currently live?": "Camarines Sur",
    "In which city/municipality does the household currently live?": "Naga",
    "What is the main material of the dwelling's external walls?": "Wood or bamboo",
    "What is the household's main source of water supply for general activities (e.g. bathing, washing of dishes)?": "Protected well",
    "What is the main source of drinking water for the household?": "Protected well",
    "What type of cooking fuel does the household mainly use?": "Charcoal",
    "Does the household own a refrigerator?": "No",
    "Does the household own a rice cooker?": "Yes",
    "What program did your child apply for in SY 2026 - 2027": "SHS VP",
    "Is your child a previous recipient of the Education Service Contracting (ESC)?": "No",
    "Date of Birth (MM/DD/YYYY)": "02/01/1990",
    "This survey is open to participants aged 18 years or older. In compliance with the Data Privacy Act of 2012, personal data collected from minors shall be handled with additional safeguards and parental consent. \n\nBy filling up this form, I confirm that I am 18 years or older.": "Yes",
})
rows.append(row)

row = base.copy()
row.update({
    "Timestamp": "2026-07-10 11:30:00",
    "Email Address": "minor@example.com",
    "LAST NAME": "Garcia",
    "FIRST NAME": "Lea",
    "Relationship with Learner": "Sibling",
    "Contact Details": "09170000000",
    "Are you the household head?": "No",
    "How many members are there in the household?": "6",
    "How many members are under 18 years of age?": "3",
    "LAST NAME of Learner": "Garcia",
    "FIRST NAME of Learner": "Marco",
    "Learner Reference Number": "999999999999",
    "Grade Level for SY 2026 - 2027": "Grade 11",
    "Region of School of Learner for SY 2026 - 2027": "Region VII",
    "School ID and School Name of Learner for SY 2026 - 2027": "305003 - Pilot Senior High School",
    "In which region does the household currently live?": "Central Visayas",
    "In which province does the household currently live?": "Cebu",
    "In which city/municipality does the household currently live?": "Cebu City",
    "What is the highest level of education completed by the household head?": "College",
    "What is the main material of the dwelling's external walls?": "Half concrete and half wood",
    "What is the household's main source of water supply for general activities (e.g. bathing, washing of dishes)?": "Piped into yard",
    "What is the main source of drinking water for the household?": "Bottled water",
    "What type of cooking fuel does the household mainly use?": "Electricity",
    "Does the household own a refrigerator?": "Yes",
    "Does the household own a rice cooker?": "No",
    "What program did your child apply for in SY 2026 - 2027": "SHS VP",
    "Is your child a previous recipient of the Education Service Contracting (ESC)?": "Yes",
    "Date of Birth (MM/DD/YYYY)": "01/15/2010",
    "This survey is open to participants aged 18 years or older. In compliance with the Data Privacy Act of 2012, personal data collected from minors shall be handled with additional safeguards and parental consent. \n\nBy filling up this form, I confirm that I am 18 years or older.": "No",
})
rows.append(row)

# Write the workbook to raw/. The master script reads this file by default.
wb = Workbook()
ws = wb.active
ws.title = "responses"
ws.append(columns)
for row in rows:
    ws.append([row.get(column, "") for column in columns])

for cell in ws[1]:
    cell.style = "Headline 4"

wb.save(raw_dir / "dummy_esc_shsv_vp_targeting_responses.xlsx")
