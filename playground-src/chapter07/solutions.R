# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 7: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

library(dplyr)

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")
first_sem <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id))


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: averages of 50 vary much less (SD about 1.8 vs 4.2); the standard
# error shrinks with the square root of the sample size
study <- first_sem$study_hours[!is.na(first_sem$study_hours)]
set.seed(1)
means_10 <- replicate(1000, mean(sample(study, 10)))
means_50 <- replicate(1000, mean(sample(study, 50)))
sd(means_10)
sd(means_50)
hist(means_50)


# Exercise 2: about 3.08 to 3.13; the average GPA of graduate students is
# plausibly in this narrow range
t.test(first_sem$gpa)$conf.int


# Exercise 3: H0: the average is 60; H1: it is not 60.
# M = 60.5, 95% CI [59.5, 61.4], p = .35: no evidence that it differs from 60
t.test(first_sem$wellbeing, mu = 60)


# Exercise 4: difference 0.003; permutation p about 0.92, t-test p about 0.92,
# Cohen's d about 0.01: no difference in GPA
observed <- mean(first_sem$gpa[first_sem$study_mode == "Full-time"]) -
  mean(first_sem$gpa[first_sem$study_mode == "Part-time"])
set.seed(2026)
shuffled <- replicate(5000, {
  mode <- sample(first_sem$study_mode)
  mean(first_sem$gpa[mode == "Full-time"]) - mean(first_sem$gpa[mode == "Part-time"])
})
mean(abs(shuffled) >= abs(observed))
t.test(gpa ~ study_mode, data = first_sem)
full <- first_sem$gpa[first_sem$study_mode == "Full-time"]
part <- first_sem$gpa[first_sem$study_mode == "Part-time"]
(mean(full) - mean(part)) / sqrt((var(full) + var(part)) / 2)


# Exercise 5: power about 0.23; about 212 students per group are needed for 80%
simulate_study <- function(n_per_group, effect = 5, sd = 11) {
  invited     <- rnorm(n_per_group, mean = 60 + effect, sd = sd)
  not_invited <- rnorm(n_per_group, mean = 60, sd = sd)
  t.test(invited, not_invited)$p.value < 0.05
}
set.seed(3)
mean(replicate(2000, simulate_study(40, effect = 3)))
power.t.test(n = 40, delta = 3, sd = 11)$power
power.t.test(delta = 3, sd = 11, power = 0.8)


# Exercise 6: 17% vs 14%, p about 0.31: no clear evidence of a relationship;
# the smallest expected count is about 38, so the test is reliable
away <- table(students$lives_away, students$considering_dropout)
away
prop.table(away, margin = 1)
test <- chisq.test(away)
test
test$expected


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: 95 of the 100 intervals contain the true average
population <- first_sem$wellbeing
true_mean  <- mean(population)
set.seed(4)
covered <- replicate(100, {
  ci <- t.test(sample(population, 30))$conf.int
  ci[1] <= true_mean & true_mean <= ci[2]
})
sum(covered)


# Exercise 8: the medians differ by 0.1 hours; p about 0.81: no evidence of a
# difference
sleepers <- first_sem |> filter(!is.na(sleep_hours))
observed <- median(sleepers$sleep_hours[sleepers$gender == "Female"]) -
  median(sleepers$sleep_hours[sleepers$gender == "Male"])
set.seed(2026)
shuffled <- replicate(5000, {
  g <- sample(sleepers$gender)
  median(sleepers$sleep_hours[g == "Female"]) - median(sleepers$sleep_hours[g == "Male"])
})
c(observed = observed, p_value = mean(abs(shuffled) >= abs(observed)))


# Exercise 9: 2 of 10 comparisons below 0.05 without correction (Education
# against Health Sciences and against Social Sciences); none after Bonferroni
p_none <- pairwise.t.test(first_sem$wellbeing, first_sem$faculty,
                          p.adjust.method = "none")$p.value
p_bonf <- pairwise.t.test(first_sem$wellbeing, first_sem$faculty,
                          p.adjust.method = "bonferroni")$p.value
round(p_none, 3)
sum(p_none < 0.05, na.rm = TRUE)
sum(p_bonf < 0.05, na.rm = TRUE)


# Exercise 10: paired p = 0.003 (CI 0.7 to 2.5 hours); unpaired p = 0.08 (CI
# -0.2 to 3.4): the pairing removes the differences between patients
drug1 <- sleep$extra[sleep$group == 1]
drug2 <- sleep$extra[sleep$group == 2]
t.test(drug2, drug1, paired = TRUE)
t.test(drug2, drug1)


# Exercise 11: sample median 150 mg, bootstrap CI 120 to 185 mg (the median of
# all students, 160 mg, is inside); medians 160 and 165 mg, Mann-Whitney p = 0.42
caffeine <- first_sem$caffeine_mg[!is.na(first_sem$caffeine_mg)]
set.seed(3)
small <- sample(caffeine, 50)
median(small)
boot <- replicate(2000, median(sample(small, replace = TRUE)))
quantile(boot, c(0.025, 0.975))
median(caffeine)
tapply(first_sem$caffeine_mg, first_sem$study_mode, median, na.rm = TRUE)
wilcox.test(caffeine_mg ~ study_mode, data = first_sem)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. If there were really no difference, a difference at least as large as the
#    one observed would appear in about 3% of studies like this one. It is not
#    the probability that the null hypothesis is true, and not the probability
#    that the result is due to chance.
# 2. No. With 12 students the study has very low power and would usually miss a
#    real, moderate difference. A non-significant result means "not enough
#    evidence", not "no difference"; the wide confidence interval shows how
#    large a difference is still plausible.
# 3. The SD describes how much individual values differ from each other. The
#    standard error describes how much the mean would vary from sample to
#    sample; it is SD / sqrt(n), so it shrinks as the sample grows.
# 4. The direction was chosen after seeing the data. A one-tailed test is
#    justified only when the direction is decided in advance and the other
#    direction is irrelevant. Choosing it afterwards halves the p-value for free.
# 5. Probably not. With a very large sample, tiny differences become
#    significant. Half a point is about 0.04 standard deviations; importance is
#    judged from the size of the effect and its practical meaning.
# 6. Both ask how surprising the difference would be if study mode had no link
#    with GPA. The permutation test builds the null distribution by shuffling,
#    the t-test with a formula; with a large sample the two agree closely.
# 7. The chi-square approximation is unreliable. Use fisher.test(), or combine
#    categories if that makes sense for the research question.
# 8. Patients differ a great deal in their overall extra sleep. The unpaired
#    test counts these differences as noise; the paired test compares each
#    patient with themselves, so they cancel out and the drug effect remains.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 7, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
