# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 9: Mixed-Effects Models
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

library(dplyr)
library(lme4)
students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")
panel <- semesters |>
  left_join(students, join_by(student_id)) |>
  mutate(time = semester - 1)


# Exercise 1: A first mixed model
# Using `sleepstudy` (it comes with lme4), fit a random intercept model of reaction time on days, and calculate the ICC.
model <- lmer(Reaction ~ Days + (1 | ______), data = sleepstudy)
vc <- as.data.frame(VarCorr(model))
vc$vcov[1] / sum(vc$vcov)

# Exercise 2: Does sleep change over the semesters?
# Fit a random intercept model for `sleep_hours` over `time`. What is the ICC? Does sleep change? Use a confidence interval to decide.
sleep_ri <- lmer(______ ~ time + (1 | student_id), data = panel)
vc <- as.data.frame(VarCorr(sleep_ri))
vc$vcov[1] / sum(vc$vcov)
confint(sleep_ri, parm = "beta_", method = "Wald")

# Exercise 3: Is a random slope worth it?
# Add a random slope of `time` to the model from Exercise 2, and compare the two models with `anova()`.
sleep_ri <- lmer(sleep_hours ~ time + (1 | student_id), data = panel)
sleep_rs <- lmer(sleep_hours ~ time + (______ | student_id), data = panel)
anova(sleep_ri, sleep_rs)

# Exercise 4: Do part-time students change differently?
# Fit `wellbeing ~ time * study_mode + (time | student_id)`. Do part-time students start at a different level? Do they change at a different rate?
wb_mode <- lmer(wellbeing ~ time * ______ + (time | student_id), data = panel)
round(summary(wb_mode)$coefficients, 2)
confint(wb_mode, parm = "beta_", method = "Wald")

# Exercise 5: Do supervisors matter for study hours?
# Fit a model for `study_hours` with random intercepts for supervisors and students, and calculate the share of variation at each level.
study_levels <- lmer(study_hours ~ time + (1 | ______) + (1 | student_id), data = panel)
vc <- as.data.frame(VarCorr(study_levels))
data.frame(level = vc$grp, share = round(vc$vcov / sum(vc$vcov), 3))

# Exercise 6: A Poisson mixed model
# Calculate each student's support score from questionnaire.csv, then fit
#   glmer(supervisor_meetings ~ support + programme +
#         (1 | supervisor_id) + (1 | student_id), family = poisson)
# and turn the fixed effects into rate ratios with exp(fixef(model)).
questionnaire <- read.csv("questionnaire.csv")

