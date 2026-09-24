\name{questionnaire}
\alias{questionnaire}
\docType{data}
\title{Baseline questionnaire in the Graduate Wellbeing Study}
\description{
Answers to a 22-item questionnaire given at the start of the study. The
items measure four scales: stress, burnout, supervisor support, and
academic satisfaction. The wording was written for the book. The data is
simulated for teaching and describes no real people.
}
\usage{questionnaire}
\format{
A data frame with 600 rows and 23 variables. Each item is answered from 1
(strongly disagree) to 5 (strongly agree); about 2 percent of answers are
missing (\code{NA}).
\describe{
  \item{student_id}{Student identifier; links to \code{\link{students}}.}
  \item{stress_1}{I feel unable to control important things in my studies.}
  \item{stress_2}{I feel nervous and stressed about my studies.}
  \item{stress_3}{I feel that difficulties in my studies are piling up.}
  \item{stress_4}{I feel confident handling problems in my studies. (Reverse-worded.)}
  \item{stress_5}{I feel overwhelmed by what I have to do.}
  \item{stress_6}{I find it hard to relax because of my studies.}
  \item{burnout_1}{I feel emotionally drained by my studies.}
  \item{burnout_2}{I feel exhausted when I think about my thesis.}
  \item{burnout_3}{Deadlines make me feel overwhelmed.}
  \item{burnout_4}{I have become less interested in my research.}
  \item{burnout_5}{I doubt the value of my studies.}
  \item{burnout_6}{I feel used up at the end of a study day.}
  \item{support_1}{My supervisor gives me useful feedback.}
  \item{support_2}{My supervisor is available when I need help.}
  \item{support_3}{My supervisor cares about my wellbeing.}
  \item{support_4}{My supervisor helps me plan my work.}
  \item{support_5}{I can discuss problems openly with my supervisor.}
  \item{support_6}{My supervisor encourages me when I struggle.}
  \item{satisfaction_1}{I am satisfied with my progress in my programme.}
  \item{satisfaction_2}{I enjoy my studies.}
  \item{satisfaction_3}{My programme meets my expectations.}
  \item{satisfaction_4}{I would choose this programme again.}
}
}
\details{
The four scales are stress (\code{stress_1} to \code{stress_6}), burnout
(\code{burnout_1} to \code{burnout_6}), supervisor support
(\code{support_1} to \code{support_6}), and academic satisfaction
(\code{satisfaction_1} to \code{satisfaction_4}).

\code{stress_4} is reverse-worded: reverse it (\code{6 - stress_4}) before
averaging the stress items. \code{burnout_3} also relates to stress.
}
\source{Simulated by \code{data-raw/generate_wellbeing.R} in the book's repository.}
\seealso{\code{\link{students}}}
\examples{
# Average of the stress items, after reversing stress_4
q <- questionnaire
q$stress_4 <- 6 - q$stress_4
stress_items <- paste0("stress_", 1:6)
q$stress_score <- rowMeans(q[stress_items], na.rm = TRUE)
summary(q$stress_score)
}
\keyword{datasets}
