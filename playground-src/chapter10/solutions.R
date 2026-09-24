# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 10: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

library(tidymodels)
tidymodels_prefer()

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")

scores <- questionnaire |>
  mutate(
    stress_4     = 6 - stress_4,
    stress       = rowMeans(pick(stress_1:stress_6), na.rm = TRUE),
    burnout      = rowMeans(pick(burnout_1:burnout_6), na.rm = TRUE),
    support      = rowMeans(pick(support_1:support_6), na.rm = TRUE),
    satisfaction = rowMeans(pick(satisfaction_1:satisfaction_4), na.rm = TRUE)
  ) |>
  select(student_id, stress, burnout, support, satisfaction)

dropout_data <- students |>
  left_join(scores, join_by(student_id)) |>
  left_join(semesters |> filter(semester == 1) |> select(-semester), join_by(student_id)) |>
  mutate(considering_dropout = factor(considering_dropout, levels = c("Yes", "No"))) |>
  select(-student_id, -supervisor_id, -workshop, -workshop_sessions)


# Exercise 1
set.seed(2026)
dropout_split <- initial_split(dropout_data, prop = 0.75, strata = considering_dropout)
dropout_train <- training(dropout_split)
dropout_test  <- testing(dropout_split)
dropout_recipe <- recipe(considering_dropout ~ ., data = dropout_train) |>
  step_impute_median(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())


# Exercise 2: about 0.80
logistic_wf <- workflow() |> add_recipe(dropout_recipe) |> add_model(logistic_reg())
set.seed(2026)
dropout_folds <- vfold_cv(dropout_train, v = 10, strata = considering_dropout)
fit_resamples(logistic_wf, dropout_folds, metrics = metric_set(roc_auc)) |> collect_metrics()


# Exercise 3: the AUC falls clearly: the questionnaire carries much of the signal
no_q <- dropout_data |> select(-stress, -burnout, -support, -satisfaction)
set.seed(2026)
no_q_split <- initial_split(no_q, prop = 0.75, strata = considering_dropout)
no_q_recipe <- recipe(considering_dropout ~ ., data = training(no_q_split)) |>
  step_impute_median(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())
set.seed(2026)
no_q_folds <- vfold_cv(training(no_q_split), v = 10, strata = considering_dropout)
workflow() |> add_recipe(no_q_recipe) |> add_model(logistic_reg()) |>
  fit_resamples(no_q_folds, metrics = metric_set(roc_auc)) |>
  collect_metrics()


# Exercise 4: larger k is better here, but logistic regression still does as well or better
knn_wf <- workflow() |>
  add_recipe(dropout_recipe) |>
  add_model(nearest_neighbor(neighbors = tune()) |> set_mode("classification"))
set.seed(2026)
knn_tuning <- tune_grid(knn_wf, dropout_folds, grid = tibble(neighbors = c(5, 11, 21, 41)),
                        metrics = metric_set(roc_auc))
collect_metrics(knn_tuning)
select_best(knn_tuning, metric = "roc_auc")


# Exercise 5
last_fit(logistic_wf, dropout_split, metrics = metric_set(roc_auc, accuracy)) |>
  collect_metrics()
