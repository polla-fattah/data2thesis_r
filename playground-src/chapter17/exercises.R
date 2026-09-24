# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 17: Using AI with R
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

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
# An assistant suggested this for "average sleep in each faculty". Does it
# handle missing values? Check it with a tiny example first.
tiny <- data.frame(faculty = c("A", "A", "B"), sleep = c(6, NA, 8))
tiny |> summarise(sleep = mean(sleep), .by = faculty)
# Fix it so that faculty A gets 6:
tiny |> summarise(sleep = mean(sleep, ______), .by = faculty)


# Exercise 2: Keyword coding and agreement
keyword_check <- open_responses_coded |>
  mutate(keyword_theme = sapply(biggest_challenge, code_by_keywords),
         theme = factor(theme, levels = themes),
         keyword_theme = factor(keyword_theme, levels = themes))
keyword_check |> accuracy(truth = theme, estimate = ______)
keyword_check |> kap(truth = theme, estimate = keyword_theme)


# Exercise 3: Read the disagreements
# Show ten answers where the keywords and Elaf disagree. Would you agree with
# Elaf in every case?


# Exercise 4: The confusion matrix
# Which theme do the keywords find most reliably? Which do they miss most often?


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
# Create a chat with chat_anthropic() (or chat_openai()), with the codebook as
# the system prompt and temperature 0, then code the 20 answers with
# parallel_chat_structured(). How many agree with Elaf?


# Exercise 6 (needs an API key): change the codebook
# Change the rule for answers with two challenges (for example, "choose the
# challenge the student describes in most detail") and code the 20 answers
# again. How many answers change theme?
