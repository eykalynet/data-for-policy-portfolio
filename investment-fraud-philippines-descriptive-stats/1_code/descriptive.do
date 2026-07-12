********************************************************************************
** TITLE   : descriptive.do
** PURPOSE : Export descriptive survey tables for portfolio-safe review.
** PROJECT : Investment fraud in the Philippines
** AUTHOR  : Erika Salvador
** DATE    : July 7, 2026
********************************************************************************

version 19
clear all
set more off
set min_memory 1g
set maxvar 32767

* Resolve paths relative to the project folder, with optional override.
local project_dir "`c(pwd)'"
if "$INVESTMENT_FRAUD_PROJECT_DIR" != "" local project_dir "$INVESTMENT_FRAUD_PROJECT_DIR"
capture confirm file "`project_dir'/1_code/descriptive.do"
if _rc {
    cd ..
    local project_dir "`c(pwd)'"
}

local encrypted_data_dir "`project_dir'/0_encrypted_data"
local code_dir "`project_dir'/1_code"
local output_dir "`project_dir'/2_outputs"
local output_date_dir "`output_dir'/2026-07-07"
local log_dir "`output_dir'/logs"

cap mkdir "`encrypted_data_dir'"
cap mkdir "`code_dir'"
cap mkdir "`output_dir'"
cap mkdir "`output_date_dir'"
cap mkdir "`log_dir'"

cap log close
log using "`log_dir'/descriptive.log", replace text

* The underlying survey data are encrypted/restricted and are not stored in this
* portfolio repository. Put the authorized local Stata file in 0_encrypted_data
* before rerunning this script.
local input "`encrypted_data_dir'/investment_preferences_deidsurvey.dta"
local outfile "`output_date_dir'/descriptive.xlsx"

capture confirm file "`input'"
if _rc {
    display as error "Encrypted input data were not found: `input'"
    display as error "This portfolio folder only includes code and aggregate outputs."
    exit 601
}

use "`input'", clear
gen long respondent_row = _n
local n_respondents = _N

putexcel set "`outfile'", replace
putexcel A1 = "Investment Fraud in the Philippines"
putexcel A2 = "Portfolio-safe descriptive tables"
putexcel A4 = "Data note"
putexcel B4 = "The underlying respondent-level survey data are encrypted/restricted and are not included in this repository."
putexcel A5 = "Repository contents"
putexcel B5 = "This folder contains the reproducible descriptive code and aggregate, non-identifying output workbook."
putexcel A7 = "Respondents in encrypted analytic file"
putexcel B7 = `n_respondents'
putexcel save

********************************************************************************
** Respondent profile
********************************************************************************

preserve
keep if !missing(gender)
contract gender, freq(count)
egen total = total(count)
gen percent = count / total
order gender count percent total
export excel using "`outfile'", sheet("profile_gender", replace) firstrow(variables) modify
restore

preserve
keep if !missing(age)
contract age, freq(count)
egen total = total(count)
gen percent = count / total
order age count percent total
export excel using "`outfile'", sheet("profile_age", replace) firstrow(variables) modify
restore

preserve
keep if !missing(urban_rural)
contract urban_rural, freq(count)
egen total = total(count)
gen percent = count / total
order urban_rural count percent total
export excel using "`outfile'", sheet("profile_urban_rural", replace) firstrow(variables) modify
restore

preserve
keep if !missing(income)
contract income, freq(count)
egen total = total(count)
gen percent = count / total
order income count percent total
export excel using "`outfile'", sheet("profile_income", replace) firstrow(variables) modify
restore

preserve
keep if !missing(education)
contract education, freq(count)
egen total = total(count)
gen percent = count / total
order education count percent total
export excel using "`outfile'", sheet("profile_education", replace) firstrow(variables) modify
restore

********************************************************************************
** Financial literacy and risk
********************************************************************************

preserve
keep if !missing(interest_rate)
contract interest_rate, freq(count)
egen total = total(count)
gen percent = count / total
order interest_rate count percent total
export excel using "`outfile'", sheet("literacy_interest_rate", replace) firstrow(variables) modify
restore

preserve
keep if !missing(inflation)
contract inflation, freq(count)
egen total = total(count)
gen percent = count / total
order inflation count percent total
export excel using "`outfile'", sheet("literacy_inflation", replace) firstrow(variables) modify
restore

preserve
keep if !missing(risk_div)
contract risk_div, freq(count)
egen total = total(count)
gen percent = count / total
order risk_div count percent total
export excel using "`outfile'", sheet("risk_diversification", replace) firstrow(variables) modify
restore

preserve
keep if !missing(risk_averse)
contract risk_averse, freq(count)
egen total = total(count)
gen percent = count / total
order risk_averse count percent total
export excel using "`outfile'", sheet("risk_preference", replace) firstrow(variables) modify
restore

********************************************************************************
** Investment products and information sources
********************************************************************************

preserve
quietly count
local n_respondents = r(N)
collapse (sum) investments_1 investments_2 investments_3 investments_4 ///
    investments_5 investments_6 investments_7 investments_8 investments_9 ///
    investments_10 investments__666 investments__777 investments__888 ///
    (count) respondent_count=respondent_row
xpose, clear varname
rename _varname item
rename v1 selected_count
drop if item == "respondent_count"
gen n_respondents = `n_respondents'
replace item = "Stocks or funds investing in stocks" if item == "investments_1"
replace item = "Real estate" if item == "investments_2"
replace item = "Fixed-term deposits or time deposits" if item == "investments_3"
replace item = "Bonds" if item == "investments_4"
replace item = "Venture capital or private equity" if item == "investments_5"
replace item = "Cryptocurrency" if item == "investments_6"
replace item = "Gold or other precious metals" if item == "investments_7"
replace item = "Business ownership or franchise" if item == "investments_8"
replace item = "Savings, alkansya, vest, or emergency fund" if item == "investments_9"
replace item = "Pag-IBIG MP2" if item == "investments_10"
replace item = "Other investment" if item == "investments__666"
replace item = "No investments" if item == "investments__777"
replace item = "Prefer not to say" if item == "investments__888"
gen selected_percent = selected_count / n_respondents
order item selected_count selected_percent n_respondents
export excel using "`outfile'", sheet("investment_products", replace) firstrow(variables) modify
restore

preserve
quietly count
local n_respondents = r(N)
collapse (sum) info_source_1 info_source_2 info_source_3 info_source_4 ///
    info_source_5 info_source_6 info_source_7 info_source__888 ///
    info_source__666 (count) respondent_count=respondent_row
xpose, clear varname
rename _varname item
rename v1 selected_count
drop if item == "respondent_count"
gen n_respondents = `n_respondents'
replace item = "Family, friends, or coworkers" if item == "info_source_1"
replace item = "Financial advisor, insurance agent, or bank" if item == "info_source_2"
replace item = "Social media" if item == "info_source_3"
replace item = "Online forums or group chats" if item == "info_source_4"
replace item = "Investment or trading apps" if item == "info_source_5"
replace item = "Television, radio, or newspapers" if item == "info_source_6"
replace item = "Government agencies" if item == "info_source_7"
replace item = "Does not seek investment information" if item == "info_source__888"
replace item = "Other source" if item == "info_source__666"
gen selected_percent = selected_count / n_respondents
order item selected_count selected_percent n_respondents
export excel using "`outfile'", sheet("information_sources", replace) firstrow(variables) modify
restore

********************************************************************************
** Fraud exposure
********************************************************************************

preserve
keep if !missing(fraud_history)
contract fraud_history, freq(count)
egen total = total(count)
gen percent = count / total
order fraud_history count percent total
export excel using "`outfile'", sheet("fraud_history", replace) firstrow(variables) modify
restore

preserve
keep if !missing(fraud_investment)
contract fraud_investment, freq(count)
egen total = total(count)
gen percent = count / total
order fraud_investment count percent total
export excel using "`outfile'", sheet("investment_fraud_history", replace) firstrow(variables) modify
restore

preserve
keep if !missing(fraud_history) & !missing(fraud_investment)
contract fraud_history fraud_investment, freq(count)
bysort fraud_history: egen fraud_history_total = total(count)
gen percent_within_fraud_history = count / fraud_history_total
order fraud_history fraud_investment count percent_within_fraud_history fraud_history_total
export excel using "`outfile'", sheet("fraud_crosstab", replace) firstrow(variables) modify
restore

********************************************************************************
** Image task ratings
********************************************************************************

preserve
keep respondent_row r1_invest_main_*
reshape long r1_invest_main_, i(respondent_row) j(slot)
rename r1_invest_main_ rating
capture confirm string variable rating
if !_rc {
    gen rating_numeric = real(substr(rating, 1, 1))
    drop rating
    rename rating_numeric rating
}
keep if !missing(rating)
contract slot rating, freq(count)
bysort slot: egen slot_total = total(count)
gen percent_within_slot = count / slot_total
export excel using "`outfile'", sheet("ratings_r1_invest_main", replace) firstrow(variables) modify
restore

preserve
keep respondent_row r1_invest_refer_*
reshape long r1_invest_refer_, i(respondent_row) j(slot)
rename r1_invest_refer_ rating
capture confirm string variable rating
if !_rc {
    gen rating_numeric = real(substr(rating, 1, 1))
    drop rating
    rename rating_numeric rating
}
keep if !missing(rating)
contract slot rating, freq(count)
bysort slot: egen slot_total = total(count)
gen percent_within_slot = count / slot_total
export excel using "`outfile'", sheet("ratings_r1_invest_refer", replace) firstrow(variables) modify
restore

preserve
keep respondent_row r1_fraud_check_*
reshape long r1_fraud_check_, i(respondent_row) j(slot)
rename r1_fraud_check_ rating
capture confirm string variable rating
if !_rc {
    gen rating_numeric = real(substr(rating, 1, 1))
    drop rating
    rename rating_numeric rating
}
keep if !missing(rating)
contract slot rating, freq(count)
bysort slot: egen slot_total = total(count)
gen percent_within_slot = count / slot_total
export excel using "`outfile'", sheet("ratings_r1_fraud_check", replace) firstrow(variables) modify
restore

preserve
keep respondent_row r2_invest_main_*
reshape long r2_invest_main_, i(respondent_row) j(slot)
rename r2_invest_main_ rating
capture confirm string variable rating
if !_rc {
    gen rating_numeric = real(substr(rating, 1, 1))
    drop rating
    rename rating_numeric rating
}
keep if !missing(rating)
contract slot rating, freq(count)
bysort slot: egen slot_total = total(count)
gen percent_within_slot = count / slot_total
export excel using "`outfile'", sheet("ratings_r2_invest_main", replace) firstrow(variables) modify
restore

preserve
keep respondent_row r2_fraud_check_*
reshape long r2_fraud_check_, i(respondent_row) j(slot)
rename r2_fraud_check_ rating
capture confirm string variable rating
if !_rc {
    gen rating_numeric = real(substr(rating, 1, 1))
    drop rating
    rename rating_numeric rating
}
keep if !missing(rating)
contract slot rating, freq(count)
bysort slot: egen slot_total = total(count)
gen percent_within_slot = count / slot_total
export excel using "`outfile'", sheet("ratings_r2_fraud_check", replace) firstrow(variables) modify
restore

di as text "descriptive.do completed: `c(current_date)' `c(current_time)'"
log close
