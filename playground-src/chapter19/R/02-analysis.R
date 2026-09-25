# 02-analysis.R
# Fits the models for the results chapter and saves the results and figures
# to output/. Run after 01-clean-data.R.

library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(patchwork)
library(lme4)
library(broom)
library(here)

students      <- read_csv(here("data", "students.csv"), show_col_types = FALSE)
questionnaire <- read_csv(here("data", "questionnaire.csv"), show_col_types = FALSE)
semesters     <- read_csv(here("data", "semesters.csv"), show_col_types = FALSE)

# Scale scores and the one-row-per-student table --------------------------------
scores <- questionnaire |>
  mutate(
    stress_4 = 6 - stress_4,
    stress   = rowMeans(pick(stress_1:stress_6), na.rm = TRUE),
    burnout  = rowMeans(pick(burnout_1:burnout_6), na.rm = TRUE),
    support  = rowMeans(pick(support_1:support_6), na.rm = TRUE)
  ) |>
  select(student_id, stress, burnout, support)

study <- students |>
  left_join(scores, join_by(student_id)) |>
  left_join(semesters |> filter(semester == 1), join_by(student_id))

# RQ3: the workshop over four semesters (mixed-effects model) --------------------
panel <- semesters |>
  left_join(students, join_by(student_id)) |>
  mutate(time = semester - 1)

workshop_model <- lmer(wellbeing ~ factor(semester) * workshop + (time | student_id),
                       data = panel)

gaps <- expand.grid(semester = 1:4, workshop = c("Invited", "Not invited")) |>
  mutate(time = semester - 1)
gaps$wellbeing <- predict(workshop_model, newdata = gaps, re.form = NA)
gaps <- gaps |>
  pivot_wider(id_cols = semester, names_from = workshop, values_from = wellbeing) |>
  mutate(gap = Invited - `Not invited`)

# RQ5: GPA (multiple regression) --------------------------------------------------
gpa_model <- lm(gpa ~ sleep_hours + study_hours + stress + support, data = study)
gpa_table <- tidy(gpa_model, conf.int = TRUE)
gpa_fit   <- glance(gpa_model)

# RQ9: considering dropout (logistic regression) ----------------------------------
dropout_model <- glm(
  I(considering_dropout == "Yes") ~ stress + support + financial_worry + employment + study_mode,
  data = study, family = binomial
)
dropout_table <- tidy(dropout_model, conf.int = TRUE, exponentiate = TRUE)

# Figure 1 ---------------------------------------------------------------------------
panel_a <- gaps |>
  pivot_longer(c(Invited, `Not invited`), names_to = "workshop", values_to = "wellbeing") |>
  ggplot(aes(x = semester, y = wellbeing, colour = workshop)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_colour_viridis_d(end = 0.8) +
  labs(x = "Semester", y = "Predicted wellbeing (0-100)", colour = "Workshop")

panel_b <- ggplot(study, aes(x = sleep_hours, y = gpa)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", formula = y ~ x, colour = "#1f6f8b") +
  labs(x = "Sleep (hours a night)", y = "GPA (semester 1)")

figure_1 <- (panel_a + panel_b) +
  plot_annotation(tag_levels = "A") &
  theme_minimal(base_size = 11)

# Save everything the results chapter needs ------------------------------------------
dir.create(here("output"), showWarnings = FALSE)
ggsave(here("output", "figure-1.png"), figure_1, width = 18, height = 8, units = "cm", dpi = 300)
saveRDS(list(study = study, gaps = gaps, gpa_table = gpa_table, gpa_fit = gpa_fit,
             dropout_table = dropout_table),
        here("output", "results.rds"))
cat("Results saved to output/\n")
