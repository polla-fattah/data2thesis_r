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


# Exercise 5 (needs an API key): code 20 answers with a language model
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
"
theme_type <- type_object(theme = type_enum(themes, "The single main theme of the answer."))
sample20 <- open_responses_coded |> slice(1:20)

if (Sys.getenv("ANTHROPIC_API_KEY") != "") {
  chat <- chat_anthropic(system_prompt = codebook, model = "claude-sonnet-5",
                         params = params(temperature = 0))
  ai20 <- parallel_chat_structured(chat, as.list(sample20$biggest_challenge),
                                   type = theme_type)
  sample20$ai_theme <- ai20$theme
  print(mean(sample20$ai_theme == sample20$theme))
  print(sample20 |> filter(ai_theme != theme) |> select(biggest_challenge, theme, ai_theme))
} else {
  message("No ANTHROPIC_API_KEY found: exercises 5 and 6 are skipped.")
}
# Compare the agreement with the keyword method (about 61%), and read the
# disagreements as in exercise 3. Twenty answers are few, so the share is only
# a rough guide.


# Exercise 6 (needs an API key): change the codebook
if (Sys.getenv("ANTHROPIC_API_KEY") != "") {
  codebook2 <- sub("choose the one the\nstudent presents first or as most important",
                   "choose the one the\nstudent describes in most detail", codebook)
  chat2 <- chat_anthropic(system_prompt = codebook2, model = "claude-sonnet-5",
                          params = params(temperature = 0))
  ai20b <- parallel_chat_structured(chat2, as.list(sample20$biggest_challenge),
                                    type = theme_type)
  print(sum(ai20b$theme != sample20$ai_theme))
}
# A change in one rule changes the coding of answers with two challenges.
# The codebook is part of the method, so it must be reported and kept with the
# code, just like a questionnaire.
