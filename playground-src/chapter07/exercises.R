# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 7: ANOVA and Regression
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

library(dplyr)
students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")
scores <- questionnaire |>
  mutate(
    stress_4 = 6 - stress_4,
    stress   = rowMeans(pick(stress_1:stress_6), na.rm = TRUE),
    support  = rowMeans(pick(support_1:support_6), na.rm = TRUE),
    burnout  = rowMeans(pick(burnout_1:burnout_6), na.rm = TRUE)
  ) |>
  select(student_id, stress, support, burnout)
study <- students |>
  left_join(scores, join_by(student_id)) |>
  left_join(semesters |> filter(semester == 1), join_by(student_id))


# Exercise 1: Wellbeing across faculties
# Does first-semester wellbeing differ between faculties? Run a one-way ANOVA and calculate eta squared. Should you run Tukey's test?
wellbeing_anova <- aov(wellbeing ~ ______, data = study)
summary(wellbeing_anova)
ss <- summary(wellbeing_anova)[[1]][["Sum Sq"]]
ss[1] / sum(ss)

# Exercise 2: One predictor
# Regress first-semester wellbeing on sleep hours. Interpret the slope and R-squared.
wb_simple <- lm(______ ~ sleep_hours, data = study)
summary(wb_simple)

# Exercise 3: More predictors
# Add stress and support to the model. What happens to the slope of sleep, and to R-squared?
wb_multiple <- lm(wellbeing ~ sleep_hours + ______ + ______, data = study)
summary(wb_multiple)

# Exercise 4: A categorical predictor
# Add `study_mode` to the model from Exercise 3. What is the reference category, and what does the coefficient mean?
wb_mode <- lm(wellbeing ~ sleep_hours + stress + support + ______, data = study)
summary(wb_mode)$coefficients

# Exercise 5: Burnout and dropout
# Fit a logistic regression of considering dropout on burnout, and turn the coefficient into an odds ratio with a confidence interval.
study <- study |> mutate(dropout = as.integer(considering_dropout == "Yes"))
burnout_model <- glm(dropout ~ burnout, data = study, family = ______)
exp(cbind(coef(burnout_model), confint.default(burnout_model)))

# Exercise 6: A predicted probability
# Using the model from Exercise 5, what is the predicted probability of considering dropout for a student with a burnout score of 2, and for one with a score of 4?
study <- study |> mutate(dropout = as.integer(considering_dropout == "Yes"))
burnout_model <- glm(dropout ~ burnout, data = study, family = binomial)
predict(burnout_model, newdata = data.frame(burnout = c(2, 4)), type = ______)

# Exercise 7: Two-way ANOVA and regression diagnostics
# (a) Does first-semester GPA depend on programme, gender, or their
#     interaction? Draw an interaction plot, then run a two-way ANOVA.
# (b) Fit lm(gpa ~ sleep_hours + study_hours + stress + support, data = study)
#     and draw its diagnostic plots with plot(model, which = 1:2).
#     Do the residuals look shapeless and roughly normal?
