# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 14: Solutions
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

set.seed(2026)
dropout_split <- initial_split(dropout_data, prop = 0.75, strata = considering_dropout)
dropout_train <- training(dropout_split)
dropout_test  <- testing(dropout_split)

dropout_recipe <- recipe(considering_dropout ~ ., data = dropout_train) |>
  step_impute_median(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())

set.seed(2026)
dropout_folds <- vfold_cv(dropout_train, v = 10, strata = considering_dropout)


# Exercise 1: A neuron by hand
sigmoid <- function(z) 1 / (1 + exp(-z))
neuron <- function(stress, support) {
  sigmoid(-4 + 1.2 * stress - 1.6 * support)
}
neuron(stress = 4, support = 2)
neuron(stress = 2, support = 4)
# The outputs fall (to about 0.08 and 0.0003): a larger negative weight means
# that support lowers the predicted risk more strongly.


# Exercise 2: One hidden neuron
one_neuron <- mlp(hidden_units = 1, penalty = tune(), epochs = 500) |>
  set_engine("nnet") |>
  set_mode("classification")
set.seed(2026)
one_tuning <- tune_grid(workflow(dropout_recipe, one_neuron), resamples = dropout_folds,
                        grid = tibble(penalty = 10^seq(-2, 1.5, by = 0.5)),
                        metrics = metric_set(roc_auc))
show_best(one_tuning, metric = "roc_auc", n = 1)
set.seed(2026)
fit_resamples(workflow(dropout_recipe, logistic_reg()), resamples = dropout_folds,
              metrics = metric_set(roc_auc)) |>
  collect_metrics()
# With enough weight decay, one hidden neuron reaches a cross-validated AUC of
# about 0.80, practically the same as logistic regression (0.80). A network with
# one hidden neuron is little more than a logistic regression with an extra step.


# Exercise 3: Seeds
best_net <- mlp(hidden_units = 10, penalty = 3.16, epochs = 500) |>
  set_engine("nnet", MaxNWts = 5000) |>
  set_mode("classification")
for (s in 1:3) {
  set.seed(s)
  result <- last_fit(workflow(dropout_recipe, best_net), dropout_split,
                     metrics = metric_set(roc_auc))
  cat("seed", s, ": test AUC", round(collect_metrics(result)$.estimate, 3), "\n")
}
# The test AUC is the same (about 0.85) for every seed: with strong weight decay,
# training ends at the same solution from any random start. Try penalty = 0.01:
# the test AUC then varies from seed to seed (about 0.75 to 0.79), because a
# lightly penalised network can end up in different places.


# Exercise 4: Epochs
for (n_epochs in c(10, 100, 1000)) {
  spec <- mlp(hidden_units = 20, penalty = 0, epochs = n_epochs) |>
    set_engine("nnet", MaxNWts = 5000) |>
    set_mode("classification")
  set.seed(2026)
  fitted <- fit(workflow(dropout_recipe, spec), data = dropout_train)
  train_auc <- augment(fitted, new_data = dropout_train) |> roc_auc(considering_dropout, .pred_Yes)
  test_auc  <- augment(fitted, new_data = dropout_test) |> roc_auc(considering_dropout, .pred_Yes)
  cat(n_epochs, "epochs: training AUC", round(train_auc$.estimate, 3),
      ", test AUC", round(test_auc$.estimate, 3), "\n")
}
# After 10 epochs the network has not yet memorised the data (training AUC about
# 0.95, test about 0.72). By 100 epochs it has (training AUC 1), and the test AUC
# has fallen to about 0.64. Without weight decay, longer training means more
# overfitting.


# Exercise 5: A regression network
data(concrete, package = "modeldata")
set.seed(1)
concrete_split <- initial_split(concrete)
concrete_recipe <- recipe(compressive_strength ~ ., data = training(concrete_split)) |>
  step_log(age) |>
  step_normalize(all_numeric_predictors())
concrete_net <- mlp(hidden_units = 10, penalty = 0.1, epochs = 1000) |>
  set_engine("nnet", MaxNWts = 5000) |>
  set_mode("regression")
set.seed(1)
last_fit(workflow(concrete_recipe, linear_reg()), concrete_split) |> collect_metrics()
set.seed(1)
last_fit(workflow(concrete_recipe, concrete_net), concrete_split) |> collect_metrics()
# The network's RMSE is about 5 megapascals, against about 7 for linear regression:
# concrete strength has curves and interactions for the network to capture.


# Exercise 6: Explain the choice
# For example: "A carefully tuned neural network predicted dropout no better
# than logistic regression (both had a cross-validated AUC of about 0.80), and
# its hundreds of weights cannot be interpreted. Logistic regression is just as
# accurate, and its odds ratios show how each factor is related to the risk."
