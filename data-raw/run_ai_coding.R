# ------------------------------------------------------------------------------
# run_ai_coding.R
#
# Codes every open-ended answer in the Graduate Wellbeing Study with a language
# model, for Chapter 17. Run it ONCE, by hand; the book reads the saved results,
# so rendering the book never needs an API key.
#
# Before running:
#   1. Get an API key from the provider (here Anthropic: console.anthropic.com).
#   2. Store it in your user .Renviron file, never in this script:
#        usethis::edit_r_environ()      # add the line ANTHROPIC_API_KEY=...
#      then restart R.
#   3. Run from the project root:  Rscript data-raw/run_ai_coding.R
#
# Cost: about 700 short requests (every answer once, plus the 200 hand-coded
# answers a second time to check consistency); a few cents to about a dollar,
# depending on the model.
#
# Output (read by book/17-ai.qmd):
#   data-raw/ai_coding_results.csv   student_id, ai_theme, ai_theme_rerun
#   data-raw/ai_coding_meta.csv      model, date, ellmer version, tokens, cost
# Afterwards, re-run the chapter so it picks up the results:
#   delete the folder book/_freeze/17-ai, then  quarto render book/17-ai.qmd
# ------------------------------------------------------------------------------

library(ellmer)
library(data2thesis)

model_name <- "claude-sonnet-5"   # record exactly which model was used

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
"

theme_type <- type_object(
  theme = type_enum(themes, "The single main theme of the answer.")
)

chat <- chat_anthropic(system_prompt = codebook, model = model_name,
                       params = params(temperature = 0))

answers <- open_responses$biggest_challenge

# First pass: every answer
first <- parallel_chat_structured(chat, as.list(answers), type = theme_type,
                                  include_tokens = TRUE, include_cost = TRUE)

# Second pass: the 200 hand-coded answers again, to check consistency
coded_rows <- match(open_responses_coded$student_id, open_responses$student_id)
second <- parallel_chat_structured(chat, as.list(answers[coded_rows]), type = theme_type,
                                   include_tokens = TRUE, include_cost = TRUE)

results <- data.frame(student_id = open_responses$student_id,
                      ai_theme = first$theme,
                      ai_theme_rerun = NA_character_)
results$ai_theme_rerun[coded_rows] <- second$theme
write.csv(results, file.path("data-raw", "ai_coding_results.csv"), row.names = FALSE)

meta <- data.frame(
  model = model_name,
  date = as.character(Sys.Date()),
  ellmer_version = as.character(packageVersion("ellmer")),
  temperature = 0,
  requests = nrow(first) + nrow(second),
  input_tokens = sum(first$input_tokens, second$input_tokens, na.rm = TRUE),
  output_tokens = sum(first$output_tokens, second$output_tokens, na.rm = TRUE),
  cost_usd = sum(first$cost, second$cost, na.rm = TRUE),
  failed = sum(is.na(first$theme)) + sum(is.na(second$theme))
)
write.csv(meta, file.path("data-raw", "ai_coding_meta.csv"), row.names = FALSE)

print(meta)
cat("Saved data-raw/ai_coding_results.csv and data-raw/ai_coding_meta.csv\n",
    "Now delete book/_freeze/17-ai and run: quarto render book/17-ai.qmd\n")
