#EDA for Descriptive statistics 
library(tidyverse)

data <- read.csv("data/appointments_clean.csv")

#nnumeric summary 
#overall & split by outcome
numeric_summary <- data %>%
  summarise(
    Variable = "Age",
    Mean = mean(Age), Median = median(Age), SD = sd(Age),
    Min = min(Age), Max = max(Age)
  ) %>%
  bind_rows(
    data %>% summarise(
      Variable = "WaitingDays",
      Mean = mean(WaitingDays), Median = median(WaitingDays), SD = sd(WaitingDays),
      Min = min(WaitingDays), Max = max(WaitingDays)
    )
  )

cat(" Overall numeric summary \n")
print(numeric_summary)

waitingdays_by_outcome <- data %>%
  group_by(No.show) %>%
  summarise(
    n = n(),
    Mean_WaitingDays = mean(WaitingDays),
    Median_WaitingDays = median(WaitingDays),
    SD_WaitingDays = sd(WaitingDays)
  )

cat("\n Waiting days by outcome \n")
print(waitingdays_by_outcome)

#frequency tables
noshow_rate_by_sms      <- data %>% count(SMS_received, No.show) %>% group_by(SMS_received) %>% mutate(pct = round(100 * n / sum(n), 1))
noshow_rate_by_agegroup <- data %>% count(AgeGroup, No.show) %>% group_by(AgeGroup) %>% mutate(pct = round(100 * n / sum(n), 1))
noshow_rate_by_scholarship <- data %>% count(Scholarship, No.show) %>% group_by(Scholarship) %>% mutate(pct = round(100 * n / sum(n), 1))

cat("\n No-show rate (%) by SMS received \n")
print(noshow_rate_by_sms)
cat("\n No-show rate (%) by age group \n")
print(noshow_rate_by_agegroup)
cat("\n No-show rate (%) by scholarship status \n")
print(noshow_rate_by_scholarship)

dir.create("Results/descriptive-stats-results", showWarnings = FALSE, recursive = TRUE)
write.csv(numeric_summary, "Results/descriptive-stats-results/numeric_summary.csv", row.names = FALSE)
write.csv(waitingdays_by_outcome, "Results/descriptive-stats-results/waitingdays_by_outcome.csv", row.names = FALSE)
write.csv(noshow_rate_by_sms, "Results/descriptive-stats-results/noshow_rate_by_sms.csv", row.names = FALSE)
write.csv(noshow_rate_by_agegroup, "Results/descriptive-stats-results/noshow_rate_by_agegroup.csv", row.names = FALSE)
write.csv(noshow_rate_by_scholarship, "Results/descriptive-stats-results/noshow_rate_by_scholarship.csv", row.names = FALSE)

cat("\nDescriptive statistics saved to Results/descriptive-stats-results/\n")
