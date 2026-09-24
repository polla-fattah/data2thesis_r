# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 2: Solutions
#
# One possible solution for each exercise. Other answers can be right too.


# Exercise 1: Picking values with a condition
ages <- c(24, 31, 28, 45, 26)
ages[ages > 30]
sum(ages > 30)


# Exercise 2: A whole vector at once
sleep <- c(6.5, 7, 5.5, 8, 6)
sleep * 60
mean(sleep < 7)   # 0.6: 60% of nights were under 7 hours


# Exercise 3: Ordered categories
answers <- factor(c("Agree", "Disagree", "Neutral", "Agree"),
                  levels = c("Disagree", "Neutral", "Agree"))
table(answers)


# Elaf's data
students <- read.csv("students.csv")

# Exercise 4: Selecting rows
both <- students[students$study_mode == "Part-time" & students$has_children == "Yes", ]
nrow(both)


# Exercise 5: Adding a column
students$over_30 <- students$age > 30
sum(students$over_30, na.rm = TRUE)
# The first answer is NA because one student's age is missing,
# so one value of over_30 is NA too.


# Exercise 6: Categories as a factor
students$faculty <- factor(students$faculty)
levels(students$faculty)


# Matrices and lists
semesters <- read.csv("semesters.csv")

# Exercise 7: A correlation matrix
vars <- semesters[, c("gpa", "sleep_hours", "wellbeing")]
correlations <- cor(vars, use = "complete.obs")
round(correlations, 2)
correlations["sleep_hours", "wellbeing"]


# Exercise 8: Results are lists
first_semester <- semesters[semesters$semester == 1, ]
result <- t.test(first_semester$sleep_hours, mu = 7)
names(result)
result$p.value


# Exercise 9: An SPSS file with labels
library(haven)
spss <- read_sav("wellbeing.sav")
attr(spss$support_3, "label")
table(as_factor(spss$faculty))
