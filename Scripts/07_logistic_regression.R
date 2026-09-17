#logistic-regression
#Hypothesis: Waiting days,= SMS reminder, age, scholarship status, & chronic conditions  predict if a patient no-shows
#H0: none of the predictors are associated with No-show 
#H1: at least one predictor is significantly associated with No-show
# installing these packages("tidyverse"), ("car"), ("pROC")&("broom")

install.packages("pROC")
install.packages("broom")
library(tidyverse)
library(car)
library(pROC)
library(broom)

data <- read.csv("data/appointments_clean.csv") %>%
  mutate(
    No.show = factor(No.show, levels = c("No", "Yes")),
    Gender = factor(Gender),
    Scholarship = factor(Scholarship),
    Hipertension = factor(Hipertension),
    Diabetes = factor(Diabetes),
    Alcoholism = factor(Alcoholism),
    SMS_received = factor(SMS_received)
  )

#sampling- train/ test split 80/20 for honest out-of-sample evaluation
set.seed(123)
train_idx <- sample(1:nrow(data), 0.8 * nrow(data))
train_data <- data[train_idx, ]
test_data  <- data[-train_idx, ]

formula_full <- No.show ~ WaitingDays + SMS_received + Age + Scholarship +
  Hipertension + Diabetes + Alcoholism + Gender

model <- glm(formula_full, data = train_data, family = binomial)

cat("Model summary \n")
print(summary(model))

#Assumption 1; VIF; test to make sure predictors aren't just copying each other
cat("\n Variance Inflation Factors (multicollinearity check) \n")
print(vif(model))

#if VIF is over 5 or 10 we got a problem

#Assumption 2: to test to check if theres continuous variables are actually linear
cat("\n Box-Tidwell test for linearity of the logit (WaitingDays, Age) \n")
bt_data <- train_data %>% mutate(
  log_WaitingDays = log(WaitingDays + 1) * (WaitingDays + 1),
  log_Age = log(Age + 1) * (Age + 1)
)
bt_model <- glm(No.show ~ WaitingDays + log_WaitingDays + Age + log_Age +
                  SMS_received + Scholarship + Hipertension + Diabetes + Alcoholism + Gender,
                data = bt_data, family = binomial)
bt_summary <- summary(bt_model)$coefficients
print(bt_summary[c("log_WaitingDays", "log_Age"), ])
cat("(non-significant interaction terms above support linearity of the logit)\n")

#Assumption 3:influential points like Cook's distance
cooks_d <- cooks.distance(model)
n_influential <- sum(cooks_d > 4 / nrow(train_data))
cat("\nObservations flagged as influential (Cook's D > 4/n):", n_influential,
    "out of", nrow(train_data), "\n")

cooks_plot_df <- data.frame(index = 1:length(cooks_d), cooks_d = cooks_d)
cooks_plot <- ggplot(cooks_plot_df, aes(x = index, y = cooks_d)) +
  geom_point(alpha = 0.3) +
  geom_hline(yintercept = 4 / nrow(train_data), color = "red", linetype = "dashed") +
  labs(title = "Cook's distance - influential point check", y = "Cook's D") +
  theme_minimal()

dir.create("Results/logistic-regression-results", showWarnings = FALSE, recursive = TRUE)
ggsave("Results/logistic-regression-results/cooks_distance.png", plot = cooks_plot, width = 7, height = 5)

#get the odds ratios & confidence intervals
cat("\n Odds ratios (exp(coef)) with 95% CI \n")
or_table <- tidy(model, exponentiate = TRUE, conf.int = TRUE)
print(or_table)
write.csv(or_table, "Results/logistic-regression-results/odds_ratios.csv", row.names = FALSE)

#Model fit pseudo R-squared & AIC
null_model <- glm(No.show ~ 1, data = train_data, family = binomial)
mcfadden_r2 <- 1 - (logLik(model) / logLik(null_model))
cat("\nMcFadden's pseudo R^2:", round(as.numeric(mcfadden_r2), 4), "\n")
cat("AIC:", AIC(model), "\n")

#Test the model on the test data
test_probs <- predict(model, newdata = test_data, type = "response")
test_pred  <- factor(ifelse(test_probs > 0.5, "Yes", "No"), levels = c("No", "Yes"))

conf_matrix <- table(Predicted = test_pred, Actual = test_data$No.show)
cat("\n Confusion matrix (test set, threshold = 0.5) \n")
print(conf_matrix)

accuracy <- sum(diag(conf_matrix)) / sum(conf_matrix)
cat("Accuracy:", round(accuracy, 3), "\n")
cat("(Note: classes are imbalanced -- ~85% show up -- so accuracy alone is\n")
cat(" a weak metric here; AUC below is more informative.)\n")

roc_obj <- roc(test_data$No.show, test_probs, levels = c("No", "Yes"), direction = "<")
cat("\nAUC:", round(auc(roc_obj), 3), "\n")

roc_plot <- ggroc(roc_obj) +
  labs(title = paste("ROC curve - test set (AUC =", round(auc(roc_obj), 3), ")")) +
  theme_minimal()
ggsave("Results/logistic-regression-results/roc_curve.png", plot = roc_plot, width = 6, height = 6)
print(roc_plot)

write.csv(as.data.frame.matrix(conf_matrix),
          "Results/logistic-regression-results/confusion_matrix.csv")

saveRDS(model, "Results/logistic-regression-results/final_model.rds")

cat("\nResults saved to Results/logistic-regression-results/\n")
