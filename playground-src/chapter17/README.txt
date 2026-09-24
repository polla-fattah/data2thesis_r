From Data to Thesis: Research Data Analysis with R
Playground, Chapter 17: Using AI with R

How to use this project
1. Double-click chapter17.Rproj. RStudio opens with this folder as the working directory.
2. Open exercises.R and work through the exercises. Run a line with Ctrl+Enter.
3. Check your answers in solutions.R, after you have tried each exercise yourself.

The exercises need these packages (install once):
install.packages(c("dplyr", "stringr", "yardstick", "ellmer", "usethis"))

Exercises 1 to 4 work without an API key. Exercises 5 and 6 call a language
model, which needs your own API key and costs a few cents:
- Create a key with a provider (for example Anthropic or OpenAI).
- Run usethis::edit_r_environ(), add a line such as ANTHROPIC_API_KEY=your-key,
  save the file, and restart R. Never put the key in a script.
- Remember the rules of Chapter 17: this is simulated data, but real research
  data may only be sent to an AI service if your ethics approval allows it.

Files
- exercises.R               the exercises, with starter code
- solutions.R               one possible solution for each exercise
- students.csv              one row per student in Elaf's study (600 students)
- open_responses.csv        the students' answers to the open question
- open_responses_coded.csv  200 answers hand-coded by Elaf into seven themes

The data is simulated for teaching and describes no real people.
Browser exercises for this chapter are at:
https://polla-fattah.github.io/R4NTR/playground/chapter17.html
