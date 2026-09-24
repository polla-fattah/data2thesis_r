# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 5: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

library(dplyr)

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")
first_sem <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id))


# Exercise 1: mildly skewed (mean a little above median)
first_sem |>
  summarise(
    mean   = mean(study_hours, na.rm = TRUE),
    median = median(study_hours, na.rm = TRUE),
    sd     = sd(study_hours, na.rm = TRUE),
    iqr    = IQR(study_hours, na.rm = TRUE)
  )


# Exercise 2: the points follow the line; wellbeing is approximately normal
qqnorm(first_sem$wellbeing)
qqline(first_sem$wellbeing)


# Exercise 3: one student (67 hours) is above the fence of 65.5 hours
x  <- first_sem$study_hours
q3 <- quantile(x, 0.75, na.rm = TRUE)
fence <- q3 + 1.5 * IQR(x, na.rm = TRUE)
fence
sum(x > fence, na.rm = TRUE)


# Exercise 4: almost no difference in sleep
left_ids <- setdiff(students$student_id,
                    semesters$student_id[semesters$semester == 3])
first_sem |>
  mutate(left_study = student_id %in% left_ids) |>
  summarise(mean_sleep = mean(sleep_hours, na.rm = TRUE), students = n(),
            .by = left_study)


# Exercise 5: about 0.4, medium to large; an association, not proof of cause
scores <- questionnaire |>
  mutate(
    support      = rowMeans(pick(support_1:support_6), na.rm = TRUE),
    satisfaction = rowMeans(pick(satisfaction_1:satisfaction_4), na.rm = TRUE)
  )
cor(scores$support, scores$satisfaction, use = "complete.obs")


# Exercise 6
first_sem |>
  summarise(
    students      = n(),
    part_time_pct = 100 * mean(study_mode == "Part-time"),
    age_mean      = mean(age, na.rm = TRUE),
    age_sd        = sd(age, na.rm = TRUE)
  )


# Exercise 7
library(psych)
describe_var <- function(x) {
  c(mean = mean(x, na.rm = TRUE), sd = sd(x, na.rm = TRUE),
    median = median(x, na.rm = TRUE), iqr = IQR(x, na.rm = TRUE),
    missing = sum(is.na(x)), skew = skew(x, na.rm = TRUE))
}
vars <- c("sleep_hours", "study_hours", "caffeine_mg", "gpa", "wellbeing")
round(t(sapply(first_sem[, vars], describe_var)), 2)
# Report mean (SD) for sleep, study hours, GPA, and wellbeing (roughly
# symmetrical); report median (IQR) for caffeine (skewness about 1.7).
