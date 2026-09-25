# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 4: Data Visualization
#
# Four parts, as on the playground page:
#   A. Practise the chapter       the book's exercises, with blanks (______) to fill
#   B. Go further                 new exercises beyond the book
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

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

# Exercise 1: Choosing a binwidth
# Try binwidths of 1, 5, and 10. Which shows the shape best?
ggplot(first_sem, aes(x = study_hours)) +
  geom_histogram(binwidth = ______, colour = "white")


# Exercise 2: Employment in order, in one colour
# Order the levels from no job to a full-time job; one colour for all bars.
students |>
  mutate(employment = factor(employment, levels = ______)) |>
  ggplot(aes(x = employment)) +
  geom_bar(fill = ______)


# Exercise 3: GPA by faculty, with clear axis labels
ggplot(first_sem, aes(x = faculty, y = gpa)) +
  ______() +
  labs(x = "______", y = "______")


# Exercise 4: Caffeine and sleep, with a trend line
ggplot(first_sem, aes(x = caffeine_mg, y = sleep_hours)) +
  geom_point(alpha = ______) +
  geom_smooth(method = ______)


# Exercise 5: Saving a graph
# Save a graph as a PNG file, 16 cm wide and 10 cm high, at 300 dpi.
p <- ggplot(first_sem, aes(x = sleep_hours)) +
  geom_histogram(binwidth = 0.5, fill = "steelblue", colour = "white")
ggsave("sleep.png", plot = p, width = ______, height = ______,
       units = "cm", dpi = ______)


# Exercise 6: The misleading graph, redrawn
# A bar chart of wellbeing by faculty whose axis starts at zero, faculties in
# order. Which of the chapter's three versions belongs in a thesis, and why?
faculty_means <- first_sem |>
  summarise(wellbeing = mean(wellbeing), .by = faculty)

ggplot(faculty_means, aes(x = reorder(faculty, ______), y = wellbeing)) +
  geom_col(fill = "grey50") +
  coord_cartesian(ylim = c(______, 100)) +
  labs(x = NULL, y = "Average wellbeing in semester 1 (0 to 100)")


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: The same numbers three ways
# Which of the three makes the comparison easiest?
ggplot(faculty_means, aes(x = "", y = wellbeing, fill = faculty)) +
  geom_col(width = 1, colour = "white") +
  coord_polar(theta = "y") +
  theme_void()

ggplot(faculty_means, aes(x = reorder(faculty, wellbeing), y = wellbeing)) +
  ______(fill = "grey50") +
  labs(x = NULL, y = "Average wellbeing")

ggplot(faculty_means, aes(x = wellbeing, y = reorder(faculty, wellbeing))) +
  ______(size = 3) +
  labs(x = "Average wellbeing", y = NULL)


# Exercise 8: A line chart, zoomed and not
# Draw it as ggplot2 does and with the y axis from 0 to 100; write a caption
# for each.
wellbeing_by_sem <- semesters |>
  left_join(students, join_by(student_id)) |>
  summarise(mean_wellbeing = mean(wellbeing), .by = c(semester, workshop))

p <- ggplot(wellbeing_by_sem, aes(x = semester, y = mean_wellbeing, colour = workshop)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  labs(x = "Semester", y = "Average wellbeing (0 to 100)", colour = "Workshop")
p
p + coord_cartesian(ylim = c(______, ______))


# Exercise 9: Anscombe's quartet yourself
anscombe_long <- tibble(
  set = rep(c("I", "II", "III", "IV"), each = 11),
  x   = c(anscombe$x1, anscombe$x2, anscombe$x3, anscombe$x4),
  y   = c(anscombe$y1, anscombe$y2, anscombe$y3, anscombe$y4)
)

anscombe_long |>
  summarise(mean_y = mean(y), sd_y = sd(y), r = ______(x, y), .by = set)

ggplot(anscombe_long, aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  ______(~ set)


# Exercise 10: Exercise and wellbeing
# Exercise days take only the values 0 to 7: spread the points sideways, make
# them transparent, and add a trend line.
ggplot(first_sem, aes(x = exercise_days, y = wellbeing)) +
  ______(width = 0.2, height = 0, alpha = 0.3) +
  geom_smooth(method = "lm") +
  labs(x = "Days of exercise per week", y = "Wellbeing in semester 1 (0 to 100)")


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Why do researchers prefer a bar chart or dot plot to a pie chart?
# 2. When is a y axis that does not start at zero acceptable?
# 3. What is the difference between mapping a colour and setting a colour?
# 4. Which kind of palette suits categories, and which suits quantities?
# 5. What is an exploratory graph for, and how does it differ from an
#    explanatory graph?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Choose a question about two variables of the study that the chapter
# did not graph. Choose the graph with the chapter's table of graphs, make an
# explanatory version ready for a thesis, and write its caption.



# Task 2: The code below draws a deliberately poor graph. Improve it, and write
# down each change you made and why.
first_sem |>
  summarise(sleep = mean(sleep_hours, na.rm = TRUE), .by = faculty) |>
  ggplot(aes(x = faculty, y = sleep, fill = faculty)) +
  geom_col() +
  coord_cartesian(ylim = c(6.3, 6.7))



# Task 3: R's built-in ChickWeight data records the weight of 50 chicks on four
# diets, from birth to day 21. Make a figure for a report that shows how weight
# grows over time on each diet, and write its caption.



# Task 4: ggplot2's mpg data records the fuel economy of 234 cars. Make three
# quick exploratory graphs of engine size (displ) against motorway fuel economy
# (hwy), then turn the most informative one into an explanatory graph.



# Task 5: Save your figure from Task 3 as a PDF file 16 cm wide and 10 cm high,
# and as a PNG at 300 dpi, and compare the two files when you zoom in.
