# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 8: Multivariate Statistical Methods
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

library(dplyr)
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")
items <- questionnaire |> select(-student_id)

scores <- questionnaire |>
  mutate(
    stress_4     = 6 - stress_4,
    stress       = rowMeans(pick(stress_1:stress_6), na.rm = TRUE),
    support      = rowMeans(pick(support_1:support_6), na.rm = TRUE),
    satisfaction = rowMeans(pick(satisfaction_1:satisfaction_4), na.rm = TRUE)
  ) |>
  select(student_id, stress, support, satisfaction)
profiles <- semesters |>
  summarise(across(c(sleep_hours, study_hours, caffeine_mg, exercise_days),
                   ~ mean(.x, na.rm = TRUE)), .by = student_id) |>
  left_join(scores, join_by(student_id)) |>
  na.omit()
profile_data <- scale(profiles |> select(-student_id))


# Exercise 1: PCA of one scale
# Run a PCA on the six support items. How much of their variation does the first component capture? What does that suggest?
support_items <- na.omit(items[, paste0("support_", 1:6)])
support_pca <- prcomp(support_items, scale. = ______)
summary(support_pca)

# Exercise 2: Three factors instead of four
# Run a factor analysis with three factors. Which two scales end up sharing a factor, and why might that be?
fa3 <- factanal(na.omit(items), factors = ______)
print(fa3$loadings, cutoff = 0.3, sort = TRUE)

# Exercise 3: A reversed item
# `stress_4` is worded the other way round from the other stress items. Correlate it with the average of the other five stress items. What sign do you expect?
other_stress <- rowMeans(questionnaire[, paste0("stress_", c(1, 2, 3, 5, 6))], na.rm = TRUE)
cor(questionnaire$______, other_stress, use = "complete.obs")

# Exercise 4: Three clusters
# Run k-means with three clusters on the profile data, then describe each cluster by its averages. Which of the four profiles from the chapter were merged?
set.seed(123)
k3 <- kmeans(profile_data, centers = ______, nstart = 25)
profiles |>
  mutate(cluster = k3$cluster) |>
  summarise(students = n(), across(sleep_hours:satisfaction, ~ round(mean(.x), 1)),
            .by = cluster)

# Exercise 5: Do two methods agree?
# Cut a hierarchical clustering tree (Ward's method) into three groups and compare it with your k-means clusters.
set.seed(123)
k3 <- kmeans(profile_data, centers = 3, nstart = 25)
tree <- hclust(dist(profile_data), method = "______")
h3 <- cutree(tree, k = 3)
table(hierarchical = h3, kmeans = k3$cluster)

# Exercise 6: With the psych and factoextra packages (from the chapter)
# (a) Run parallel analysis on the items with psych::fa.parallel(). How many
#     factors does it suggest?
# (b) Run psych::fa() with 4 factors, oblimin rotation, and fm = "ml".
#     Which item cross-loads? Which loads negatively?
# (c) Calculate Cronbach's alpha for the stress scale with psych::alpha() (write it in full: ggplot2 also has an alpha() function),
#     first WITHOUT reversing stress_4, then after reversing it. Compare.
# (d) Draw the k-means clusters (k = 4) with factoextra::fviz_cluster().
library(psych)
library(factoextra)

