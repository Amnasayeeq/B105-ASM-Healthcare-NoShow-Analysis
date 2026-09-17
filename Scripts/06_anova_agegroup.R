#ANOVA-age-group
# Hypothesis: Does the average wait time change depending on the patient's age group?
# (Child / Teen / Adult / Senior)?
#   H0: All age groups have the same average wait time
#   H1: at least one age group's mean waiting time differs. 

library(tidyverse)

data <- read.csv("data/appointments_clean.csv") %>%
  mutate(AgeGroup = factor(AgeGroup, levels = c("Child", "Teen", "Adult", "Senior")))

anova_model <- aov(WaitingDays ~ AgeGroup, data = data)

#Assumption 1: normality of residuals
cat("Shapiro-Wilk test on ANOVA residuals\n")
resid_sample <- sample(residuals(anova_model), min(5000, length(residuals(anova_model))))
shapiro_result <- shapiro.test(resid_sample)
print(shapiro_result)

#Assumption 2: homogeneity of variance
cat("\n Bartlett's test for equal variances across groups \n")
bartlett_result <- bartlett.test(WaitingDays ~ AgeGroup, data = data)
print(bartlett_result)

#Decisions;Make a call based on normality: if it fails- run Kruskal-Wallis instead. If alright run ANOVA
if (shapiro_result$p.value < 0.05) {
  cat("\nNormality of residuals is VIOLATED (p < 0.05).\n")
  cat("Standard one-way ANOVA would not be valid here, so we switch to its\n")
  cat("non-parametric alternative: the Kruskal-Wallis test.\n\n")
  
  cat("Kruskal-Wallis test \n")
  kw_result <- kruskal.test(WaitingDays ~ AgeGroup, data = data)
  print(kw_result)
  
  if (kw_result$p.value < 0.05) {
    cat("\n Post-hoc pairwise comparisons (Wilcoxon, Bonferroni-corrected) \n")
    posthoc <- pairwise.wilcox.test(data$WaitingDays, data$AgeGroup, p.adjust.method = "bonferroni")
    print(posthoc)
  }
  primary_p <- kw_result$p.value
  test_used <- "Kruskal-Wallis"
} else {
  cat("\nNormality assumption holds -- reporting standard one-way ANOVA.\n")
  anova_summary <- summary(anova_model)
  print(anova_summary)
  primary_p <- anova_summary[[1]][["Pr(>F)"]][1]
  test_used <- "One-way ANOVA"
  
  cat("\n Post-hoc: Tukey HSD \n")
  print(TukeyHSD(anova_model))
}

#Visualisation, making a plot
box_plot <- ggplot(data, aes(x = AgeGroup, y = WaitingDays, fill = AgeGroup)) +
  geom_boxplot() +
  labs(title = "Waiting days across age groups",
       subtitle = paste(test_used, "p =", signif(primary_p, 3)),
       x = "Age group", y = "Waiting days") +
  theme_minimal() + theme(legend.position = "none")

dir.create("Results/anova-results", showWarnings = FALSE, recursive = TRUE)
ggsave("Results/anova-results/waitingdays_by_agegroup_boxplot.png", plot = box_plot, width = 7, height = 5)
print(box_plot)

cat("\nResults saved to Results/anova-results/\n")

