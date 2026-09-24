# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 12: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

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


# Exercise 1: MAE and RMSE
tiny <- tibble(
  actual    = c(3.2, 2.8, 3.6, 3.0, 2.5),
  predicted = c(3.0, 2.9, 3.3, 3.1, 2.9)
)
errors <- tiny$actual - tiny$predicted
mean(abs(errors))
sqrt(mean(errors^2))
tiny |> regression_metrics(truth = actual, estimate = predicted)

tiny$predicted[5] <- 3.5
tiny |> regression_metrics(truth = actual, estimate = predicted)
# The MAE rises from 0.22 to 0.34, the RMSE from 0.25 to 0.48: squaring gives
# the one big miss much more weight.


# Exercise 2: 150 students
set.seed(3)
small_train <- gpa_train |> slice_sample(n = 150)
lm_wf <- workflow(gpa_recipe, linear_reg())
lasso_wf <- workflow(gpa_recipe, linear_reg(penalty = 0.03, mixture = 1) |> set_engine("glmnet"))
fit(lm_wf, data = small_train) |>
  augment(new_data = gpa_test) |>
  regression_metrics(final_gpa, .pred)
fit(lasso_wf, data = small_train) |>
  augment(new_data = gpa_test) |>
  regression_metrics(final_gpa, .pred)
# With 150 students, ordinary regression still overfits (test RMSE about 0.26),
# while the lasso reaches about 0.20, close to what it achieves with all the
# training students. The gap is smaller than with 60 students, but still large.


# Exercise 3: Ridge and lasso coefficients
glmnet_wf <- workflow(gpa_recipe,
                      linear_reg(penalty = tune(), mixture = tune()) |> set_engine("glmnet"))
glmnet_grid <- expand_grid(penalty = 10^seq(-4, 0, length.out = 20),
                           mixture = c(0, 0.5, 1))
set.seed(2026)
glmnet_tuning <- tune_grid(glmnet_wf, resamples = gpa_folds, grid = glmnet_grid,
                           metrics = metric_set(rmse))

best_ridge <- select_best(glmnet_tuning |> filter_parameters(mixture == 0), metric = "rmse")
best_lasso <- select_best(glmnet_tuning |> filter_parameters(mixture == 1), metric = "rmse")
ridge_coefs <- glmnet_wf |> finalize_workflow(best_ridge) |> fit(gpa_train) |> tidy()
lasso_coefs <- glmnet_wf |> finalize_workflow(best_lasso) |> fit(gpa_train) |> tidy()
sum(ridge_coefs$estimate == 0)
sum(lasso_coefs$estimate == 0)
# Ridge shrinks the coefficients but keeps every predictor (no zeros); the lasso
# sets most of them to exactly zero.


# Exercise 4: Scale scores instead of items
scale_data <- gpa_data |>
  mutate(
    stress_4     = 6 - stress_4,
    stress       = rowMeans(pick(stress_1:stress_6), na.rm = TRUE),
    burnout      = rowMeans(pick(burnout_1:burnout_6), na.rm = TRUE),
    support      = rowMeans(pick(support_1:support_6), na.rm = TRUE),
    satisfaction = rowMeans(pick(satisfaction_1:satisfaction_4), na.rm = TRUE)
  ) |>
  select(-matches("_[1-6]$"))

set.seed(2026)
scale_split <- initial_split(scale_data, prop = 0.75, strata = final_gpa)
set.seed(2026)
scale_folds <- vfold_cv(training(scale_split), v = 10, strata = final_gpa)
scale_recipe <- recipe(final_gpa ~ ., data = training(scale_split)) |>
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())
set.seed(2026)
scale_tuning <- tune_grid(
  workflow(scale_recipe, linear_reg(penalty = tune(), mixture = 1) |> set_engine("glmnet")),
  resamples = scale_folds,
  grid = tibble(penalty = 10^seq(-4, 0, length.out = 20)),
  metrics = metric_set(rmse)
)
show_best(scale_tuning, metric = "rmse", n = 1)
# The best RMSE is about 0.20, the same as with the 22 items: the lasso copes
# well with many related predictors, and the scale scores lose nothing here.
# (matches("_[1-6]$") selects the item columns, whose names end in _1 to _6;
# the semester columns end in _s1 or _s2, so they are kept.)


# Exercise 5: More trees for XGBoost
xgb_wf <- workflow(gpa_recipe,
                   boost_tree(trees = tune(), learn_rate = 0.03, tree_depth = 1) |>
                     set_engine("xgboost") |>
                     set_mode("regression"))
set.seed(2026)
xgb_tuning <- tune_grid(xgb_wf, resamples = gpa_folds,
                        grid = tibble(trees = c(100, 500, 1000)),
                        metrics = metric_set(rmse))
collect_metrics(xgb_tuning)
# 100 trees are not enough with a learning rate of 0.03 (RMSE about 0.22);
# 500 trees reach about 0.21, and 1000 add nothing. With a small learning
# rate, boosting needs more trees, but beyond a point extra trees do not help.


# Exercise 6: The final test
best_glmnet <- select_best(glmnet_tuning, metric = "rmse")
final_fit <- glmnet_wf |>
  finalize_workflow(best_glmnet) |>
  last_fit(gpa_split, metrics = regression_metrics)
collect_metrics(final_fit)
# For example: "On students the model had never seen, predicted final GPAs were
# off by about 0.16 GPA points on average (RMSE 0.19), and the predictions
# captured about 65% of the differences in final GPA between students."
