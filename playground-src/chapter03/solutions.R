# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 3: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

library(dplyr)
library(tidyr)
library(stringr)
library(readr)

students    <- read.csv("students.csv")
semesters   <- read.csv("semesters.csv")
supervisors <- read.csv("supervisors.csv")


# Exercise 1
c(6.5, 7, 5.5, 8, 6) |> mean() |> round(1)


# Exercise 2
students |>
  summarise(mean_age = mean(age, na.rm = TRUE), .by = faculty) |>
  arrange(desc(mean_age))


# Exercise 3
semesters |>
  mutate(sleep_group = case_when(
    sleep_hours < 6 ~ "Short",
    sleep_hours >= 7 ~ "Recommended",
    .default = "Moderate"
  )) |>
  count(sleep_group)


# Exercise 4
semesters |>
  select(student_id, semester, gpa) |>
  pivot_wider(names_from = semester, values_from = gpa) |>
  head()


# Exercise 5
semesters |>
  left_join(students, join_by(student_id)) |>
  summarise(mean_gpa = mean(gpa, na.rm = TRUE), .by = study_mode)


# Exercise 6
students |>
  anti_join(semesters |> filter(semester == 4), join_by(student_id)) |>
  nrow()


# Exercise 7
messy <- tibble(
  gender = c("F", "female", "Male", "m", "Female"),
  stress = c("3", "99", "4", "2", "5")
)
clean <- messy |>
  mutate(
    gender = if_else(str_starts(str_to_lower(gender), "f"), "Female", "Male"),
    stress = as.integer(na_if(stress, "99"))
  )
clean
mean(clean$stress, na.rm = TRUE)   # 3.5 (with the 99 left in, it would be 22.6)


# Exercise 8: Clean Elaf's full survey export -----------------------------------

library(readxl)
raw <- read_excel("wellbeing_raw.xlsx")

# 2. Remove test responses and duplicates
responses <- raw |>
  filter(!str_detect(str_to_upper(`Q1_Student ID`), "^TEST")) |>
  select(-`Response ID`) |>
  distinct()

# 3. Rename the variables
item_names <- c(paste0("stress_", 1:6), paste0("burnout_", 1:6),
                paste0("support_", 1:6), paste0("satisfaction_", 1:4))
responses <- responses |>
  rename(
    student_id          = `Q1_Student ID`,
    age                 = Q2_Age,
    gender              = Q3_Gender,
    faculty             = Q4_Faculty,
    programme           = Q5_Programme,
    study_mode          = `Q6_Study mode`,
    employment          = `Q7_Paid work`,
    has_children        = Q8_Children,
    lives_away          = `Q9_Moved away from family`,
    financial_worry     = `Q10_How worried are you about money? (1-5)`,
    workshop            = `Workshop group`,
    workshop_sessions   = `Workshop sessions attended`,
    considering_dropout = `Y1_Considered leaving?`
  ) |>
  rename_with(~ item_names, .cols = Q11_1:Q11_22)

# 4. Fix the inconsistent categories
responses <- responses |>
  mutate(
    gender = if_else(str_starts(str_to_lower(str_trim(gender)), "f"), "Female", "Male"),
    faculty = case_when(
      str_detect(str_to_lower(faculty), "educ")    ~ "Education",
      str_detect(str_to_lower(faculty), "health")  ~ "Health Sciences",
      str_detect(str_to_lower(faculty), "humanit") ~ "Humanities",
      str_detect(str_to_lower(faculty), "social")  ~ "Social Sciences",
      str_detect(str_to_lower(faculty), "natural|^sciences$") ~ "Natural Sciences"
    ),
    programme  = if_else(str_detect(str_to_lower(programme), "ph"), "PhD", "Master's"),
    study_mode = if_else(str_detect(str_to_lower(study_mode), "part"), "Part-time", "Full-time"),
    employment = if_else(str_to_lower(employment) %in% c("none", "no job"), "None", employment),
    across(c(has_children, lives_away, considering_dropout),
           ~ if_else(str_starts(str_to_lower(.x), "y"), "Yes", "No"))
  )

# 5. Missing codes and text to numbers; 6. impossible values
responses <- responses |>
  mutate(
    financial_worry = financial_worry |> na_if("99") |> na_if("-9") |> as.integer(),
    across(all_of(item_names), ~ as.integer(na_if(.x, "99"))),
    workshop_sessions = as.integer(workshop_sessions),
    age = parse_number(age),
    age = if_else(age > 100, NA, age)
  )

# 7. Scale scores (reverse stress_4 first)
scores <- responses |>
  select(student_id, all_of(item_names)) |>
  mutate(
    stress_4           = 6 - stress_4,
    stress_score       = rowMeans(pick(stress_1:stress_6), na.rm = TRUE),
    burnout_score      = rowMeans(pick(burnout_1:burnout_6), na.rm = TRUE),
    support_score      = rowMeans(pick(support_1:support_6), na.rm = TRUE),
    satisfaction_score = rowMeans(pick(satisfaction_1:satisfaction_4), na.rm = TRUE)
  ) |>
  select(student_id, ends_with("_score"))

# 8. Semester measurements from wide to long
semesters_clean <- responses |>
  select(student_id, matches("_S[1-4]$")) |>
  pivot_longer(cols = -student_id, names_to = c(".value", "semester"), names_sep = "_S") |>
  rename(gpa = GPA, sleep_hours = Sleep, study_hours = Study,
         exercise_days = Exercise, caffeine_mg = Caffeine,
         supervisor_meetings = Meetings, wellbeing = Wellbeing) |>
  mutate(
    semester    = as.integer(semester),
    sleep_hours = parse_number(str_replace(sleep_hours, ",", ".")),
    across(c(gpa, study_hours, exercise_days, caffeine_mg, supervisor_meetings, wellbeing),
           parse_number),
    sleep_hours = if_else(sleep_hours > 24, NA, sleep_hours),
    study_hours = if_else(study_hours > 168, NA, study_hours),
    gpa         = if_else(gpa > 4, NA, gpa)
  ) |>
  filter(!if_all(gpa:wellbeing, is.na))

# Checks
nrow(responses)        # 600 students
nrow(semesters_clean)  # 2,326 semester records
head(scores)
