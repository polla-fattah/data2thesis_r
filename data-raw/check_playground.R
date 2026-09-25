# ------------------------------------------------------------------------------
# check_playground.R
#
# Runs the solutions.R of every playground chapter (or of the chapters named on
# the command line) in a fresh R process, inside a temporary folder that holds
# the chapter's data files, as the downloaded project would. Reports which
# chapters run cleanly. The numbers quoted in the explanations are checked by
# reading the output against the page.
#
# Run from the project root:
#   Rscript data-raw/check_playground.R              # every chapter
#   Rscript data-raw/check_playground.R chapter01    # one or more chapters
# ------------------------------------------------------------------------------

src_root <- "playground-src"
chapters <- commandArgs(trailingOnly = TRUE)
if (length(chapters) == 0) {
  chapters <- list.dirs(src_root, full.names = FALSE, recursive = FALSE)
}
rscript <- file.path(R.home("bin"), "Rscript")

results <- vapply(chapters, function(chapter) {
  src <- file.path(src_root, chapter)
  work <- file.path(tempdir(), paste0("check-", chapter))
  unlink(work, recursive = TRUE)
  dir.create(work, recursive = TRUE)

  # The chapter's scripts, plus its data files ("file -> folder" puts a file in
  # a subfolder, as in build_playground.R)
  file.copy(list.files(src, full.names = TRUE), work, recursive = TRUE)
  data_lines <- readLines(file.path(src, "files.txt"))
  for (line in data_lines[nzchar(trimws(data_lines))]) {
    parts <- trimws(strsplit(line, "->", fixed = TRUE)[[1]])
    target <- if (length(parts) == 2) file.path(work, parts[2]) else work
    dir.create(target, showWarnings = FALSE, recursive = TRUE)
    file.copy(file.path("data", parts[1]), target)
  }

  log <- file.path(work, "solutions.log")
  status <- system2(rscript, c("--vanilla", "-e",
                               shQuote(sprintf("setwd('%s'); source('solutions.R', echo = TRUE, max.deparse.length = Inf)",
                                               normalizePath(work, "/")))),
                    stdout = log, stderr = log)
  cat(sprintf("%-10s %s\n", chapter, if (status == 0) "ok" else "FAILED"))
  # The temporary folder disappears with this R session, so show the end of the
  # log of a failed chapter here
  if (status != 0) cat(tail(readLines(log), 20), sep = "\n")
  status == 0
}, logical(1))

if (!all(results)) quit(status = 1)
