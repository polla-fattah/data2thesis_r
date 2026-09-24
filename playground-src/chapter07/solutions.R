# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 7: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

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


# Exercise 1
wellbeing_anova <- aov(wellbeing ~ faculty, data = study)
summary(wellbeing_anova)
ss <- summary(wellbeing_anova)[[1]][["Sum Sq"]]
ss[1] / sum(ss)

# Exercise 2
wb_simple <- lm(wellbeing ~ sleep_hours, data = study)
summary(wb_simple)

# Exercise 3
wb_multiple <- lm(wellbeing ~ sleep_hours + stress + support, data = study)
summary(wb_multiple)

# Exercise 4
wb_mode <- lm(wellbeing ~ sleep_hours + stress + support + study_mode, data = study)
summary(wb_mode)$coefficients

# Exercise 5
study <- study |> mutate(dropout = as.integer(considering_dropout == "Yes"))
burnout_model <- glm(dropout ~ burnout, data = study, family = binomial)
exp(cbind(coef(burnout_model), confint.default(burnout_model)))

# Exercise 6
predict(burnout_model, newdata = data.frame(burnout = c(2, 4)), type = "response")

# Exercise 7
# (a) Two-way ANOVA
study |>
  summarise(gpa = mean(gpa), .by = c(programme, gender)) |>
  with(interaction.plot(programme, gender, gpa))
summary(aov(gpa ~ programme * gender, data = study))

# (b) Diagnostics
gpa_model <- lm(gpa ~ sleep_hours + study_hours + stress + support, data = study)
par(mfrow = c(1, 2))
plot(gpa_model, which = 1:2)
par(mfrow = c(1, 1))
