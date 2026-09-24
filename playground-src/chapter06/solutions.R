# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 6: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

library(dplyr)

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")
first_sem <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id))


# Exercise 1: averages of 50 vary much less (SD about 1.8 vs 4.2)
study <- first_sem$study_hours[!is.na(first_sem$study_hours)]
set.seed(1)
means_10 <- replicate(1000, mean(sample(study, 10)))
means_50 <- replicate(1000, mean(sample(study, 50)))
sd(means_10)
sd(means_50)


# Exercise 2: about 3.08 to 3.13
t.test(first_sem$gpa)$conf.int


# Exercise 3: p about 0.35, CI includes 60: no evidence of a difference
t.test(first_sem$wellbeing, mu = 60)


# Exercise 4: no difference in GPA (p about 0.9, d about 0)
t.test(gpa ~ study_mode, data = first_sem)
full <- first_sem$gpa[first_sem$study_mode == "Full-time"]
part <- first_sem$gpa[first_sem$study_mode == "Part-time"]
(mean(full) - mean(part)) / sqrt((var(full) + var(part)) / 2)


# Exercise 5: 17% vs 14%, p about 0.31: no clear evidence of a relationship
away <- table(students$lives_away, students$considering_dropout)
away
prop.table(away, margin = 1)
chisq.test(away)


# Exercise 6: smallest expected count about 38, so the test is reliable
chisq.test(away)$expected


# Exercise 7
# (a) Bootstrap CI for the median
caffeine <- first_sem$caffeine_mg[!is.na(first_sem$caffeine_mg)]
set.seed(3)
small_sample <- sample(caffeine, 50)
boot_medians <- replicate(2000, median(sample(small_sample, replace = TRUE)))
quantile(boot_medians, c(0.025, 0.975))
median(caffeine)   # the median of all 600 students

# (b) Mann-Whitney U test
tapply(first_sem$caffeine_mg, first_sem$study_mode, median, na.rm = TRUE)
wilcox.test(caffeine_mg ~ study_mode, data = first_sem)
