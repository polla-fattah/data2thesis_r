# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 5: Descriptive Statistics and Exploratory Data Analysis
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

library(dplyr)

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")
first_sem <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id))


# Exercise 1: Mean, median, SD, and IQR of first-semester study_hours
first_sem |>
  summarise(
    mean   = mean(study_hours, na.rm = TRUE),
    median = ______(study_hours, na.rm = TRUE),
    sd     = ______(study_hours, na.rm = TRUE),
    iqr    = ______(study_hours, na.rm = TRUE)
  )


# Exercise 2: Q-Q plot of first-semester wellbeing
qqnorm(first_sem$______)
qqline(first_sem$______)


# Exercise 3: How many students are above the box plot fence for study_hours?
x  <- first_sem$study_hours
q3 <- quantile(x, 0.75, na.rm = TRUE)
fence <- q3 + 1.5 * ______(x, na.rm = TRUE)
fence
sum(x > ______, na.rm = TRUE)


# Exercise 4: First-semester sleep of students who left vs stayed
left_ids <- setdiff(students$student_id,
                    semesters$student_id[semesters$semester == 3])
first_sem |>
  mutate(left_study = student_id %in% ______) |>
  summarise(mean_sleep = mean(sleep_hours, na.rm = TRUE), students = n(),
            .by = ______)


# Exercise 5: Correlation between support and satisfaction scores
scores <- questionnaire |>
  mutate(
    support      = rowMeans(pick(support_1:support_6), na.rm = TRUE),
    satisfaction = rowMeans(pick(______), na.rm = TRUE)
  )
cor(scores$support, scores$______, use = "complete.obs")


# Exercise 6: Describe the sample
first_sem |>
  summarise(
    students      = n(),
    part_time_pct = 100 * mean(study_mode == ______),
    age_mean      = mean(age, na.rm = TRUE),
    age_sd        = ______
  )


# Exercise 7: A descriptive table for your thesis
# For sleep_hours, study_hours, caffeine_mg, gpa, and wellbeing (first semester),
# make a table with the mean, SD, median, IQR, number missing, and skewness
# (psych::skew). Decide, for each variable, whether you would report the
# mean (SD) or the median (IQR), and why.
library(psych)

