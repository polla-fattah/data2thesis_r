# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 4: Data Visualization
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

library(ggplot2)
library(dplyr)

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")
first_sem <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id))


# Exercise 1: Histogram of study_hours. Try binwidths of 1, 5, and 10.
ggplot(first_sem, aes(x = ______)) +
  geom_histogram(binwidth = 5)


# Exercise 2: Bar chart of employment, all bars in one colour
ggplot(students, aes(x = employment)) +
  geom_bar(______)


# Exercise 3: Box plots of GPA by faculty, labelled "Faculty" and "GPA (0 to 4)"
ggplot(first_sem, aes(x = faculty, y = gpa)) +
  geom_boxplot() +
  labs(x = ______, y = ______)


# Exercise 4: Caffeine against sleep, transparent points and a straight trend line
ggplot(first_sem, aes(x = caffeine_mg, y = sleep_hours)) +
  geom_point(alpha = ______) +
  geom_smooth(method = ______)


# Exercise 5: Density of wellbeing, one curve per study_mode
ggplot(first_sem, aes(x = wellbeing, ______)) +
  geom_density(alpha = 0.5)


# Exercise 6: Exercise 4 with one panel per programme, labels, theme_minimal()
ggplot(first_sem, aes(x = caffeine_mg, y = sleep_hours)) +
  geom_point(alpha = 0.4) +
  facet_wrap(~ ______) +
  labs(x = "Caffeine per day (mg)", y = "Sleep per night (hours)") +
  ______()


# Exercise 7: Save a figure for a journal
# Store your graph from Exercise 6 in an object called p, then save it as
# a PNG file 16 cm wide and 10 cm high, at 300 dpi.
# Open the file afterwards: is the text readable at that size?
p <- ______
ggsave("caffeine-sleep.png", plot = p, width = ______, height = ______, units = "cm", dpi = ______)
