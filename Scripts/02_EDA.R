#Exploratory Data Analysis

#the cleaned appointments dataset

library(tidyverse)

data <- read.csv("data/appointments_clean.csv")

cat(" No-show overall rate \n")
print(prop.table(table(data$No.show)))

#Distributions
pdf("Results/EDA-results/histograms.pdf")

ggplot(data, aes(x = Age)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  ggtitle("Distribution of patient age") -> p1
print(p1)

ggplot(data, aes(x = WaitingDays)) +
  geom_histogram(bins = 30, fill = "salmon", color = "black") +
  ggtitle("Distribution of waiting days (scheduling to appointment)") -> p2
print(p2)

dev.off()

ggsave("Results/EDA-results/age_distribution.png", plot = p1, width = 7, height = 5)
ggsave("Results/EDA-results/waitingdays_distribution.png", plot = p2, width = 7, height = 5)

#no-shows; 
#SMS reminders
sms_plot <- data %>%
  count(SMS_received, No.show) %>%
  group_by(SMS_received) %>%
  mutate(pct = n / sum(n)) %>%
  ggplot(aes(x = SMS_received, y = pct, fill = No.show)) +
  geom_col(position = "fill") +
  labs(title = "No-show rate by SMS reminder", x = "SMS received", y = "Proportion") +
  theme_minimal()
ggsave("Results/EDA-results/noshow_by_sms.png", plot = sms_plot, width = 7, height = 5)
print(sms_plot)

#age group
age_plot <- data %>%
  count(AgeGroup, No.show) %>%
  group_by(AgeGroup) %>%
  mutate(pct = n / sum(n)) %>%
  ggplot(aes(x = AgeGroup, y = pct, fill = No.show)) +
  geom_col(position = "fill") +
  labs(title = "No-show rate by age group", x = "Age group", y = "Proportion") +
  theme_minimal()
ggsave("Results/EDA-results/noshow_by_agegroup.png", plot = age_plot, width = 7, height = 5)
print(age_plot)

#no-show vs waiting days 
wait_box <- ggplot(data, aes(x = No.show, y = WaitingDays, fill = No.show)) +
  geom_boxplot() +
  labs(title = "Waiting days by appointment outcome", x = "No-show", y = "Waiting days") +
  theme_minimal() + theme(legend.position = "none")
ggsave("Results/EDA-results/waitingdays_by_noshow_boxplot.png", plot = wait_box, width = 7, height = 5)
print(wait_box)

cat("\nEDA plots saved to Results/EDA-results/\n")