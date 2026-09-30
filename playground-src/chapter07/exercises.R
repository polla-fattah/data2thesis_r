# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 7: Hypothesis Testing and Statistical Inference
#
# Four parts, as on the playground page:
#   A. Practise the chapter   the book's exercises, with blanks (______) to fill
#   B. Go further             new exercises beyond the book
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself         open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

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

# Exercise 1: Two sampling distributions
# Draw 1,000 samples of 10 students' first-semester study hours, and 1,000
# samples of 50. Compare the SD of the two sets of averages, plot the averages
# of 50, and explain the difference.
study <- first_sem$study_hours[!is.na(first_sem$study_hours)]
set.seed(1)
means_10 <- replicate(1000, mean(sample(study, 10)))
means_50 <- replicate(1000, mean(sample(study, ______)))
sd(means_10)
sd(means_50)
hist(means_50)


# Exercise 2: A confidence interval
# Calculate a 95% confidence interval for the average first-semester GPA, and
# explain in one sentence what it tells you.
______(first_sem$gpa)$conf.int


# Exercise 3: A one-sample test against 60
# Test whether average first-semester wellbeing differs from 60. State the
# hypotheses, run the test, and write a one-sentence conclusion.
# H0:
# H1:
t.test(first_sem$wellbeing, mu = ______)


# Exercise 4: Full-time and part-time students
# Compare first-semester GPA with a permutation test of 5,000 shuffles, then
# with a two-sample t-test. Calculate Cohen's d and compare the two p-values.
observed <- mean(first_sem$gpa[first_sem$study_mode == "Full-time"]) -
  mean(first_sem$gpa[first_sem$study_mode == "Part-time"])
set.seed(2026)
shuffled <- replicate(5000, {
  mode <- sample(first_sem$______)
  mean(first_sem$gpa[mode == "Full-time"]) - mean(first_sem$gpa[mode == "Part-time"])
})
mean(abs(shuffled) >= abs(observed))
______(gpa ~ study_mode, data = first_sem)
full <- first_sem$gpa[first_sem$study_mode == "Full-time"]
part <- first_sem$gpa[first_sem$study_mode == "Part-time"]
(mean(full) - mean(part)) / sqrt((var(full) + var(part)) / 2)


# Exercise 5: Power by simulation
# Find the power of a study with 40 students per group when the true workshop
# effect is 3 points instead of 5, and explain what it means for a researcher.
simulate_study <- function(n_per_group, effect = 5, sd = 11) {
  invited     <- rnorm(n_per_group, mean = 60 + effect, sd = sd)
  not_invited <- rnorm(n_per_group, mean = 60, sd = sd)
  t.test(invited, not_invited)$p.value < 0.05
}
set.seed(3)
mean(replicate(2000, simulate_study(______, effect = ______)))


# Exercise 6: Living away and dropout
# Test whether living away from family is related to considering dropout. Make
# the table, look at the proportions, run a chi-square test, and check the
# expected counts.
away <- table(students$lives_away, students$considering_dropout)
away
prop.table(away, margin = 1)
test <- ______(away)
test
test$______


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: How often a confidence interval is right
# Treat the 600 students as the population. Draw 100 samples of 30, calculate a
# 95% interval for average wellbeing from each, and count how many contain the
# true average.
population <- first_sem$wellbeing
true_mean  <- mean(population)
set.seed(4)
covered <- replicate(100, {
  ci <- t.test(sample(population, ______))$conf.int
  ci[1] <= true_mean & true_mean <= ci[2]
})
sum(covered)


# Exercise 8: A permutation test for medians
# Test whether the median first-semester sleep of women and men differs, with
# 5,000 shuffles of the gender labels.
sleepers <- first_sem |> filter(!is.na(sleep_hours))
observed <- median(sleepers$sleep_hours[sleepers$gender == "Female"]) -
  median(sleepers$sleep_hours[sleepers$gender == "Male"])
set.seed(2026)
shuffled <- replicate(5000, {
  g <- sample(sleepers$______)
  median(sleepers$sleep_hours[g == "Female"]) - median(sleepers$sleep_hours[g == "Male"])
})
c(observed = observed, p_value = mean(abs(shuffled) >= abs(______)))


# Exercise 9: Many tests at once
# Compare the wellbeing of every pair of faculties without a correction and with
# a Bonferroni correction. Count the "significant" comparisons each time.
p_none <- pairwise.t.test(first_sem$wellbeing, first_sem$faculty,
                          p.adjust.method = "______")$p.value
p_bonf <- pairwise.t.test(first_sem$wellbeing, first_sem$faculty,
                          p.adjust.method = "bonferroni")$p.value
sum(p_none < 0.05, na.rm = TRUE)
sum(p_bonf < 0.05, na.rm = TRUE)


# Exercise 10: Paired or not
# R's built-in sleep data: 10 patients, each on two drugs. Analyse it with a
# paired t-test, then wrongly as two independent groups, and compare.
drug1 <- sleep$extra[sleep$group == 1]
drug2 <- sleep$extra[sleep$group == 2]
t.test(drug2, drug1, paired = ______)
t.test(drug2, drug1)


# Exercise 11: Bootstrap and rank tests
# (a) With set.seed(3), sample 50 students' first-semester caffeine intake and
#     calculate a 95% bootstrap interval for the median (2,000 resamples).
# (b) Compare the caffeine intake of full-time and part-time students with a
#     Mann-Whitney U test, and report the two medians.
caffeine <- first_sem$caffeine_mg[!is.na(first_sem$caffeine_mg)]
set.seed(3)
small <- sample(caffeine, 50)
boot <- replicate(2000, median(sample(small, replace = ______)))
quantile(boot, c(0.025, 0.975))
tapply(first_sem$caffeine_mg, first_sem$study_mode, median, na.rm = TRUE)
______(caffeine_mg ~ study_mode, data = first_sem)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. A study reports p = 0.03 for the difference between two groups. What does
#    this number mean, and what does it not mean?
# 2. A study of 12 students finds no significant difference between two
#    teaching methods. Can it conclude that the methods are equally effective?
# 3. What is the difference between the standard deviation of a variable and
#    the standard error of its mean?
# 4. A researcher sees that the invited group scored higher and then decides to
#    use a one-tailed test, which gives p = 0.04 instead of 0.08. What is wrong?
# 5. With 10,000 students, a difference of 0.5 points on a 100-point wellbeing
#    scale is highly significant. Is it an important finding?
# 6. In Exercise 4, the permutation test and the t-test gave almost the same
#    p-value. Why?
# 7. A chi-square test has two expected counts below 5. What should you do?
# 8. Why does the paired test in Exercise 10 find the effect when the unpaired
#    test does not?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own analysis
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Part-time students may report more stress than full-time students.
# Calculate each student's stress score from the questionnaire (reverse
# stress_4 first), state the hypotheses, compare the two groups with a graph and
# a suitable test, calculate an effect size, and write a reporting sentence.



# Task 2: Choose a claim of your own about the average of one variable (for
# example, that graduate students study more than 25 hours a week in their first
# semester). State the hypotheses, decide whether a one-tailed or two-tailed
# test is justified, run the test, and report it with a confidence interval.



# Task 3: Choose two categorical variables in students that the chapter did not
# relate (for example, programme and has_children). Make the table and the
# proportions, test whether they are related, check the expected counts, and
# describe the result in words.



# Task 4: A colleague plans a study to detect a difference of 0.3 standard
# deviations between two groups. Use simulation to find how many participants
# per group are needed for 80% power, check with power.t.test(), and write the
# sample-size justification for their methods section.



# Task 5: R's built-in chickwts data records the weight of chicks fed six feeds.
# Choose two feeds, compare the chicks' weights with a graph and a test of your
# choice, justify the choice, and report the result with an effect size.



# Task 6: R's built-in InsectSprays data records the number of insects on plots
# treated with six sprays. Compare sprays C and D: look at the distributions,
# decide between a t-test and a Mann-Whitney U test, run it, and explain.



# Task 7: Test whether first-semester sleep differs between the five faculties
# with every pairwise t-test. Report how many comparisons are significant with
# and without a correction, and write the two sentences you would put in a
# thesis.


