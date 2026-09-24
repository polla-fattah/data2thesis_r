From Data to Thesis: Research Data Analysis with R
Playground, Chapter 18: Putting It All Together

Elaf's complete project, from the raw survey export to a results chapter.

How to run it
1. Double-click chapter18.Rproj. RStudio opens with this folder as the working directory.
2. Open R/01-clean-data.R and click Source. It reads data-raw/wellbeing_raw.xlsx
   and writes clean tables to data/.
3. Open R/02-analysis.R and click Source. It fits the models and writes
   output/results.rds and output/figure-1.png.
4. Open results.qmd and click Render. It produces the results chapter as a web
   page and a Word document, with every number taken from the analysis.
Then work through exercises.txt.

The project needs these packages (install once):
install.packages(c("dplyr", "tidyr", "stringr", "readr", "readxl", "here",
                   "ggplot2", "patchwork", "lme4", "broom", "knitr", "rmarkdown"))
You also need Quarto, which is installed with RStudio.

Folders
- data-raw/   the survey export; never edit it by hand
- R/          the scripts, numbered in the order they run
- data/       clean data, created by R/01-clean-data.R
- output/     results and figures, created by R/02-analysis.R
Everything in data/ and output/ can be deleted and recreated by running the scripts.

The data is simulated for teaching and describes no real people.
Browser exercises for this chapter are at:
https://polla-fattah.github.io/R4NTR/playground/chapter18.html
