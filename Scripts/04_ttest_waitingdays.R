#T-Test; waiting days
# Hypothesis: Is there a statistically significant difference in mean waiting time (the days between booking and appointment) 
#b/w patients who show up and patients who no-show?
#H0: mu_show = mu_noshow
#H1: mu_show != mu_noshow

library(tidyverse)
library(car)

data <- read.csv("data/appointments_clean.csv") %>%
  mutate(No.show = factor(No.show, levels = c("No", "Yes")))

show_wait   <- data$WaitingDays[data$No.show == "No"]
noshow_wait <- data$WaitingDays[data$No.show == "Yes"]

#assumption 1: Normality
#the 5000 observations so we sample where its needed
cat("Shapiro-Wilk normality test (show group)\n")
print(shapiro.test(sample(show_wait, min(5000, length(show_wait)))))
cat("\n Shapiro-Wilk normality test (no-show group)\n")
print(shapiro.test(sample(noshow_wait, min(5000, length(noshow_wait)))))
#waiting days is right skewed 
#expecting both p-values  below 0.05, normality violated

#Assumption 2:Homogeneity of variance

cat("\n Levene's test for equal variances \n")
levene_result <- leveneTest(WaitingDays ~ No.show, data = data)
print(levene_result)

#Decision

#as the data is skewed it automatically  fails the normality test 
#therefore the groups are independent & we can't trust normality now we're just running both a&b
#(a) - Welch's t-test handles unequal variance & samples big 
#(b) - Wilcoxon rank-sum test as a backup since the data isnot normal
cat("\n Welch Two Sample t-test (primary) \n")
t_result <- t.test(WaitingDays ~ No.show, data = data)  
#this is Welch by default
print(t_result)

cat("\n Wilcoxon rank-sum test (non-parametric confirmatory check) \n")
wilcox_result <- wilcox.test(WaitingDays ~ No.show, data = data)
print(wilcox_result)

#Visualisationing no show waiting days
box_plot <- ggplot(data, aes(x = No.show, y = WaitingDays, fill = No.show)) +
  geom_boxplot() +
  labs(title = "Waiting days: show vs no-show",
       subtitle = paste("Welch t-test p =", signif(t_result$p.value, 3),
                        "| Wilcoxon p =", signif(wilcox_result$p.value, 3)),
       x = "No-show", y = "Waiting days (days)") +
  theme_minimal() + theme(legend.position = "none")

dir.create("Results/t-test-results", showWarnings = FALSE, recursive = TRUE)
ggsave("Results/t-test-results/waitingdays_boxplot.png", plot = box_plot, width = 7, height = 5)
print(box_plot)

density_plot <- ggplot(data, aes(x = WaitingDays, fill = No.show)) +
  geom_density(alpha = 0.5) +
  labs(title = "Distribution of waiting days by outcome") +
  theme_minimal()
ggsave("Results/t-test-results/waitingdays_density.png", plot = density_plot, width = 7, height = 5)

cat("\nResults saved to Results/t-test-results/\n")
