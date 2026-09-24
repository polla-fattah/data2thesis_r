\name{data2thesis_example}
\alias{data2thesis_example}
\title{Find the raw data files that come with the package}
\description{
The package includes the case-study data as files, so you can practise
importing them: CSV files, a messy Excel export of the survey
(\code{wellbeing_raw.xlsx}), and an SPSS file with variable and value
labels (\code{wellbeing.sav}). \code{data2thesis_example()} returns the full path
to one of these files on your computer.
}
\usage{
data2thesis_example(file = NULL)
}
\arguments{
  \item{file}{Name of a file. If \code{NULL} (the default), the names of all available files are returned.}
}
\value{
The full path to the file, or a character vector of file names when
\code{file} is \code{NULL}.
}
\examples{
# List the files
data2thesis_example()

# Read one of the CSV files
path <- data2thesis_example("students.csv")
students_from_file <- read.csv(path)
head(students_from_file)

# The Excel and SPSS files need the readxl and haven packages:
# readxl::read_excel(data2thesis_example("wellbeing_raw.xlsx"))
# haven::read_sav(data2thesis_example("wellbeing.sav"))
}
