# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 18: Using AI with R
#
# Four parts, as on the playground page:
#   A. Practise the chapter       the book's exercises, with blanks (______) to fill
#   B. Go further                 new exercises beyond the book
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Exercise 4 and Task 2 call a language model (see README.txt); everything else
# runs without one.
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

library(dplyr)
library(stringr)

students             <- read.csv("students.csv")
semesters            <- read.csv("semesters.csv")
open_responses       <- read.csv("open_responses.csv")
open_responses_coded <- read.csv("open_responses_coded.csv")
ai_coding            <- read.csv("ai_coding_results.csv")   # the chapter's saved model run

keywords <- c(
  Supervision = "\\b(supervis|feedback|guidance|meeting)",
  Workload    = "\\b(time|deadline|workload|too much|assignment|reading|busy)",
  Finances    = "\\b(money|fee|scholarship|rent|afford|salary|income|funding|stipend|loan)",
  Family      = "\\b(famil|child|kid|son\\b|daughter|baby|parent|mother|father|husband|wife)",
  Health      = "\\b(sleep|tired|stress|anxi|health|ill\\b|burnout|headache|coffee|exhaust)",
  Isolation   = "\\b(lonel|alone|friends|outsider|miss (home|my)|far from|know no one)",
  Other       = "\\b(ethic|participant|statistic|library|procedure|english|power cut|laptop|internet|software)"
)
themes <- names(keywords)
code_by_keywords <- function(answer, dictionary = keywords) {
  hits <- sapply(dictionary, \(pattern) str_count(str_to_lower(answer), pattern))
  if (all(hits == 0)) "Other" else names(dictionary)[which.max(hits)]
}

# Cohen's kappa by hand (yardstick's kap() gives the same)
kappa_of <- function(a, b) {
  levels <- union(a, b)
  a <- factor(a, levels)
  b <- factor(b, levels)
  observed <- mean(a == b)
  chance   <- sum(prop.table(table(a)) * prop.table(table(b)))
  (observed - chance) / (1 - chance)
}


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: Checking an assistant's code
# The suggestion for "average sleep in each faculty and semester":
semesters |>
  left_join(students, join_by(student_id)) |>
  summarise(sleep = mean(sleep_hours), .by = c(faculty, semester)) |>
  head()
mean(c(6, 7, NA))   # a tiny example with a known answer
fixed <- semesters |>
  left_join(students, join_by(student_id)) |>
  summarise(sleep = mean(sleep_hours, na.rm = ______),
            missing = sum(is.na(sleep_hours)),
            .by = c(faculty, semester))
head(fixed)


# Exercise 2: Three more keywords
check <- open_responses_coded |>
  mutate(keyword_theme = sapply(biggest_challenge, code_by_keywords))
c(agreement = mean(check$theme == check$keyword_theme),
  kappa = kappa_of(check$theme, check$keyword_theme))
new_keywords <- keywords
new_keywords["Workload"]  <- "\\b(time|deadline|workload|too much|assignment|reading|busy|thesis|work|______)"
new_keywords["Isolation"] <- "\\b(lonel|alone|friends|outsider|miss (home|my)|far from|know no one|isolat|on my own)"
check_new <- open_responses_coded |>
  mutate(keyword_theme = sapply(biggest_challenge, code_by_keywords, dictionary = new_keywords))
c(agreement = mean(check_new$theme == check_new$keyword_theme),
  kappa = kappa_of(check_new$theme, check_new$keyword_theme))


# Exercise 3: Reading the disagreements
disagreements <- check |> filter(theme ______ keyword_theme)
nrow(disagreements)
set.seed(18)
disagreements |> slice_sample(n = 10) |> select(biggest_challenge, theme, keyword_theme)


# Exercise 4: Coding 20 answers with a language model
# (needs Ollama or an API key; see README.txt)
library(ellmer)
codebook <- "
You are helping a researcher code open-ended survey answers from graduate
students, who were asked: 'What has been your biggest challenge during your
studies?' Assign each answer to exactly ONE theme: the main challenge the
student describes. If several challenges are mentioned, choose the one the
student presents first or as most important.

Themes:
- Supervision: the supervisor; feedback, guidance, meetings, disagreements.
- Workload: too much work or too little time; deadlines, coursework, reading.
- Finances: money, fees, scholarships, living costs, paid work to pay for study.
- Family: children, partners, parents, caring duties, studying at home.
- Health: physical or mental health, sleep, stress, anxiety, burnout, illness.
- Isolation: loneliness, being far from home, no colleagues or friends.
- Other: anything else, such as ethics approval, statistics, academic English.

Reply with the name of the theme only, exactly as written above.
"
use_local <- TRUE   # FALSE: an online model with an API key in .Renviron
make_chat <- function(prompt) {
  if (use_local) {
    chat_ollama(system_prompt = prompt, model = "gemma4:e4b", params = params(temperature = 0))
  } else {
    chat_anthropic(system_prompt = prompt, model = "claude-sonnet-5", params = params(temperature = 0))
  }
}
model_available <- if (use_local) {
  tryCatch({ models_ollama(); TRUE }, error = function(e) FALSE)
} else {
  Sys.getenv("ANTHROPIC_API_KEY") != ""
}
code_answers <- function(chat, answers) {
  replies <- parallel_chat_text(chat, as.list(answers))
  themes[match(tolower(gsub("[^A-Za-z]", "", replies)), tolower(themes))]
}
sample20 <- open_responses_coded |> slice(1:20)
# Code the 20 answers with code_answers(make_chat(codebook), ...) and count how
# many agree with the hand coding. Then change one theme definition in the
# codebook and code them again.

# Without a model: the chapter's saved results for the same 200 answers
model_check <- open_responses_coded |> left_join(ai_coding, join_by(student_id))
c(agreement = mean(model_check$theme == model_check$ai_theme),
  kappa     = kappa_of(model_check$theme, model_check$______))
table(hand = model_check$theme, model = model_check$ai_theme)


# Exercise 5: A methods paragraph for AI coding in a study of your own
# (write it as comments)


# Exercise 6: A coder who always says Workload
coder_a <- c(rep("Workload", 16), rep("Family", 4))
coder_b <- rep("______", 20)
c(agreement = mean(coder_a == coder_b), kappa = kappa_of(coder_a, coder_b))


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: Kappa with three themes, as Workload becomes more common
for (n_workload in c(10, 20, 40, 80)) {
  coder_a <- c(rep("Workload", n_workload), rep("Family", 6), rep("Finances", 4))
  coder_b <- c(rep("Workload", n_workload - 2), "Family", "Finances",
               rep("Family", 5), "Workload", rep("Finances", 3), "Workload")
  print(round(c(workload_answers = n_workload,
                agreement = mean(coder_a == coder_b),
                kappa = kappa_of(coder_a, ______)), 3))
}


# Exercise 8: The dictionary's most common confusion
confusion <- table(hand = check$theme, keywords = check$keyword_theme)
confusion
as.data.frame(confusion) |>
  filter(hand ______ keywords) |>
  arrange(desc(Freq)) |>
  head(3)


# Exercise 9: Long answers and short answers
lengths <- check |> mutate(words = str_count(biggest_challenge, "______"))
lengths |>
  summarise(answers = n(), mean_words = round(mean(words), 1), .by = theme) |>
  arrange(desc(mean_words))
lengths |>
  mutate(correct = theme == keyword_theme) |>
  summarise(mean_words = round(mean(words), 1), .by = correct)


# Exercise 10: Three mistakes an assistant might make
# 1. "The average age of the students"
mean(students$age)
# 2. "The number of students in the Faculty of Education"
students |> filter(faculty == "education") |> nrow()
# 3. "The percentage of part-time students in each faculty"
students |>
  count(faculty, study_mode) |>
  mutate(percent = 100 * n / sum(n)) |>
  filter(study_mode == "Part-time")


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Why can raw agreement between two coders be misleading?
# 2. What is a hallucination?
# 3. Why is a temperature of 0 used when a model codes research data?
# 4. What must be recorded so that AI coding can be reproduced and checked?
# 5. When must data not be sent to an online model?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own work
# under each task.
# ==============================================================================

# Task 1: Invent an open question and ten answers, write a codebook of four or
# five themes, code the answers yourself, have a fellow student or a model code
# them, and calculate the kappa between the two codings.



# Task 2: Change one theme definition in the codebook, code 20 hand-coded
# answers with a local model, and compare the agreement before and after.



# Task 3: Write the paragraph disclosing the use of AI in a thesis of your own.
