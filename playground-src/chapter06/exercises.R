# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 6: Hypothesis Testing and Statistical Inference
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

library(dplyr)

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")
first_sem <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id))


# Exercise 1: Sampling distributions of average study hours, n = 10 and n = 50
study <- first_sem$study_hours[!is.na(first_sem$study_hours)]
set.seed(1)
means_10 <- replicate(1000, mean(sample(study, 10)))
means_50 <- replicate(1000, mean(sample(study, ______)))
sd(means_10)
sd(______)


# Exercise 2: 95% confidence interval for average first-semester GPA
t.test(first_sem$______)$conf.int


# Exercise 3: Is average first-semester wellbeing different from 60?
t.test(first_sem$wellbeing, mu = ______)


# Exercise 4: Full-time vs part-time GPA, with Cohen's d
t.test(gpa ~ ______, data = first_sem)
full <- first_sem$gpa[first_sem$study_mode == "Full-time"]
part <- first_sem$gpa[first_sem$study_mode == "Part-time"]
(mean(full) - mean(part)) / sqrt((var(full) + var(______)) / 2)


# Exercise 5: Is living away from family related to considering dropout?
away <- table(students$lives_away, students$______)
away
prop.table(away, margin = 1)
chisq.test(away)


# Exercise 6: Check the expected counts of Exercise 5
chisq.test(away)$______


# Exercise 7: Bootstrap and non-parametric tests
# (a) Draw a random sample of 50 students' first-semester caffeine intake
#     (set.seed(3) first). Calculate a 95% bootstrap confidence interval for
#     its median, using 2,000 resamples. Does it contain the median of all
#     600 students?
# (b) Caffeine is skewed. Compare the caffeine intake of full-time and
#     part-time students with a Mann-Whitney U test (wilcox.test), and
#     report the two medians.

