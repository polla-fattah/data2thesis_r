\name{counselling_visits}
\alias{counselling_visits}
\docType{data}
\title{Weekly visits to the university counselling service}
\description{
Weekly numbers of student visits to the university counselling service
over five academic years. In the book, the counselling doctors ask Elaf to
analyse these records as an internal analysis to help them plan staffing;
it is not part of her thesis. The series has a yearly pattern (busier
before exams, quieter in breaks and summer), a gentle upward trend, and one
unusual week. The data is simulated for teaching.
}
\usage{counselling_visits}
\format{
A data frame with 260 rows and 2 variables:
\describe{
  \item{week_start}{Date of the Monday that starts the week.}
  \item{visits}{Number of student visits that week.}
}
}
\source{Simulated by \code{data-raw/generate_wellbeing.R} in the book's repository.}
\examples{
plot(visits ~ week_start, data = counselling_visits, type = "l",
     xlab = "Week", ylab = "Visits")
}
\keyword{datasets}
