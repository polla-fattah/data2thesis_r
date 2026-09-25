# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 12: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

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

# Exercise 1: support first (below 2.55), then burnout (3.63 or more): poorly
# supported, burnt-out students are the group to watch (70% consider dropout)
tree2_wf <- workflow() |>
  add_recipe(tree_recipe) |>
  add_model(decision_tree(tree_depth = 2, min_n = 10) |> set_mode("classification"))
tree2_fit <- fit(tree2_wf, data = dropout_train)
tree2_engine <- extract_fit_engine(tree2_fit)
tree2_engine
plot(tree2_engine, uniform = TRUE, margin = 0.1)
text(tree2_engine, use.n = TRUE, cex = 0.8)


# Exercise 2: AUC 0.783 (mtry 2), 0.780 (5), 0.775 (10); the default (4) gives
# 0.781: differences far smaller than the standard errors
forest_wf <- workflow() |>
  add_recipe(tree_recipe) |>
  add_model(rand_forest(trees = 500, mtry = tune()) |>
              set_engine("ranger") |> set_mode("classification"))
set.seed(2026)
forest_tuning <- tune_grid(forest_wf, dropout_folds,
                           grid = tibble(mtry = c(2, 5, 10)),
                           metrics = metric_set(roc_auc))
collect_metrics(forest_tuning)


# Exercise 3: AUC 0.73, 0.75, 0.77, 0.79 for 41, 81, 161, 301 neighbours. With
# equal votes from all training students, every prediction would be the same
# and the AUC 0.5; kknn's distance weighting delays this.
knn_wf <- workflow() |>
  add_recipe(dropout_recipe) |>
  add_model(nearest_neighbor(neighbors = tune()) |> set_mode("classification"))
set.seed(2026)
knn_tuning <- tune_grid(knn_wf, dropout_folds,
                        grid = tibble(neighbors = c(41, 81, 161, 301)),
                        metrics = metric_set(roc_auc))
collect_metrics(knn_tuning)


# Exercise 4: precision 0.67, recall 0.80, F1 0.73
precision_tiny <- 8 / 12
recall_tiny    <- 8 / 10
f1 <- 2 * precision_tiny * recall_tiny / (precision_tiny + recall_tiny)
c(precision = precision_tiny, recall = recall_tiny, f1 = f1)


# Exercise 5: 0.5 flags 8% (recall 31%, precision 57%), 0.4 flags 13%: from the
# table, 0.5 is the threshold that stays within the 10% limit
threshold_table <- map(c(0.5, 0.4, 0.3, 0.2, 0.15, 0.1), \(t) {
  cv_predictions |>
    mutate(flag = factor(if_else(.pred_Yes >= t, "Yes", "No"), levels = c("Yes", "No"))) |>
    summarise(
      threshold   = t,
      flagged     = mean(flag == "Yes"),
      recall      = sensitivity_vec(considering_dropout, flag),
      precision   = precision_vec(considering_dropout, flag),
      specificity = specificity_vec(considering_dropout, flag)
    )
}) |>
  list_rbind()
threshold_table


# Exercise 6: downsampling: sensitivity 0.75, AUC 0.79; upsampling: 0.67 and
# 0.79; neither improves the AUC (0.80 without resampling)
downsample_recipe <- dropout_recipe |>
  step_downsample(considering_dropout, under_ratio = 1)
downsample_wf <- workflow() |> add_recipe(downsample_recipe) |> add_model(logistic_reg())
set.seed(2026)
fit_resamples(downsample_wf, resamples = dropout_folds,
              metrics = metric_set(roc_auc, sensitivity, precision)) |>
  collect_metrics()


# Exercise 7: cheapest threshold 0.28, close to the decision-theory rule of 0.25
cost_miss        <- 3
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
# B. GO FURTHER
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


# Exercise 8: 0.5: recall 0.60, precision 0.75; 0.35: 0.80 and 0.67; 0.12:
# 1.00 and 0.56
prob  <- c(0.90, 0.80, 0.70, 0.60, 0.45, 0.40, 0.30, 0.20, 0.15, 0.10)
truth <- c(1,    1,    0,    1,    0,    1,    0,    0,    1,    0)
for (t in c(0.5, 0.35, 0.12)) {
  flag <- prob >= t
  print(c(threshold = t,
          TP = sum(flag & truth == 1), FP = sum(flag & truth == 0),
          FN = sum(!flag & truth == 1), TN = sum(!flag & truth == 0),
          recall    = sum(flag & truth == 1) / sum(truth == 1),
          precision = sum(flag & truth == 1) / sum(flag)))
}


# Exercise 9: cheapest threshold 0.14; decision-theory rule 2 / 12 = 0.17
cost_miss        <- 10
cost_false_alarm <- 2
thresholds   <- seq(0.02, 0.6, by = 0.02)
misses       <- sapply(thresholds, function(t) sum(cv_pred$prob <  t & cv_pred$truth == 1))
false_alarms <- sapply(thresholds, function(t) sum(cv_pred$prob >= t & cv_pred$truth == 0))
total_cost   <- cost_miss * misses + cost_false_alarm * false_alarms
thresholds[which.min(total_cost)]
cost_false_alarm / (cost_false_alarm + cost_miss)


# Exercise 10: recall from 0.50 (Social Sciences) to 0.83 (Humanities), on 9 to
# 28 students at risk per faculty: too few to judge, but the check is needed
cv_pred |>
  mutate(flag = prob >= 0.2) |>
  summarise(at_risk   = sum(truth == 1),
            found     = sum(flag & truth == 1),
            recall    = sum(flag & truth == 1) / sum(truth == 1),
            precision = sum(flag & truth == 1) / sum(flag),
            .by = faculty)


# Exercise 11: k-NN 46 of 50 correct, the tree 48 of 50; versicolor and
# virginica are the species that get confused
set.seed(5)
train_rows <- sample(150, 100)
x <- scale(iris[, 1:4])

knn_by_hand <- function(train_x, train_y, test_x, k) {
  apply(test_x, 1, function(row) {
    distances <- sqrt(colSums((t(train_x) - row)^2))
    nearest   <- train_y[order(distances)[1:k]]
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
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. Recall: the share of truly positive cases flagged. Precision: the share of
#    flagged cases that are truly positive.
# 2. It sets how many errors of each kind the decisions produce; what those
#    errors cost is a judgement about consequences for people.
# 3. The votes of many trees grown on bootstrap samples with random subsets of
#    predictors; their different errors partly cancel.
# 4. It uses distances, which predictors in large units would dominate.
# 5. It shifts the probabilities upwards (like a lower threshold); it rarely
#    improves the AUC, and the probabilities lose their meaning.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 12, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
