# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 15: Neural Networks
#
# Four parts, as on the playground page:
#   A. Practise the chapter       the book's exercises, with tidymodels
#   B. Go further                 new exercises beyond the book, with base R
#                                 and nnet
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

library(tidymodels)
library(nnet)
tidymodels_prefer()

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")

sigmoid <- function(z) 1 / (1 + exp(-z))

# The chapter's data, split, recipe, and folds
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

# Exercise 1: A neuron with new weights (support twice as important)
neuron <- function(stress, support) {
  sigmoid(-4 + 1.2 * stress + ______ * support)
}
neuron(stress = 4, support = 2)
neuron(stress = 2, support = 4)


# Exercise 2: One hidden neuron, weight decay 1, against logistic regression
one_neuron <- mlp(hidden_units = ______, penalty = 1, epochs = 500) |>
  set_engine("nnet", MaxNWts = 5000) |>
  set_mode("classification")
set.seed(2026)
fit_resamples(workflow(dropout_recipe, one_neuron), dropout_folds,
              metrics = metric_set(roc_auc)) |> collect_metrics()
set.seed(2026)
fit_resamples(workflow(dropout_recipe, logistic_reg()), dropout_folds,
              metrics = metric_set(roc_auc)) |> collect_metrics()


# Exercise 3: When the seed matters
# The chapter's tuned network (10 hidden units, penalty 3.16), three seeds, then
# the same with a penalty of 0.01.
for (penalty in c(3.16, 0.01)) {
  test_auc <- sapply(1:3, function(seed) {
    set.seed(______)
    net <- mlp(hidden_units = 10, penalty = penalty, epochs = 500) |>
      set_engine("nnet", MaxNWts = 5000) |> set_mode("classification")
    fitted <- fit(workflow(dropout_recipe, net), data = dropout_train)
    augment(fitted, new_data = dropout_test) |>
      roc_auc(considering_dropout, .pred_Yes) |> pull(.estimate)
  })
  print(round(c(penalty = penalty, test_auc), 3))
}


# Exercise 4: Epochs (20 neurons, no weight decay)
for (epochs in c(10, 100, 1000)) {
  set.seed(2026)
  net <- mlp(hidden_units = 20, penalty = 0, epochs = ______) |>
    set_engine("nnet", MaxNWts = 5000) |> set_mode("classification")
  fitted <- fit(workflow(dropout_recipe, net), data = dropout_train)
  print(round(c(epochs = epochs,
                train = augment(fitted, new_data = dropout_train) |>
                  roc_auc(considering_dropout, .pred_Yes) |> pull(.estimate),
                test  = augment(fitted, new_data = dropout_test) |>
                  roc_auc(considering_dropout, .pred_Yes) |> pull(.estimate)), 3))
}


# Exercise 5: Explaining the choice to the research group
# Two or three sentences on why the thesis does not use a neural network.


# Exercise 6: The learning rate (0.1, 10, and 100)
six <- data.frame(stress  = c(2.0, 2.5, 3.0, 3.5, 4.0, 4.5) - 3.25,
                  dropout = c(0,   0,   1,   0,   1,   1))
log_loss <- function(b0, b1) {
  p <- sigmoid(b0 + b1 * six$stress)
  -mean(six$dropout * log(p) + (1 - six$dropout) * log(1 - p))
}
par(mfrow = c(1, 3))
for (learning_rate in c(0.1, ______, 100)) {
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
# B. GO FURTHER (base R and nnet, as on the playground page)
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


# Exercise 7: Gradient descent with two predictors, against glm()
X <- cbind(1, train$stress, train$support)
y <- train$dropout
b <- c(0, 0, 0)
for (step in 1:2000) {
  p <- sigmoid(X %*% b)
  b <- b - 1 * t(X) %*% (p - ______) / nrow(X)
}
rbind(gradient_descent = as.vector(b),
      glm = coef(glm(dropout ~ stress + support, data = train, family = binomial)))


# Exercise 8: A hidden layer by hand
students_3 <- data.frame(stress = c(4, 2, 3.5), support = c(2, 4, 1.5))
h1 <- sigmoid(-3 + 1.5 * students_3$stress - 0.5 * students_3$support)
h2 <- sigmoid( 2 - 0.2 * students_3$stress - 1.0 * students_3$support)
output <- ______(-2 + 3 * h1 + 2 * h2)
round(cbind(students_3, h1, h2, output), 3)


# Exercise 9: Weight decay with a small sample (60 students)
set.seed(7)
small <- train[sample(nrow(train), 60), ]
for (decay in c(0, 0.1, 1, 10)) {
  test_auc <- sapply(1:3, function(seed) {
    set.seed(seed)
    net <- nnet(dropout ~ ., data = small, size = 5, decay = ______,
                maxit = 1000, entropy = TRUE, trace = FALSE)
    round(auc(predict(net, test), test$dropout), 3)
  })
  print(c(decay = decay, test_auc))
}
auc(predict(glm(dropout ~ ., data = small, family = binomial), test, type = "response"),
    test$dropout)


# Exercise 10: A network for timber volume (trees)
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
                linout = ______, maxit = 2000, trace = FALSE)
    predict(net, new_data)
  }))


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Why is a single neuron with a sigmoid activation the same as a logistic
#    regression?
# 2. What does the learning rate control?
# 3. What does weight decay prevent?
# 4. Why must the seed be set, and reported, when training a neural network?
# 5. When are neural networks worth using?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Tune a network for a different outcome with tidymodels (hidden units
# and penalty by cross-validation), compare it fairly with a regression model
# on the same folds, and decide which to use.



# Task 2: Explain to a non-specialist, as comments above your own
# gradient-descent loop, what training a network means.



# Task 3: Is a neural network worth trying? (a) diagnosing skin lesions from
# 20,000 labelled photographs; (b) predicting which of 300 respondents change
# jobs from 12 questionnaire scores; (c) next week's hospital admissions from
# ten years of daily records.
