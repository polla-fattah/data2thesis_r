# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 12: Classification Models
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
library(themis)
library(rpart)
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

# The chapter's split, recipes, folds, and workflows
set.seed(2026)
dropout_split <- initial_split(dropout_data, prop = 0.75, strata = considering_dropout)
dropout_train <- training(dropout_split)
dropout_test  <- testing(dropout_split)
dropout_recipe <- recipe(considering_dropout ~ ., data = dropout_train) |>
  step_impute_median(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors())
tree_recipe <- recipe(considering_dropout ~ ., data = dropout_train) |>
  step_impute_median(all_numeric_predictors())
set.seed(2026)
dropout_folds <- vfold_cv(dropout_train, v = 10, strata = considering_dropout)
logistic_wf <- workflow() |> add_recipe(dropout_recipe) |> add_model(logistic_reg())

set.seed(2026)
logistic_cv <- fit_resamples(logistic_wf, resamples = dropout_folds,
                             control = control_resamples(save_pred = TRUE))
cv_predictions <- collect_predictions(logistic_cv)


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: A tree of depth 2
# Which predictors does it use? Explain it as you would to a counsellor.
tree2_wf <- workflow() |>
  add_recipe(tree_recipe) |>
  add_model(decision_tree(tree_depth = ______, min_n = 10) |> set_mode("classification"))
tree2_fit <- fit(tree2_wf, data = dropout_train)
tree2_engine <- extract_fit_engine(tree2_fit)
tree2_engine
plot(tree2_engine, uniform = TRUE, margin = 0.1)
text(tree2_engine, use.n = TRUE, cex = 0.8)


# Exercise 2: Tuning the forest's mtry over c(2, 5, 10) (needs ranger)
forest_wf <- workflow() |>
  add_recipe(tree_recipe) |>
  add_model(rand_forest(trees = 500, mtry = ______()) |>
              set_engine("ranger") |> set_mode("classification"))
set.seed(2026)
forest_tuning <- tune_grid(forest_wf, dropout_folds,
                           grid = tibble(mtry = c(2, 5, 10)),
                           metrics = metric_set(roc_auc))
collect_metrics(forest_tuning)


# Exercise 3: Very many neighbours (needs kknn)
knn_wf <- workflow() |>
  add_recipe(dropout_recipe) |>
  add_model(nearest_neighbor(neighbors = tune()) |> set_mode("classification"))
set.seed(2026)
knn_tuning <- tune_grid(knn_wf, dropout_folds,
                        grid = tibble(neighbors = c(41, 81, ______, 301)),
                        metrics = metric_set(roc_auc))
collect_metrics(knn_tuning)


# Exercise 4: The F1 score by hand (tiny example: 8 of 12 flagged are among
# the 10 at risk)
precision_tiny <- 8 / ______
recall_tiny    <- 8 / 10
f1 <- 2 * precision_tiny * recall_tiny / (______)
c(precision = precision_tiny, recall = recall_tiny, f1 = f1)


# Exercise 5: Contacting only 10% of students
threshold_table <- map(c(0.5, 0.4, 0.3, 0.2, 0.15, 0.1), \(t) {
  cv_predictions |>
    mutate(flag = factor(if_else(.pred_Yes >= t, "Yes", "No"), levels = c("Yes", "No"))) |>
    summarise(
      threshold   = t,
      flagged     = mean(flag == "Yes"),
      recall      = sensitivity_vec(considering_dropout, flag),
      precision   = ______(considering_dropout, flag),
      specificity = specificity_vec(considering_dropout, flag)
    )
}) |>
  list_rbind()
threshold_table


# Exercise 6: Downsampling instead of upsampling (needs themis)
downsample_recipe <- dropout_recipe |>
  ______(considering_dropout, under_ratio = 1)
downsample_wf <- workflow() |> add_recipe(downsample_recipe) |> add_model(logistic_reg())
set.seed(2026)
fit_resamples(downsample_wf, resamples = dropout_folds,
              metrics = metric_set(roc_auc, sensitivity, precision)) |>
  collect_metrics()


# Exercise 7: A cheaper missed student (cost 3 instead of 10)
cost_miss        <- ______
cost_false_alarm <- 1
cost_curve <- map(seq(0.02, 0.6, by = 0.02), \(t) {
  cv_predictions |>
    summarise(threshold    = t,
              misses       = sum(.pred_Yes < t & considering_dropout == "Yes"),
              false_alarms = sum(.pred_Yes >= t & considering_dropout == "No"),
              flagged      = mean(.pred_Yes >= t))
}) |>
  list_rbind() |>
  mutate(total_cost = cost_miss * misses + cost_false_alarm * false_alarms)
cost_curve |> slice_min(total_cost, n = 1, with_ties = FALSE)
cost_false_alarm / (cost_false_alarm + cost_miss)


# ==============================================================================
# B. GO FURTHER (base R, as on the playground page)
# ==============================================================================

ml_data <- students |>
  left_join(scores, join_by(student_id)) |>
  left_join(semesters |> filter(semester == 1) |> select(-semester), join_by(student_id)) |>
  mutate(dropout = as.integer(considering_dropout == "Yes")) |>
  select(-student_id, -supervisor_id, -workshop, -workshop_sessions, -considering_dropout) |>
  na.omit()

set.seed(2026)
folds <- sample(rep(1:10, length.out = nrow(ml_data)))
cv_pred <- data.frame(prob = NA_real_, truth = ml_data$dropout, faculty = ml_data$faculty)
for (f in 1:10) {
  fit <- suppressWarnings(glm(dropout ~ ., data = ml_data[folds != f, ], family = binomial))
  cv_pred$prob[folds == f] <- predict(fit, ml_data[folds == f, ], type = "response")
}


# Exercise 8: Confusion matrices by hand at thresholds 0.5, 0.35, and 0.12
prob  <- c(0.90, 0.80, 0.70, 0.60, 0.45, 0.40, 0.30, 0.20, 0.15, 0.10)
truth <- c(1,    1,    0,    1,    0,    1,    0,    0,    1,    0)
for (t in c(0.5, 0.35, 0.12)) {
  flag <- prob ______ t
  print(c(threshold = t,
          TP = sum(flag & truth == 1), FP = sum(flag & truth == 0),
          FN = sum(!flag & truth == 1), TN = sum(!flag & truth == 0),
          recall    = sum(flag & truth == 1) / sum(truth == 1),
          precision = sum(flag & truth == 1) / sum(flag)))
}


# Exercise 9: When a false alarm has a cost (a letter: cost 2; a miss: 10)
cost_miss        <- 10
cost_false_alarm <- 2
thresholds   <- seq(0.02, 0.6, by = 0.02)
misses       <- sapply(thresholds, function(t) sum(cv_pred$prob <  t & cv_pred$truth == 1))
false_alarms <- sapply(thresholds, function(t) sum(cv_pred$prob >= t & cv_pred$truth == 0))
total_cost   <- cost_miss * misses + ______ * false_alarms
thresholds[which.min(total_cost)]
cost_false_alarm / (cost_false_alarm + cost_miss)


# Exercise 10: Does it work for every faculty? (threshold 0.2)
cv_pred |>
  mutate(flag = prob >= 0.2) |>
  summarise(at_risk   = sum(truth == 1),
            found     = sum(flag & truth == 1),
            recall    = sum(flag & truth == 1) / sum(______),
            precision = sum(flag & truth == 1) / sum(flag),
            .by = faculty)


# Exercise 11: Classifying iris species with a tree and k-NN by hand
set.seed(5)
train_rows <- sample(150, 100)
x <- scale(iris[, 1:4])

knn_by_hand <- function(train_x, train_y, test_x, k) {
  apply(test_x, 1, function(row) {
    distances <- sqrt(colSums((t(train_x) - row)^2))
    nearest   <- train_y[order(distances)[1:______]]
    names(which.max(table(nearest)))
  })
}
knn_pred <- knn_by_hand(x[train_rows, ], iris$Species[train_rows], x[-train_rows, ], k = 5)
table(predicted = knn_pred, truth = iris$Species[-train_rows])

iris_tree <- rpart(Species ~ ., data = iris[train_rows, ], method = "class")
tree_pred <- predict(iris_tree, iris[-train_rows, ], type = "class")
table(predicted = tree_pred, truth = iris$Species[-train_rows])
iris_tree


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. What is the difference between precision and recall?
# 2. Why is choosing a classification threshold a value judgement and not only
#    a statistical decision?
# 3. What does a random forest average, and why does averaging help?
# 4. Why does k-nearest neighbours need the predictors to be normalised?
# 5. What does upsampling change, and what does it not change?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Invent a scenario for the dropout model (for example, a screening
# followed by a costly interview), justify the costs, choose a threshold from
# cross-validated predictions, and report recall, precision, and share flagged.



# Task 2: Compare three classifiers on a new outcome (such as lives_away) with
# a workflow set (workflowsets::workflow_set()), and argue for one, using the
# AUC and how easily each can be explained.



# Task 3: Write the paragraph reporting a classifier for a thesis: model,
# evaluation, AUC, threshold and its reasons, and recall and precision at it.
