# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 6: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

library(dplyr)

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")
first_sem <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id))


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: mean 27.6, median 26: mildly right-skewed. Mean and SD (27.6,
# 13.1) are acceptable; median and IQR (26, 19) would be safer with a longer tail.
first_sem |>
  summarise(
    mean   = mean(study_hours, na.rm = TRUE),
    median = median(study_hours, na.rm = TRUE),
    sd     = sd(study_hours, na.rm = TRUE),
    iqr    = IQR(study_hours, na.rm = TRUE)
  )


# Exercise 2: the points follow the line closely: close to normal
qqnorm(first_sem$wellbeing)
qqline(first_sem$wellbeing)


# Exercise 3: fence 65.5 hours; one student (S0312, part-time, no job) studies
# 67 hours and sleeps 3.9: extreme but consistent, so a real case to keep
x  <- first_sem$study_hours
q3 <- quantile(x, 0.75, na.rm = TRUE)
fence <- q3 + 1.5 * IQR(x, na.rm = TRUE)
fence
sum(x > fence, na.rm = TRUE)
first_sem |>
  filter(study_hours > fence) |>
  select(student_id, study_hours, sleep_hours, gpa, wellbeing, employment, study_mode)


# Exercise 4: the 37 who left slept like the 563 who stayed (6.4 vs 6.5 hours)
# but had lower wellbeing (57.4 vs 60.7): attrition is related to wellbeing,
# not to sleep
left_ids <- setdiff(students$student_id,
                    semesters$student_id[semesters$semester == 3])
first_sem |>
  mutate(left_study = student_id %in% left_ids) |>
  summarise(mean_sleep = mean(sleep_hours, na.rm = TRUE),
            mean_wellbeing = mean(wellbeing),
            students = n(),
            .by = left_study)


# Exercise 5: r = 0.41, medium. Not causal: satisfied students may view their
# supervisors more kindly, or a third variable may raise both.
scores <- questionnaire |>
  mutate(
    support      = rowMeans(pick(support_1:support_6), na.rm = TRUE),
    satisfaction = rowMeans(pick(satisfaction_1:satisfaction_4), na.rm = TRUE)
  )
cor(scores$support, scores$satisfaction, use = "complete.obs")


# Exercise 6 (model answer):
# age: skewed ratio; median and IQR (or mean and SD with a note on the skew).
# gender, faculty, programme, study_mode, has_children, lives_away, workshop,
#   considering_dropout: nominal; counts and percentages.
# employment, financial_worry: ordinal; percentages, and the median for worry.
# workshop_sessions: a count with seven values; median and IQR, or percentages.
# student_id, supervisor_id: identifiers, not summarised (students per
#   supervisor is worth reporting).


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: deviations -3, -1, 0, 1, 3 (they sum to zero); squares sum to 20;
# variance 5; SD 2.24, the same as sd()
sleep_five <- c(4, 6, 7, 8, 10)
deviations <- sleep_five - mean(sleep_five)
deviations
deviations^2
variance <- sum(deviations^2) / (length(sleep_five) - 1)
sqrt(variance)
sd(sleep_five)


# Exercise 8: mean 29.7, median 29; a tail of older students (up to 52) pulls
# the mean up: right skew
mean(students$age, na.rm = TRUE)
median(students$age, na.rm = TRUE)
hist(students$age, breaks = 20, main = "", xlab = "Age (years)")


# Exercise 9: few, scattered gaps (at most 8 per column and semester) in the
# self-reported variables; the 37 students with no rows in semesters 3 and 4 do
# not show up as NA at all
semesters |>
  group_by(semester) |>
  summarise(across(everything(), ~ sum(is.na(.x)))) |>
  as.data.frame()


# Exercise 10: mean 70.9 minutes, in the valley between peaks near 55 and 80;
# only 20 of 272 waits are within 3 minutes of it. Split at 67: 99 short waits
# (mean 54.6) and 173 long (mean 80.2).
mean(faithful$waiting)
hist(faithful$waiting, breaks = 20, main = "", xlab = "Waiting time (minutes)")
faithful |>
  mutate(type = if_else(waiting < 67, "short", "long")) |>
  group_by(type) |>
  summarise(eruptions = n(), mean_wait = mean(waiting))


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. Percentages in each category, and the median: the order is meaningful, the
#    steps are not equal, so the mean suggests false precision.
# 2. A typical student sleeps about 1.1 hours more or less than 6.5; if roughly
#    normal, two-thirds sleep between 5.4 and 7.6 hours.
# 3. It is usually a real case. Check it: set impossible values to missing, keep
#    possible ones, and report results with and without it if it matters.
# 4. At random: gaps depend on something measured, which an analysis can
#    include. Not at random: gaps depend on the missing value itself; the
#    answers that remain are not typical, and the data cannot show it.
# 5. No. r measures straight-line relationships only; a curve can give r near
#    0 although the variables are strongly related.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 6, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
