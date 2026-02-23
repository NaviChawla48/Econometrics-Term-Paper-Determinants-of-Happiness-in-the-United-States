log using "happiness_log.smcl", replace

*1.1: Setup and load data
clear all
set more off
cd "C:\Users\navic\Downloads\Econometrics"
use "GSS2024.dta", clear
describe happy income health marital educ degree age sex race region attend
tab happy

*1.2: Create independent and dependent variables
*Main binary outcome: 1 = very or pretty happy; 0 = not too happy
gen happy_bin = .
replace happy_bin = 1 if inlist(happy,1,2)  
replace happy_bin = 0 if happy == 3         
label define happy_bin_lab 0 "Not too happy" 1 "Very/pretty happy"
label values happy_bin happy_bin_lab
* Alternative 3-level numeric outcome for OLS robustness checks later
gen happy3 = .
replace happy3 = 3 if happy == 1   // very happy
replace happy3 = 2 if happy == 2   // pretty happy
replace happy3 = 1 if happy == 3   // not too happy
label define happy3_lab 1 "Not too happy" 2 "Pretty happy" 3 "Very happy"
label values happy3 happy3_lab
* Check for missingness
tab happy happy_bin, missing
sum happy3

*1.3: Clean and label predictors and controls
tab income, missing
tab health, missing
tab marital, missing
sum educ, detail
sum age, detail
tab sex
tab race
tab region
misstable summarize happy_bin income health marital educ age sex race region
* Create analysis sample
gen sample_main = 1
foreach v in happy_bin income health marital educ age sex race region {
    replace sample_main = 0 if missing(`v')
}
count if sample_main==1
count if sample_main==0

*1.4: Descriptive statistics and tables
* Distribution of happiness
tab happy, missing
tab happy_bin
* Summary stats (main sample only)
preserve
keep if sample_main==1
sum happy3 income educ age
* Categorical summaries
tab income
tab health
tab marital
tab sex
tab race
tab region
* Cross-tabs for intuition
tab happy_bin income
tab happy_bin health
tab happy_bin marital
restore

*1.5: Binary logit model
preserve
keep if sample_main==1
* Logit with robust SEs
logit happy_bin i.income i.health i.marital c.educ c.age i.sex i.race i.region, vce(robust)
estimates store logit_main
* Average marginal effects
margins, dydx(*) atmeans post
estimates store ame_main
restore

*1.6: OLS comparison model for robustness
preserve
keep if sample_main==1
reg happy3 i.income i.health i.marital c.educ c.age i.sex i.race i.region, vce(robust)
estimates store ols_main
restore

log close

translate "happiness_log.smcl" "happiness_log.txt", replace