\name{supervisors}
\alias{supervisors}
\docType{data}
\title{Supervisors in the Graduate Wellbeing Study}
\description{
One row per supervisor. Students of the same supervisor tend to be more
alike, which the book uses to introduce mixed-effects models. The data is
simulated for teaching and describes no real people.
}
\usage{supervisors}
\format{
A data frame with 120 rows and 4 variables:
\describe{
  \item{supervisor_id}{Supervisor identifier, \code{SUP001} to \code{SUP120}.}
  \item{faculty}{The supervisor's faculty.}
  \item{rank}{\code{"Lecturer"}, \code{"Assistant Professor"}, or \code{"Professor"}.}
  \item{n_students}{Number of students in the study supervised (1 to 12).}
}
}
\source{Simulated by \code{data-raw/generate_wellbeing.R} in the book's repository.}
\seealso{\code{\link{students}}}
\examples{
table(supervisors$rank)
# Join each student to their supervisor's information
head(merge(students, supervisors, by = c("supervisor_id", "faculty")))
}
\keyword{datasets}
