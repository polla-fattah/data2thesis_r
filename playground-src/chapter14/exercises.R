# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 14: Neural Networks
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
# Double the importance of support (weight -1.6 instead of -0.8).
sigmoid <- function(z) 1 / (1 + exp(-z))
neuron <- function(stress, support) {
  sigmoid(-4 + 1.2 * stress + ______ * support)
}
neuron(stress = 4, support = 2)
neuron(stress = 2, support = 4)


# Exercise 2: One hidden neuron
# Tune the weight decay of a network with a single hidden neuron and compare its
# cross-validated AUC with logistic regression.
one_neuron <- mlp(hidden_units = ______, penalty = tune(), epochs = 500) |>
  set_engine("nnet") |>
  set_mode("classification")


# Exercise 3: Seeds
# Fit the chapter's best network (10 hidden neurons, penalty 3.16) with
# last_fit() three times, with seeds 1, 2, and 3. How much does the test AUC vary?
best_net <- mlp(hidden_units = 10, penalty = 3.16, epochs = 500) |>
  set_engine("nnet", MaxNWts = 5000) |>
  set_mode("classification")


# Exercise 4: Epochs
# Train a 20-neuron network without weight decay for 10, 100, and 1000 epochs.
# Compare the training and test AUCs.
for (n_epochs in c(10, 100, 1000)) {
  spec <- mlp(hidden_units = 20, penalty = 0, epochs = ______) |>
    set_engine("nnet", MaxNWts = 5000) |>
    set_mode("classification")
  # fit on dropout_train, then calculate roc_auc on dropout_train and dropout_test
}


# Exercise 5: A regression network
# Predict the compressive strength of concrete (modeldata) with a network of
# 10 hidden neurons and weight decay 0.1, and compare its RMSE with linear regression.
data(concrete, package = "modeldata")


# Exercise 6: Explain the choice
# In two or three sentences, explain to Elaf's research group why she keeps
# logistic regression instead of the neural network.
