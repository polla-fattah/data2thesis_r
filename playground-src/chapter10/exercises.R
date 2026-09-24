# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 10: Introduction to Machine Learning in R
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

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


# Exercise 1: A stratified split (75/25) and a recipe
set.seed(2026)
dropout_split <- initial_split(dropout_data, prop = ______, strata = ______)
dropout_train <- training(dropout_split)
dropout_test  <- testing(dropout_split)
dropout_recipe <- recipe(considering_dropout ~ ., data = dropout_train) |>
  step_impute_median(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())


# Exercise 2: Cross-validated AUC of logistic regression
logistic_wf <- workflow() |> add_recipe(dropout_recipe) |> add_model(logistic_reg())
set.seed(2026)
dropout_folds <- vfold_cv(dropout_train, v = ______, strata = considering_dropout)
fit_resamples(logistic_wf, dropout_folds, metrics = metric_set(roc_auc)) |> collect_metrics()


# Exercise 3: Without the questionnaire
# Remove stress, burnout, support, and satisfaction, and repeat Exercise 2
# (you need a new split, recipe, and folds). How much does the AUC fall?


# Exercise 4: Tune k-nearest neighbours over neighbors = c(5, 11, 21, 41)
knn_wf <- workflow() |>
  add_recipe(dropout_recipe) |>
  add_model(nearest_neighbor(neighbors = tune()) |> set_mode("classification"))


# Exercise 5: The final test
# Use last_fit() to fit the logistic workflow on the training data and
# evaluate it once on the test data.

