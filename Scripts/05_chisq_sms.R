#Chi-square test
#Hypothesis: Is there a statistically significant association between receiving an SMS reminders & whether a patient is a no-shows?
#H0: SMS_received & No.show are independent
#H1: SMS_received & No.show are associated

library(tidyverse)

data <- read.csv("data/appointments_clean.csv")

#Assumption 1: both variables are categorical
#SMS_received (No/Yes) &  No.show (No/Yes) are both categorical

#Assumption 2: observations of independence  
#Each row is distinct appointments
# one patient's outcome doesnot mechanically determine anothers

contingency_table <- table(data$SMS_received, data$No.show)
cat("Contingency table (observed counts) \n")
print(contingency_table)

#Assumption 3: is expected cell counts at least 5
expected <- chisq.test(contingency_table)$expected
cat("\n Expected cell counts \n")
print(expected)
cat("\nAll expected counts >= 5:", all(expected >= 5), "\n")

#Running the chi-squared test
chisq_result <- chisq.test(contingency_table, correct = TRUE)
cat("\n Chi-squared test of independence \n")
print(chisq_result)

# Effect size- Cramer's V for a 2x2 table this equals the phi coefficienty
n <- sum(contingency_table)
cramers_v <- sqrt(chisq_result$statistic / n)
cat("Cramer's V (effect size):", round(cramers_v, 3), "\n")

#Visualisation, making a plot
bar_plot <- data %>%
  count(SMS_received, No.show) %>%
  group_by(SMS_received) %>%
  mutate(pct = n / sum(n)) %>%
  ggplot(aes(x = SMS_received, y = pct, fill = No.show)) +
  geom_col(position = "fill") +
  labs(title = "No-show rate by SMS reminder",
       subtitle = paste("Chi-squared p =", signif(chisq_result$p.value, 3),
                        "| Cramer's V =", round(cramers_v, 3)),
       x = "SMS received", y = "Proportion") +
  theme_minimal()

dir.create("Results/chi-square-results", showWarnings = FALSE, recursive = TRUE)
ggsave("Results/chi-square-results/noshow_by_sms_barplot.png", plot = bar_plot, width = 7, height = 5)
print(bar_plot)

write.csv(as.data.frame.matrix(contingency_table),
          "Results/chi-square-results/contingency_table.csv")

cat("\nResults saved to Results/chi-square-results/\n")

