# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 6: Descriptive Statistics and Exploratory Data Analysis
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

students      <- read.csv("students.csv")
semesters     <- read.csv("semesters.csv")
questionnaire <- read.csv("questionnaire.csv")
first_sem <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id))


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: Four summaries of study hours
# Symmetrical or skewed? Which pair of summaries would you report?
first_sem |>
  summarise(
    mean   = mean(study_hours, na.rm = TRUE),
    median = ______(study_hours, na.rm = TRUE),
    sd     = ______(study_hours, na.rm = TRUE),
    iqr    = ______(study_hours, na.rm = TRUE)
  )


# Exercise 2: Is wellbeing normal? A Q-Q plot.
______(first_sem$wellbeing)
qqline(first_sem$wellbeing)


# Exercise 3: Unusually high study hours (box plot rule), and their other values
x  <- first_sem$study_hours
q3 <- quantile(x, 0.75, na.rm = TRUE)
fence <- q3 + ______ * IQR(x, na.rm = TRUE)
fence
sum(x > fence, na.rm = TRUE)
first_sem |>
  filter(study_hours > fence) |>
  select(student_id, study_hours, sleep_hours, gpa, wellbeing, employment, study_mode)


# Exercise 4: Sleep of students who left
# Do they differ in sleep as they did in wellbeing?
left_ids <- ______(students$student_id,
                   semesters$student_id[semesters$semester == 3])
first_sem |>
  mutate(left_study = student_id %in% left_ids) |>
  summarise(mean_sleep = mean(sleep_hours, na.rm = TRUE),
            mean_wellbeing = mean(wellbeing),
            students = n(),
            .by = left_study)


# Exercise 5: Support and satisfaction
# The correlation, classified with Cohen's guidelines. Why is it not evidence
# that support causes satisfaction?
scores <- questionnaire |>
  mutate(
    support      = ______(pick(support_1:support_6), na.rm = TRUE),
    satisfaction = ______(pick(satisfaction_1:satisfaction_4), na.rm = TRUE)
  )
______(scores$support, scores$satisfaction, use = "complete.obs")


# Exercise 6: A summary for every variable
# For each variable in students, choose the summary you would report, and
# justify each choice in one sentence.


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: The standard deviation by hand
sleep_five <- c(4, 6, 7, 8, 10)
deviations <- sleep_five - mean(sleep_five)
deviations
deviations^2
variance <- sum(deviations^2) / (______)
______(variance)
sd(sleep_five)


# Exercise 8: Mean and median of age, explained with a histogram
mean(students$age, na.rm = TRUE)
______(students$age, na.rm = TRUE)
hist(students$age, breaks = 20, main = "", xlab = "Age (years)")


# Exercise 9: Where are the gaps?
# Missing values in every column of semesters, by semester.
semesters |>
  group_by(semester) |>
  summarise(across(everything(), ~ sum(______(.x)))) |>
  as.data.frame()


# Exercise 10: When one mean misleads
# Old Faithful's waiting times: the mean, a histogram, and a split into short
# and long waits at a cut-off read from the histogram.
mean(faithful$waiting)
hist(faithful$waiting, breaks = 20, main = "", xlab = "Waiting time (minutes)")
faithful |>
  mutate(type = if_else(waiting < ______, "short", "long")) |>
  group_by(type) |>
  summarise(eruptions = n(), mean_wait = mean(waiting))


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Which summary suits an ordinal variable, such as the five answers to a
#    question about money worries?
# 2. Sleep has a mean of 6.5 hours and an SD of 1.1 hours. What does the SD
#    mean in words?
# 3. Why is an outlier not simply deleted?
# 4. What is the difference between data missing at random and data missing
#    not at random?
# 5. Two variables have a correlation of 0. Does that mean they are unrelated?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: A complete "Table 1" describing the sample (percentages, mean and SD,
# or median and IQR, as each variable requires, with missing counts), and the
# paragraph describing the sample, with every number calculated by code.



# Task 2: Describe supervisor_meetings in the first semester: centre, spread,
# shape, and unusual values. Which summaries would you report?



# Task 3: Describe airquality for a report: centre, spread, and shape of ozone
# and temperature, missing data, and the relationship between the two.



# Task 4: precip gives the yearly rainfall of 70 US cities. Describe its
# distribution, name the unusual cities, and choose between mean and median.
