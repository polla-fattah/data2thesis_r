# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 9: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

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

# Exercise 1: the first component captures 57%, the others 7% to 10% each:
# the items mostly measure one thing
support_items <- na.omit(items[, paste0("support_", 1:6)])
support_pca <- prcomp(support_items, scale. = TRUE)
summary(support_pca)


# Exercise 2: stress and burnout share the first factor; support and
# satisfaction keep one each. factanal() uses only the 396 complete cases.
fa3 <- factanal(na.omit(items), factors = 3, rotation = "promax")
print(fa3$loadings, cutoff = 0.3, sort = TRUE)

# The chapter's psych version, which uses every student:
if (requireNamespace("psych", quietly = TRUE)) {
  print(psych::fa(items, nfactors = 3, rotate = "oblimin", fm = "ml")$loadings,
        cutoff = 0.3, sort = TRUE)
}


# Exercise 3: alpha 0.57 without reversing, 0.83 with stress_4 reversed
cronbach <- function(x) {
  x <- na.omit(x)
  k <- ncol(x)
  k / (k - 1) * (1 - sum(apply(x, 2, var)) / var(rowSums(x)))
}

stress_items <- questionnaire[, paste0("stress_", 1:6)]
cronbach(stress_items)

stress_reversed <- stress_items |> mutate(stress_4 = 6 - stress_4)
cronbach(stress_reversed)

if (requireNamespace("psych", quietly = TRUE)) {
  psych::alpha(stress_reversed)$total$raw_alpha
}


# Exercise 4: balanced (about 208), disengaged (about 206), overloaded (about
# 185); the overloaded cluster merges the two overloaded clusters of the
# four-cluster solution (very high and moderate caffeine)
set.seed(123)
k3 <- kmeans(profile_data, centers = 3, nstart = 25)
profiles |>
  mutate(cluster = k3$cluster) |>
  summarise(students = n(), across(sleep_hours:satisfaction, ~ round(mean(.x), 1)),
            .by = cluster)

set.seed(123)
k4 <- kmeans(profile_data, centers = 4, nstart = 25)
table(three = k3$cluster, four = k4$cluster)


# Exercise 5 (model answer): "The elbow and silhouette criteria did not
# identify a clear number of clusters. We chose four, the number of profiles
# expected from previous research, because the clusters were interpretable and
# substantial; a three-cluster solution merged two overloaded profiles that
# differed mainly in caffeine. The clusters are reported as descriptive
# summaries, not natural groups."


# Exercise 6: one item correlates 0.41; 8 items are needed for 0.80
set.seed(42)
true_stress <- rnorm(600)
simulated_items <- sapply(1:20, function(i) true_stress + rnorm(600, sd = 2))

sapply(1:20, function(k) cor(rowMeans(simulated_items[, 1:k, drop = FALSE]), true_stress)) |>
  setNames(paste(1:20, "items")) |>
  round(2)


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: alpha rises from 0.86 to 0.92, but the correlation with the true
# stress level falls from 0.92 to 0.67: reliability is not validity
set.seed(42)
true_stress <- rnorm(600)
items_clean <- sapply(1:6, function(i) true_stress + rnorm(600))
mood <- rnorm(600)
items_mood <- items_clean + mood

round(c(alpha_clean = cronbach(as.data.frame(items_clean)),
        alpha_mood  = cronbach(as.data.frame(items_mood)),
        r_clean     = cor(rowMeans(items_clean), true_stress),
        r_mood      = cor(rowMeans(items_mood), true_stress)), 2)


# Exercise 8: the first component (56%) contrasts stress and burnout with
# support and satisfaction: a general dimension of how a student is doing
scale_scores <- na.omit(scores |> select(-student_id))
scores_pca <- prcomp(scale_scores, scale. = TRUE)
summary(scores_pca)
round(scores_pca$rotation, 2)


# Exercise 9: random data still gives four tidy clusters, capturing 26% of the
# variation; the real profiles give 47%
set.seed(1)
random_data <- scale(matrix(runif(nrow(profile_data) * ncol(profile_data)),
                            ncol = ncol(profile_data)))
k_random <- kmeans(random_data, centers = 4, nstart = 25)
set.seed(123)
k_real <- kmeans(profile_data, centers = 4, nstart = 25)

table(k_random$cluster)
c(random = k_random$betweenss / k_random$totss,
  real   = k_real$betweenss / k_real$totss)


# Exercise 10: unscaled, the first component is just Assault (97%); scaled, it
# is overall violent crime (62%), and the second is urban population (25%)
sapply(USArrests, var)
unscaled <- prcomp(USArrests)
round(unscaled$rotation[, 1:2], 2)
scaled <- prcomp(USArrests, scale. = TRUE)
round(scaled$rotation[, 1:2], 2)
summary(scaled)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. Each item is signal plus its own noise; averaging keeps the shared signal
#    and lets the separate noise cancel.
# 2. PCA summarises total variation with no theory; factor analysis models the
#    shared variation as caused by latent variables, separating item noise.
# 3. The item reflects two constructs; check its wording, and consider dropping
#    it or reporting results with and without it.
# 4. No: alpha shows the items agree (reliability), perhaps about the wrong
#    thing. Validity needs other evidence.
# 5. Clustering always returns the requested number of groups, even in random
#    data, and depends on many choices. Clusters are summaries, not types.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 9, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
