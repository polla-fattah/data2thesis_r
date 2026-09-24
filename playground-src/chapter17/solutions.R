# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 17: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

library(dplyr)
library(stringr)
library(yardstick)

students             <- read.csv("students.csv")
open_responses       <- read.csv("open_responses.csv")
open_responses_coded <- read.csv("open_responses_coded.csv")

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

code_by_keywords <- function(answer) {
  hits <- sapply(keywords, \(pattern) str_count(str_to_lower(answer), pattern))
  if (all(hits == 0)) "Other" else names(keywords)[which.max(hits)]
}


# Exercise 1: Check an assistant's code
tiny <- data.frame(faculty = c("A", "A", "B"), sleep = c(6, NA, 8))
tiny |> summarise(sleep = mean(sleep), .by = faculty)
tiny |> summarise(sleep = mean(sleep, na.rm = TRUE), .by = faculty)
# Without na.rm = TRUE, one missing value makes the whole faculty's mean NA.
# The tiny example shows it at once; in 600 students it might go unnoticed.


# Exercise 2: Keyword coding and agreement
keyword_check <- open_responses_coded |>
  mutate(keyword_theme = sapply(biggest_challenge, code_by_keywords),
         theme = factor(theme, levels = themes),
         keyword_theme = factor(keyword_theme, levels = themes))
keyword_check |> accuracy(truth = theme, estimate = keyword_theme)
keyword_check |> kap(truth = theme, estimate = keyword_theme)
# About 61% agreement and a kappa of about 0.51: moderate.


# Exercise 3: Read the disagreements
keyword_check |>
  filter(theme != keyword_theme) |>
  select(biggest_challenge, theme, keyword_theme) |>
  head(10)
# Most disagreements are answers whose words point to one theme while the
# meaning points to another, or answers that mention two challenges. A few
# could reasonably be coded either way: coding always involves judgement.


# Exercise 4: The confusion matrix
keyword_check |> conf_mat(truth = theme, estimate = keyword_theme)
# Supervision and Finances, which have distinctive words, are found most
# reliably (about 80% of each). Isolation is missed most often: loneliness is described in many ways, and few of them
# contain the dictionary's words.


# Exercise 5 (needs Ollama or an API key): code 20 answers with a language model
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

# A local model through Ollama (free, no key; see README.txt), or set
# use_local <- FALSE to use an online model with an API key in .Renviron.
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

# Ask for the theme name as text, and check each reply against the list of themes
code_answers <- function(chat, answers) {
  replies <- parallel_chat_text(chat, as.list(answers))
  themes[match(tolower(gsub("[^A-Za-z]", "", replies)), tolower(themes))]
}
sample20 <- open_responses_coded |> slice(1:20)

if (model_available) {
  sample20$ai_theme <- code_answers(make_chat(codebook), sample20$biggest_challenge)
  print(mean(sample20$ai_theme == sample20$theme, na.rm = TRUE))
  print(sample20 |> filter(ai_theme != theme) |> select(biggest_challenge, theme, ai_theme))
} else {
  message("No model available (start Ollama, or set an API key): exercises 5 and 6 are skipped.")
}
# Compare the agreement with the keyword method (about 61%), and read the
# disagreements as in exercise 3. Twenty answers are few, so the share is only
# a rough guide.


# Exercise 6 (needs Ollama or an API key): change the codebook
if (model_available) {
  codebook2 <- sub("choose the one the\nstudent presents first or as most important",
                   "choose the one the\nstudent describes in most detail", codebook)
  second_try <- code_answers(make_chat(codebook2), sample20$biggest_challenge)
  print(sum(second_try != sample20$ai_theme, na.rm = TRUE))
}
# Count how many answers change theme. With the local model and these 20
# answers, none did: the model reads the same answers the same way under either
# rule. A rule that makes no difference is also worth knowing; try it on all 200
# hand-coded answers, where more answers mention two challenges. Either way, the
# codebook is part of the method, so it must be reported and kept with the code,
# just like a questionnaire.
