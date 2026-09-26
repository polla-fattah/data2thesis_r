# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 18: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open. Exercise 4 calls a
# language model only if one is available; otherwise it is skipped.

library(dplyr)
library(stringr)

students             <- read.csv("students.csv")
semesters            <- read.csv("semesters.csv")
open_responses       <- read.csv("open_responses.csv")
open_responses_coded <- read.csv("open_responses_coded.csv")
ai_coding            <- read.csv("ai_coding_results.csv")

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

# Exercise 1: without na.rm, 13 of the 20 averages are NA; with it, every group
# has an average (Education, semester 1: 6.64 hours)
semesters |>
  left_join(students, join_by(student_id)) |>
  summarise(sleep = mean(sleep_hours), .by = c(faculty, semester)) |>
  head()
mean(c(6, 7, NA))
fixed <- semesters |>
  left_join(students, join_by(student_id)) |>
  summarise(sleep = mean(sleep_hours, na.rm = TRUE),
            missing = sum(is.na(sleep_hours)),
            .by = c(faculty, semester))
head(fixed)


# Exercise 2: 61% agreement (kappa 0.51) before, 61.5% (kappa 0.51) after:
# every new word fixes some answers and breaks others; tuning on these 200
# answers is overfitting
check <- open_responses_coded |>
  mutate(keyword_theme = sapply(biggest_challenge, code_by_keywords))
c(agreement = mean(check$theme == check$keyword_theme),
  kappa = kappa_of(check$theme, check$keyword_theme))
new_keywords <- keywords
new_keywords["Workload"]  <- "\\b(time|deadline|workload|too much|assignment|reading|busy|thesis|work|course)"
new_keywords["Isolation"] <- "\\b(lonel|alone|friends|outsider|miss (home|my)|far from|know no one|isolat|on my own)"
check_new <- open_responses_coded |>
  mutate(keyword_theme = sapply(biggest_challenge, code_by_keywords, dictionary = new_keywords))
c(agreement = mean(check_new$theme == check_new$keyword_theme),
  kappa = kappa_of(check_new$theme, check_new$keyword_theme))


# Exercise 3: 78 disagreements; in most, the hand coding is clearly right, and a
# few answers are genuinely ambiguous
disagreements <- check |> filter(theme != keyword_theme)
nrow(disagreements)
set.seed(18)
disagreements |> slice_sample(n = 10) |> select(biggest_challenge, theme, keyword_theme)


# Exercise 4: the saved run agrees on 90% (kappa 0.87); with a live model, count
# the agreement on 20 answers, then change a theme definition and code again
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
use_local <- TRUE
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

if (model_available) {
  sample20$ai_theme <- code_answers(make_chat(codebook), sample20$biggest_challenge)
  print(sum(sample20$ai_theme == sample20$theme, na.rm = TRUE))
  # A changed definition: Workload now also covers paid work
  codebook2 <- sub("- Workload: too much work or too little time; deadlines, coursework, reading.",
                   "- Workload: too much work or too little time, including paid work; deadlines, coursework, reading.",
                   codebook, fixed = TRUE)
  second_try <- code_answers(make_chat(codebook2), sample20$biggest_challenge)
  print(sum(second_try == sample20$theme, na.rm = TRUE))
} else {
  message("No model available (start Ollama, or set an API key): the live part of exercise 4 is skipped.")
}

model_check <- open_responses_coded |> left_join(ai_coding, join_by(student_id))
c(agreement = mean(model_check$theme == model_check$ai_theme),
  kappa     = kappa_of(model_check$theme, model_check$ai_theme))
table(hand = model_check$theme, model = model_check$ai_theme)


# Exercise 5 (model answer): name the codebook, the hand-coded sample, the model
# and its settings (version, local or online, temperature 0), the validation
# (kappa against the hand coding, disagreements read), a rerun for stability,
# how the data was protected, and where prompts and replies are kept.


# Exercise 6: agreement 80%, kappa exactly 0: agreeing only by always choosing
# the most common theme is chance agreement
coder_a <- c(rep("Workload", 16), rep("Family", 4))
coder_b <- rep("Workload", 20)
c(agreement = mean(coder_a == coder_b), kappa = kappa_of(coder_a, coder_b))


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

# Exercise 7: agreement 0.80 -> 0.96, kappa only 0.68 -> 0.78, as a common
# theme adds chance agreement
for (n_workload in c(10, 20, 40, 80)) {
  coder_a <- c(rep("Workload", n_workload), rep("Family", 6), rep("Finances", 4))
  coder_b <- c(rep("Workload", n_workload - 2), "Family", "Finances",
               rep("Family", 5), "Workload", rep("Finances", 3), "Workload")
  print(round(c(workload_answers = n_workload,
                agreement = mean(coder_a == coder_b),
                kappa = kappa_of(coder_a, coder_b)), 3))
}


# Exercise 8: Workload coded as Other (10), Isolation as Supervision (8) and
# as Other (6); Isolation is handled worst (8 of 31 correct)
confusion <- table(hand = check$theme, keywords = check$keyword_theme)
confusion
as.data.frame(confusion) |>
  filter(hand != keywords) |>
  arrange(desc(Freq)) |>
  head(3)


# Exercise 9: Supervision answers longest (21 words), Isolation shortest (15);
# wrongly coded answers are longer (20 against 17 words)
lengths <- check |> mutate(words = str_count(biggest_challenge, "\\S+"))
lengths |>
  summarise(answers = n(), mean_words = round(mean(words), 1), .by = theme) |>
  arrange(desc(mean_words))
lengths |>
  mutate(correct = theme == keyword_theme) |>
  summarise(mean_words = round(mean(words), 1), .by = correct)


# Exercise 10: 1. a missing value (na.rm = TRUE: 29.7); 2. the spelling of the
# category ("Education": 148); 3. a silent logic error (.by = faculty)
mean(students$age, na.rm = TRUE)
students |> filter(faculty == "Education") |> nrow()
students |>
  count(faculty, study_mode) |>
  mutate(percent = 100 * n / sum(n), .by = faculty) |>
  filter(study_mode == "Part-time")


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. Some agreement happens by chance, and it is high when one theme is common;
#    kappa subtracts it.
# 2. A confident, fluent answer that is false: an invented function, argument,
#    reference, or fact. Found by checking.
# 3. At temperature 0 the model always gives its most likely answer, so the
#    coding is consistent and reproducible.
# 4. Provider, model and version, date, settings, the full prompt and codebook,
#    software versions, and the replies themselves, saved to a file.
# 5. When it could identify participants or is confidential, unless ethics
#    approval, consent, and university rules allow it; a local model avoids it.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open.
# ==============================================================================
