# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 3: Data Manipulation
#
# Four parts, as on the playground page:
#   A. Practise the chapter       the book's exercises, with blanks (______) to fill
#   B. Go further                 new exercises beyond the book
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

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

# Exercise 1: Average age by faculty, sorted from oldest to youngest
students |>
  group_by(faculty) |>
  ______(mean_age = mean(age, na.rm = TRUE)) |>
  arrange(______(mean_age))


# Exercise 2: Sleep in three categories
# "Short" under 6 hours, "Recommended" 7 or more, "Moderate" otherwise. Count
# the semester records in each category. Then check what happened to the
# records with no sleep value.
semesters |>
  mutate(sleep_group = case_when(
    sleep_hours < 6 ~ "Short",
    sleep_hours ______ 7 ~ "Recommended",
    .default = "Moderate"
  )) |>
  ______(sleep_group)


# Exercise 3: One column per semester
# A table of GPA with one row per student and one column per semester.
semesters |>
  select(student_id, semester, gpa) |>
  pivot_wider(names_from = ______, values_from = ______, names_prefix = "S") |>
  head()


# Exercise 4: GPA by study mode
semesters |>
  ______(students, join_by(student_id)) |>
  group_by(study_mode) |>
  summarise(mean_gpa = mean(gpa, na.rm = TRUE))


# Exercise 5: A reversed item
# Explain why stress_4 must be reversed before the stress score is calculated,
# and what would happen to the scores if it were not.


# Exercise 6: Clean data in your own field
# For each quality of clean data (valid, accurate, complete, consistent,
# unique), give one example of a problem from your own field and the cleaning
# decision it would require.


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: The missing-code trap
# Two skipped answers were recorded as 99. Compare the mean and the median with
# and without the codes.
answers <- c(4, 3, 5, 99, 2, 99, 1)
mean(answers)
median(answers)
mean(______(answers, 99), na.rm = TRUE)
median(______(answers, 99), na.rm = TRUE)


# Exercise 8: Checking two tables against each other
# Count each supervisor's students from the first-semester data, with their
# average wellbeing, join to supervisors, and check whether the counts disagree.
check <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id)) |>
  group_by(supervisor_id) |>
  summarise(n_counted = ______(),
            mean_wellbeing = mean(wellbeing, na.rm = TRUE)) |>
  left_join(supervisors, join_by(supervisor_id))
head(check)
check |> filter(n_counted ______ n_students)


# Exercise 9: The questionnaire in long format
# One row per student per item; then the average answer to each item.
long <- questionnaire |>
  ______(-student_id, names_to = "item", values_to = "answer")
dim(long)
long |>
  group_by(item) |>
  summarise(mean_answer = mean(answer, na.rm = TRUE)) |>
  print(n = 22)


# Exercise 10: A small messy table
# Clean the faculty spellings and the sleep values, count the students in each
# faculty, and calculate the average sleep.
messy <- tibble(
  faculty = c("Education", "education ", "EDUCATION", "Health Sciences", "health sci."),
  sleep   = c("6,5", "7 hrs", "8", "5.5", "7,5")
)
clean <- messy |>
  mutate(
    faculty = if_else(str_detect(str_to_lower(faculty), "educ"), "Education", "Health Sciences"),
    sleep   = parse_number(str_replace(sleep, ______, ______))
  )
clean
count(clean, faculty)
mean(clean$sleep)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Clean data is valid, accurate, complete, consistent, and unique. What does
#    each quality guard against?
# 2. Why is the raw data file never edited by hand?
# 3. What is tidy data?
# 4. What is the difference between left_join() and anti_join()?
# 5. Why should a 99 not be replaced with NA everywhere in a file?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Which faculty has the largest share of students who live away from
# their family, and how does that share differ between Master's and PhD
# students in each faculty? One table that answers both parts, and two
# sentences describing it.



# Task 2: Calculate each student's burnout score as the average of the six
# burnout items, join it to the first-semester records, and compare the average
# burnout of students who have and have not considered dropping out.



# Task 3: R's built-in airquality data records daily air quality in New York in
# 1973. Find which columns have missing values and how many, decide what to do
# about them for an analysis of ozone, and write the methods sentence.



# Task 4: Clean wellbeing_raw.xlsx from scratch (readxl::read_excel()), without
# looking at the chapter's code, and compare your result with the clean tables:
# the number of students, the categories of each variable, and a few averages.



# Task 5: Write the methods paragraph reporting your cleaning in Task 4, with
# every number (test responses, duplicates, impossible values, missing codes)
# calculated by code.
