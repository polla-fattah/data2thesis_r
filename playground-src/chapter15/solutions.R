# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 15: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

library(tidymodels)
library(nnet)
tidymodels_prefer()

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")

sigmoid <- function(z) 1 / (1 + exp(-z))

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


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: outputs 0.08 and 0.0003 (from 0.31 and 0.008): a negative weight
# lowers the output
neuron <- function(stress, support) {
  sigmoid(-4 + 1.2 * stress - 1.6 * support)
}
neuron(stress = 4, support = 2)
neuron(stress = 2, support = 4)


# Exercise 2: cross-validated AUC 0.79 for one hidden neuron, 0.80 for logistic
# regression: one neuron ranks students by one combination of the predictors
one_neuron <- mlp(hidden_units = 1, penalty = 1, epochs = 500) |>
  set_engine("nnet", MaxNWts = 5000) |>
  set_mode("classification")
set.seed(2026)
fit_resamples(workflow(dropout_recipe, one_neuron), dropout_folds,
              metrics = metric_set(roc_auc)) |> collect_metrics()
set.seed(2026)
fit_resamples(workflow(dropout_recipe, logistic_reg()), dropout_folds,
              metrics = metric_set(roc_auc)) |> collect_metrics()


# Exercise 3: with penalty 3.16, all three seeds give a test AUC of 0.853; with
# 0.01, 0.75 to 0.79: the seed matters when the network is under-regularised
for (penalty in c(3.16, 0.01)) {
  test_auc <- sapply(1:3, function(seed) {
    set.seed(seed)
    net <- mlp(hidden_units = 10, penalty = penalty, epochs = 500) |>
      set_engine("nnet", MaxNWts = 5000) |> set_mode("classification")
    fitted <- fit(workflow(dropout_recipe, net), data = dropout_train)
    augment(fitted, new_data = dropout_test) |>
      roc_auc(considering_dropout, .pred_Yes) |> pull(.estimate)
  })
  print(round(c(penalty = penalty, test_auc), 3))
}


# Exercise 4: 10 epochs: train 0.95, test 0.72; 100 and 1,000: train 1.00, test
# 0.64: the network first learns the pattern, then memorises the noise
for (epochs in c(10, 100, 1000)) {
  set.seed(2026)
  net <- mlp(hidden_units = 20, penalty = 0, epochs = epochs) |>
    set_engine("nnet", MaxNWts = 5000) |> set_mode("classification")
  fitted <- fit(workflow(dropout_recipe, net), data = dropout_train)
  print(round(c(epochs = epochs,
                train = augment(fitted, new_data = dropout_train) |>
                  roc_auc(considering_dropout, .pred_Yes) |> pull(.estimate),
                test  = augment(fitted, new_data = dropout_test) |>
                  roc_auc(considering_dropout, .pred_Yes) |> pull(.estimate)), 3))
}


# Exercise 5 (model answer): "A tuned neural network predicted dropout no
# better than logistic regression (both a cross-validated AUC of about 0.80).
# Its weights cannot be interpreted, while logistic regression gives odds
# ratios, so we kept logistic regression and report the network as tried."


# Exercise 6: 0.1 is slow (loss 0.44 after 100 steps); 10 overshoots at first
# but settles quickly on this tiny problem; 100 overshoots wildly and the loss
# becomes NaN
six <- data.frame(stress  = c(2.0, 2.5, 3.0, 3.5, 4.0, 4.5) - 3.25,
                  dropout = c(0,   0,   1,   0,   1,   1))
log_loss <- function(b0, b1) {
  p <- sigmoid(b0 + b1 * six$stress)
  -mean(six$dropout * log(p) + (1 - six$dropout) * log(1 - p))
}
par(mfrow = c(1, 3))
for (learning_rate in c(0.1, 10, 100)) {
  b0 <- 0
  b1 <- 0
  loss_history <- numeric(200)
  for (step in 1:200) {
    p  <- sigmoid(b0 + b1 * six$stress)
    b0 <- b0 - learning_rate * mean(p - six$dropout)
    b1 <- b1 - learning_rate * mean((p - six$dropout) * six$stress)
    loss_history[step] <- log_loss(b0, b1)
  }
  plot(loss_history, type = "l", main = paste("Learning rate", learning_rate),
       xlab = "Step", ylab = "Log loss")
  print(c(learning_rate = learning_rate, b1 = b1, final_loss = loss_history[200]))
}
par(mfrow = c(1, 1))


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

auc <- function(prob, truth) {
  r <- rank(prob); n1 <- sum(truth == 1); n0 <- sum(truth == 0)
  (sum(r[truth == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}
nn_data <- students |>
  left_join(scores, join_by(student_id)) |>
  left_join(semesters |> filter(semester == 1), join_by(student_id)) |>
  mutate(dropout = as.integer(considering_dropout == "Yes")) |>
  select(dropout, stress, burnout, support, financial_worry, sleep_hours,
         study_hours, caffeine_mg, wellbeing, gpa) |>
  na.omit()
set.seed(10)
train_rows <- sample(nrow(nn_data), round(0.75 * nrow(nn_data)))
train <- nn_data[train_rows, ]
test  <- nn_data[-train_rows, ]
predictors <- setdiff(names(train), "dropout")
centres <- sapply(train[predictors], mean)
spreads <- sapply(train[predictors], sd)
train[predictors] <- scale(train[predictors], centres, spreads)
test[predictors]  <- scale(test[predictors], centres, spreads)


# Exercise 7: -2.246, 0.915, -0.649, identical to glm()
X <- cbind(1, train$stress, train$support)
y <- train$dropout
b <- c(0, 0, 0)
for (step in 1:2000) {
  p <- sigmoid(X %*% b)
  b <- b - 1 * t(X) %*% (p - y) / nrow(X)
}
rbind(gradient_descent = as.vector(b),
      glm = coef(glm(dropout ~ stress + support, data = train, family = binomial)))


# Exercise 8: outputs 0.78, 0.19, and 0.80; h1 responds to high stress, h2 to
# low support
students_3 <- data.frame(stress = c(4, 2, 3.5), support = c(2, 4, 1.5))
h1 <- sigmoid(-3 + 1.5 * students_3$stress - 0.5 * students_3$support)
h2 <- sigmoid( 2 - 0.2 * students_3$stress - 1.0 * students_3$support)
output <- sigmoid(-2 + 3 * h1 + 2 * h2)
round(cbind(students_3, h1, h2, output), 3)


# Exercise 9: decay 0: 0.76 to 0.81 by seed; 0.1: 0.81 to 0.85; 1: 0.889 for
# every seed; 10: 0.85. Logistic regression on the same 60 students: 0.85.
set.seed(7)
small <- train[sample(nrow(train), 60), ]
for (decay in c(0, 0.1, 1, 10)) {
  test_auc <- sapply(1:3, function(seed) {
    set.seed(seed)
    net <- nnet(dropout ~ ., data = small, size = 5, decay = decay,
                maxit = 1000, entropy = TRUE, trace = FALSE)
    round(auc(predict(net, test), test$dropout), 3)
  })
  print(c(decay = decay, test_auc))
}
auc(predict(glm(dropout ~ ., data = small, family = binomial), test, type = "response"),
    test$dropout)


# Exercise 10: linear model 4.3 cubic feet, network 5.5: 31 trees are too few
# for 13 weights
cherry <- datasets::trees   # datasets:: avoids a clash with dials::trees()
cherry_scaled <- data.frame(scale(cherry[, c("Girth", "Height")]), Volume = cherry$Volume)
loo_rmse <- function(fit_and_predict) {
  errors <- sapply(1:nrow(cherry_scaled), function(i) {
    cherry_scaled$Volume[i] - fit_and_predict(cherry_scaled[-i, ], cherry_scaled[i, ])
  })
  sqrt(mean(errors^2))
}
c(linear = loo_rmse(function(fit_data, new_data)
                      predict(lm(Volume ~ Girth + Height, data = fit_data), new_data)),
  network = loo_rmse(function(fit_data, new_data) {
    set.seed(1)
    net <- nnet(Volume ~ Girth + Height, data = fit_data, size = 3, decay = 0.1,
                linout = TRUE, maxit = 2000, trace = FALSE)
    predict(net, new_data)
  }))


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. It computes a weighted sum plus a constant, passed through the sigmoid: the
#    bias is the intercept and the weights the coefficients.
# 2. How far the weights move at each step; too small is slow, too large
#    overshoots and can diverge.
# 3. Overfitting: a penalty on large weights keeps the network smooth and makes
#    different starts end at similar solutions.
# 4. Training starts from random weights, so results can depend on the start;
#    setting and reporting the seed makes them reproducible.
# 5. With much data and complex, interacting inputs (images, sound, text);
#    rarely for small tabular data with smooth relationships.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 15, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
