# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 12: Predictive Regression
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

library(tidymodels)
tidymodels_prefer()

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")

year_one <- semesters |>
  filter(semester <= 2) |>
  pivot_wider(id_cols = student_id, names_from = semester,
              values_from = gpa:wellbeing, names_glue = "{.value}_s{semester}")

final_gpa <- semesters |>
  filter(semester == 4, !is.na(gpa)) |>
  select(student_id, final_gpa = gpa)

gpa_data <- students |>
  left_join(questionnaire, join_by(student_id)) |>
  left_join(year_one, join_by(student_id)) |>
  inner_join(final_gpa, join_by(student_id)) |>
  select(-student_id, -supervisor_id, -considering_dropout)

set.seed(2026)
gpa_split <- initial_split(gpa_data, prop = 0.75, strata = final_gpa)
gpa_train <- training(gpa_split)
gpa_test  <- testing(gpa_split)

set.seed(2026)
gpa_folds <- vfold_cv(gpa_train, v = 10, strata = final_gpa)

gpa_recipe <- recipe(final_gpa ~ ., data = gpa_train) |>
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())

regression_metrics <- metric_set(rmse, mae, rsq)


# Exercise 1: MAE and RMSE, by hand and with yardstick
tiny <- tibble(
  actual    = c(3.2, 2.8, 3.6, 3.0, 2.5),
  predicted = c(3.0, 2.9, 3.3, 3.1, 2.9)
)
errors <- tiny$actual - tiny$predicted
mean(abs(______))
sqrt(mean(______))
tiny |> regression_metrics(truth = actual, estimate = predicted)
# Then change one prediction so that it is off by 1.0. Which measure changes more?


# Exercise 2: Ordinary regression and the lasso with 150 students
# Repeat the chapter's 60-student experiment with 150 students.
set.seed(3)
small_train <- gpa_train |> slice_sample(n = ______)
lm_wf <- workflow(gpa_recipe, linear_reg())
lasso_wf <- workflow(gpa_recipe, linear_reg(penalty = 0.03, mixture = 1) |> set_engine("glmnet"))


# Exercise 3: Tune ridge, elastic net, and lasso; compare ridge and lasso coefficients
glmnet_wf <- workflow(gpa_recipe,
                      linear_reg(penalty = tune(), mixture = tune()) |> set_engine("glmnet"))
glmnet_grid <- expand_grid(penalty = 10^seq(-4, 0, length.out = 20),
                           mixture = c(0, 0.5, 1))
set.seed(2026)
glmnet_tuning <- tune_grid(glmnet_wf, resamples = gpa_folds, grid = glmnet_grid,
                           metrics = metric_set(rmse))
# Pick the best ridge (mixture 0) and the best lasso (mixture 1) with
# select_best(glmnet_tuning |> filter_parameters(mixture == ______), metric = "rmse"),
# fit each on gpa_train, and count the coefficients that are exactly zero.


# Exercise 4: The lasso with the four scale scores instead of the 22 items
# Hint: compute stress, burnout, support, and satisfaction as in Chapter 10,
# remove the item columns, and repeat the tuning of Exercise 3 for mixture = 1.


# Exercise 5: More trees for XGBoost
xgb_wf <- workflow(gpa_recipe,
                   boost_tree(trees = tune(), learn_rate = 0.03, tree_depth = 1) |>
                     set_engine("xgboost") |>
                     set_mode("regression"))
set.seed(2026)
xgb_tuning <- tune_grid(xgb_wf, resamples = gpa_folds,
                        grid = tibble(trees = c(______)),
                        metrics = metric_set(rmse))
collect_metrics(xgb_tuning)


# Exercise 6: The final test
# Finalise the best glmnet workflow, run last_fit() on gpa_split, and report
# the RMSE, MAE, and R² in one sentence for the academic advisers.
