# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 3: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

library(dplyr)
library(tidyr)
library(stringr)
library(readr)

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
supervisors   <- read.csv("supervisors.csv")
questionnaire <- read.csv("questionnaire.csv")


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: Natural Sciences oldest (30.7), Humanities youngest (29.2)
students |>
  group_by(faculty) |>
  summarise(mean_age = mean(age, na.rm = TRUE)) |>
  arrange(desc(mean_age))


# Exercise 2: .default also catches the 21 records with no sleep value, which
# would be counted as "Moderate" (882). Keeping them missing: Short 682,
# Recommended 762, Moderate 861, NA 21.
semesters |>
  mutate(sleep_group = case_when(
    is.na(sleep_hours) ~ NA,
    sleep_hours < 6 ~ "Short",
    sleep_hours >= 7 ~ "Recommended",
    .default = "Moderate"
  )) |>
  count(sleep_group)


# Exercise 3: one row per student, columns S1 to S4; students who left have NA
# in the later semesters
semesters |>
  select(student_id, semester, gpa) |>
  pivot_wider(names_from = semester, values_from = gpa, names_prefix = "S") |>
  head()


# Exercise 4: full-time 3.09, part-time 3.10
semesters |>
  left_join(students, join_by(student_id)) |>
  group_by(study_mode) |>
  summarise(mean_gpa = mean(gpa, na.rm = TRUE))


# Exercise 5 (model answer): stress_4 ("I feel confident handling problems in
# my studies") is worded so that agreeing means less stress, the opposite of the
# other five items. Unreversed, it pulls every score towards the middle: a
# student answering 5, 5, 5, 1, 5, 5 scores 4.33 instead of 5. Scores spread
# less, are less reliable, and relate more weakly to other variables.
# Reverse with 6 - stress_4 on a 1-to-5 scale.


# Exercise 6 (model answer), from health research:
# Valid: a blood pressure of 1,200 mmHg; set to missing and report the count.
# Accurate: "below detection limit" stored as 0; decide on 0, missing, or half
#   the limit, and state the choice.
# Complete: values missing after a missed visit; mark as NA, not 0 or -9.
# Consistent: weight in kilograms at one site and pounds at another; convert.
# Unique: a patient registered twice; match on date of birth and hospital
#   number, and keep one record.


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: with the codes, mean 30.4 (impossible) and median 4; without, both
# are 3. The median is less affected, but still wrong, and it looks plausible.
answers <- c(4, 3, 5, 99, 2, 99, 1)
mean(answers)
median(answers)
mean(na_if(answers, 99), na.rm = TRUE)
median(na_if(answers, 99), na.rm = TRUE)


# Exercise 8: no disagreements; all 120 supervisors match, with 1 to 12
# students each
check <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id)) |>
  group_by(supervisor_id) |>
  summarise(n_counted = n(),
            mean_wellbeing = mean(wellbeing, na.rm = TRUE)) |>
  left_join(supervisors, join_by(supervisor_id))
head(check)
check |> filter(n_counted != n_students)


# Exercise 9: 13,200 rows (600 students x 22 items); stress_4 has the lowest
# stress average (2.90), because it is the reversed item
long <- questionnaire |>
  pivot_longer(-student_id, names_to = "item", values_to = "answer")
dim(long)
long |>
  group_by(item) |>
  summarise(mean_answer = mean(answer, na.rm = TRUE)) |>
  print(n = 22)


# Exercise 10: 3 Education, 2 Health Sciences; average sleep 6.9 hours.
# Without the comma fix, 6,5 becomes 65 and the average 32.1.
messy <- tibble(
  faculty = c("Education", "education ", "EDUCATION", "Health Sciences", "health sci."),
  sleep   = c("6,5", "7 hrs", "8", "5.5", "7,5")
)
clean <- messy |>
  mutate(
    faculty = if_else(str_detect(str_to_lower(faculty), "educ"), "Education", "Health Sciences"),
    sleep   = parse_number(str_replace(sleep, ",", "."))
  )
clean
count(clean, faculty)
mean(clean$sleep)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. Valid: impossible values. Accurate: values that do not mean what they seem,
#    such as codes read as answers. Complete: missing values hidden behind codes.
#    Consistent: one answer recorded in several ways. Unique: cases counted
#    more than once.
# 2. Hand edits leave no record. With an untouched raw file and cleaning by
#    code, every decision can be seen, checked, changed, and rerun.
# 3. Each variable forms a column, each observation a row, and each value a
#    cell.
# 4. left_join() keeps every row of the first table and adds matching columns;
#    anti_join() keeps only the rows of the first table with no match.
# 5. 99 is not always a code: in a 0-100 wellbeing score it is a real value.
#    Replace codes only in the columns where the codebook says they are codes.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 3, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
