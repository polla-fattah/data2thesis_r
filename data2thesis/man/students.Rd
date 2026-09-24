\name{students}
\alias{students}
\docType{data}
\title{Students in the Graduate Wellbeing Study}
\description{
One row per student: background information collected at the start of the
study, the randomly assigned workshop group, and the answer to the end of
year 1 question about considering dropout. The data is simulated for
teaching and describes no real people.
}
\usage{students}
\format{
A data frame with 600 rows and 14 variables:
\describe{
  \item{student_id}{Student identifier, \code{S0001} to \code{S0600}.}
  \item{supervisor_id}{The student's supervisor; links to \code{\link{supervisors}}.}
  \item{age}{Age in years at the start of the study.}
  \item{gender}{\code{"Female"} or \code{"Male"}.}
  \item{faculty}{Education, Health Sciences, Humanities, Natural Sciences, or Social Sciences.}
  \item{programme}{\code{"Master's"} or \code{"PhD"}.}
  \item{study_mode}{\code{"Full-time"} or \code{"Part-time"}.}
  \item{employment}{Paid work alongside study: \code{"None"}, \code{"Part-time job"}, or \code{"Full-time job"}.}
  \item{has_children}{\code{"Yes"} or \code{"No"}.}
  \item{lives_away}{Moved away from family to study: \code{"Yes"} or \code{"No"}.}
  \item{financial_worry}{"How worried are you about money?" from 1 (not at all) to 5 (extremely).}
  \item{workshop}{Randomly invited to the wellbeing workshop: \code{"Invited"} or \code{"Not invited"}.}
  \item{workshop_sessions}{Number of the six workshop sessions attended (0 if not invited).}
  \item{considering_dropout}{At the end of year 1, "Have you seriously considered leaving your programme?": \code{"Yes"} or \code{"No"}.}
}
}
\source{Simulated by \code{data-raw/generate_wellbeing.R} in the book's repository.}
\seealso{\code{\link{questionnaire}}, \code{\link{semesters}}, \code{\link{supervisors}}}
\examples{
head(students)
table(students$faculty)
table(students$workshop, students$considering_dropout)
}
\keyword{datasets}
