# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 1: Solutions
#
# These are one possible solution for each exercise. Other answers can be
# right too.


# Exercise 1: R as a calculator
(6.5 + 7 + 5.5) / 3
# R follows the usual order of operations, so the brackets matter.
# Without them, R would divide only 5.5 by 3:
6.5 + 7 + 5.5 / 3


# Exercise 2: Storing values in an object
sleep <- c(6.5, 7, 5.5, 8)
sleep
mean(sleep)
# The average rises from 6.33 to 6.75 hours.


# Exercise 3: More functions
sleep <- c(6.5, 7, 5.5, 8)
min(sleep)
max(sleep)
length(sleep)
round(mean(sleep), 1)


# Exercise 4: Opening the data
students <- read.csv("students.csv")
nrow(students)   # 600 students
ncol(students)   # 14 variables
head(students)
names(students)  # the names of all the variables


# Exercise 5: A first question, and a first surprise
mean(students$age, na.rm = TRUE)
# na.rm = TRUE tells R to remove missing values before calculating.
# How many ages are missing?
sum(is.na(students$age))


# Exercise 6: Counting
table(students$faculty)
table(students$workshop)
# Exactly half the students, 300, were invited: the invitation was random.


# Challenge: Your first plot
semesters <- read.csv("semesters.csv")
hist(semesters$sleep_hours,
     main = "How long do graduate students sleep?",
     xlab = "Hours of sleep per night")
