# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 5: From Research Question to Data
#
# Four parts, as on the playground page:
#   A. Practise the chapter       the book's exercises, with blanks (______) to fill
#   B. Go further                 new exercises beyond the book
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Several exercises ask for a written answer: write it as comments.
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

# Exercise 1: Better research questions
# Improve these questions so that data could answer them, and say whether your
# version is descriptive, relational, or causal.
# (a) "Is exercise good for students?"
# (b) "What makes supervisors effective?"


# Exercise 2: A falsifiable hypothesis
# "Do students with children study fewer hours per week?"
# H1:
# H0:
# Against H1:
first_sem |>
  group_by(has_children) |>
  summarise(students = ______(), study_hours = mean(study_hours, na.rm = TRUE))


# Exercise 3: Levels of measurement
# Give the level of measurement of each variable in students (as comments).
# Then make financial_worry an ordered factor with labels.
students <- students |>
  mutate(financial_worry = factor(financial_worry,
                                  levels = 1:5,
                                  labels = c(______),
                                  ordered = ______))
table(students$financial_worry, useNA = "ifany")


# Exercise 4: The null world with small groups
# Groups of 30 instead of 150: between which values do 95% of the chance
# differences lie?
set.seed(2026)
chance_differences <- replicate(5000, {
  wellbeing <- rnorm(______, mean = 60, sd = 11)
  group     <- sample(rep(c("Invited", "Not invited"), ______))
  mean(wellbeing[group == "Invited"]) - mean(wellbeing[group == "Not invited"])
})
quantile(chance_differences, c(0.025, 0.975))


# Exercise 5: Did the randomisation work?
students |>
  group_by(workshop) |>
  summarise(part_time = 100 * ______(study_mode == "Part-time"),
            children  = 100 * ______(has_children == "Yes"),
            away      = 100 * ______(lives_away == "Yes"))


# Exercise 6: How many students?
# A difference of 0.3 standard deviations, with 80% and with 90% power.
power.t.test(delta = ______, sd = 1, power = 0.80)
power.t.test(delta = ______, sd = 1, power = ______)


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: Kinds of questions
# Descriptive, relational, or causal?
# 1. What share of graduate students work in a paid job?
# 2. Is financial worry associated with considering dropping out?
# 3. Does a random invitation to a mindfulness course reduce stress?
# 4. How does average sleep change over four semesters?
# 5. Do students who meet their supervisor more often have higher GPAs?


# Exercise 8: Hypotheses that could be wrong
# Rewrite each so that it could be wrong, and name the result against it.
# 1. "Stress affects students in various ways."
# 2. "The workshop works for students who engage with it properly."
# 3. "Social media use may be related to wellbeing."


# Exercise 9: Stratified and simple random samples
# 2,000 samples of 50, simple and stratified by study mode. Compare the number
# of part-time students and the spread of the average wellbeing.
full_time <- first_sem |> filter(study_mode == "Full-time")
part_time <- first_sem |> filter(study_mode == "Part-time")

set.seed(5)
simple <- replicate(2000, {
  s <- slice_sample(first_sem, n = 50)
  c(n_part = sum(s$study_mode == "Part-time"), mean_wb = mean(s$wellbeing))
})
stratified <- replicate(2000, {
  s <- bind_rows(slice_sample(full_time, n = 35), slice_sample(part_time, n = ______))
  c(n_part = sum(s$study_mode == "Part-time"), mean_wb = mean(s$wellbeing))
})
range(simple["n_part", ])
range(stratified["n_part", ])
sd(simple["mean_wb", ])
sd(stratified["mean_wb", ])


# Exercise 10: Power for a correlation
# How many students are needed to detect a correlation of 0.2 with 80% power?
set.seed(6)
power_r <- function(n, r = 0.2) {
  mean(replicate(1000, {
    x <- rnorm(n)
    y <- r * x + sqrt(1 - r^2) * rnorm(n)
    ______(x, y)$p.value < 0.05
  }))
}
sapply(c(100, 150, 200, 250), power_r)


# Exercise 11: A bigger biased sample
# The voluntary-survey simulation with samples of 400 students. Is the average
# estimate close to the true value?
population <- first_sem$wellbeing
true_mean  <- mean(population)
chance_to_answer <- plogis((population - true_mean) / 10)

set.seed(5)
voluntary_400 <- replicate(2000, {
  chosen <- sample(length(population), ______, prob = chance_to_answer)
  mean(population[chosen])
})
c(true = true_mean, voluntary = mean(voluntary_400), spread = sd(voluntary_400))


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Why must a hypothesis be stated before the data is analysed?
# 2. A test rejects the null hypothesis. What has it not shown?
# 3. What is the difference between reliability and validity?
# 4. Why is a larger biased sample still biased?
# 5. What does random assignment balance that measuring and adjusting for
#    variables cannot?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own work
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: For a topic from your own field, write the topic, a research problem,
# a research question (descriptive, relational, or causal?), a falsifiable
# hypothesis, its null hypothesis, and the result that would count against it.



# Task 2: Write an analysis plan for two hypotheses of your own as a data frame
# with the columns hypothesis, outcome, predictor, method, and support.



# Task 3: Check the balance of the workshop invitation on every baseline
# variable in students, in one table, and write the methods sentence.



# Task 4: ToothGrowth has 10 guinea pigs per group. Find the smallest
# difference, in standard deviations, that two groups of 10 could detect with
# 80% power, and write the limitation this implies.
