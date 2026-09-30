# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 11: Introduction to Machine Learning in R
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

# The chapter's split, recipe, workflow, and folds
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

# Exercise 1: The model without the questionnaire
# How much does the cross-validated AUC fall?
fit_resamples(logistic_wf, dropout_folds, metrics = metric_set(roc_auc)) |>
  collect_metrics()

train_no_q <- dropout_train |> select(-stress, -burnout, -support, -satisfaction)
no_q_recipe <- recipe(considering_dropout ~ ______, data = train_no_q) |>
  step_impute_median(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())
set.seed(2026)
no_q_folds <- vfold_cv(train_no_q, v = 10, strata = considering_dropout)
workflow() |> add_recipe(no_q_recipe) |> add_model(logistic_reg()) |>
  fit_resamples(no_q_folds, metrics = metric_set(roc_auc)) |>
  collect_metrics()


# Exercise 2: A different split (80/20, seed 7)
set.seed(7)
split_80 <- initial_split(dropout_data, prop = ______, strata = considering_dropout)
recipe_80 <- recipe(considering_dropout ~ ., data = training(split_80)) |>
  step_impute_median(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())
fit_80 <- workflow() |> add_recipe(recipe_80) |> add_model(logistic_reg()) |>
  fit(data = training(split_80))
augment(fit_80, new_data = testing(split_80)) |> roc_auc(considering_dropout, .pred_Yes)
augment(fit(logistic_wf, dropout_train), new_data = dropout_test) |>
  roc_auc(considering_dropout, .pred_Yes)


# Exercise 3: Tuning k-nearest neighbours (needs the kknn package)
knn_wf <- workflow() |>
  add_recipe(dropout_recipe) |>
  add_model(nearest_neighbor(neighbors = ______()) |> set_mode("classification"))
set.seed(2026)
knn_tuning <- tune_grid(knn_wf, dropout_folds,
                        grid = tibble(neighbors = c(5, 11, 21, 41)),
                        metrics = metric_set(roc_auc))
collect_metrics(knn_tuning)


# Exercise 4: Zero-variance predictors
# Add step_zv(all_predictors()) and compare the number of prepared columns.
# When is this step useful?
dropout_recipe |> prep() |> bake(new_data = NULL) |> ncol()
dropout_recipe |> ______(all_predictors()) |> prep() |> bake(new_data = NULL) |> ncol()


# Exercise 5: Explaining accuracy to an administrator
# Why might a model with 85% accuracy be useless for finding students at risk?


# Exercise 6: More training points (50 instead of 15)
true_curve  <- function(x) sin(2 * x)
make_points <- function(n) {
  x <- runif(n, 0, 3)
  data.frame(x = x, y = true_curve(x) + rnorm(n, sd = 0.3))
}
rmse <- function(observed, predicted) sqrt(mean((observed - predicted)^2))

set.seed(3)
train_points <- make_points(______)
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
# B. GO FURTHER (base R, as on the playground page)
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


# Exercise 7: Data leakage
# Choose 5 of 200 noise columns with all the data, and with training data only.
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
chosen_with_training <- order(-abs(cor(noise[______, ], y[______])))[1:5]
c(leaky = test_auc_of(chosen_with_all_data), correct = test_auc_of(chosen_with_training))


# Exercise 8: Cross-validation by hand (five folds, glm only)
set.seed(2026)
folds <- sample(rep(1:5, length.out = nrow(ml_data)))
table(folds)

fold_auc <- sapply(1:5, function(k) {
  fit <- glm(dropout ~ stress + burnout + support + satisfaction + financial_worry,
             data = ml_data[folds ______ k, ], family = binomial)
  auc(predict(fit, ml_data[folds ______ k, ], type = "response"),
      ml_data$dropout[folds == k])
})
round(fold_auc, 3)
mean(fold_auc)


# Exercise 9: Noisier data, simpler model (sd = 0.6, 15 points)
make_noisy <- function(n) {
  x <- runif(n, 0, 3)
  data.frame(x = x, y = true_curve(x) + rnorm(n, sd = ______))
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


# Exercise 10: Who survived the Titanic?
titanic <- as.data.frame(Titanic)
titanic <- titanic[rep(seq_len(nrow(titanic)), titanic$Freq), c("Class", "Sex", "Age", "Survived")]
titanic$survived <- as.integer(titanic$Survived == "Yes")
nrow(titanic)

set.seed(4)
train_rows <- sample(nrow(titanic), round(0.75 * nrow(titanic)))
fit  <- glm(survived ~ Class + Sex + Age, data = titanic[train_rows, ], family = binomial)
prob <- predict(fit, titanic[-train_rows, ], type = ______)

auc(prob, titanic$survived[-train_rows])
mean((prob > 0.5) == titanic$survived[-train_rows])
mean(titanic$survived[-train_rows] == 0)
round(exp(coef(fit)), 2)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. What is the difference between a model built for prediction and one built
#    for explanation?
# 2. Why is the test set used only once?
# 3. What does cross-validation estimate?
# 4. What is overfitting, in one sentence?
# 5. What is data leakage?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: A predictive model for another yes-or-no outcome, such as lives_away,
# with tidymodels: split, recipe, compare two sets of predictors by
# cross-validation, and report the test AUC alongside the accuracy of always
# predicting the more common answer.



# Task 2: Using the numbers from Task 1, explain why accuracy would, or would
# not, be misleading for your outcome.



# Task 3: Write the prediction section of a methods chapter for your model:
# data, outcome and predictors, split, model comparison, and final test.
