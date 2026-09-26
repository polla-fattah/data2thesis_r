# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 17: Reproducible Research
#
# This script holds the R parts of the playground page. The Quarto and Shiny
# tasks (Exercises 2, 3, 4, and 8) are in exercises.txt.
#   A. Practise the chapter       the book's exercises, with blanks (______) to fill
#   B. Go further                 new exercises beyond the book
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

library(dplyr)

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: A sentence that writes itself (as inline code would)
sleep <- c(6.5, 7, 5.5)
paste0("My three friends slept ", round(mean(sleep), ______), " hours on average last night.")
sleep[2] <- 8
paste0("My three friends slept ", round(mean(sleep), ______), " hours on average last night.")


# Exercises 2 to 4: see exercises.txt


# Exercise 5: The smallest cells
cells <- students |>
  count(faculty, study_mode, gender, has_children) |>
  arrange(n)
head(cells, 6)
sum(cells$n < 5)
for (drop in c("faculty", "study_mode", "gender", "has_children")) {
  kept <- setdiff(c("faculty", "study_mode", "gender", "has_children"), drop)
  smallest <- min(count(students, across(all_of(kept)))$n)
  print(c(removed = drop, smallest_cell = ______))
}


# Exercise 6: A sixth analysis (excluding the five highest scores)
forking_paths <- function() {
  group     <- rep(c("A", "B"), each = 30)
  score     <- rexp(60, rate = 1 / 10)
  covariate <- rnorm(60)
  z <- abs(as.numeric(scale(score)))
  keep <- rank(-score) > 5
  p <- c(
    t_test         = t.test(score ~ group)$p.value,
    no_outliers    = t.test(score[z < 2] ~ group[z < 2])$p.value,
    log_scale      = t.test(log(score) ~ group)$p.value,
    rank_test      = wilcox.test(score ~ group)$p.value,
    with_covariate = summary(lm(score ~ group + covariate))$coefficients[2, 4],
    no_top_five    = t.test(score[______] ~ group[keep])$p.value
  )
  c(first_analysis = p[["t_test"]] < 0.05, any_analysis = any(p < 0.05))
}
set.seed(17)
rowMeans(replicate(2000, forking_paths()))


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: How many forking paths? (1, 2, 5, and 10 analyses)
ten_paths <- function() {
  group <- rep(c("A", "B"), each = 30)
  score <- rexp(60, rate = 1 / 10)
  covariate <- rnorm(60)
  z <- abs(as.numeric(scale(score)))
  keep_top <- rank(-score) > 5
  keep_bottom <- rank(score) > 5
  c(t_test         = t.test(score ~ group)$p.value,
    rank_test      = wilcox.test(score ~ group)$p.value,
    log_scale      = t.test(log(score) ~ group)$p.value,
    no_outliers    = t.test(score[z < 2] ~ group[z < 2])$p.value,
    with_covariate = summary(lm(score ~ group + covariate))$coefficients[2, 4],
    sqrt_scale     = t.test(sqrt(score) ~ group)$p.value,
    outliers_2_5   = t.test(score[z < 2.5] ~ group[z < 2.5])$p.value,
    no_top_five    = t.test(score[keep_top] ~ group[keep_top])$p.value,
    no_bottom_five = t.test(score[keep_bottom] ~ group[keep_bottom])$p.value,
    equal_variance = t.test(score ~ group, var.equal = TRUE)$p.value)
}
set.seed(17)
p_values <- replicate(2000, ten_paths())
tried <- c(1, 2, 5, 10)
rate <- sapply(tried, function(k)
  mean(apply(p_values[1:k, , drop = FALSE], 2, function(p) any(p < ______))))
rbind(analyses_tried = tried, false_positive_rate = round(rate, 3),
      if_independent = round(1 - 0.95^tried, 3))


# Exercise 8: see exercises.txt


# Exercise 9: Grouping instead of removing
grouped <- students |>
  mutate(faculty_group = if_else(faculty %in% c("Natural Sciences", "Health Sciences"),
                                 "Sciences", "Humanities and social sciences")) |>
  count(faculty_group, study_mode, gender, has_children) |>
  arrange(n)
head(grouped, 4)
sum(grouped$n < ______)


# Exercise 10: Recording the software
r_version <- paste(R.version$major, R.version$minor, sep = ".")
dplyr_version <- as.character(______("dplyr"))
paste0("Analyses were carried out in R version ", r_version,
       " (R Core Team), with data preparation in dplyr version ", dplyr_version, ".")
sessionInfo()


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. What is the difference between a reproducible result and a replicable one?
# 2. Why should numbers in the text of a thesis not be typed by hand?
# 3. What does renv record, and why does it matter?
# 4. Why is removing names and student numbers not enough to anonymise data?
# 5. What does preregistration protect against?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers.
# ==============================================================================

# Task 1: Write a reporting sentence as code, with every number (means,
# difference, test statistic, p-value, sample sizes) calculated and inserted by
# paste0() or sprintf(), rounded as a journal would print them.



# Task 2: see exercises.txt (a Quarto report and a second dashboard input).

# Task 3: Write a preregistration for a study of your own with the AsPredicted
# headings: hypotheses, dependent variable, conditions, analyses, exclusions,
# sample size, and anything else.
