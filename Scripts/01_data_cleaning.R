#Data cleaning

#Question: Business problem; outpatient clinics losing capacity when patients miss scheduled appointments
# using dataset here from kaggle 
# install.packages("tidyverse")
library(tidyverse)

raw <- read.csv("data/appointments_raw.csv", stringsAsFactors = FALSE)

cat(" Raw data structure \n")
str(raw)
cat("\n Missing values per column \n")
print(colSums(is.na(raw)))
cat("\nDuplicate AppointmentIDs:", sum(duplicated(raw$AppointmentID)), "\n")

#parse dates 
raw$ScheduledDay   <- as.Date(substr(raw$ScheduledDay, 1, 10))
raw$AppointmentDay <- as.Date(substr(raw$AppointmentDay, 1, 10))
raw$WaitingDays     <- as.numeric(raw$AppointmentDay - raw$ScheduledDay)

#data-quality problems
n_start <- nrow(raw)

n_negative_age  <- sum(raw$Age < 0)
n_negative_wait <- sum(raw$WaitingDays < 0)

cat("\n Data-quality issues found \n")
cat("Rows with Age < 0        :", n_negative_age, "(data-entry errors, dropped)\n")
cat("Rows with negative wait  :", n_negative_wait, "(AppointmentDay before ScheduledDay, dropped)\n")

clean <- raw %>%
  filter(Age >= 0, WaitingDays >= 0) %>%
  distinct(AppointmentID, .keep_all = TRUE)

cat("\nRows removed in cleaning :", n_start - nrow(clean), "\n")
cat("Rows remaining           :", nrow(clean), "\n")

#conversions
clean <- clean %>%
  mutate(
    Gender        = factor(Gender, levels = c("F", "M")),
    Scholarship   = factor(Scholarship, levels = c(0, 1), labels = c("No", "Yes")),
    Hipertension  = factor(Hipertension, levels = c(0, 1), labels = c("No", "Yes")),
    Diabetes      = factor(Diabetes, levels = c(0, 1), labels = c("No", "Yes")),
    Alcoholism    = factor(Alcoholism, levels = c(0, 1), labels = c("No", "Yes")),
    Handcap       = factor(ifelse(Handcap > 0, 1, 0), levels = c(0, 1), labels = c("No", "Yes")),
    SMS_received  = factor(SMS_received, levels = c(0, 1), labels = c("No", "Yes")),
    `No.show`     = factor(`No.show`, levels = c("No", "Yes")),
    Neighbourhood = factor(Neighbourhood),
    AgeGroup      = cut(Age,
                        breaks = c(-1, 12, 19, 59, 200),
                        labels = c("Child", "Teen", "Adult", "Senior"))
  )

write.csv(clean, "data/appointments_clean.csv", row.names = FALSE)
cat("\nCleaned dataset written to data/appointments_clean.csv\n")
