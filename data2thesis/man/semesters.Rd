\name{semesters}
\alias{semesters}
\docType{data}
\title{Semester records in the Graduate Wellbeing Study}
\description{
One row per student per semester (long format), over four semesters. Some
students left the study after year 1, so they have no rows for semesters 3
and 4. The data is simulated for teaching and describes no real people.
}
\usage{semesters}
\format{
A data frame with 2,326 rows and 9 variables:
\describe{
  \item{student_id}{Student identifier; links to \code{\link{students}}.}
  \item{semester}{Semester number, 1 to 4.}
  \item{gpa}{Semester GPA on a 0 to 4 scale.}
  \item{sleep_hours}{Average hours of sleep per night.}
  \item{study_hours}{Hours of study per week.}
  \item{exercise_days}{Days per week with at least 30 minutes of exercise.}
  \item{caffeine_mg}{Average daily caffeine in milligrams.}
  \item{supervisor_meetings}{Number of meetings with the supervisor during the semester.}
  \item{wellbeing}{Wellbeing index from 0 to 100 (higher is better).}
}
}
\source{Simulated by \code{data-raw/generate_wellbeing.R} in the book's repository.}
\seealso{\code{\link{students}}}
\examples{
head(semesters)
# Average wellbeing in each semester
aggregate(wellbeing ~ semester, data = semesters, FUN = mean)
}
\keyword{datasets}
