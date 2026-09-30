# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 9: Multivariate Statistical Methods
#
# Four parts, as on the playground page:
#   A. Practise the chapter       the book's exercises, with blanks (______) to fill
#   B. Go further                 new exercises beyond the book
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

library(dplyr)

semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")
items <- questionnaire |> select(-student_id)

scores <- questionnaire |>
  mutate(
    stress_4     = 6 - stress_4,
    stress       = rowMeans(pick(stress_1:stress_6), na.rm = TRUE),
    burnout      = rowMeans(pick(burnout_1:burnout_6), na.rm = TRUE),
    support      = rowMeans(pick(support_1:support_6), na.rm = TRUE),
    satisfaction = rowMeans(pick(satisfaction_1:satisfaction_4), na.rm = TRUE)
  ) |>
  select(student_id, stress, burnout, support, satisfaction)
profiles <- semesters |>
  summarise(across(c(sleep_hours, study_hours, caffeine_mg, exercise_days),
                   ~ mean(.x, na.rm = TRUE)), .by = student_id) |>
  left_join(scores |> select(-burnout), join_by(student_id)) |>
  na.omit()
profile_data <- scale(profiles |> select(-student_id))


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: PCA of the support items
# How much variation does the first component capture? What does that suggest?
support_items <- na.omit(items[, paste0("support_", 1:6)])
support_pca <- ______(support_items, scale. = TRUE)
summary(support_pca)


# Exercise 2: Three factors instead of four
# Which scales share a factor, and why?
fa3 <- factanal(na.omit(items), factors = ______, rotation = "promax")
print(fa3$loadings, cutoff = 0.3, sort = TRUE)


# Exercise 3: Cronbach's alpha without reversing stress_4
cronbach <- function(x) {
  x <- na.omit(x)
  k <- ncol(x)
  k / (k - 1) * (1 - sum(apply(x, 2, ______)) / var(rowSums(x)))
}

stress_items <- questionnaire[, paste0("stress_", 1:6)]
cronbach(stress_items)

stress_reversed <- stress_items |> mutate(stress_4 = ______ - stress_4)
cronbach(stress_reversed)


# Exercise 4: Three clusters
# Describe the clusters; which profiles of the 4-cluster solution merged?
set.seed(123)
k3 <- kmeans(profile_data, centers = ______, nstart = 25)
profiles |>
  mutate(cluster = k3$cluster) |>
  summarise(students = n(), across(sleep_hours:satisfaction, ~ round(mean(.x), 1)),
            .by = cluster)

set.seed(123)
k4 <- kmeans(profile_data, centers = 4, nstart = 25)
table(three = k3$cluster, four = k4$cluster)


# Exercise 5: Justifying the number of clusters
# Two or three sentences for a thesis methods section.


# Exercise 6: Noisier items
# With sd = 2, how many items are needed for a correlation of at least 0.8?
set.seed(42)
true_stress <- rnorm(600)
simulated_items <- sapply(1:20, function(i) true_stress + rnorm(600, sd = ______))

sapply(1:20, function(k) cor(rowMeans(simulated_items[, 1:k, drop = FALSE]), true_stress)) |>
  setNames(paste(1:20, "items")) |>
  round(2)


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: When alpha misleads
# Add the same "mood" noise to every item: compare alpha, and the correlation
# with the true stress level, with and without it.
set.seed(42)
true_stress <- rnorm(600)
items_clean <- sapply(1:6, function(i) true_stress + rnorm(600))
mood <- rnorm(600)
items_mood <- items_clean + ______

round(c(alpha_clean = cronbach(as.data.frame(items_clean)),
        alpha_mood  = cronbach(as.data.frame(items_mood)),
        r_clean     = cor(rowMeans(items_clean), true_stress),
        r_mood      = cor(rowMeans(items_mood), true_stress)), 2)


# Exercise 8: PCA of the four scale scores
scale_scores <- na.omit(scores |> select(-student_id))
scores_pca <- prcomp(scale_scores, scale. = ______)
summary(scores_pca)
round(scores_pca$rotation, 2)


# Exercise 9: Clusters in random data
set.seed(1)
random_data <- scale(matrix(runif(nrow(profile_data) * ncol(profile_data)),
                            ncol = ncol(profile_data)))
k_random <- kmeans(random_data, centers = 4, nstart = 25)
set.seed(123)
k_real <- kmeans(profile_data, centers = 4, nstart = 25)

table(k_random$cluster)
c(random = k_random$betweenss / k_random$______,
  real   = k_real$betweenss / k_real$totss)


# Exercise 10: Why PCA scales the variables (USArrests)
sapply(USArrests, var)
unscaled <- prcomp(USArrests)
round(unscaled$rotation[, 1:2], 2)
scaled <- prcomp(USArrests, scale. = ______)
round(scaled$rotation[, 1:2], 2)
summary(scaled)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Why does a questionnaire use several items for each construct?
# 2. What is the difference between PCA and factor analysis?
# 3. An item loads 0.45 on one factor and 0.40 on another. What does this
#    cross-loading mean?
# 4. A scale has a Cronbach's alpha of 0.93. Does that show that it is valid?
# 5. Why should clusters not be described as natural groups of people?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Check the burnout scale fully: item correlations, Cronbach's alpha,
# and alpha with each item dropped. Write the one-sentence report. (psych's
# alpha() gives all of this at once.)



# Task 2: Cluster the students on a different set of variables of your choice,
# choose the number of clusters, describe them, and argue whether they would be
# useful to a university.



# Task 3: Write the methods paragraph describing one scale: number of items, an
# example item, answer scale, scoring (with reversed items), and reliability,
# with the numbers calculated by code.



# Task 4: attitude: seven ratings of supervisors in 30 departments. Run a PCA,
# decide how many components to keep, and interpret them.
