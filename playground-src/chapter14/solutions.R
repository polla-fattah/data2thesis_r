# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 14: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

library(dplyr)
library(mclust)
library(dbscan)

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
                   ~ mean(.x, na.rm = TRUE)), .by = student_id) |>
  left_join(scores, join_by(student_id)) |>
  na.omit()
profile_data <- scale(profiles |> select(-student_id))

set.seed(123)
profile_gmm <- Mclust(profile_data, G = 1:8, verbose = FALSE)
set.seed(123)
kmeans_clusters <- kmeans(profile_data, centers = 4, nstart = 25)


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: disengaged (201), balanced (200), overloaded (166), and a small
# extreme group (32: 43 study hours, 4.9 hours of sleep, over 560 mg caffeine)
# split off the overloaded profile; agreement with k-means 0.73
set.seed(123)
gmm4 <- Mclust(profile_data, G = 4, verbose = FALSE)
profiles |>
  mutate(cluster = gmm4$classification) |>
  summarise(students = n(), across(sleep_hours:satisfaction, ~ round(mean(.x), 1)),
            .by = cluster)
table(three = profile_gmm$classification, four = gmm4$classification)
adjustedRandIndex(gmm4$classification, kmeans_clusters$cluster)


# Exercise 2: 432 of 599 students (72%) are clear members
certainty <- apply(profile_gmm$z, 1, max)
sum(certainty > 0.95)
mean(certainty > 0.95)


# Exercise 3: eps 1.2: 4 clusters, 290 noise; 1.6: 1 cluster, 49 noise;
# 2: 1 and 13; 2.4: 1 and 9
for (eps in c(1.2, 1.6, 2, 2.4)) {
  clusters <- dbscan(profile_data, eps = eps, minPts = 8)$cluster
  print(c(eps = eps, clusters = max(clusters), noise = sum(clusters == 0)))
}


# Exercise 4: without the 13 noise students, the profiles hardly change
# (agreement 0.85); the overloaded profile's caffeine falls from 284 to 268 mg
keep <- dbscan(profile_data, eps = 2, minPts = 8)$cluster != 0
gmm_kept <- Mclust(profile_data[keep, ], G = 3, verbose = FALSE)
profiles[keep, ] |>
  mutate(cluster = gmm_kept$classification) |>
  summarise(students = n(), across(sleep_hours:satisfaction, ~ round(mean(.x), 1)),
            .by = cluster)
adjustedRandIndex(profile_gmm$classification[keep], gmm_kept$classification)


# Exercise 5: adjusted Rand index 0.63; most disagreements are students the
# mixture model calls disengaged and Ward's method places with the balanced
hierarchical <- cutree(hclust(dist(profile_data), method = "ward.D2"), k = 3)
adjustedRandIndex(profile_gmm$classification, hierarchical)
table(profile_gmm$classification, hierarchical)


# Exercise 6: final GPA 3.27 (balanced), 3.07 (overloaded), 2.99 (disengaged):
# the overloaded study most but finish below the balanced
final_gpa <- semesters |>
  filter(semester == 4) |>
  select(student_id, final_gpa = gpa)
profiles |>
  mutate(profile = profile_gmm$classification) |>
  left_join(final_gpa, join_by(student_id)) |>
  summarise(students  = n(),
            final_gpa = round(mean(final_gpa, na.rm = TRUE), 2),
            study     = round(mean(study_hours), 1),
            stress    = round(mean(stress), 1),
            .by = profile)


# Exercise 7: without a gap: k-means 0.53, mixture 0.98, DBSCAN 0.00 (one
# region); with a gap: k-means 0.79, mixture 1.00, DBSCAN 0.98 (two clusters)
for (long_y in c(1.4, 3)) {
  set.seed(8)
  shapes <- data.frame(
    x = c(rnorm(100, 0, 0.4), rnorm(100, 3, 2), runif(15, -2, 7)),
    y = c(rnorm(100, 0, 0.4), rnorm(100, long_y, 0.2), runif(15, -2, 4)),
    truth = rep(c("Round group", "Long group", "Scattered"), c(100, 100, 15))
  )
  xy   <- shapes[, c("x", "y")]
  real <- shapes$truth != "Scattered"
  km <- kmeans(xy, 2, nstart = 25)$cluster
  gm <- Mclust(xy, G = 2, verbose = FALSE)$classification
  db <- dbscan(xy, eps = 0.5, minPts = 5)$cluster
  print(round(c(long_group_y = long_y,
                kmeans  = adjustedRandIndex(shapes$truth[real], km[real]),
                mixture = adjustedRandIndex(shapes$truth[real], gm[real]),
                dbscan  = adjustedRandIndex(shapes$truth[real], db[real]),
                dbscan_clusters = max(db)), 2))
}


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 8: 1.000, 0.423, 0.000: a 67-minute wait is slightly more likely to
# be long, because long waits are nearly twice as common
wait  <- c(50, 67, 85)
short <- 0.36 * dnorm(wait, mean = 54.6, sd = 5.9)
long  <- 0.64 * dnorm(wait, mean = 80.1, sd = 5.9)
round(short / (short + long), 3)


# Exercise 9: k-means 0.38 (splits the large group); DBSCAN at best 0.66 (one
# density threshold cannot suit groups of different densities); mixture 0.94
set.seed(4)
groups <- data.frame(
  x = c(rnorm(300, 0, 1.2), rnorm(30, 3, 0.3), rnorm(60, 0, 0.5)),
  y = c(rnorm(300, 0, 1.2), rnorm(30, 0, 0.3), rnorm(60, 4.5, 0.5)),
  truth = rep(c("large", "small", "medium"), c(300, 30, 60))
)
km <- kmeans(groups[, c("x", "y")], centers = 3, nstart = 25)$cluster
table(truth = groups$truth, kmeans = km)
adjustedRandIndex(groups$truth, km)
for (eps in c(0.3, 0.4, 0.5, 0.6)) {
  db <- dbscan(groups[, c("x", "y")], eps = eps, minPts = 5)$cluster
  print(round(c(eps = eps, clusters = max(db), noise = sum(db == 0),
                ari = adjustedRandIndex(groups$truth, db)), 2))
}
adjustedRandIndex(groups$truth,
                  Mclust(groups[, c("x", "y")], G = 3, verbose = FALSE)$classification)


# Exercise 10: eps 0.2 and 0.3 find the two kinds of eruption (waits of about
# 54 and 80 minutes); 0.1 fragments the data, 0.5 merges it
geyser <- scale(faithful)
for (eps in c(0.1, 0.2, 0.3, 0.5)) {
  db <- dbscan(geyser, eps = eps, minPts = 5)$cluster
  print(c(eps = eps, clusters = max(db), noise = sum(db == 0)))
}
db <- dbscan(geyser, eps = 0.3, minPts = 5)$cluster
tapply(faithful$waiting, db, mean)


# Exercise 11: agreement 0.94; DBSCAN also finds 15 isolated earthquakes and a
# tiny third cluster of 12
positions <- scale(quakes[, c("long", "lat")])
set.seed(1)
km <- kmeans(positions, centers = 2, nstart = 25)$cluster
db <- dbscan(positions, eps = 0.3, minPts = 10)$cluster
table(kmeans = km, dbscan = db)
adjustedRandIndex(km, db)
plot(quakes$long, quakes$lat, col = db + 1, pch = 19, cex = 0.6,
     xlab = "Longitude", ylab = "Latitude")


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. k-means: cases nearest a centre (round, similar groups, every case in
#    one). Mixture: a distribution with its own centre, spread, shape, and size
#    (probabilities). DBSCAN: dense regions of any shape, with noise allowed.
# 2. Hard: one cluster per case, with certainty. Soft: a probability for each
#    cluster, so uncertain cases are shown as uncertain.
# 3. Fit against the number of parameters; higher BIC is better in mclust.
# 4. The students form one continuous cloud with no sparse gaps between the
#    profiles.
# 5. Several kinds of evidence: separation, stability across samples and
#    methods, interpretability, and differences on outcomes not used.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 14, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
