# ------------------------------------------------------------------------------
# build_playground.R
#
# Builds the downloadable project for each playground chapter:
# playground-src/chapterNN/ (scripts, README, .Rproj, and files.txt listing the
# data files it needs) becomes site/playground/chapterNN.zip, with the data copied
# in from data/.
#
# Run from the project root, after generate_wellbeing.R:
#   Rscript data-raw/build_playground.R
# ------------------------------------------------------------------------------

src_root <- "playground-src"
out_root <- file.path("site", "playground")

chapters <- list.dirs(src_root, full.names = FALSE, recursive = FALSE)

for (chapter in chapters) {
  src <- file.path(src_root, chapter)
  staging <- file.path(tempdir(), chapter)
  unlink(staging, recursive = TRUE)
  dir.create(staging, recursive = TRUE)

  # Project files and folders (everything except the list of data files)
  project_files <- setdiff(list.files(src), "files.txt")
  file.copy(file.path(src, project_files), staging, recursive = TRUE)

  # Data files the chapter needs; a line "file -> folder" puts a file in a subfolder
  data_lines <- readLines(file.path(src, "files.txt"))
  data_lines <- data_lines[nzchar(trimws(data_lines))]
  parts <- strsplit(data_lines, "->", fixed = TRUE)
  data_files <- trimws(vapply(parts, `[`, character(1), 1))
  folders <- vapply(parts, function(p) if (length(p) > 1) trimws(p[2]) else ".", character(1))
  for (folder in unique(folders)) {
    dir.create(file.path(staging, folder), recursive = TRUE, showWarnings = FALSE)
  }
  ok <- mapply(function(file, folder) file.copy(file.path("data", file), file.path(staging, folder)),
               data_files, folders)
  if (!all(ok)) stop("Missing data file(s): ", paste(data_files[!ok], collapse = ", "))

  # Zip with the chapter folder at the top level, so unzipping gives one folder
  zipfile <- normalizePath(file.path(out_root, paste0(chapter, ".zip")), mustWork = FALSE)
  unlink(zipfile)
  old <- setwd(tempdir())
  utils::zip(zipfile, files = chapter, flags = "-r9Xq")
  setwd(old)

  cat(chapter, ":", length(project_files), "project files +",
      length(data_files), "data files ->", file.path(out_root, basename(zipfile)), "\n")
}
