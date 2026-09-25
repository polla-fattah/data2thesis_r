# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 13: Predictive Regression
#
# Four parts, as on the playground page:
#   A. Practise the chapter       the book's exercises, with tidymodels
#   B. Go further                 new exercises beyond the book, in base R
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

library(tidymodels)
library(rpart)
tidymodels_prefer()

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")

# The chapter's data, split, folds, and recipe
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

make_recipe <- function(data) {
  recipe(final_gpa ~ ., data = data) |>
    step_impute_median(all_numeric_predictors()) |>
    step_impute_mode(all_nominal_predictors()) |>
    step_dummy(all_nominal_predictors()) |>
    step_normalize(all_numeric_predictors())
}
gpa_recipe <- make_recipe(gpa_train)
regression_metrics <- metric_set(rmse, mae, rsq)


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: MAE and RMSE by hand, then one prediction off by 1.0
tiny <- tibble(actual    = c(3.2, 2.8, 3.6, 3.0, 2.5),
               predicted = c(3.0, 2.9, 3.3, 3.1, 2.9))
errors <- tiny$actual - tiny$predicted
c(mae = mean(______(errors)), rmse = sqrt(mean(errors^2)))
tiny |> regression_metrics(truth = actual, estimate = predicted)

tiny$predicted[5] <- 3.5
tiny |> regression_metrics(truth = actual, estimate = predicted)


# Exercise 2: Sixty students or 150: ordinary regression against the lasso
lm_wf    <- workflow(gpa_recipe, linear_reg())
lasso_wf <- workflow(gpa_recipe, linear_reg(penalty = 0.03, mixture = 1) |> set_engine("glmnet"))
for (n in c(60, ______)) {
  set.seed(3)
  small_train <- gpa_train |> slice_sample(n = n)
  print(c(students = n,
          ordinary = augment(fit(lm_wf, small_train), gpa_test) |> rmse(final_gpa, .pred) |> pull(.estimate),
          lasso    = augment(fit(lasso_wf, small_train), gpa_test) |> rmse(final_gpa, .pred) |> pull(.estimate)))
}


# Exercise 3: Ridge and lasso coefficients
glmnet_wf <- workflow(gpa_recipe,
                      linear_reg(penalty = tune(), mixture = tune()) |> set_engine("glmnet"))
set.seed(2026)
glmnet_tuning <- tune_grid(glmnet_wf, resamples = gpa_folds,
                           grid = expand_grid(penalty = 10^seq(-4, 0, length.out = 20),
                                              mixture = c(0, 0.5, 1)),
                           metrics = metric_set(rmse))
best_ridge <- show_best(glmnet_tuning |> filter_parameters(parameters = tibble(mixture = ______)),
                        metric = "rmse", n = 1)
ridge_fit <- workflow(gpa_recipe,
                      linear_reg(penalty = best_ridge$penalty, mixture = 0) |> set_engine("glmnet")) |>
  fit(data = gpa_train)
lasso_fit <- glmnet_wf |> finalize_workflow(select_best(glmnet_tuning, metric = "rmse")) |>
  fit(data = gpa_train)
c(ridge_zero = sum(tidy(ridge_fit)$estimate == 0),
  lasso_zero = sum(tidy(lasso_fit)$estimate == 0))


# Exercise 4: Scale scores instead of items
scale_scores <- questionnaire |>
  mutate(
    stress_4     = 6 - stress_4,
    stress       = rowMeans(pick(stress_1:stress_6), na.rm = TRUE),
    burnout      = rowMeans(pick(burnout_1:burnout_6), na.rm = TRUE),
    support      = rowMeans(pick(support_1:support_6), na.rm = TRUE),
    satisfaction = rowMeans(pick(satisfaction_1:satisfaction_4), na.rm = TRUE)
  ) |>
  select(student_id, stress, burnout, support, satisfaction)
scores_data <- students |>
  left_join(scale_scores, join_by(student_id)) |>
  left_join(year_one, join_by(student_id)) |>
  inner_join(final_gpa, join_by(student_id)) |>
  select(-student_id, -supervisor_id, -considering_dropout)
set.seed(2026)
scores_split <- initial_split(scores_data, prop = 0.75, strata = final_gpa)
set.seed(2026)
scores_folds <- vfold_cv(training(scores_split), v = 10, strata = final_gpa)
set.seed(2026)
tune_grid(workflow(make_recipe(training(scores_split)),
                   linear_reg(penalty = tune(), mixture = 1) |> set_engine("glmnet")),
          resamples = scores_folds,
          grid = tibble(penalty = 10^seq(-4, 0, length.out = 20)),
          metrics = metric_set(rmse)) |>
  show_best(metric = "rmse", n = 1)


# Exercise 5: More trees for XGBoost (learning rate 0.03)
xgb_wf <- workflow(gpa_recipe,
                   boost_tree(trees = tune(), learn_rate = ______) |>
                     set_engine("xgboost") |> set_mode("regression"))
set.seed(2026)
xgb_tuning <- tune_grid(xgb_wf, resamples = gpa_folds,
                        grid = tibble(trees = c(100, 500, 1000)),
                        metrics = metric_set(rmse))
collect_metrics(xgb_tuning)


# Exercise 6: Explaining the RMSE to advisers
# Two sentences on what an RMSE of 0.2 means for one student's predicted GPA.


# ==============================================================================
# B. GO FURTHER (base R, as on the playground page)
# ==============================================================================

gpa_simple <- students |>
  select(student_id, age, financial_worry) |>
  left_join(questionnaire, join_by(student_id)) |>
  left_join(year_one, join_by(student_id)) |>
  inner_join(final_gpa, join_by(student_id)) |>
  select(-student_id) |>
  mutate(across(everything(), \(x) replace(x, is.na(x), median(x, na.rm = TRUE))))
set.seed(12)
train_rows <- sample(nrow(gpa_simple), round(0.75 * nrow(gpa_simple)))
train <- gpa_simple[train_rows, ]
test  <- gpa_simple[-train_rows, ]
rmse_of <- function(actual, predicted) sqrt(mean((actual - predicted)^2))


# Exercise 7: Ridge regression by hand
X <- scale(as.matrix(train[, c("gpa_s1", "gpa_s2")]))
y <- train$final_gpa - mean(train$final_gpa)
cor(train$gpa_s1, train$gpa_s2)
for (lambda in c(0, 10, 100, 1000, 10000)) {
  b <- solve(t(X) %*% X + lambda * ______(ncol(X))) %*% t(X) %*% y
  print(round(c(lambda = lambda, gpa_s1 = b[1], gpa_s2 = b[2]), 4))
}


# Exercise 8: One sample of 60, or ten?
results <- t(sapply(1:10, function(s) {
  set.seed(s)
  small <- train[sample(nrow(train), 60), ]
  c(all_predictors = rmse_of(test$final_gpa, predict(lm(final_gpa ~ ., data = small), test)),
    two_gpas       = rmse_of(test$final_gpa, predict(lm(final_gpa ~ gpa_s1 + gpa_s2, data = small), test)))
}))
round(results, 3)
round(apply(results, 2, ______), 3)


# Exercise 9: Boosting by hand (100 rounds, one-split trees)
learn_rate <- 0.3
boost_train <- train
pred_train <- rep(mean(train$final_gpa), nrow(train))
pred_test  <- rep(mean(train$final_gpa), nrow(test))
train_rmse <- test_rmse <- numeric(100)
for (i in 1:100) {
  boost_train$error <- boost_train$final_gpa - pred_train
  tree <- rpart(error ~ . - final_gpa, data = boost_train,
                control = rpart.control(maxdepth = 1))
  pred_train <- pred_train + learn_rate * predict(tree, boost_train)
  pred_test  <- pred_test  + learn_rate * ______(tree, test)
  train_rmse[i] <- rmse_of(train$final_gpa, pred_train)
  test_rmse[i]  <- rmse_of(test$final_gpa, pred_test)
}
plot(train_rmse, type = "l", ylim = range(c(train_rmse, test_rmse)),
     xlab = "Number of trees", ylab = "RMSE")
lines(test_rmse, lty = 2)
c(best_round = which.min(test_rmse), best_test_rmse = min(test_rmse))


# Exercise 10: The shape of a tree (trees, leave-one-out cross-validation)
cherry <- datasets::trees   # datasets:: avoids a clash with dials::trees()
loo_rmse <- function(formula, back = identity) {
  squared_errors <- sapply(1:nrow(cherry), function(i) {
    model <- lm(formula, data = cherry[-i, ])
    (cherry$Volume[i] - back(predict(model, cherry[i, ])))^2
  })
  sqrt(mean(squared_errors))
}
c(linear  = loo_rmse(Volume ~ Girth + Height),
  log_log = loo_rmse(log(Volume) ~ log(Girth) + log(Height), back = ______))
coef(lm(log(Volume) ~ log(Girth) + log(Height), data = cherry))


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Why does ordinary regression overfit when there are many predictors and
#    few cases?
# 2. What is the difference between ridge regression and the lasso?
# 3. What does the penalty lambda do, and how is its value chosen?
# 4. How does boosting differ from a random forest?
# 5. Why are a model's predictions pulled towards the average?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Predict semester 4 wellbeing from year-one information; compare the
# lasso and XGBoost with the baseline, and report the test RMSE.



# Task 2: Explain why the predictors your lasso kept are not a list of the
# causes of wellbeing.



# Task 3: Two sentences for student services on what your model's RMSE means
# for one student, in the units of the wellbeing scale.
