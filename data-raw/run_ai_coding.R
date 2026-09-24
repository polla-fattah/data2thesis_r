# ------------------------------------------------------------------------------
# run_ai_coding.R
#
# Codes every open-ended answer in the Graduate Wellbeing Study with a language
# model, for Chapter 17. Run it once, by hand; the book reads the saved results,
# so rendering the book never calls a model.
#
# The book's results use a LOCAL model through Ollama (ollama.com): free, no
# API key, and the answers never leave the computer. Before running:
#   1. Install Ollama and download the model:  ollama pull gemma4:e4b
#   2. Make sure Ollama is running (its app, or `ollama serve`).
#   3. Run from the project root:  Rscript data-raw/run_ai_coding.R
# About 700 requests; with an 8 GB laptop GPU this takes about 30-40 minutes.
#
# To use an online model instead, replace chat_ollama() below with, for example,
# chat_anthropic(model = "claude-sonnet-5") or chat_openai(), after storing the
# provider's API key in .Renviron (usethis::edit_r_environ()).
#
# Output (read by book/17-ai.qmd):
#   data-raw/ai_coding_results.csv   student_id, ai_theme, ai_theme_rerun
#   data-raw/ai_coding_meta.csv      provider, model, date, versions, timing
# Afterwards, delete the folder book/_freeze/17-ai and run:
#   quarto render book/17-ai.qmd
# ------------------------------------------------------------------------------

library(ellmer)
library(data2thesis)

provider   <- "Ollama (local)"
model_name <- "gemma4:e4b"          # record exactly which model was used

themes <- c("Supervision", "Workload", "Finances", "Family", "Health",
            "Isolation", "Other")

codebook <- "
You are helping a researcher code open-ended survey answers from graduate
students, who were asked: 'What has been your biggest challenge during your
studies?' Assign each answer to exactly ONE theme: the main challenge the
student describes. If several challenges are mentioned, choose the one the
student presents first or as most important.

Themes:
- Supervision: the supervisor or supervisors; feedback, guidance, meetings,
  disagreements with or availability of the supervisor.
- Workload: too much work or too little time; deadlines, coursework, reading,
  data collection, teaching duties.
- Finances: money, fees, scholarships and funding, living costs, paid work
  taken to pay for studies.
- Family: children, partners, parents, caring duties, family obligations,
  studying at home.
- Health: physical or mental health, sleep, stress, anxiety, burnout, illness.
- Isolation: loneliness, being far from home or family, having no colleagues
  or friends to work with.
- Other: anything else, such as ethics approval, finding participants,
  learning statistics, academic English, university procedures, equipment.

Reply with the name of the theme only, exactly as written above.
"

chat <- chat_ollama(system_prompt = codebook, model = model_name,
                    params = params(temperature = 0))

# Small local models do not always follow a structured-output format, so the
# model replies with the theme name as text, and R checks the reply against the
# list of themes. A reply that is not one of the themes becomes NA and is counted.
code_answers <- function(answers) {
  replies <- parallel_chat_text(chat, as.list(answers))
  themes[match(tolower(gsub("[^A-Za-z]", "", replies)), tolower(themes))]
}

answers <- open_responses$biggest_challenge
started <- Sys.time()

# First pass: every answer
first <- code_answers(answers)

# Second pass: the 200 hand-coded answers again, to check consistency
coded_rows <- match(open_responses_coded$student_id, open_responses$student_id)
second <- code_answers(answers[coded_rows])

minutes <- as.numeric(difftime(Sys.time(), started, units = "mins"))

results <- data.frame(student_id = open_responses$student_id,
                      ai_theme = first,
                      ai_theme_rerun = NA_character_)
results$ai_theme_rerun[coded_rows] <- second
write.csv(results, file.path("data-raw", "ai_coding_results.csv"), row.names = FALSE)

ollama_version <- tryCatch(system("ollama --version", intern = TRUE)[1], error = function(e) NA)
meta <- data.frame(
  provider = provider,
  model = model_name,
  date = as.character(Sys.Date()),
  ellmer_version = as.character(packageVersion("ellmer")),
  ollama_version = ollama_version,
  temperature = 0,
  requests = length(first) + length(second),
  minutes = round(minutes, 1),
  cost_usd = 0,
  failed = sum(is.na(first)) + sum(is.na(second))
)
write.csv(meta, file.path("data-raw", "ai_coding_meta.csv"), row.names = FALSE)

print(meta)
cat("Saved data-raw/ai_coding_results.csv and data-raw/ai_coding_meta.csv\n",
    "Now delete book/_freeze/17-ai and run: quarto render book/17-ai.qmd\n")
