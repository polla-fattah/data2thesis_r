# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 9: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

library(dplyr)
library(lme4)
students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")
panel <- semesters |>
  left_join(students, join_by(student_id)) |>
  mutate(time = semester - 1)


# Exercise 1
model <- lmer(Reaction ~ Days + (1 | Subject), data = sleepstudy)
vc <- as.data.frame(VarCorr(model))
vc$vcov[1] / sum(vc$vcov)

# Exercise 2
sleep_ri <- lmer(sleep_hours ~ time + (1 | student_id), data = panel)
vc <- as.data.frame(VarCorr(sleep_ri))
vc$vcov[1] / sum(vc$vcov)
confint(sleep_ri, parm = "beta_", method = "Wald")

# Exercise 3
sleep_ri <- lmer(sleep_hours ~ time + (1 | student_id), data = panel)
sleep_rs <- lmer(sleep_hours ~ time + (time | student_id), data = panel)
anova(sleep_ri, sleep_rs)

# Exercise 4
wb_mode <- lmer(wellbeing ~ time * study_mode + (time | student_id), data = panel)
round(summary(wb_mode)$coefficients, 2)
confint(wb_mode, parm = "beta_", method = "Wald")

# Exercise 5
study_levels <- lmer(study_hours ~ time + (1 | supervisor_id) + (1 | student_id), data = panel)
vc <- as.data.frame(VarCorr(study_levels))
data.frame(level = vc$grp, share = round(vc$vcov / sum(vc$vcov), 3))

# Exercise 6: about 48% more meetings per point of support; PhD about 19% more
questionnaire <- read.csv("questionnaire.csv")
support_scores <- questionnaire |>
  mutate(support = rowMeans(pick(support_1:support_6), na.rm = TRUE)) |>
  select(student_id, support)
meetings_model <- glmer(
  supervisor_meetings ~ support + programme + (1 | supervisor_id) + (1 | student_id),
  data = panel |> left_join(support_scores, join_by(student_id)),
  family = poisson
)
exp(fixef(meetings_model))
