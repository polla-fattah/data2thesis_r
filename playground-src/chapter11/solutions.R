# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 11: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

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
logistic_wf <- workflow() |> add_recipe(dropout_recipe) |> add_model(logistic_reg())
set.seed(2026)
dropout_folds <- vfold_cv(dropout_train, v = 10, strata = considering_dropout)


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: cross-validated AUC 0.80 with every predictor, 0.69 without the
# questionnaire: the questionnaire carries much of the signal
fit_resamples(logistic_wf, dropout_folds, metrics = metric_set(roc_auc)) |>
  collect_metrics()

train_no_q <- dropout_train |> select(-stress, -burnout, -support, -satisfaction)
no_q_recipe <- recipe(considering_dropout ~ ., data = train_no_q) |>
  step_impute_median(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())
set.seed(2026)
no_q_folds <- vfold_cv(train_no_q, v = 10, strata = considering_dropout)
workflow() |> add_recipe(no_q_recipe) |> add_model(logistic_reg()) |>
  fit_resamples(no_q_folds, metrics = metric_set(roc_auc)) |>
  collect_metrics()


# Exercise 2: test AUC 0.81 (80/20, seed 7) against 0.84 (75/25, seed 2026). A
# small test set, with few students at risk, makes a single test AUC noisy.
set.seed(7)
split_80 <- initial_split(dropout_data, prop = 0.8, strata = considering_dropout)
recipe_80 <- recipe(considering_dropout ~ ., data = training(split_80)) |>
  step_impute_median(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())
fit_80 <- workflow() |> add_recipe(recipe_80) |> add_model(logistic_reg()) |>
  fit(data = training(split_80))
augment(fit_80, new_data = testing(split_80)) |> roc_auc(considering_dropout, .pred_Yes)
augment(fit(logistic_wf, dropout_train), new_data = dropout_test) |>
  roc_auc(considering_dropout, .pred_Yes)


# Exercise 3: AUC 0.62, 0.67, 0.71, 0.73 for 5, 11, 21, 41 neighbours; 41 is
# best, but logistic regression (0.80) is better still
knn_wf <- workflow() |>
  add_recipe(dropout_recipe) |>
  add_model(nearest_neighbor(neighbors = tune()) |> set_mode("classification"))
set.seed(2026)
knn_tuning <- tune_grid(knn_wf, dropout_folds,
                        grid = tibble(neighbors = c(5, 11, 21, 41)),
                        metrics = metric_set(roc_auc))
collect_metrics(knn_tuning)


# Exercise 4: 25 columns either way: no zero-variance predictors here. Useful
# when a rare category gives an all-zero dummy in a small training set or fold,
# or when filtering makes a column constant.
dropout_recipe |> prep() |> bake(new_data = NULL) |> ncol()
dropout_recipe |> step_zv(all_predictors()) |> prep() |> bake(new_data = NULL) |> ncol()


# Exercise 5 (model answer): only about 15% consider dropping out, so predicting
# "No" for everyone is already 85% accurate and finds nobody at risk. What
# matters is how many at-risk students are found, and at what cost in false
# alarms: the AUC and sensitivity describe that.


# Exercise 6: with 15 points the new-data error is lowest at degree 3 and
# explodes at degree 12; with 50 points it is flat and low from degree 3 to 12
# (minimum at degree 5): more data lets flexibility follow the pattern
true_curve  <- function(x) sin(2 * x)
make_points <- function(n) {
  x <- runif(n, 0, 3)
  data.frame(x = x, y = true_curve(x) + rnorm(n, sd = 0.3))
}
rmse <- function(observed, predicted) sqrt(mean((observed - predicted)^2))

set.seed(3)
train_points <- make_points(50)
new_points   <- make_points(300)
new_points   <- new_points[new_points$x >= min(train_points$x) &
                             new_points$x <= max(train_points$x), ]
errors <- data.frame(degree = 1:12)
errors$training <- sapply(1:12, function(d)
  rmse(train_points$y, predict(lm(y ~ poly(x, d), data = train_points), train_points)))
errors$new_data <- sapply(1:12, function(d)
  rmse(new_points$y, predict(lm(y ~ poly(x, d), data = train_points), new_points)))
round(errors, 3)


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

ml_data <- students |>
  left_join(scores, join_by(student_id)) |>
  left_join(semesters |> filter(semester == 1) |> select(-semester), join_by(student_id)) |>
  mutate(dropout = as.integer(considering_dropout == "Yes")) |>
  select(-student_id, -supervisor_id, -workshop, -workshop_sessions, -considering_dropout) |>
  na.omit()

auc <- function(prob, truth) {
  r <- rank(prob); n1 <- sum(truth == 1); n0 <- sum(truth == 0)
  (sum(r[truth == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}


# Exercise 7: leaky 0.69, correct 0.50, from columns of pure noise
set.seed(1)
noise <- matrix(rnorm(nrow(ml_data) * 200), ncol = 200)
colnames(noise) <- paste0("noise_", 1:200)
y <- ml_data$dropout
train_rows <- sample(nrow(ml_data), round(0.75 * nrow(ml_data)))

test_auc_of <- function(columns) {
  d <- data.frame(y = y, noise[, columns])
  fit <- glm(y ~ ., data = d[train_rows, ], family = binomial)
  auc(predict(fit, d[-train_rows, ], type = "response"), y[-train_rows])
}

chosen_with_all_data <- order(-abs(cor(noise, y)))[1:5]
chosen_with_training <- order(-abs(cor(noise[train_rows, ], y[train_rows])))[1:5]
c(leaky = test_auc_of(chosen_with_all_data), correct = test_auc_of(chosen_with_training))


# Exercise 8: fold AUCs 0.82 to 0.86, mean 0.85
set.seed(2026)
folds <- sample(rep(1:5, length.out = nrow(ml_data)))
table(folds)

fold_auc <- sapply(1:5, function(k) {
  fit <- glm(dropout ~ stress + burnout + support + satisfaction + financial_worry,
             data = ml_data[folds != k, ], family = binomial)
  auc(predict(fit, ml_data[folds == k, ], type = "response"),
      ml_data$dropout[folds == k])
})
round(fold_auc, 3)
mean(fold_auc)


# Exercise 9: with sd = 0.6, the lowest new-data error is at degree 1
make_noisy <- function(n) {
  x <- runif(n, 0, 3)
  data.frame(x = x, y = true_curve(x) + rnorm(n, sd = 0.6))
}
set.seed(3)
train_points <- make_noisy(15)
new_points   <- make_noisy(300)
new_points   <- new_points[new_points$x >= min(train_points$x) &
                             new_points$x <= max(train_points$x), ]
new_error <- sapply(1:12, function(d)
  rmse(new_points$y, predict(lm(y ~ poly(x, d), data = train_points), new_points)))
round(new_error, 3)
which.min(new_error)


# Exercise 10: test AUC 0.75; accuracy 79% against 68% for "nobody survived";
# women had about 11 times the odds of surviving
titanic <- as.data.frame(Titanic)
titanic <- titanic[rep(seq_len(nrow(titanic)), titanic$Freq), c("Class", "Sex", "Age", "Survived")]
titanic$survived <- as.integer(titanic$Survived == "Yes")
nrow(titanic)

set.seed(4)
train_rows <- sample(nrow(titanic), round(0.75 * nrow(titanic)))
fit  <- glm(survived ~ Class + Sex + Age, data = titanic[train_rows, ], family = binomial)
prob <- predict(fit, titanic[-train_rows, ], type = "response")

auc(prob, titanic$survived[-train_rows])
mean((prob > 0.5) == titanic$survived[-train_rows])
mean(titanic$survived[-train_rows] == 0)
round(exp(coef(fit)), 2)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. Explanation asks why (coefficients and their uncertainty matter);
#    prediction asks how well a model forecasts new cases.
# 2. Each decision based on the test result makes it part of model building,
#    and its estimate becomes too optimistic.
# 3. How well a way of building a model will perform on new data, from the
#    training data alone; used to compare models and tune settings.
# 4. Learning the noise of the training data along with the pattern, so the
#    model does well on its own data and poorly on new data.
# 5. Letting test-set information, or information unavailable at prediction
#    time, into model building; it makes the model look better than it is.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 11, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
