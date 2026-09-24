# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 1: Getting Started with R
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.


# Warming up with a few numbers ------------------------------------------------

# Exercise 1: R as a calculator
# Elaf slept 6.5, 7, and 5.5 hours on three nights. What is her average sleep?
(6.5 + 7 + 5.5) / 3


# Exercise 2: Storing values in an object
# Store the numbers in an object called sleep, then use mean().
# Add a fourth night of 8 hours. What happens to the average?
sleep <- c(6.5, 7, 5.5)
sleep
mean(sleep)


# Exercise 3: More functions
# Find the shortest and longest night and the number of nights.
# Then round the average to one decimal place with round().
sleep <- c(6.5, 7, 5.5, 8)
min(sleep)
# Now try max(), length(), and round(mean(sleep), 1)



# Elaf's data ------------------------------------------------------------------

# Exercise 4: Opening the data
# Read students.csv. How many rows and columns are there? Look at the first rows.
students <- read.csv("students.csv")
nrow(students)
ncol(students)
head(students)


# Exercise 5: A first question, and a first surprise
# What is the average age? The answer is NA: one age is missing.
# Use the na.rm argument of mean() so R ignores the missing value.
mean(students$age)


# Exercise 6: Counting
# How many students come from each faculty?
# How many were invited to the wellbeing workshop (variable: workshop)?
table(students$faculty)


# Challenge: Your first plot
# Draw a histogram of sleep hours from semesters.csv with hist().
# Can you add a title with the main argument?
semesters <- read.csv("semesters.csv")
hist(semesters$sleep_hours)
