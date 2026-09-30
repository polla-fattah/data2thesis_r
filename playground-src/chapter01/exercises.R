# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 1: Getting Started with R
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

# Exercise 1: A supervisor's sleep
# A supervisor sleeps 8, 7.5, 6, and 7 hours on four nights. Store the numbers in
# an object called supervisor_sleep and find the average, rounded to one
# decimal place.
supervisor_sleep <- ______(8, 7.5, 6, 7)
round(mean(supervisor_sleep), ______)


# Exercise 2: Text and numbers
# Check the types of "600" and 600 with class(), and explain the difference.
class("600")
class(______)


# Exercise 3: A missing value
# Explain why mean(c(4, NA, 6)) returns NA, and get the average of the two
# known values.
mean(c(4, NA, 6))
mean(c(4, NA, 6), ______ = TRUE)


# Exercise 4: The youngest and the oldest student
______(students$age, na.rm = TRUE)
______(students$age, na.rm = TRUE)


# Exercise 5: Part-time students
# Using table(), find how many students study part-time (variable study_mode).
______(students$study_mode)


# Exercise 6: Decisions without a record
# Think of an analysis you have done, or read about, with a point-and-click
# program. List three decisions in it that a reader could not check without a
# written record.
# 1.
# 2.
# 3.


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: Calculating with a whole week
# Convert the week to minutes, find the difference between the longest and the
# shortest night in minutes, and count the nights under 7 hours.
week <- c(6.5, 7, 5.5, 8, 7.5, 6, 9)
minutes <- week * ______
minutes
max(minutes) - min(minutes)
sum(week ______ 7)


# Exercise 8: Master's and PhD students
# Find how many students are in each programme, and the share of PhD students.
counts <- table(students$programme)
counts
counts["PhD"] / ______(counts)


# Exercise 9: Reading error messages
# Each line below has one mistake. Remove the # at the start of a line, run it,
# read the error message, and fix the mistake.
sleep_week <- c(6.5, 7, 5.5, 8)
# round(mean(sleep_week), 1
# mean(sleep_wek)
# toupper(wellbeing)


# Exercise 10: A built-in dataset
# PlantGrowth records the dried weight of plants under a control condition and
# two treatments. Find the number of plants, their average weight, and the
# number of plants in each group.
head(PlantGrowth)
______(PlantGrowth)
mean(PlantGrowth$weight)
______(PlantGrowth$group)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. When R prints a result, it starts the line with [1]. What does it mean?
# 2. Why does mean() return NA when one value is missing, instead of averaging
#    the others?
# 3. What is the difference between typing code in the Console and writing it
#    in a script?
# 4. What does library() do that install.packages() does not?
# 5. Why is a script called a record of the decisions in an analysis?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Store your own hours of sleep for the last seven nights, with a
# comment above each step, and report the average, the shortest night, and the
# number of nights under 7 hours.



# Task 2: Using students, report three facts about the sample, each from one
# line of code (for example, the number of faculties, the share of women, and
# the median age).



# Task 3: R's built-in women data gives the average height (inches) and weight
# (pounds) of American women aged 30 to 39. Find the number of rows, convert both
# variables to centimetres and kilograms (1 inch = 2.54 cm, 1 pound = 0.4536 kg),
# and report the average height and weight in the new units.



# Task 4: Set up an RStudio Project for your own thesis, with a data/ folder for
# raw data and a first script that reads a file and prints its number of rows
# and columns.
