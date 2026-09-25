# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 4: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

library(ggplot2)
library(dplyr)

students  <- read.csv("students.csv")
semesters <- read.csv("semesters.csv")
first_sem <- semesters |>
  filter(semester == 1) |>
  left_join(students, join_by(student_id))


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: a binwidth of 5 shows the shape best: a peak in the mid-twenties
# and a long tail to the right. 1 is too jagged, 10 hides the tail.
ggplot(first_sem, aes(x = study_hours)) +
  geom_histogram(binwidth = 5, colour = "white")


# Exercise 2: 307 no job, 196 part-time, 97 full-time. The colour is set
# outside aes(), so there is no legend.
students |>
  mutate(employment = factor(employment,
                             levels = c("None", "Part-time job", "Full-time job"))) |>
  ggplot(aes(x = employment)) +
  geom_bar(fill = "steelblue") +
  labs(x = "Paid work", y = "Number of students")


# Exercise 3: medians between 3.06 and 3.14; the boxes overlap almost
# completely
ggplot(first_sem, aes(x = faculty, y = gpa)) +
  geom_boxplot() +
  labs(x = "Faculty", y = "GPA in semester 1 (0 to 4)")


# Exercise 4: more caffeine, less sleep (about half an hour less per extra
# 100 mg); the graph cannot say which causes which
ggplot(first_sem, aes(x = caffeine_mg, y = sleep_hours)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm") +
  labs(x = "Caffeine per day (mg)", y = "Hours of sleep per night")


# Exercise 5
p <- ggplot(first_sem, aes(x = sleep_hours)) +
  geom_histogram(binwidth = 0.5, fill = "steelblue", colour = "white")
ggsave("sleep.png", plot = p, width = 16, height = 10, units = "cm", dpi = 300)


# Exercise 6: averages between 58.9 and 61.9, a 3-point difference. The
# redesigned strip plot is best for a thesis: honest like this bar chart, but it
# also shows that differences within faculties are far larger than between.
faculty_means <- first_sem |>
  summarise(wellbeing = mean(wellbeing), .by = faculty)

ggplot(faculty_means, aes(x = reorder(faculty, wellbeing), y = wellbeing)) +
  geom_col(fill = "grey50") +
  coord_cartesian(ylim = c(0, 100)) +
  labs(x = NULL, y = "Average wellbeing in semester 1 (0 to 100)")


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: the dot plot is easiest: positions on a common scale, which may
# be zoomed without distortion. A pie of averages makes no sense, since
# averages are not parts of a whole.
ggplot(faculty_means, aes(x = reorder(faculty, wellbeing), y = wellbeing)) +
  geom_col(fill = "grey50") +
  labs(x = NULL, y = "Average wellbeing")

ggplot(faculty_means, aes(x = wellbeing, y = reorder(faculty, wellbeing))) +
  geom_point(size = 3) +
  labs(x = "Average wellbeing", y = NULL)


# Exercise 8: zoomed (about 58 to 66), the invited group's rise in semester 2
# looks dramatic; on the full scale, the same 5 points look modest. Both are
# honest if the caption says what is shown.
wellbeing_by_sem <- semesters |>
  left_join(students, join_by(student_id)) |>
  summarise(mean_wellbeing = mean(wellbeing), .by = c(semester, workshop))

p <- ggplot(wellbeing_by_sem, aes(x = semester, y = mean_wellbeing, colour = workshop)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  labs(x = "Semester", y = "Average wellbeing (0 to 100)", colour = "Workshop")
p
p + coord_cartesian(ylim = c(0, 100))


# Exercise 9: every set has mean_y 7.50, sd_y 2.03, and r 0.82, but the four
# panels tell four different stories
anscombe_long <- tibble(
  set = rep(c("I", "II", "III", "IV"), each = 11),
  x   = c(anscombe$x1, anscombe$x2, anscombe$x3, anscombe$x4),
  y   = c(anscombe$y1, anscombe$y2, anscombe$y3, anscombe$y4)
)

anscombe_long |>
  summarise(mean_y = mean(y), sd_y = sd(y), r = cor(x, y), .by = set)

ggplot(anscombe_long, aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~ set)


# Exercise 10: a gentle rise; a weak relationship (correlation about 0.2), with
# little data at six and seven days
ggplot(first_sem, aes(x = exercise_days, y = wellbeing)) +
  geom_jitter(width = 0.2, height = 0, alpha = 0.3) +
  geom_smooth(method = "lm") +
  labs(x = "Days of exercise per week", y = "Wellbeing in semester 1 (0 to 100)")


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. People judge positions and lengths on a common scale far more accurately
#    than angles and areas.
# 2. For positions (lines, points, dots), when the reader is told. Never for
#    bars, which show values by their length.
# 3. Mapping (inside aes()) links colour to a variable and adds a legend;
#    setting (outside aes()) gives everything one fixed colour.
# 4. Categories: a qualitative palette. Quantities: a sequential palette, or a
#    diverging one around a meaningful midpoint. Not a rainbow.
# 5. Exploratory graphs are quick, many, and for the researcher, to find
#    patterns and problems. An explanatory graph is one careful figure for
#    readers, with one clear message.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 4, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
