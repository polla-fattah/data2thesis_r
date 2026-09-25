# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 14: Advanced Clustering
#
# Four parts, as on the playground page:
#   A. Practise the chapter       the book's exercises, with mclust and dbscan
#   B. Go further                 new exercises beyond the book, in base R
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

library(dplyr)
library(mclust)
library(dbscan)

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")

# The chapter's profile data and three-profile mixture model
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

# Exercise 1: Four mixture profiles
# Describe them; which three-cluster profile was split? Compare with k-means.
set.seed(123)
gmm4 <- Mclust(profile_data, G = ______, verbose = FALSE)
profiles |>
  mutate(cluster = gmm4$classification) |>
  summarise(students = n(), across(sleep_hours:satisfaction, ~ round(mean(.x), 1)),
            .by = cluster)
table(three = profile_gmm$classification, four = gmm4$classification)
adjustedRandIndex(gmm4$classification, kmeans_clusters$cluster)


# Exercise 2: Clear members (probability above 0.95)
certainty <- apply(profile_gmm$z, 1, ______)
sum(certainty > 0.95)
mean(certainty > 0.95)


# Exercise 3: DBSCAN with different eps (minPts = 8)
for (eps in c(1.2, 1.6, 2, 2.4)) {
  clusters <- dbscan(profile_data, eps = eps, minPts = ______)$cluster
  print(c(eps = eps, clusters = max(clusters), noise = sum(clusters == 0)))
}


# Exercise 4: The profiles without the noise students
keep <- dbscan(profile_data, eps = 2, minPts = 8)$cluster ______ 0
gmm_kept <- Mclust(profile_data[keep, ], G = 3, verbose = FALSE)
profiles[keep, ] |>
  mutate(cluster = gmm_kept$classification) |>
  summarise(students = n(), across(sleep_hours:satisfaction, ~ round(mean(.x), 1)),
            .by = cluster)
adjustedRandIndex(profile_gmm$classification[keep], gmm_kept$classification)


# Exercise 5: Mixture model against hierarchical clustering (Ward, 3 clusters)
hierarchical <- cutree(hclust(dist(profile_data), method = "ward.D2"), k = 3)
______(profile_gmm$classification, hierarchical)
table(profile_gmm$classification, hierarchical)


# Exercise 6: Profiles and final GPA
final_gpa <- semesters |>
  filter(semester == 4) |>
  select(student_id, final_gpa = gpa)
profiles |>
  mutate(profile = profile_gmm$classification) |>
  left_join(final_gpa, join_by(student_id)) |>
  summarise(students  = n(),
            final_gpa = round(______(final_gpa, na.rm = TRUE), 2),
            study     = round(mean(study_hours), 1),
            stress    = round(mean(stress), 1),
            .by = profile)


# Exercise 7: A gap between the groups (long group moved to y = 3)
for (long_y in c(1.4, ______)) {
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
# B. GO FURTHER (base R, as on the playground page)
# ==============================================================================

# Exercise 8: Membership probabilities by hand (Old Faithful)
wait  <- c(50, 67, 85)
short <- 0.36 * dnorm(wait, mean = 54.6, sd = 5.9)
long  <- 0.64 * dnorm(wait, mean = ______, sd = 5.9)
round(short / (short + ______), 3)


# Exercise 9: Groups of different sizes and densities
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
  db <- dbscan(groups[, c("x", "y")], eps = ______, minPts = 5)$cluster
  print(round(c(eps = eps, clusters = max(db), noise = sum(db == 0),
                ari = adjustedRandIndex(groups$truth, db)), 2))
}
adjustedRandIndex(groups$truth,
                  Mclust(groups[, c("x", "y")], G = 3, verbose = FALSE)$classification)


# Exercise 10: DBSCAN on Old Faithful
geyser <- scale(faithful)
for (eps in c(0.1, 0.2, 0.3, 0.5)) {
  db <- dbscan(geyser, eps = eps, minPts = 5)$cluster
  print(c(eps = eps, clusters = max(db), noise = sum(db == 0)))
}
db <- dbscan(geyser, eps = 0.3, minPts = 5)$cluster
tapply(faithful$waiting, db, ______)


# Exercise 11: Earthquakes near Fiji
positions <- scale(quakes[, c("long", "lat")])
set.seed(1)
km <- kmeans(positions, centers = 2, nstart = 25)$cluster
db <- dbscan(positions, eps = 0.3, minPts = 10)$cluster
table(kmeans = km, dbscan = db)
adjustedRandIndex(km, ______)
plot(quakes$long, quakes$lat, col = db + 1, pch = 19, cex = 0.6,
     xlab = "Longitude", ylab = "Latitude")


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. What are the three definitions of a group used by k-means, mixture
#    models, and DBSCAN?
# 2. What is the difference between hard and soft membership?
# 3. What does BIC compare when choosing the number of clusters?
# 4. Why did DBSCAN find only one cluster of students in the chapter?
# 5. How can a clustering be judged when there is no answer key?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Find profiles with a mixture model on variables of your choice;
# report the share of clear members, and describe the uncertain students.



# Task 2: Check the stability of the three profiles on 20 bootstrap samples,
# comparing each with the full-data profiles with adjustedRandIndex().



# Task 3: Write the clustering paragraph of a methods section, reporting every
# choice (variables, scaling, method, number of clusters, validation).
