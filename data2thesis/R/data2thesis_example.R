# Find the raw files that come with the package, so readers can practise
# importing them with read.csv(), readxl::read_excel() or haven::read_sav().
data2thesis_example <- function(file = NULL) {
  dir <- system.file("extdata", package = "data2thesis")
  if (is.null(file)) {
    return(list.files(dir))
  }
  path <- file.path(dir, file)
  if (!file.exists(path)) {
    stop("'", file, "' is not one of the example files. ",
         "Run data2thesis_example() to see the available files.", call. = FALSE)
  }
  path
}
