# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 8: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

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

# Exercise 1: F = 2.02, p = 0.09, eta squared 0.013: not significant, so no
# Tukey's test
wellbeing_anova <- aov(wellbeing ~ faculty, data = study)
summary(wellbeing_anova)
ss <- summary(wellbeing_anova)[[1]][["Sum Sq"]]
ss[1] / sum(ss)


# Exercise 2: slope 5.3 points per hour of sleep; R-squared 0.21
wb_simple <- lm(wellbeing ~ sleep_hours, data = study)
summary(wb_simple)


# Exercise 3: the slope of sleep falls from 5.3 to 3.9 (stress took some of its
# credit); R-squared doubles, from 0.21 to 0.43
wb_multiple <- lm(wellbeing ~ sleep_hours + stress + support, data = study)
summary(wb_multiple)
coef(wb_simple)["sleep_hours"]
coef(wb_multiple)["sleep_hours"]


# Exercise 4: reference Full-time; part-time students about 3.0 points lower,
# holding the rest constant. With Part-time as reference: Full-time +3.0.
wb_mode <- lm(wellbeing ~ sleep_hours + stress + support + study_mode, data = study)
summary(wb_mode)$coefficients

study_ref <- study |> mutate(study_mode = relevel(factor(study_mode), ref = "Part-time"))
coef(lm(wellbeing ~ sleep_hours + stress + support + study_mode, data = study_ref))


# Exercise 5: odds ratio 3.7 (95% CI 2.5 to 5.4); predicted probabilities 3%
# (burnout 2) and 31% (burnout 4)
burnout <- questionnaire |>
  mutate(burnout = rowMeans(pick(burnout_1:burnout_6), na.rm = TRUE)) |>
  select(student_id, burnout)
study_b <- study |>
  left_join(burnout, join_by(student_id)) |>
  mutate(dropout = as.integer(considering_dropout == "Yes"))

burnout_model <- glm(dropout ~ burnout, data = study_b, family = binomial)
exp(cbind(odds_ratio = coef(burnout_model), confint.default(burnout_model)))
predict(burnout_model, newdata = data.frame(burnout = c(2, 4)), type = "response")


# Exercise 6 (model answer): fast-food outlets and heart disease, with poverty
# as a possible common cause. Regress disease on outlets and income: if the
# outlet coefficient stays clearly above zero, the direct explanation survives;
# if it shrinks towards zero, poverty was confounding. Unmeasured confounders
# remain possible.


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: SS between 1.31, SS within 0.55, F = 10.7, as aov() reports
group_scores <- tibble(
  group  = rep(c("A", "B", "C"), each = 4),
  stress = c(2.5, 3.0, 2.8, 3.1,   3.4, 3.8, 3.5, 3.9,   2.9, 3.3, 3.0, 3.4)
) |>
  mutate(group_mean = mean(stress), .by = group)

grand_mean <- mean(group_scores$stress)
ss_between <- sum((group_scores$group_mean - grand_mean)^2)
ss_within  <- sum((group_scores$stress - group_scores$group_mean)^2)
F_value <- (ss_between / 2) / (ss_within / 9)
F_value
summary(aov(stress ~ group, data = group_scores))


# Exercise 8: the line and the band averages agree within a point where most
# students are (6 and 7 hours); tiny groups at the edges bounce around it
bands <- study |>
  filter(!is.na(sleep_hours)) |>
  mutate(sleep_band = round(sleep_hours)) |>
  summarise(students = n(), mean_wellbeing = mean(wellbeing), .by = sleep_band) |>
  arrange(sleep_band)

wb_line <- lm(wellbeing ~ sleep_hours, data = study)
bands |>
  mutate(line = predict(wb_line, newdata = data.frame(sleep_hours = sleep_band)))


# Exercise 9: overall, 45% of men and 30% of women admitted; within
# departments, women's rate is higher in four of six. The department is a
# confounder: women applied mostly to departments that admitted few applicants.
admissions <- as.data.frame(UCBAdmissions)
head(admissions)

admissions |>
  summarise(rate = sum(Freq[Admit == "Admitted"]) / sum(Freq),
            applicants = sum(Freq), .by = Gender)

admissions |>
  summarise(rate = sum(Freq[Admit == "Admitted"]) / sum(Freq),
            applicants = sum(Freq), .by = c(Dept, Gender)) |>
  arrange(Dept)


# Exercise 10: the straight line's residuals form an arch; with the squared
# term they scatter evenly. R-squared 0.004 vs 0.036; the curve peaks at about
# 32 hours.
straight <- lm(gpa ~ study_hours, data = study)
curved   <- lm(gpa ~ study_hours + I(study_hours^2), data = study)

scatter.smooth(straight$model$study_hours, resid(straight),
               xlab = "Study hours", ylab = "Residual (straight line)")
abline(h = 0, lty = 2)
scatter.smooth(curved$model$study_hours, resid(curved),
               xlab = "Study hours", ylab = "Residual (curve)")
abline(h = 0, lty = 2)
c(straight = summary(straight)$r.squared, curved = summary(curved)$r.squared)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. Variation between group averages against variation within groups, each per
#    degree of freedom. Near 1: no more than chance; large: more.
# 2. The difference in the outcome between cases that differ by one unit in
#    that predictor but have the same values of the other predictors in the
#    model. A statistical comparison, limited to measured predictors.
# 3. A variable that affects both the predictor and the outcome, creating or
#    distorting an association (sleep, for caffeine and GPA).
# 4. The spread is not constant: coefficients are unbiased, but standard
#    errors, p-values, and intervals are unreliable. Transform the outcome or
#    use robust standard errors.
# 5. Odds are p / (1 - p). Doubling small odds nearly doubles the probability,
#    but odds of 1 (50%) doubled give 67%. Report predicted probabilities too.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 8, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
