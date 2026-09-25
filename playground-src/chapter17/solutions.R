# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 17: Solutions
#
# One possible solution for the R exercises in parts A and B, and model answers
# for part C. The Quarto and Shiny tasks have finished versions in the
# solutions folder. Part D has no solutions: the tasks are open.

library(dplyr)

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: 6.3 hours, then 6.7 after the change
sleep <- c(6.5, 7, 5.5)
paste0("My three friends slept ", round(mean(sleep), 1), " hours on average last night.")
sleep[2] <- 8
paste0("My three friends slept ", round(mean(sleep), 1), " hours on average last night.")


# Exercise 5: five cells below 5 (all part-time students with children; the
# smallest have 3). Smallest cell without faculty 21, without children 11,
# without study mode 10, without gender 7.
cells <- students |>
  count(faculty, study_mode, gender, has_children) |>
  arrange(n)
head(cells, 6)
sum(cells$n < 5)
for (drop in c("faculty", "study_mode", "gender", "has_children")) {
  kept <- setdiff(c("faculty", "study_mode", "gender", "has_children"), drop)
  smallest <- min(count(students, across(all_of(kept)))$n)
  print(c(removed = drop, smallest_cell = smallest))
}


# Exercise 6: first analysis 5.5%; any of six 12.4% (10.9% with five)
forking_paths <- function() {
  group     <- rep(c("A", "B"), each = 30)
  score     <- rexp(60, rate = 1 / 10)
  covariate <- rnorm(60)
  z <- abs(as.numeric(scale(score)))
  keep <- rank(-score) > 5
  p <- c(
    t_test         = t.test(score ~ group)$p.value,
    no_outliers    = t.test(score[z < 2] ~ group[z < 2])$p.value,
    log_scale      = t.test(log(score) ~ group)$p.value,
    rank_test      = wilcox.test(score ~ group)$p.value,
    with_covariate = summary(lm(score ~ group + covariate))$coefficients[2, 4],
    no_top_five    = t.test(score[keep] ~ group[keep])$p.value
  )
  c(first_analysis = p[["t_test"]] < 0.05, any_analysis = any(p < 0.05))
}
set.seed(17)
rowMeans(replicate(2000, forking_paths()))


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: 5.5%, 7.7%, 10.9%, 13.9% for 1, 2, 5, 10 analyses; independent
# tests would give 5%, 10%, 23%, 40%: related analyses add less each
ten_paths <- function() {
  group <- rep(c("A", "B"), each = 30)
  score <- rexp(60, rate = 1 / 10)
  covariate <- rnorm(60)
  z <- abs(as.numeric(scale(score)))
  keep_top <- rank(-score) > 5
  keep_bottom <- rank(score) > 5
  c(t_test         = t.test(score ~ group)$p.value,
    rank_test      = wilcox.test(score ~ group)$p.value,
    log_scale      = t.test(log(score) ~ group)$p.value,
    no_outliers    = t.test(score[z < 2] ~ group[z < 2])$p.value,
    with_covariate = summary(lm(score ~ group + covariate))$coefficients[2, 4],
    sqrt_scale     = t.test(sqrt(score) ~ group)$p.value,
    outliers_2_5   = t.test(score[z < 2.5] ~ group[z < 2.5])$p.value,
    no_top_five    = t.test(score[keep_top] ~ group[keep_top])$p.value,
    no_bottom_five = t.test(score[keep_bottom] ~ group[keep_bottom])$p.value,
    equal_variance = t.test(score ~ group, var.equal = TRUE)$p.value)
}
set.seed(17)
p_values <- replicate(2000, ten_paths())
tried <- c(1, 2, 5, 10)
rate <- sapply(tried, function(k)
  mean(apply(p_values[1:k, , drop = FALSE], 2, function(p) any(p < 0.05))))
rbind(analyses_tried = tried, false_positive_rate = round(rate, 3),
      if_independent = round(1 - 0.95^tried, 3))


# Exercise 9: no cell below 5; the smallest now has 8 students
grouped <- students |>
  mutate(faculty_group = if_else(faculty %in% c("Natural Sciences", "Health Sciences"),
                                 "Sciences", "Humanities and social sciences")) |>
  count(faculty_group, study_mode, gender, has_children) |>
  arrange(n)
head(grouped, 4)
sum(grouped$n < 5)


# Exercise 10: the sentence reports the versions actually used
r_version <- paste(R.version$major, R.version$minor, sep = ".")
dplyr_version <- as.character(packageVersion("dplyr"))
paste0("Analyses were carried out in R version ", r_version,
       " (R Core Team), with data preparation in dplyr version ", dplyr_version, ".")
sessionInfo()


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. Reproducible: same data and code give the same result. Replicable: a new
#    study with new data finds the same thing.
# 2. Typed numbers go out of date when the data or analysis changes; inline
#    code recalculates them at every render.
# 3. The exact version of every package (renv.lock), so the project can be
#    restored and give the same results later or elsewhere.
# 4. Combinations of ordinary variables can identify people; small cells must
#    be protected, within what participants consented to.
# 5. Choosing the analysis after seeing the results (forking paths), which
#    inflates false positives; it separates confirmatory from exploratory.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open.
# ==============================================================================
