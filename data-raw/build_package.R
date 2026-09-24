# ------------------------------------------------------------------------------
# build_package.R
#
# Copies the generated case-study data from data/ into the data2thesis package,
# so readers can either download the files or install the package.
#
# Run from the project root, after generate_wellbeing.R:
#   Rscript data-raw/build_package.R
# Then build and check the package:
#   R CMD build data2thesis
#   R CMD check data2thesis_1.0.0.tar.gz
# ------------------------------------------------------------------------------

pkg <- "data2thesis"
dir.create(file.path(pkg, "data"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(pkg, "inst", "extdata"), recursive = TRUE, showWarnings = FALSE)

read <- function(file) {
  read.csv(file.path("data", file), stringsAsFactors = FALSE, na.strings = "",
           encoding = "UTF-8")
}

# The package data matches the CSV files exactly (character columns stay
# character), so book code works the same whichever way the data is loaded.
students             <- read("students.csv")
questionnaire        <- read("questionnaire.csv")
semesters            <- read("semesters.csv")
supervisors          <- read("supervisors.csv")
open_responses       <- read("open_responses.csv")
open_responses_coded <- read("open_responses_coded.csv")
counselling_visits   <- read("counselling_visits.csv")
counselling_visits$week_start <- as.Date(counselling_visits$week_start)

datasets <- c("students", "questionnaire", "semesters", "supervisors",
              "open_responses", "open_responses_coded", "counselling_visits")
for (d in datasets) {
  save(list = d, file = file.path(pkg, "data", paste0(d, ".rda")), compress = "xz")
}

# Raw files for the importing and cleaning chapters
extdata <- c("students.csv", "questionnaire.csv", "semesters.csv", "supervisors.csv",
             "open_responses.csv", "open_responses_coded.csv", "counselling_visits.csv",
             "wellbeing_raw.xlsx", "wellbeing.sav")
file.copy(file.path("data", extdata), file.path(pkg, "inst", "extdata"), overwrite = TRUE)

# Keep the package version in step with the dataset version
version <- readLines(file.path("data", "VERSION"))
desc <- readLines(file.path(pkg, "DESCRIPTION"))
desc <- sub("^Version: .*", paste("Version:", version), desc)
writeLines(desc, file.path(pkg, "DESCRIPTION"))

cat("data2thesis", version, "prepared:", length(datasets), "datasets,",
    length(extdata), "raw files\n")
