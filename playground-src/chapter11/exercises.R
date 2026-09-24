# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 11: Classification Models
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

# Trees and forests need no dummy variables or normalisation
tree_recipe <- recipe(considering_dropout ~ ., data = dropout_train) |>
  step_impute_median(all_numeric_predictors())

set.seed(2026)
dropout_folds <- vfold_cv(dropout_train, v = 10, strata = considering_dropout)


# Exercise 1: A tree of depth 2
# Fit it, draw it, and explain it in plain words.
tree2_fit <- workflow() |>
  add_recipe(tree_recipe) |>
  add_model(decision_tree(tree_depth = ______, min_n = 10) |> set_mode("classification")) |>
  fit(data = dropout_train)
tree2 <- extract_fit_engine(tree2_fit)
plot(tree2, uniform = TRUE, margin = 0.1)
text(tree2, use.n = TRUE)


# Exercise 2: Tune the random forest's mtry over c(2, 5, 10)
forest_wf <- workflow() |>
  add_recipe(tree_recipe) |>
  add_model(rand_forest(trees = 500, mtry = ______) |>
              set_engine("ranger") |> set_mode("classification"))
set.seed(2026)
forest_tuning <- tune_grid(forest_wf, resamples = dropout_folds,
                           grid = tibble(mtry = c(2, 5, 10)),
                           metrics = metric_set(roc_auc))
collect_metrics(forest_tuning)


# Exercise 3: Extend the k-NN grid to neighbors = c(41, 81, 161, 301)
# Does the AUC keep rising?
knn_wf <- workflow() |>
  add_recipe(dropout_recipe) |>
  add_model(nearest_neighbor(neighbors = tune()) |> set_mode("classification"))


# Exercise 4: Compare a linear and an RBF support vector machine
# with cross-validation (svm_linear() needs set_engine("kernlab")).


# Exercise 5: Choose a threshold that flags about 10% of students
logistic_wf <- workflow() |> add_recipe(dropout_recipe) |> add_model(logistic_reg())
set.seed(2026)
logistic_cv <- fit_resamples(logistic_wf, resamples = dropout_folds,
                             control = control_resamples(save_pred = ______))
cv_predictions <- collect_predictions(logistic_cv)
threshold_table <- map(c(0.5, 0.45, 0.4, 0.35, 0.3), \(t) {
  cv_predictions |>
    mutate(flag = factor(if_else(.pred_Yes >= t, "Yes", "No"), levels = c("Yes", "No"))) |>
    summarise(threshold = t,
              flagged   = mean(flag == "Yes"),
              recall    = sensitivity_vec(considering_dropout, flag),
              precision = precision_vec(considering_dropout, flag))
}) |> list_rbind()
threshold_table


# Exercise 6: Downsampling instead of upsampling
# Compare the cross-validated sensitivity and AUC with the chapter's upsampling.
library(themis)
downsample_wf <- workflow() |>
  add_recipe(dropout_recipe |> step_downsample(considering_dropout)) |>
  add_model(logistic_reg())


# Exercise 7: Does the model find at-risk students equally often in every faculty?
# Fit logistic_wf on the training data, flag test students with a threshold of 0.2,
# and count, for each faculty, the at-risk students and how many of them are flagged.
