# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 13: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

library(dplyr)
library(mclust)
library(dbscan)
library(cluster)

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")

q <- questionnaire
q$stress_4 <- 6 - q$stress_4

scores <- q |>
  mutate(
    stress       = rowMeans(pick(stress_1:stress_6), na.rm = TRUE),
    support      = rowMeans(pick(support_1:support_6), na.rm = TRUE),
    satisfaction = rowMeans(pick(satisfaction_1:satisfaction_4), na.rm = TRUE)
  ) |>
  select(student_id, stress, support, satisfaction)

profiles <- semesters |>
  summarise(across(c(sleep_hours, study_hours, caffeine_mg, exercise_days),
                   ~ mean(.x, na.rm = TRUE)),
            .by = student_id) |>
  left_join(scores, join_by(student_id)) |>
  na.omit()

profile_data <- scale(profiles |> select(-student_id))

profile_gmm <- Mclust(profile_data, G = 1:8)
summary(profile_gmm)


# Exercise 1: Four profiles
gmm4 <- Mclust(profile_data, G = 4)
profiles |>
  mutate(cluster = gmm4$classification) |>
  summarise(students = n(), across(sleep_hours:satisfaction, ~ round(mean(.x), 1)),
            .by = cluster)
# The overloaded profile is split: a small group of 32 students with very high
# caffeine (about 560 mg a day) and the shortest sleep separates from the rest.
# It resembles the smaller, high-caffeine overloaded cluster that k-means found
# in Chapter 8, though it is smaller still.


# Exercise 2: Clear members
certainty <- apply(profile_gmm$z, 1, max)
sum(certainty > 0.95)
mean(certainty > 0.95)
# About 430 students, roughly 72% of the sample, belong to one profile with a
# probability above 0.95. The rest are, to some degree, mixtures.


# Exercise 3: DBSCAN with different eps values
for (e in c(1.2, 1.6, 2, 2.4)) {
  db <- dbscan(profile_data, eps = e, minPts = 8)
  cat("eps", e, ": clusters", max(db$cluster), ", noise", sum(db$cluster == 0), "\n")
}
# With eps = 1.2 the neighbourhoods are so small that most regions look sparse:
# 290 students are labelled noise and the cloud breaks into fragments. From 1.6
# upwards there is one cluster, and the noise shrinks to the most unusual students.


# Exercise 4: Profiles without the unusual students
db <- dbscan(profile_data, eps = 2, minPts = 8)
typical <- profiles |> filter(db$cluster != 0)
typical_gmm <- Mclust(scale(typical |> select(-student_id)), G = 1:8)
summary(typical_gmm)
typical |>
  mutate(cluster = typical_gmm$classification) |>
  summarise(students = n(), across(sleep_hours:satisfaction, ~ round(mean(.x), 1)),
            .by = cluster)
# BIC again chooses three profiles with the same descriptions (balanced,
# overloaded, disengaged); only the group sizes shift a little. The profiles are
# robust to leaving out the unusual students.


# Exercise 5: Mixture model versus hierarchical clustering
tree <- hclust(dist(profile_data), method = "ward.D2")
adjustedRandIndex(cutree(tree, k = 3), profile_gmm$classification)
# An ARI of about 0.63: substantial agreement between the two methods.


# Exercise 6: Profiles and final GPA
final_gpa <- semesters |>
  filter(semester == 4) |>
  select(student_id, final_gpa = gpa)
profiles |>
  mutate(cluster = profile_gmm$classification) |>
  left_join(final_gpa, join_by(student_id)) |>
  summarise(students = n(), final_gpa = round(mean(final_gpa, na.rm = TRUE), 2),
            .by = cluster)
# Balanced students have the highest final GPA (about 3.27), disengaged students
# the lowest (about 2.99), with overloaded students in between. Long study hours
# do not buy the best grades when sleep and wellbeing suffer.
