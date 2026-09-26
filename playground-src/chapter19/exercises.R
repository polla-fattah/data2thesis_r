# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 19: Putting It All Together
#
# This script holds the R parts of the playground page. The project tasks
# (running the scripts, changing a cleaning rule, the thesis figure) are in
# exercises.txt.
#   A. Practise the chapter       the book's exercises, with blanks (______) to fill
#   B. Go further                 new exercises beyond the book
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

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


# Exercise 2: Students with children in Table 1
describe_more <- function(d) {
  rbind(describe(d),
        data.frame(Characteristic = "Has children",
                   Value = ______(d$has_children == "Yes")))
}
data.frame(
  Characteristic = describe_more(study)$Characteristic,
  Masters = describe_more(filter(study, programme == "Master's"))$Value,
  PhD     = describe_more(filter(study, programme == "PhD"))$Value,
  All     = describe_more(study)$Value
)


# Exercise 3: A sentence for the effect of support on GPA
gpa_model <- lm(gpa ~ sleep_hours + study_hours + stress + support, data = study)
estimate <- coef(gpa_model)["support"]
ci       <- confint(gpa_model)["support", ]
p        <- summary(gpa_model)$coefficients["support", "Pr(>|t|)"]
paste0("Each one-point increase in supervisor support was associated with a GPA ",
       sprintf("%.2f", estimate), " points higher (95% CI ", sprintf("%.2f", ci[1]),
       " to ", sprintf("%.2f", ci[2]), ", ", ______(p),
       "), holding sleep, study hours, and stress constant.")


# Exercise 4: see exercises.txt (a third panel for the thesis figure)


# Exercise 5: A method for a research question from your own field
# (write your answer as comments)


# Exercise 6: The chain of reasoning for RQ2 (sleep less than 7 hours?)
sleep_test <- t.test(study$sleep_hours, mu = ______, alternative = "less")
sleep_ci   <- t.test(study$sleep_hours, mu = 7)$conf.int
c(mean = unname(sleep_test$estimate), lower = sleep_ci[1], upper = sleep_ci[2],
  p = sleep_test$p.value, n = sum(!is.na(study$sleep_hours)))
# Fill in: question, hypothesis, design, variables, analysis, result,
# conclusion, limitation.


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: A helper for confidence intervals, used in three sentences
format_ci <- function(estimate, low, high, digits = 2) {
  f <- paste0("%.", digits, "f")
  paste0(sprintf(f, estimate), " (95% CI ", sprintf(f, low), " to ", sprintf(f, ______), ")")
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


# Exercise 8: The chain of reasoning for RQ4 (stress and faculties)
stress_anova <- aov(stress ~ faculty, data = study)
anova_table  <- summary(stress_anova)[[1]]
anova_table
anova_table[["Sum Sq"]][1] / sum(anova_table[["Sum Sq"]])
tukey <- TukeyHSD(stress_anova)$faculty
tukey[tukey[, "p adj"] < ______, , drop = FALSE]
round(tapply(study$stress, study$faculty, mean), 2)


# Exercise 9: Table 1 by faculty
faculties <- sort(unique(study$faculty))
table_1 <- data.frame(Characteristic = describe(study)$Characteristic)
for (f in faculties) {
  table_1[[f]] <- describe(filter(study, faculty == ______))$Value
}
table_1


# Exercise 10: Choosing methods for five research questions (as comments)
# 1. How many hours a week do nurses in a hospital work, on average?
# 2. Is the number of hours worked related to burnout, allowing for age and ward?
# 3. Burnout measured every three months for two years: does it rise?
# 4. Can nurses who will leave within a year be identified from their records?
# 5. Are there groups of nurses with similar shifts, overtime, and sick days?


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Why should every number in a thesis be traced to code?
# 2. What is the difference between a result and a conclusion?
# 3. Why is the workshop conclusion the only causal one in the chapter?
# 4. What is a limitations section for?
# 5. What are reporting standards such as JARS, CONSORT, and STROBE for?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers.
# ==============================================================================

# Task 1: The capstone. A research question the book did not answer (for
# example, exercise and wellbeing, allowing for sleep), carried through the
# whole chain, then written as a Quarto report like results.qmd.



# Task 2: Check your report against the JARS items for participants, measures,
# and results, and add anything missing.

# Task 3: Review a fellow student's report with the chain of reasoning, and
# write three constructive comments.
