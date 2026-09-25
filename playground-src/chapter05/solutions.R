# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 5: Solutions
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

# Exercise 1 (model answer):
# (a) "Do graduate students who exercise on more days per week report higher
#     wellbeing?" (relational), or "Does a programme of three weekly exercise
#     sessions raise wellbeing after one semester?" (causal; needs random
#     assignment).
# (b) "Is the number of supervisor meetings per semester associated with
#     students' satisfaction with their progress?" (relational)


# Exercise 2: both groups study about 27.6 hours; no support for H1
# H1: students with children study fewer hours per week than students without
# H0: the two groups study the same number of hours on average
# Against H1: an equal or higher average for students with children
first_sem |>
  group_by(has_children) |>
  summarise(students = n(), study_hours = mean(study_hours, na.rm = TRUE))


# Exercise 3: 38 missing answers.
# Nominal: student_id, supervisor_id, gender, faculty, programme, study_mode,
#   has_children, lives_away, workshop, considering_dropout
# Ordinal: employment, financial_worry
# Ratio: age, workshop_sessions
students <- students |>
  mutate(financial_worry = factor(financial_worry,
                                  levels = 1:5,
                                  labels = c("Not at all", "A little", "Moderately",
                                             "Very", "Extremely"),
                                  ordered = TRUE))
table(students$financial_worry, useNA = "ifany")


# Exercise 4: about -5.5 to +5.5 points, more than twice as wide as with 150
# per group; a real 5-point effect would be hidden in chance
set.seed(2026)
chance_differences <- replicate(5000, {
  wellbeing <- rnorm(60, mean = 60, sd = 11)
  group     <- sample(rep(c("Invited", "Not invited"), 30))
  mean(wellbeing[group == "Invited"]) - mean(wellbeing[group == "Not invited"])
})
quantile(chance_differences, c(0.025, 0.975))


# Exercise 5: similar groups; the largest gap (living away, 39% vs 46%) is the
# kind of difference chance produces
students |>
  group_by(workshop) |>
  summarise(part_time = 100 * mean(study_mode == "Part-time"),
            children  = 100 * mean(has_children == "Yes"),
            away      = 100 * mean(lives_away == "Yes"))


# Exercise 6: 176 per group for 80% power, 235 for 90% (round up)
power.t.test(delta = 0.3, sd = 1, power = 0.80)
power.t.test(delta = 0.3, sd = 1, power = 0.90)


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7 (model answer): 1 descriptive; 2 relational; 3 causal (random
# invitation); 4 descriptive (change in one variable); 5 relational, though
# often wrongly answered in causal words.

# Exercise 8 (model answer):
# 1. "Students with higher stress scores report lower wellbeing"; against it: a
#    correlation of zero or above.
# 2. "Students who attended at least four of six sessions have higher
#    wellbeing in semester 2 than students not invited"; against it: an equal
#    or lower average. (Not randomised: students chose how many to attend.)
# 3. "Students who spend more hours a day on social media report lower
#    wellbeing"; against it: no association, or a positive one.


# Exercise 9: simple samples contain 5 to 25 part-time students, stratified
# samples always 15; the spread of average wellbeing is almost the same (1.63
# vs 1.62), because study mode explains little of wellbeing
full_time <- first_sem |> filter(study_mode == "Full-time")
part_time <- first_sem |> filter(study_mode == "Part-time")

set.seed(5)
simple <- replicate(2000, {
  s <- slice_sample(first_sem, n = 50)
  c(n_part = sum(s$study_mode == "Part-time"), mean_wb = mean(s$wellbeing))
})
stratified <- replicate(2000, {
  s <- bind_rows(slice_sample(full_time, n = 35), slice_sample(part_time, n = 15))
  c(n_part = sum(s$study_mode == "Part-time"), mean_wb = mean(s$wellbeing))
})
range(simple["n_part", ])
range(stratified["n_part", ])
sd(simple["mean_wb", ])
sd(stratified["mean_wb", ])


# Exercise 10: power about 0.51, 0.71, 0.83, 0.87; roughly 190 to 200 students
# for 80% power (the exact formula gives 194)
set.seed(6)
power_r <- function(n, r = 0.2) {
  mean(replicate(1000, {
    x <- rnorm(n)
    y <- r * x + sqrt(1 - r^2) * rnorm(n)
    cor.test(x, y)$p.value < 0.05
  }))
}
sapply(c(100, 150, 200, 250), power_r)


# Exercise 11: true 60.5, voluntary samples of 400 estimate 63.9 with a spread
# of 0.3: consistently wrong
population <- first_sem$wellbeing
true_mean  <- mean(population)
chance_to_answer <- plogis((population - true_mean) / 10)

set.seed(5)
voluntary_400 <- replicate(2000, {
  chosen <- sample(length(population), 400, prob = chance_to_answer)
  mean(population[chosen])
})
c(true = true_mean, voluntary = mean(voluntary_400), spread = sd(voluntary_400))


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. A hypothesis written after seeing the data describes the data; it cannot
#    fail. Stating it first gives the test a real chance to fail.
# 2. That the research hypothesis is true, that the effect is large, or (in an
#    observational study) that one variable causes the other.
# 3. Reliable: consistent results. Valid: measures the right thing. A scale
#    that always shows 2 kg too much is reliable but not valid.
# 4. More data reduces random error, not systematic error: the estimate gets
#    narrower around the wrong value.
# 5. The variables that were never measured. Adjustment covers only recorded
#    confounders; randomisation balances everything on average.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 5, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
