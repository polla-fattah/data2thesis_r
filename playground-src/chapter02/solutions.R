# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 2: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: two ages, 31 and 45, are over 30
ages <- c(24, 31, 28, 45, 26)
ages[ages > 30]
sum(ages > 30)


# Exercise 2: Disagree 1, Neutral 1, Agree 2, in the order of the scale
answers <- factor(c("Agree", "Disagree", "Neutral", "Agree"),
                  levels = c("Disagree", "Neutral", "Agree"))
table(answers)


# Exercise 3: 51 students are part-time and have children
sum(students$study_mode == "Part-time" & students$has_children == "Yes")


# Exercise 4: 205 students are older than 30. Without na.rm = TRUE the answer
# is NA, because one age is missing and the comparison is NA for that student.
students$over_30 <- students$age > 30
sum(students$over_30)
sum(students$over_30, na.rm = TRUE)


# Exercise 5: "My supervisor cares about my wellbeing."
library(haven)
spss <- read_sav("wellbeing.sav")
attr(spss$support_3, "label")


# Exercise 6 (model answer):
# students: a student (600 rows). Are part-time students more likely to
#   consider dropping out?
# semesters: one student in one semester (2,326 rows). Does sleep change over
#   the four semesters?
# questionnaire: a student, with the 22 item answers. Are stress and burnout
#   related?
# supervisors: a supervisor (120 rows). Do professors supervise more students
#   than lecturers?


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: a factor, an ordered factor ("Rarely" < "Sometimes" < "Often"),
# a number, and a logical column
five <- data.frame(
  faculty  = factor(c("Science", "Education", "Science", "Engineering", "Education")),
  exercise = factor(c("Rarely", "Often", "Sometimes", "Rarely", "Often"),
                    levels = c("Rarely", "Sometimes", "Often"),
                    ordered = TRUE),
  age      = c(26, 34, 29, 41, 25),
  works    = c(TRUE, FALSE, FALSE, TRUE, TRUE)
)
str(five)
five$exercise > "Rarely"


# Exercise 8: one student, S0007, a Master's student in Health Sciences
students[is.na(students$age), c("student_id", "faculty", "programme")]


# Exercise 9: S0001 has four rows; 2,326 rows but 600 students; 37 students have
# no records for semesters 3 and 4
semesters[semesters$student_id == "S0001", ]
nrow(semesters)
length(unique(semesters$student_id))
table(semesters$semester)


# Exercise 10: len and dose are numeric, supp is a factor
codebook <- data.frame(
  variable = names(ToothGrowth),
  meaning  = c("Length of the tooth-growing cells (odontoblasts)",
               "How vitamin C was given: orange juice (OJ) or ascorbic acid (VC)",
               "Dose of vitamin C in milligrams per day"),
  type     = sapply(ToothGrowth, class),
  values   = c("4.2 to 33.9", "OJ, VC", "0.5, 1, 2"),
  row.names = NULL
)
codebook


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. A vector holds one type only. A number can be written as text but text
#    cannot become a number, so R converts everything to text.
# 2. x[2] keeps only the second value; x[-2] keeps everything except it.
# 3. They list the possible categories and fix their order, which controls
#    tables, graphs, and the reference category in a regression.
# 4. The unit of the question is the student. Counting rows counts semesters,
#    gives students with more semesters more weight, and treats repeated
#    measurements of one person as independent people.
# 5. The meaning of every value: what each variable measures, the question
#    behind it, its units or scale, the category codes, and missing-value codes.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 2, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
