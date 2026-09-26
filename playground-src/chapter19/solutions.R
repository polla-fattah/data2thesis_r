# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 19: Solutions
#
# One possible solution for the R exercises in parts A and B, and model answers
# for part C. The project tasks are in exercises.txt, with hints and answers at
# its end. Part D has no solutions: the tasks are open.

library(dplyr)
library(here)

# The clean data made by the project's cleaning script (run it first if needed)
if (!file.exists(here("data", "students.csv"))) source(here("R", "01-clean-data.R"))
students      <- read.csv(here("data", "students.csv"))
semesters     <- read.csv(here("data", "semesters.csv"))
questionnaire <- read.csv(here("data", "questionnaire.csv"))

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

mean_sd  <- function(x) sprintf("%.1f (%.1f)", mean(x, na.rm = TRUE), sd(x, na.rm = TRUE))
percent  <- function(x) sprintf("%.0f%%", 100 * mean(x, na.rm = TRUE))
format_p <- function(p) if (p < 0.001) "p < .001" else paste("p =", sub("^0", "", sprintf("%.3f", p)))
describe <- function(d) {
  data.frame(
    Characteristic = c("Students", "Age, mean (SD)", "Women", "Part-time",
                       "Stress (1-5), mean (SD)", "Support (1-5), mean (SD)",
                       "Wellbeing in semester 1, mean (SD)", "Considered dropping out"),
    Value = c(nrow(d), mean_sd(d$age), percent(d$gender == "Female"),
              percent(d$study_mode == "Part-time"), mean_sd(d$stress),
              mean_sd(d$support), mean_sd(d$wellbeing),
              percent(d$considering_dropout == "Yes"))
  )
}


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: see exercises.txt (run the project; change a cleaning rule)


# Exercise 2: 20% of Master's and 40% of PhD students have children, 26% in all
describe_more <- function(d) {
  rbind(describe(d),
        data.frame(Characteristic = "Has children",
                   Value = percent(d$has_children == "Yes")))
}
data.frame(
  Characteristic = describe_more(study)$Characteristic,
  Masters = describe_more(filter(study, programme == "Master's"))$Value,
  PhD     = describe_more(filter(study, programme == "PhD"))$Value,
  All     = describe_more(study)$Value
)


# Exercise 3: "... a GPA 0.11 points higher (95% CI 0.08 to 0.14, p < .001) ..."
gpa_model <- lm(gpa ~ sleep_hours + study_hours + stress + support, data = study)
estimate <- coef(gpa_model)["support"]
ci       <- confint(gpa_model)["support", ]
p        <- summary(gpa_model)$coefficients["support", "Pr(>|t|)"]
paste0("Each one-point increase in supervisor support was associated with a GPA ",
       sprintf("%.2f", estimate), " points higher (95% CI ", sprintf("%.2f", ci[1]),
       " to ", sprintf("%.2f", ci[2]), ", ", format_p(p),
       "), holding sleep, study hours, and stress constant.")


# Exercise 4: see exercises.txt (a third panel for the thesis figure)


# Exercise 5 (model answer): name the goal, the outcome type, and whether the
# observations are repeated or nested; follow the guide to the method and the
# chapter to reread (for example, repeated yes-or-no outcomes: Chapter 10).


# Exercise 6: mean 6.48 hours (95% CI 6.40 to 6.57), p < .001, n = 594.
# Hypothesis: average sleep is below 7 hours. Design: observational, first
# semester. Variable: self-reported sleep. Analysis: one-sided one-sample
# t-test against 7. Conclusion: students sleep about half an hour less than
# recommended. Limitation: self-reported sleep; one university; one semester.
sleep_test <- t.test(study$sleep_hours, mu = 7, alternative = "less")
sleep_ci   <- t.test(study$sleep_hours, mu = 7)$conf.int
c(mean = unname(sleep_test$estimate), lower = sleep_ci[1], upper = sleep_ci[2],
  p = sleep_test$p.value, n = sum(!is.na(study$sleep_hours)))


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: GPA higher by 0.11 (95% CI 0.08 to 0.13) per hour of sleep;
# wellbeing higher by 3.8 (95% CI 1.7 to 5.9) for full-time students; odds of
# considering dropout multiplied by 3.6 (95% CI 2.3 to 5.8) per point of stress
format_ci <- function(estimate, low, high, digits = 2) {
  f <- paste0("%.", digits, "f")
  paste0(sprintf(f, estimate), " (95% CI ", sprintf(f, low), " to ", sprintf(f, high), ")")
}
ci <- confint(gpa_model)["sleep_hours", ]
paste("Each extra hour of sleep went with a GPA higher by",
      format_ci(coef(gpa_model)["sleep_hours"], ci[1], ci[2]), "points.")
mode_test <- t.test(wellbeing ~ study_mode, data = study)
paste("Full-time students' wellbeing was higher by",
      format_ci(-diff(mode_test$estimate), mode_test$conf.int[1], mode_test$conf.int[2], 1),
      "points.")
dropout_model <- glm(I(considering_dropout == "Yes") ~ stress + support + financial_worry +
                       employment + study_mode, data = study, family = binomial)
or <- exp(cbind(coef(dropout_model), confint.default(dropout_model)))["stress", ]
paste0("Each point of stress multiplied the odds of considering dropout by ",
       format_ci(or[1], or[2], or[3], 1), ".")


# Exercise 8: F(4, 595) = 4.15, p = .003, eta squared 0.03; only Health
# Sciences (3.37) and Humanities (3.03) differ. Significant but small, and
# observational: students chose their faculty.
stress_anova <- aov(stress ~ faculty, data = study)
anova_table  <- summary(stress_anova)[[1]]
anova_table
anova_table[["Sum Sq"]][1] / sum(anova_table[["Sum Sq"]])
tukey <- TukeyHSD(stress_anova)$faculty
tukey[tukey[, "p adj"] < 0.05, , drop = FALSE]
round(tapply(study$stress, study$faculty, mean), 2)


# Exercise 9: five columns from one function, 87 to 154 students each
faculties <- sort(unique(study$faculty))
table_1 <- data.frame(Characteristic = describe(study)$Characteristic)
for (f in faculties) {
  table_1[[f]] <- describe(filter(study, faculty == f))$Value
}
table_1


# Exercise 10 (model answer): 1. describe: mean with CI, histogram; 2. multiple
# regression (mixed model if wards matter); 3. mixed-effects model over time;
# 4. classification, tested on held-out nurses; 5. clustering, reported as
# descriptive profiles.


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. So that every result can be checked, repeated, and updated, and cannot be
#    mistyped.
# 2. A result is what the analysis produced; a conclusion is what it means for
#    the question, given the design, the measures, and their limits.
# 3. Only the workshop invitation was assigned at random.
# 4. To show how far the conclusions reach: other explanations, measurement
#    problems, and to whom the results apply.
# 5. They list what readers need to judge a study, so that nothing essential is
#    missing.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open.
# ==============================================================================
