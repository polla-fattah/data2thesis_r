# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 13: Advanced Clustering
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

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
# Fit a mixture model with exactly 4 clusters and describe the profiles.
# Which of the three-cluster profiles has been split?
gmm4 <- Mclust(profile_data, G = ______)
profiles |>
  mutate(cluster = gmm4$classification) |>
  summarise(students = n(), across(sleep_hours:satisfaction, ~ round(mean(.x), 1)),
            .by = cluster)


# Exercise 2: Clear members
# How many students have a membership probability above 0.95? What share is that?
certainty <- apply(profile_gmm$z, 1, max)


# Exercise 3: DBSCAN with different eps values
# Try eps = 1.2, 1.6, 2, and 2.4 (minPts = 8). Count clusters and noise points.
for (e in c(1.2, 1.6, 2, 2.4)) {
  db <- dbscan(profile_data, eps = e, minPts = ______)
  cat("eps", e, ": clusters", max(db$cluster), ", noise", sum(db$cluster == 0), "\n")
}


# Exercise 4: Profiles without the unusual students
# Remove the DBSCAN noise students (eps = 2, minPts = 8), scale the data again,
# and fit the mixture model. Do the profiles change?


# Exercise 5: Mixture model versus hierarchical clustering
# Cut a Ward's-method tree into 3 clusters and compare it with the mixture model.
tree <- hclust(dist(profile_data), method = "ward.D2")
adjustedRandIndex(cutree(tree, k = 3), ______)


# Exercise 6: Profiles and final GPA
# Compare the three mixture-model profiles on GPA in semester 4.
final_gpa <- semesters |>
  filter(semester == 4) |>
  select(student_id, final_gpa = gpa)
