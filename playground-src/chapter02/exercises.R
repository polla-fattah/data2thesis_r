# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 2: Data Structures in R
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.


# Vectors and factors ----------------------------------------------------------

# Exercise 1: Picking values with a condition
# Show only the ages over 30, then count how many there are.
ages <- c(24, 31, 28, 45, 26)
ages[______]
sum(______)


# Exercise 2: A whole vector at once
# Convert Elaf's sleep to minutes, and find the share of nights under 7 hours.
sleep <- c(6.5, 7, 5.5, 8, 6)
sleep * ______
mean(sleep ______ 7)


# Exercise 3: Ordered categories
# Make the levels run from "Disagree" through "Neutral" to "Agree".
answers <- factor(c("Agree", "Disagree", "Neutral", "Agree"),
                  levels = ______)
table(answers)


# Elaf's data ------------------------------------------------------------------

students <- read.csv("students.csv")

# Exercise 4: Selecting rows
# How many students study part-time AND have children (has_children == "Yes")?
both <- students[students$study_mode == "Part-time" & ______, ]
nrow(both)


# Exercise 5: Adding a column
# Add over_30 (TRUE for students older than 30) and count them.
# Why is the first answer NA?
students$over_30 <- students$age > 30
sum(students$over_30)


# Exercise 6: Categories as a factor
# Turn faculty into a factor and list its levels.
students$faculty <- ______(students$faculty)
levels(students$faculty)


# Matrices and lists -----------------------------------------------------------

semesters <- read.csv("semesters.csv")

# Exercise 7: A correlation matrix
# Pick out the correlation between sleep_hours and wellbeing.
vars <- semesters[, c("gpa", "sleep_hours", "wellbeing")]
correlations <- cor(vars, use = "complete.obs")
round(correlations, 2)
correlations["______", "______"]


# Exercise 8: Results are lists
# List the parts of the t-test result, then pick out the p-value.
first_semester <- semesters[semesters$semester == 1, ]
result <- t.test(first_semester$sleep_hours, mu = 7)
names(result)
result$______


# Importing data (on your own computer only) -----------------------------------

# Exercise 9: An SPSS file with labels
# Read wellbeing.sav with haven, find the question behind support_3,
# and count the students in each faculty using the labels.
# install.packages("haven")   # once, if you do not have it
library(haven)
spss <- read_sav("wellbeing.sav")
attr(spss$support_3, "______")
table(as_factor(spss$______))
