# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 2: Data Structures in R
#
# Four parts, as on the playground page:
#   A. Practise the chapter       the book's exercises, with blanks (______) to fill
#   B. Go further                 new exercises beyond the book
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: Ages over 30
# Show only the ages over 30 with logical indexing, and count them.
ages <- c(24, 31, 28, 45, 26)
ages[______]
sum(______)


# Exercise 2: Levels in order
# Make the levels run from "Disagree" through "Neutral" to "Agree", and check
# the order with table().
answers <- factor(c("Agree", "Disagree", "Neutral", "Agree"),
                  levels = ______)
table(answers)


# Exercise 3: Part-time students with children
sum(students$study_mode == "Part-time" ______ students$has_children == "Yes")


# Exercise 4: A new column
# Add over_30, TRUE for students older than 30. Count them, and explain why the
# count might need na.rm = TRUE.
students$over_30 <- students$age ______ 30
sum(students$over_30)
sum(students$over_30, ______)


# Exercise 5: A question behind a variable
# Read the SPSS file and find the question behind support_3.
# install.packages("haven")   # once, if you do not have it
library(haven)
spss <- ______("wellbeing.sav")
attr(spss$support_3, "______")


# Exercise 6: Units of analysis
# State the unit of analysis of students, semesters, questionnaire, and
# supervisors. For each, name one research question it could answer on its own.
# students:
# semesters:
# questionnaire:
# supervisors:


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: A data frame of every kind
# Five invented students, with a nominal category, an ordered category, a
# number, and a logical value. Check the type of every column.
five <- data.frame(
  faculty  = factor(c("Science", "Education", "Science", "Engineering", "Education")),
  exercise = factor(c("Rarely", "Often", "Sometimes", "Rarely", "Often"),
                    levels = c("Rarely", "Sometimes", "Often"),
                    ______ = TRUE),
  age      = c(26, 34, 29, 41, 25),
  works    = c(TRUE, FALSE, FALSE, TRUE, TRUE)
)
______(five)


# Exercise 8: The student with no age
# Show the ID, faculty, and programme of the students whose age is missing.
students[______(students$age), c("student_id", "faculty", "programme")]


# Exercise 9: Rows and students
# Show the rows of student S0001, count all the rows, and count the different
# students.
semesters[semesters$student_id == "S0001", ]
nrow(semesters)
length(______(semesters$student_id))
table(semesters$semester)


# Exercise 10: A codebook for a built-in dataset
# Build a codebook for ToothGrowth: name, meaning, type, and possible values.
codebook <- data.frame(
  variable = names(ToothGrowth),
  meaning  = c("Length of the tooth-growing cells (odontoblasts)",
               "How vitamin C was given: orange juice (OJ) or ascorbic acid (VC)",
               "Dose of vitamin C in milligrams per day"),
  type     = ______(ToothGrowth, class),
  values   = c("4.2 to 33.9", "OJ, VC", "0.5, 1, 2")
)
codebook


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Why does c(6.5, "seven") become a vector of text?
# 2. What is the difference between x[2] and x[-2]?
# 3. What are a factor's levels for?
# 4. Why should a question about students count each student once, even when a
#    table has several rows per student?
# 5. What does a codebook add to a data file?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Import the semester data twice: from semesters.csv, and from the
# Excel file wellbeing_raw.xlsx with the readxl package. Check the structure of
# each, and report how many rows, different students, and semesters the CSV
# file contains. Note any differences between the two imports.



# Task 2: Choose three variables from students (for example gender, employment,
# and financial_worry). Decide whether each should be a factor, an ordered
# factor, or a number, convert it, check with str(), and justify each choice in
# one sentence.



# Task 3: R's built-in esoph data comes from a study of cancer of the
# oesophagus. Look at it with str(), head(), and ?esoph. What does one row
# represent? How many people does the data describe? Which variables are
# ordered factors, and why?



# Task 4: Read wellbeing.sav, build its codebook with the name, label, and type
# of every variable, add a column for notes, and save it as a CSV file with
# write.csv().
