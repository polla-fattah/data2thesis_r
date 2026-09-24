\name{open_responses}
\alias{open_responses}
\alias{open_responses_coded}
\docType{data}
\title{Open-ended answers in the Graduate Wellbeing Study}
\description{
Answers to the final-survey question "What has been your biggest challenge
during your studies?". \code{open_responses_coded} is a subset of 200
answers with a theme assigned by hand, used to check how well an AI tool
codes the answers. The data is simulated for teaching and describes no
real people.
}
\usage{
open_responses

open_responses_coded
}
\format{
\code{open_responses} is a data frame with 535 rows and 2 variables;
\code{open_responses_coded} has 200 rows and 3 variables:
\describe{
  \item{student_id}{Student identifier; links to \code{\link{students}}.}
  \item{biggest_challenge}{The answer, in the student's own words.}
  \item{theme}{(coded subset only) Supervision, Workload, Finances, Family, Health, Isolation, or Other.}
}
}
\source{Simulated by \code{data-raw/generate_wellbeing.R} in the book's repository.}
\examples{
head(open_responses$biggest_challenge)
table(open_responses_coded$theme)
}
\keyword{datasets}
