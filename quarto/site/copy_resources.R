# Runs before each render of the website: copies the case-study data and the
# downloadable chapter projects from the repository into the site, so the
# playground can load them. The originals stay in data/ and playground/.

repo <- normalizePath(file.path("..", ".."))
# Data next to the playground pages, so exercises use read.csv("students.csv")
# exactly as the downloadable projects do
data_files <- c("students.csv", "semesters.csv")
file.copy(file.path(repo, "data", data_files), "playground", overwrite = TRUE)

zips <- list.files(file.path(repo, "playground"), pattern = "\\.zip$", full.names = TRUE)
file.copy(zips, "playground", overwrite = TRUE)

pkg <- list.files(file.path(repo, "data"), pattern = "^data2thesis_.*\\.tar\\.gz$", full.names = TRUE)
dir.create("downloads", showWarnings = FALSE)
file.copy(pkg, "downloads", overwrite = TRUE)
