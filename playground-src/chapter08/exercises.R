# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 8: ANOVA and Regression
#
# Four parts, as on the playground page:
#   A. Practise the chapter       the book's exercises, with blanks (______) to fill
#   B. Go further                 new exercises beyond the book
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

library(dplyr)

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")
scores <- questionnaire |>
  mutate(
    stress_4 = 6 - stress_4,
    stress   = rowMeans(pick(stress_1:stress_6), na.rm = TRUE),
    support  = rowMeans(pick(support_1:support_6), na.rm = TRUE)
  ) |>
  select(student_id, stress, support)
study <- students |>
  left_join(scores, join_by(student_id)) |>
  left_join(semesters |> filter(semester == 1), join_by(student_id))


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: Wellbeing across faculties
# One-way ANOVA and eta squared; Tukey's test only if the ANOVA is significant.
wellbeing_anova <- ______(wellbeing ~ faculty, data = study)
summary(wellbeing_anova)
ss <- summary(wellbeing_anova)[[1]][["Sum Sq"]]
ss[1] / ______(ss)


# Exercise 2: Wellbeing and sleep
# Interpret the slope and R-squared.
wb_simple <- ______(wellbeing ~ sleep_hours, data = study)
summary(wb_simple)


# Exercise 3: Adding stress and support
# What happens to the slope of sleep, and to R-squared?
wb_simple   <- lm(wellbeing ~ sleep_hours, data = study)
wb_multiple <- lm(wellbeing ~ sleep_hours + stress + support, data = study)
summary(wb_multiple)
coef(wb_simple)["sleep_hours"]
______(wb_multiple)["sleep_hours"]


# Exercise 4: A categorical predictor
# Name the reference category and explain its coefficient; then make part-time
# the reference category.
wb_mode <- lm(wellbeing ~ sleep_hours + stress + support + study_mode, data = study)
summary(wb_mode)$coefficients

study_ref <- study |> mutate(study_mode = relevel(factor(study_mode), ref = ______))
coef(lm(wellbeing ~ sleep_hours + stress + support + study_mode, data = study_ref))


# Exercise 5: Burnout and dropout
# Odds ratio, and predicted probabilities for burnout scores of 2 and 4.
burnout <- questionnaire |>
  mutate(burnout = rowMeans(pick(burnout_1:burnout_6), na.rm = TRUE)) |>
  select(student_id, burnout)
study_b <- study |>
  left_join(burnout, join_by(student_id)) |>
  mutate(dropout = as.integer(considering_dropout == "Yes"))

burnout_model <- glm(dropout ~ burnout, data = study_b, family = ______)
exp(cbind(odds_ratio = coef(burnout_model), confint.default(burnout_model)))
predict(burnout_model, newdata = data.frame(burnout = c(2, 4)), type = ______)


# Exercise 6: A confounder in your own field
# Draw (on paper) a confounder that might explain an association in your field,
# and describe how a regression could separate the two explanations.


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: F by hand, compared with aov()
group_scores <- tibble(
  group  = rep(c("A", "B", "C"), each = 4),
  stress = c(2.5, 3.0, 2.8, 3.1,   3.4, 3.8, 3.5, 3.9,   2.9, 3.3, 3.0, 3.4)
) |>
  mutate(group_mean = mean(stress), .by = group)

grand_mean <- mean(group_scores$stress)
ss_between <- sum((group_scores$group_mean - grand_mean)^2)
ss_within  <- sum((group_scores$stress - group_scores$group_mean)^2)
F_value <- (ss_between / ______) / (ss_within / ______)
F_value
summary(aov(stress ~ group, data = group_scores))


# Exercise 8: Regression as conditional means
# Average wellbeing per whole hour of sleep, beside the line's predictions.
bands <- study |>
  filter(!is.na(sleep_hours)) |>
  mutate(sleep_band = round(sleep_hours)) |>
  summarise(students = n(), mean_wellbeing = mean(wellbeing), .by = sleep_band) |>
  arrange(sleep_band)

wb_line <- lm(wellbeing ~ sleep_hours, data = study)
bands |>
  mutate(line = ______(wb_line, newdata = data.frame(sleep_hours = sleep_band)))


# Exercise 9: Simpson's paradox
# Admission rates of men and women at Berkeley in 1973, overall and by department.
admissions <- as.data.frame(UCBAdmissions)
head(admissions)

admissions |>
  summarise(rate = sum(Freq[Admit == "Admitted"]) / ______(Freq),
            applicants = sum(Freq), .by = Gender)

admissions |>
  summarise(rate = sum(Freq[Admit == "Admitted"]) / sum(Freq),
            applicants = sum(Freq), .by = c(Dept, Gender)) |>
  arrange(Dept)


# Exercise 10: A missed curve in the residuals
straight <- lm(gpa ~ study_hours, data = study)
curved   <- lm(gpa ~ study_hours + I(study_hours^______), data = study)

scatter.smooth(straight$model$study_hours, resid(straight),
               xlab = "Study hours", ylab = "Residual (straight line)")
abline(h = 0, lty = 2)
scatter.smooth(curved$model$study_hours, resid(curved),
               xlab = "Study hours", ylab = "Residual (curve)")
abline(h = 0, lty = 2)
c(straight = summary(straight)$r.squared, curved = summary(curved)$r.squared)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. What does the F statistic of an ANOVA compare?
# 2. In a multiple regression, what does "holding the other predictors
#    constant" mean?
# 3. What is a confounder?
# 4. A residual plot shows a funnel. What does it mean?
# 5. An odds ratio of 2 does not mean that the probability doubles. Why not?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: A regression model for first-semester wellbeing with predictors of
# your choice, justified by a research question; check the residual plot, and
# write the reporting paragraph with every number calculated by code.



# Task 2: Does the effect of support on wellbeing differ between full-time and
# part-time students? Centre support, fit an interaction, interpret it, and
# draw an interaction plot.



# Task 3: A logistic regression for another yes-or-no variable (such as
# lives_away) with two or three justified predictors: odds ratios with
# confidence intervals, and predicted probabilities for two contrasting
# students.



# Task 4: trees: predict volume from girth and height, check whether a straight
# line is adequate, and explain what you would change if it is not.
