# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 8: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

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


# Exercise 1
support_items <- na.omit(items[, paste0("support_", 1:6)])
support_pca <- prcomp(support_items, scale. = TRUE)
summary(support_pca)

# Exercise 2
fa3 <- factanal(na.omit(items), factors = 3)
print(fa3$loadings, cutoff = 0.3, sort = TRUE)

# Exercise 3
other_stress <- rowMeans(questionnaire[, paste0("stress_", c(1, 2, 3, 5, 6))], na.rm = TRUE)
cor(questionnaire$stress_4, other_stress, use = "complete.obs")

# Exercise 4
set.seed(123)
k3 <- kmeans(profile_data, centers = 3, nstart = 25)
profiles |>
  mutate(cluster = k3$cluster) |>
  summarise(students = n(), across(sleep_hours:satisfaction, ~ round(mean(.x), 1)),
            .by = cluster)

# Exercise 5
set.seed(123)
k3 <- kmeans(profile_data, centers = 3, nstart = 25)
tree <- hclust(dist(profile_data), method = "ward.D2")
h3 <- cutree(tree, k = 3)
table(hierarchical = h3, kmeans = k3$cluster)

# Exercise 6
library(psych)
library(factoextra)
# (a) parallel analysis suggests 4 factors
set.seed(1)
fa.parallel(items, fa = "fa")$nfact
# (b) burnout_3 cross-loads on stress; stress_4 loads negatively
efa <- fa(items, nfactors = 4, rotate = "oblimin", fm = "ml")
print(efa$loadings, cutoff = 0.3, sort = TRUE)
# (c) about 0.57 without reversing, about 0.83 after
psych::alpha(questionnaire[, paste0("stress_", 1:6)], check.keys = FALSE)$total$raw_alpha
q <- questionnaire
q$stress_4 <- 6 - q$stress_4
psych::alpha(q[, paste0("stress_", 1:6)])$total$raw_alpha
# (d)
set.seed(123)
k4 <- kmeans(profile_data, centers = 4, nstart = 25)
fviz_cluster(k4, data = profile_data, geom = "point", ellipse.type = "convex")
