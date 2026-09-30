# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 10: Mixed-Effects Models
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
library(lme4)

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")
panel <- semesters |>
  left_join(students, join_by(student_id)) |>
  mutate(time = semester - 1)


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: Sleep over the semesters
# Random intercept model; ICC; does sleep change?
sleep_ri <- ______(sleep_hours ~ time + (1 | student_id), data = panel)
vc <- as.data.frame(VarCorr(sleep_ri))
vc$vcov[1] / ______(vc$vcov)
confint(sleep_ri, parm = "beta_", method = "Wald")


# Exercise 2: Is a random slope worth keeping?
sleep_rs <- lmer(sleep_hours ~ time + (______ | student_id), data = panel)
anova(sleep_ri, sleep_rs)
VarCorr(sleep_rs)


# Exercise 3: Do part-time students change differently?
wb_mode <- lmer(wellbeing ~ time ______ study_mode + (time | student_id), data = panel)
round(summary(wb_mode)$coefficients, 2)
confint(wb_mode, parm = "beta_", method = "Wald")


# Exercise 4: Supervisors and study hours
# How much of the variation lies between supervisors?
study_levels <- lmer(study_hours ~ time + (______ | supervisor_id) + (1 | student_id),
                     data = panel)
vc <- as.data.frame(VarCorr(study_levels))
data.frame(level = vc$grp, share = round(vc$vcov / sum(vc$vcov), 3))


# Exercise 5: Supervisors who differ more
# sd = 10 for style: what happens to the false alarm rate of the ordinary
# regression, and why? (200 repetitions; try 500 if you have the time.)
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
rowMeans(replicate(200, simulate_clustered(style_sd = ______)))


# Exercise 6: Explaining it to a fellow student
# Why would an ordinary regression of all the semester records be wrong?


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: How much information is in the records?
# The design effect for GPA (then change gpa to sleep_hours).
records_per_student <- nrow(panel) / length(unique(panel$student_id))

gpa_null <- lmer(gpa ~ 1 + (1 | student_id), data = panel)
vc  <- as.data.frame(VarCorr(gpa_null))
icc <- vc$vcov[1] / sum(vc$vcov)
design_effect <- 1 + (records_per_student - 1) * ______
c(icc = icc, design_effect = design_effect,
  worth = sum(!is.na(panel$gpa)) / design_effect)


# Exercise 8: Averaging first, or a mixed model
averages <- panel |>
  summarise(wellbeing = ______(wellbeing), .by = c(student_id, study_mode))

summary(lm(wellbeing ~ study_mode, data = averages))$coefficients
summary(lmer(wellbeing ~ study_mode + (1 | student_id), data = panel))$coefficients
summary(lm(wellbeing ~ study_mode, data = panel))$coefficients


# Exercise 9: How long a study needs to run (sleepstudy, days 0 to 4)
full  <- lmer(Reaction ~ Days + (Days | Subject), data = sleepstudy)
early <- lmer(Reaction ~ Days + (Days | Subject),
              data = sleepstudy |> filter(Days ______ 4))
summary(full)$coefficients
summary(early)$coefficients
VarCorr(full)
VarCorr(early)


# Exercise 10: Growth curves for chicks
chick_model <- lmer(weight ~ Time + (______ | Chick), data = ChickWeight)
summary(chick_model)$coefficients
VarCorr(chick_model)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Why are repeated records of the same student not independent?
# 2. What does the intraclass correlation (ICC) measure?
# 3. What is the difference between a fixed effect and a random effect?
# 4. What does a singular fit mean, and what should you do about it?
# 5. In the chapter's simulation, why did the ordinary regression produce so
#    many false alarms?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Model the change in exercise_days over the semesters, choose the
# random effects with a likelihood ratio test, calculate the ICC, and report.



# Task 2: Does the workshop effect over time differ between Master's and PhD
# students? A three-way interaction, described with predicted wellbeing for the
# four groups in semester 2.



# Task 3: The reporting paragraph for a mixed model of GPA over the semesters,
# with random effects and numbers of observations and students, all by code.



# Task 4: Orange: five trees at seven ages. Give every tree its own growth
# rate, and explain why five trees make the random effects uncertain.
