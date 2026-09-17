#Running the full pipeline in order

source("Scripts/01_data_cleaning.R")
source("Scripts/02_EDA.R")
source("Scripts/03_descriptive_stats.R")
source("Scripts/04_ttest_waitingdays.R")
source("Scripts/05_chisq_sms.R")
source("Scripts/06_anova_agegroup.R")
source("Scripts/07_logistic_regression.R")
source("scripts/00_run_all.R")