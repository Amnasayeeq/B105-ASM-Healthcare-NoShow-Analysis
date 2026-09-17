# Reducing No-Shows and Wait-Time Waste in Outpatient Healthcare

## Project Overview
This project conducts a comprehensive statistical analysis of the "Medical Appointment No Shows" dataset (~110,000 outpatient appointments, Vitoria, Brazil) to identify the key drivers of patient no-shows. The goal is to give an outpatient clinic data-driven guidance on which levers actually reduce wasted appointment slots, rather than applying the same blanket scheduling and reminder policy to every patient. The analysis progresses from exploratory data analysis to inferential testing and a predictive logistic regression model.

## Key Business Questions
1.	What percentage of the scheduled appointments is not attended? 
2.	Is there a difference in the likelihood of a no show appointment depending on the difference in days between booking the appointment and the appointment day (waiting time)? 
3.	Do SMS reminders actually have an impact on reducing no shows? 
4.	Is waiting time systematically different for each age group of patients? 
5.	How well can the combination of these factors predict a no show, and which of them is best able to do so?
   
## Methodology
The analysis was conducted in R and followed a structured workflow:
1. **Data Cleaning & Preparation:** Parsed scheduling/appointment dates, derived a `WaitingDays` feature, removed known data-entry errors (negative ages, impossible negative waits), and typed all categorical variables as factors.
2. **Exploratory Data Analysis (EDA):** Visualized distributions of age, waiting time, and no-show rate across SMS reminder status, age group, and scholarship status.
3. **Inferential Statistics:** Performed a Welch two-sample t-test (confirmed with Wilcoxon), a chi-squared test of independence, and a one-way ANOVA with an automatic Kruskal-Wallis fallback when residual normality was violated.
4. **Predictive Modelling:** Built a multiple logistic regression predicting no-show status from waiting time, SMS receipt, age, scholarship status, and chronic conditions (hypertension, diabetes, alcoholism), with a full assumption check — multicollinearity (VIF), linearity of the logit (Box-Tidwell), and influential points (Cook's distance) — followed by an 80/20 train/test evaluation.

## Key Findings
* **Waiting time is the clearest actionable risk factor.** Each additional day between booking and the appointment is associated with roughly a 2% increase in the odds of a no-show (OR = 1.02, p < .001) — small per day, but it compounds for bookings made far in advance.
* **SMS reminders correlate with *higher*, not lower, no-show odds (OR = 1.42, p < .001) — and this is a confounding effect, not a causal one.** Reminders in this dataset were not randomly assigned, so this is best read as evidence that reminders were preferentially sent to already-higher-risk bookings, not that reminders themselves backfire. A randomized A/B test would be needed to establish the true causal effect before changing reminder policy.
* **No-show risk is predictable but not strongly so.** The logistic regression achieved a McFadden's pseudo-R² of 0.040 and a test-set AUC of 0.665 — a real, statistically significant signal (age, scholarship status, diabetes, and alcoholism were all significant predictors too), but not yet a strong standalone predictive tool.

## Repository Structure
* `/EDA-results/`: Plots and visuals from the initial exploratory data analysis.
* `/Results/`: Plots and tables generated during hypothesis testing (t-test, chi-squared, ANOVA) and the logistic regression model.
* `/data/`: Contains the raw and cleaned appointment datasets.
* `/descriptive-stats-results/`: Summary statistics and frequency tables in CSV format.
* `/scripts/`: All R scripts used for the analysis, numbered in pipeline order (`00_run_all.R` runs everything).
* `Amna - B105 Applied Statistical Modeling - Final Report.pdf`: The complete report, including all methodologies, assumption checks, interpretations, and business recommendations.

## How to Use This Repository
To replicate this analysis, follow these steps:

1. **Clone the repository** to your local machine using Git:
```
git clone "https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git"
```

2. **Get the dataset:** Download `KaggleV2-May-2016.csv` from [Kaggle's "Medical Appointment No Shows"](https://www.kaggle.com/datasets/joniarroba/noshowappointments), rename it `appointments_raw.csv`, and place it in the `data/` folder.

3. **Set the working directory in R:** Open R or RStudio, and before running any scripts, set your working directory to the root of the cloned folder:
```r
# Example:
setwd("./YOUR-REPO-NAME")
```

4. **Run the scripts:** Run `scripts/00_run_all.R` to execute the full pipeline in order, or run the numbered scripts individually. Install the packages listed at the top of each script first (`tidyverse`, `car`, `pROC`, `broom`).
