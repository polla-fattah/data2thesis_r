# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 10: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

library(dplyr)
library(lme4)

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")
panel <- semesters |>
  left_join(students, join_by(student_id)) |>
  mutate(time = semester - 1)


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: ICC 0.83; the slope of time is almost exactly zero, with a narrow
# interval (-0.015 to 0.016): sleep does not change
sleep_ri <- lmer(sleep_hours ~ time + (1 | student_id), data = panel)
vc <- as.data.frame(VarCorr(sleep_ri))
vc$vcov[1] / sum(vc$vcov)
confint(sleep_ri, parm = "beta_", method = "Wald")


# Exercise 2: the test favours the random slope (chi-squared 7.8, p = 0.02),
# but the slopes' SD is only 0.05 hours per semester: statistically detectable,
# practically unimportant
sleep_rs <- lmer(sleep_hours ~ time + (time | student_id), data = panel)
anova(sleep_ri, sleep_rs)
VarCorr(sleep_rs)


# Exercise 3: part-time students start 3.9 points lower (CI -5.9 to -1.9); the
# slope difference (0.14, CI -0.34 to 0.61) includes zero: same rate of change
wb_mode <- lmer(wellbeing ~ time * study_mode + (time | student_id), data = panel)
round(summary(wb_mode)$coefficients, 2)
confint(wb_mode, parm = "beta_", method = "Wald")


# Exercise 4: supervisor share 0 (a singular fit); 91% between students
study_levels <- lmer(study_hours ~ time + (1 | supervisor_id) + (1 | student_id),
                     data = panel)
vc <- as.data.frame(VarCorr(study_levels))
data.frame(level = vc$grp, share = round(vc$vcov / sum(vc$vcov), 3))


# Exercise 5: the ordinary regression's false alarms rise to about 46% (about
# 27% with sd = 5); the mixed model stays near 8%. Larger differences between
# supervisors make their students more alike, so the data holds even less
# independent information.
simulate_clustered <- function(style_sd) {
  supervisor <- rep(1:20, each = 10)
  trained    <- rep(rep(c(0, 1), 10), each = 10)
  style      <- rnorm(20, sd = style_sd)[supervisor]
  wellbeing  <- 60 + style + rnorm(200, sd = 10)

  p_ordinary <- summary(lm(wellbeing ~ trained))$coefficients["trained", 4]
  mixed      <- suppressMessages(lmer(wellbeing ~ trained + (1 | supervisor)))
  t_mixed    <- coef(summary(mixed))["trained", "t value"]
  c(ordinary = p_ordinary < 0.05, mixed = 2 * pnorm(-abs(t_mixed)) < 0.05)
}

set.seed(12)
rowMeans(replicate(200, simulate_clustered(style_sd = 10)))


# Exercise 6 (model answer): a student's records are far more alike than
# records of different students, so 2,326 records of 600 students carry about
# as much information as 700 independent ones. An ordinary regression counts
# them all as independent, so its standard errors and p-values are too small.


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: GPA: ICC 0.71, design effect 3.0, worth about 767 records.
# Sleep: ICC 0.83, design effect 3.4, worth about 679.
records_per_student <- nrow(panel) / length(unique(panel$student_id))

gpa_null <- lmer(gpa ~ 1 + (1 | student_id), data = panel)
vc  <- as.data.frame(VarCorr(gpa_null))
icc <- vc$vcov[1] / sum(vc$vcov)
design_effect <- 1 + (records_per_student - 1) * icc
c(icc = icc, design_effect = design_effect,
  worth = sum(!is.na(panel$gpa)) / design_effect)


# Exercise 8: averages and mixed model agree (-3.7, SE 0.98); the ordinary
# regression of all records gives SE 0.54, far too small
averages <- panel |>
  summarise(wellbeing = mean(wellbeing), .by = c(student_id, study_mode))

summary(lm(wellbeing ~ study_mode, data = averages))$coefficients
summary(lmer(wellbeing ~ study_mode + (1 | student_id), data = panel))$coefficients
summary(lm(wellbeing ~ study_mode, data = panel))$coefficients


# Exercise 9: five days give a slope of 8.2 ms per day (SE 2.4), against 10.5
# (SE 1.5) for ten days; a slope describes only the period observed
full  <- lmer(Reaction ~ Days + (Days | Subject), data = sleepstudy)
early <- lmer(Reaction ~ Days + (Days | Subject),
              data = sleepstudy |> filter(Days <= 4))
summary(full)$coefficients
summary(early)$coefficients
VarCorr(full)
VarCorr(early)


# Exercise 10: average growth 8.5 g per day, SD of growth rates 3.8 g per day;
# the intercept (29 g, below the real 41 g) and the -0.95 correlation show that
# growth is curved, not straight
chick_model <- lmer(weight ~ Time + (Time | Chick), data = ChickWeight)
summary(chick_model)$coefficients
VarCorr(chick_model)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. Each student brings stable characteristics to every record, so a second
#    record partly repeats the first.
# 2. The share of variation between groups rather than within them; higher
#    means ignoring the grouping is more wrong.
# 3. Fixed: quantities of interest, one number each. Random: how groups vary
#    around the average, estimated as a standard deviation.
# 4. The random effects are too complex for the data (a zero variance or a
#    correlation of +-1). Simplify the random effects and report it.
# 5. The course was given to 20 supervisors; their students were not
#    independent, so the ordinary regression underestimated the standard error.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 10, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
