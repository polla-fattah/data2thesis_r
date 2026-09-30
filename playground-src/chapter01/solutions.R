# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 1: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: 7.125 hours, which rounds to 7.1
supervisor_sleep <- c(8, 7.5, 6, 7)
round(mean(supervisor_sleep), 1)


# Exercise 2: "600" is character (text that contains digits); 600 is numeric,
# a number R can calculate with. "600" + 1 gives an error.
class("600")
class(600)


# Exercise 3: the average of known values and an unknown value is unknown, so R
# answers NA rather than guess. With na.rm = TRUE the average is 5.
mean(c(4, NA, 6))
mean(c(4, NA, 6), na.rm = TRUE)


# Exercise 4: the youngest student is 23, the oldest 52
min(students$age, na.rm = TRUE)
max(students$age, na.rm = TRUE)


# Exercise 5: 177 part-time and 423 full-time students
table(students$study_mode)


# Exercise 6 (model answer): any three of these, or similar ones: which cases
# were removed and why; how missing values were handled; which questionnaire
# items were reversed; how a continuous variable was grouped, and where the
# cut-offs were; which test was chosen, with which options; which of several
# analyses tried is the one reported. Each can change the result, and none is
# visible in a table of results. A script records all of them.


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: 210 minutes between the longest and the shortest night; 3 nights
# under 7 hours. sum() counts TRUE values as 1.
week <- c(6.5, 7, 5.5, 8, 7.5, 6, 9)
minutes <- week * 60
minutes
max(minutes) - min(minutes)
sum(week < 7)


# Exercise 8: 426 Master's and 174 PhD students; 29% are PhD students
counts <- table(students$programme)
counts
counts["PhD"] / sum(counts)


# Exercise 9: a missing closing bracket ("unexpected end of input"), a
# misspelled object, and a word without quotation marks ("object not found")
sleep_week <- c(6.5, 7, 5.5, 8)
round(mean(sleep_week), 1)
mean(sleep_week)
toupper("wellbeing")


# Exercise 10: 30 plants, 10 in each group, average weight 5.07
head(PlantGrowth)
nrow(PlantGrowth)
mean(PlantGrowth$weight)
table(PlantGrowth$group)


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. It is the position of the first value on that line. When a result takes
#    several lines, each line starts with the position of its first value.
# 2. The honest answer is unknown. Removing missing values is a decision that
#    can change the result, so R leaves it to the researcher (na.rm = TRUE),
#    who should report it.
# 3. Console code runs once and is gone. A script is saved, so it can be read,
#    corrected, rerun from the start, and shared. The analysis belongs in a
#    script.
# 4. install.packages() downloads and stores a package, once. library() loads
#    it into the current session, in every session.
# 5. Every step is written in it, in order: which file was read, which cases
#    were removed, how variables were changed, which tests were run. Anyone can
#    check the decisions and repeat the analysis exactly.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 1, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
