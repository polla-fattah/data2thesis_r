# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 13: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

library(tidymodels)
library(rpart)
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

# Exercise 1: MAE 0.22, RMSE 0.25; with one miss of 1.0, MAE 0.34 but RMSE
# 0.48: squaring gives the big miss far more weight
tiny <- tibble(actual    = c(3.2, 2.8, 3.6, 3.0, 2.5),
               predicted = c(3.0, 2.9, 3.3, 3.1, 2.9))
errors <- tiny$actual - tiny$predicted
c(mae = mean(abs(errors)), rmse = sqrt(mean(errors^2)))
tiny |> regression_metrics(truth = actual, estimate = predicted)

tiny$predicted[5] <- 3.5
tiny |> regression_metrics(truth = actual, estimate = predicted)


# Exercise 2: 60 students: ordinary 0.53, lasso 0.20; 150 students: ordinary
# 0.26, lasso 0.20. The gap shrinks from 0.32 to 0.07.
lm_wf    <- workflow(gpa_recipe, linear_reg())
lasso_wf <- workflow(gpa_recipe, linear_reg(penalty = 0.03, mixture = 1) |> set_engine("glmnet"))
for (n in c(60, 150)) {
  set.seed(3)
  small_train <- gpa_train |> slice_sample(n = n)
  print(c(students = n,
          ordinary = augment(fit(lm_wf, small_train), gpa_test) |> rmse(final_gpa, .pred) |> pull(.estimate),
          lasso    = augment(fit(lasso_wf, small_train), gpa_test) |> rmse(final_gpa, .pred) |> pull(.estimate)))
}


# Exercise 3: best ridge penalty about 0.055 (RMSE 0.213); ridge keeps all 51
# coefficients (none zero), the lasso sets 41 to zero
glmnet_wf <- workflow(gpa_recipe,
                      linear_reg(penalty = tune(), mixture = tune()) |> set_engine("glmnet"))
set.seed(2026)
glmnet_tuning <- tune_grid(glmnet_wf, resamples = gpa_folds,
                           grid = expand_grid(penalty = 10^seq(-4, 0, length.out = 20),
                                              mixture = c(0, 0.5, 1)),
                           metrics = metric_set(rmse))
best_ridge <- show_best(glmnet_tuning |> filter_parameters(parameters = tibble(mixture = 0)),
                        metric = "rmse", n = 1)
ridge_fit <- workflow(gpa_recipe,
                      linear_reg(penalty = best_ridge$penalty, mixture = 0) |> set_engine("glmnet")) |>
  fit(data = gpa_train)
lasso_fit <- glmnet_wf |> finalize_workflow(select_best(glmnet_tuning, metric = "rmse")) |>
  fit(data = gpa_train)
c(ridge_zero = sum(tidy(ridge_fit)$estimate == 0),
  lasso_zero = sum(tidy(lasso_fit)$estimate == 0))


# Exercise 4: lasso RMSE 0.203 with the four scale scores, 0.204 with the 22
# items: the scores lose nothing
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


# Exercise 5: RMSE 0.224 (100 trees), 0.223 (500), 0.223 (1,000): almost all
# the gain comes in the first 100 trees; none beats the lasso (0.204)
xgb_wf <- workflow(gpa_recipe,
                   boost_tree(trees = tune(), learn_rate = 0.03) |>
                     set_engine("xgboost") |> set_mode("regression"))
set.seed(2026)
xgb_tuning <- tune_grid(xgb_wf, resamples = gpa_folds,
                        grid = tibble(trees = c(100, 500, 1000)),
                        metrics = metric_set(rmse))
collect_metrics(xgb_tuning)


# Exercise 6 (model answer): "Predictions are typically about 0.2 grade points
# from the GPA a student achieves: a student predicted at 3.0 will usually end
# between about 2.8 and 3.2. The prediction starts a conversation; it is not a
# verdict."


# ==============================================================================
# B. GO FURTHER
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


# Exercise 7: coefficients shrink (0.120 and 0.154 with no penalty, 0.055 and
# 0.059 at 1,000) and become more equal: ridge shares the credit
X <- scale(as.matrix(train[, c("gpa_s1", "gpa_s2")]))
y <- train$final_gpa - mean(train$final_gpa)
cor(train$gpa_s1, train$gpa_s2)
for (lambda in c(0, 10, 100, 1000, 10000)) {
  b <- solve(t(X) %*% X + lambda * diag(ncol(X))) %*% t(X) %*% y
  print(round(c(lambda = lambda, gpa_s1 = b[1], gpa_s2 = b[2]), 4))
}


# Exercise 8: all predictors: 0.27 to 0.39 (SD 0.036); two GPAs: 0.197 to
# 0.205 (SD 0.003): the flexible model is worse and far more variable
results <- t(sapply(1:10, function(s) {
  set.seed(s)
  small <- train[sample(nrow(train), 60), ]
  c(all_predictors = rmse_of(test$final_gpa, predict(lm(final_gpa ~ ., data = small), test)),
    two_gpas       = rmse_of(test$final_gpa, predict(lm(final_gpa ~ gpa_s1 + gpa_s2, data = small), test)))
}))
round(results, 3)
round(apply(results, 2, sd), 3)


# Exercise 9: test RMSE lowest (0.205) after 16 trees, then levels off at 0.207
# while the training RMSE keeps falling (0.187 after 100)
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
  pred_test  <- pred_test  + learn_rate * predict(tree, test)
  train_rmse[i] <- rmse_of(train$final_gpa, pred_train)
  test_rmse[i]  <- rmse_of(test$final_gpa, pred_test)
}
plot(train_rmse, type = "l", ylim = range(c(train_rmse, test_rmse)),
     xlab = "Number of trees", ylab = "RMSE")
lines(test_rmse, lty = 2)
c(best_round = which.min(test_rmse), best_test_rmse = min(test_rmse))


# Exercise 10: straight line 4.3 cubic feet, log-log 2.6; volume grows with
# girth^2.0 and height^1.1, like a cylinder
cherry <- datasets::trees   # datasets:: avoids a clash with dials::trees()
loo_rmse <- function(formula, back = identity) {
  squared_errors <- sapply(1:nrow(cherry), function(i) {
    model <- lm(formula, data = cherry[-i, ])
    (cherry$Volume[i] - back(predict(model, cherry[i, ])))^2
  })
  sqrt(mean(squared_errors))
}
c(linear  = loo_rmse(Volume ~ Girth + Height),
  log_log = loo_rmse(log(Volume) ~ log(Girth) + log(Height), back = exp))
coef(lm(log(Volume) ~ log(Girth) + log(Height), data = cherry))


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. Each predictor adds a coefficient that can fit the sample; with many
#    coefficients and few cases, they fit noise, and correlated predictors make
#    the coefficients unstable.
# 2. Ridge shrinks every coefficient and keeps all predictors; the lasso also
#    sets some to exactly zero, selecting predictors.
# 3. It sets how much large coefficients cost (0 = ordinary regression; very
#    large = the mean for everyone). Chosen by cross-validation.
# 4. A forest averages many deep, independent trees (less variance); boosting
#    adds small trees in sequence, each fitted to the errors so far (less bias).
# 5. Part of every outcome is unpredictable luck; the model predicts only the
#    predictable part, so extremes are pulled towards the mean.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 13, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
