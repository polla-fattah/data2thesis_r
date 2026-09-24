# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 4: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

library(ggplot2)
library(dplyr)

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")
first_sem <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id))


# Exercise 1: a binwidth of about 5 hours shows the shape best
ggplot(first_sem, aes(x = study_hours)) +
  geom_histogram(binwidth = 5)


# Exercise 2: a fixed colour is set outside aes()
ggplot(students, aes(x = employment)) +
  geom_bar(fill = "darkorange")


# Exercise 3
ggplot(first_sem, aes(x = faculty, y = gpa)) +
  geom_boxplot() +
  labs(x = "Faculty", y = "GPA (0 to 4)")


# Exercise 4: students who take more caffeine sleep less
ggplot(first_sem, aes(x = caffeine_mg, y = sleep_hours)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm")


# Exercise 5: colour that depends on a variable is mapped inside aes()
ggplot(first_sem, aes(x = wellbeing, fill = study_mode)) +
  geom_density(alpha = 0.5)


# Exercise 6
ggplot(first_sem, aes(x = caffeine_mg, y = sleep_hours)) +
  geom_point(alpha = 0.4) +
  facet_wrap(~ programme) +
  labs(x = "Caffeine per day (mg)", y = "Sleep per night (hours)") +
  theme_minimal()


# Exercise 7
p <- ggplot(first_sem, aes(x = caffeine_mg, y = sleep_hours)) +
  geom_point(alpha = 0.4) +
  facet_wrap(~ programme) +
  labs(x = "Caffeine per day (mg)", y = "Sleep per night (hours)") +
  theme_minimal(base_size = 12)
ggsave("caffeine-sleep.png", plot = p, width = 16, height = 10, units = "cm", dpi = 300)
