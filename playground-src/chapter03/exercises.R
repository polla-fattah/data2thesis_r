# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 3: Data Manipulation
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

library(dplyr)
library(tidyr)
library(stringr)
library(readr)

students    <- read.csv("students.csv")
semesters   <- read.csv("semesters.csv")
supervisors <- read.csv("supervisors.csv")


# The pipe and the verbs -------------------------------------------------------

# Exercise 1: Rewrite round(mean(c(6.5, 7, 5.5, 8, 6)), 1) with the pipe
c(6.5, 7, 5.5, 8, 6) |> ______ |> ______


# Exercise 2: Average age by faculty, oldest first
students |>
  summarise(mean_age = mean(age, na.rm = TRUE), .by = ______) |>
  arrange(______)


# Exercise 3: Sleep groups: "Short" (< 6), "Recommended" (>= 7), "Moderate" otherwise
semesters |>
  mutate(sleep_group = case_when(
    sleep_hours < 6 ~ "Short",
    ______ ~ "Recommended",
    .default = ______
  )) |>
  count(sleep_group)


# Reshaping and joining --------------------------------------------------------

# Exercise 4: Each student's GPA, one column per semester
semesters |>
  select(student_id, semester, gpa) |>
  pivot_wider(names_from = ______, values_from = ______) |>
  head()


# Exercise 5: Average GPA of full-time and part-time students
semesters |>
  left_join(students, join_by(______)) |>
  summarise(mean_gpa = mean(gpa, na.rm = TRUE), .by = ______)


# Exercise 6: How many students have no record for semester 4?
students |>
  anti_join(semesters |> filter(semester == ______), join_by(student_id)) |>
  nrow()


# Cleaning ---------------------------------------------------------------------

# Exercise 7: Clean a small messy table, then average stress
messy <- tibble(
  gender = c("F", "female", "Male", "m", "Female"),
  stress = c("3", "99", "4", "2", "5")
)
clean <- messy |>
  mutate(
    gender = if_else(str_starts(str_to_lower(gender), "f"), ______, ______),
    stress = as.integer(na_if(stress, ______))
  )
clean
mean(clean$stress, na.rm = TRUE)


# Exercise 8: Clean Elaf's full survey export
# Work through Section 3.6 of the book on wellbeing_raw.xlsx, step by step:
#   1. read the file with readxl::read_excel()
#   2. remove test responses and duplicates
#   3. rename the variables
#   4. fix the inconsistent categories
#   5. turn missing codes into NA and text into numbers
#   6. set impossible values to NA
#   7. compute the four scale scores (reverse stress_4 first!)
#   8. reshape the semester measurements from wide to long
# Then check: are there 600 students and 2,326 semester records?
library(readxl)
raw <- read_excel("wellbeing_raw.xlsx")

