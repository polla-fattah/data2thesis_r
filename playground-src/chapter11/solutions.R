# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 11: Solutions
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

# Trees and forests need no dummy variables or normalisation
tree_recipe <- recipe(considering_dropout ~ ., data = dropout_train) |>
  step_impute_median(all_numeric_predictors())

set.seed(2026)
dropout_folds <- vfold_cv(dropout_train, v = 10, strata = considering_dropout)


# Exercise 1: A tree of depth 2
tree2_fit <- workflow() |>
  add_recipe(tree_recipe) |>
  add_model(decision_tree(tree_depth = 2, min_n = 10) |> set_mode("classification")) |>
  fit(data = dropout_train)
tree2 <- extract_fit_engine(tree2_fit)
plot(tree2, uniform = TRUE, margin = 0.1)
text(tree2, use.n = TRUE)
tree2
# The first question is about support. Only for students with low support does
# the tree ask a second question, about burnout. In plain words: students with
# low support and high burnout are the most likely to consider dropping out.


# Exercise 2: Tune the random forest's mtry
forest_wf <- workflow() |>
  add_recipe(tree_recipe) |>
  add_model(rand_forest(trees = 500, mtry = tune()) |>
              set_engine("ranger") |> set_mode("classification"))
set.seed(2026)
forest_tuning <- tune_grid(forest_wf, resamples = dropout_folds,
                           grid = tibble(mtry = c(2, 5, 10)),
                           metrics = metric_set(roc_auc))
collect_metrics(forest_tuning)
# mtry = 2 does slightly best (AUC about 0.78), but the differences are much
# smaller than the standard errors, and no forest beats logistic regression (0.80).


# Exercise 3: Extend the k-NN grid
knn_wf <- workflow() |>
  add_recipe(dropout_recipe) |>
  add_model(nearest_neighbor(neighbors = tune()) |> set_mode("classification"))
set.seed(2026)
knn_tuning <- tune_grid(knn_wf, resamples = dropout_folds,
                        grid = tibble(neighbors = c(41, 81, 161, 301)),
                        metrics = metric_set(roc_auc))
collect_metrics(knn_tuning)
# The AUC keeps rising, to about 0.79 with k = 301. The training folds have about
# 400 students, so each prediction then averages over most of them, weighted by
# distance: k-NN has become a very smooth model, and a smooth model suits this data.


# Exercise 4: Linear and RBF support vector machines
svm_models <- workflow_set(
  preproc = list(normalised = dropout_recipe),
  models  = list(
    svm_linear = svm_linear() |> set_engine("kernlab") |> set_mode("classification"),
    svm_rbf    = svm_rbf() |> set_mode("classification")
  )
)
svm_comparison <- workflow_map(svm_models, "fit_resamples", resamples = dropout_folds,
                               metrics = metric_set(roc_auc), seed = 2026)
rank_results(svm_comparison, rank_metric = "roc_auc") |> select(wflow_id, mean, std_err)
# The linear SVM does a little better: a straight boundary suits this data.


# Exercise 5: A threshold that flags about 10% of students
logistic_wf <- workflow() |> add_recipe(dropout_recipe) |> add_model(logistic_reg())
set.seed(2026)
logistic_cv <- fit_resamples(logistic_wf, resamples = dropout_folds,
                             control = control_resamples(save_pred = TRUE))
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
# A threshold of 0.45 flags about 9% of students. It finds only about a third of
# those at risk, but more than half of the flagged students are truly at risk.


# Exercise 6: Downsampling
library(themis)
downsample_wf <- workflow() |>
  add_recipe(dropout_recipe |> step_downsample(considering_dropout)) |>
  add_model(logistic_reg())
set.seed(2026)
fit_resamples(downsample_wf, resamples = dropout_folds,
              metrics = metric_set(roc_auc, sensitivity, precision)) |>
  collect_metrics()
# Like upsampling, downsampling raises the sensitivity at the 0.5 threshold
# (to about 75%) without improving the AUC (0.79). It also throws away most of
# the "No" students, so each model learns from much less data.


# Exercise 7: At-risk students found, by faculty
logistic_fit <- fit(logistic_wf, data = dropout_train)
augment(logistic_fit, new_data = dropout_test) |>
  filter(considering_dropout == "Yes") |>
  summarise(at_risk = n(), flagged = sum(.pred_Yes >= 0.2), .by = faculty)
# With only a handful of at-risk students in each faculty, the shares are too
# uncertain to compare. A real check needs far more data.
