# 01-clean-data.R
# Reads the raw survey export and writes clean tables to data/.
# Run from the project (open chapter18.Rproj first). The raw file in
# data-raw/ is never changed; everything in data/ is recreated by this script.

library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(readxl)
library(here)

raw <- read_excel(here("data-raw", "wellbeing_raw.xlsx"))

item_names <- c(paste0("stress_", 1:6), paste0("burnout_", 1:6),
                paste0("support_", 1:6), paste0("satisfaction_", 1:4))

# 1. Remove test responses and duplicates ------------------------------------
responses <- raw |>
  filter(!str_detect(str_to_upper(`Q1_Student ID`), "^TEST")) |>
  select(-`Response ID`) |>
  distinct()

# 2. Usable names ---------------------------------------------------------------
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

# 3. Consistent categories ------------------------------------------------------
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

# 4. Missing codes, numbers stored as text, impossible values -------------------
responses <- responses |>
  mutate(
    financial_worry = financial_worry |> na_if("99") |> na_if("-9") |> as.integer(),
    across(all_of(item_names), ~ as.integer(na_if(.x, "99"))),
    workshop_sessions = as.integer(workshop_sessions),
    age = parse_number(age),
    age = if_else(age > 100, NA, age)
  )

# 5. The three clean tables -----------------------------------------------------
students_clean <- responses |>
  select(student_id:considering_dropout)

questionnaire_clean <- responses |>
  select(student_id, all_of(item_names))

semesters_clean <- responses |>
  select(student_id, matches("_S[1-4]$")) |>
  pivot_longer(-student_id, names_to = c(".value", "semester"), names_sep = "_S") |>
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

# 6. Checks: look at the result before trusting it ------------------------------
stopifnot(
  nrow(students_clean) == n_distinct(students_clean$student_id),   # one row per student
  all(students_clean$gender %in% c("Female", "Male")),
  !anyNA(students_clean$faculty),
  all(semesters_clean$sleep_hours <= 24, na.rm = TRUE),
  all(semesters_clean$gpa <= 4, na.rm = TRUE)
)
students_clean |> count(faculty)
semesters_clean |> summarise(across(everything(), ~ sum(is.na(.x))))

# 7. Save ------------------------------------------------------------------------
dir.create(here("data"), showWarnings = FALSE)
write_csv(students_clean, here("data", "students.csv"))
write_csv(questionnaire_clean, here("data", "questionnaire.csv"))
write_csv(semesters_clean, here("data", "semesters.csv"))
cat("Clean data written to data/:", nrow(students_clean), "students,",
    nrow(semesters_clean), "semester records\n")
