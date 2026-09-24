# ------------------------------------------------------------------------------
# check_wellbeing.R
#
# Confirms that the generated Graduate Wellbeing Study contains the effects the
# specification promises (data/specification.md, section 5). Each check runs
# the analysis a chapter will run and compares the result with its target.
# If a check fails, adjust the generator, not the book.
#
# Run from the project root, after generate_wellbeing.R:
#   Rscript data-raw/check_wellbeing.R
# ------------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(psych)
  library(lme4)
  library(haven)
  library(readxl)
})

read <- function(file) read.csv(file.path("data", file), stringsAsFactors = FALSE)
students      <- read("students.csv")
questionnaire <- read("questionnaire.csv")
semesters     <- read("semesters.csv")
supervisors   <- read("supervisors.csv")
open_resp     <- read("open_responses.csv")
open_coded    <- read("open_responses_coded.csv")
visits        <- read("counselling_visits.csv")
truth         <- readRDS("data-raw/truth.rds")

results <- data.frame(section = character(), check = character(),
                      value = character(), target = character(), ok = logical())
check <- function(section, name, value, ok, target) {
  shown <- if (is.numeric(value)) format(round(value, 3), nsmall = 3) else as.character(value)
  results[nrow(results) + 1, ] <<- list(section, name, shown, target, isTRUE(ok))
}
between <- function(x, lo, hi) !is.na(x) && x >= lo && x <= hi

# Scale scores, as readers will compute them in Chapter 3 ----------------------

q <- questionnaire
q$stress_4 <- 6 - q$stress_4
scale_items <- function(prefix) grep(paste0("^", prefix, "_[0-9]+$"), names(q), value = TRUE)
for (s in c("stress", "burnout", "support", "satisfaction")) {
  q[[paste0(s, "_score")]] <- rowMeans(q[scale_items(s)], na.rm = TRUE)
}
d <- merge(students, q[c("student_id", grep("_score$", names(q), value = TRUE))],
           by = "student_id")
s1 <- merge(d, semesters[semesters$semester == 1, ], by = "student_id")
s2 <- merge(d, semesters[semesters$semester == 2, ], by = "student_id")

# Sizes -------------------------------------------------------------------------

check("Sizes", "students", nrow(students), nrow(students) == 600, "600")
check("Sizes", "semester rows", nrow(semesters), between(nrow(semesters), 2290, 2370), "about 2,330")
check("Sizes", "supervisors", nrow(supervisors), nrow(supervisors) == 120, "120")
check("Sizes", "max students per supervisor", max(supervisors$n_students),
      max(supervisors$n_students) <= 12 && min(supervisors$n_students) >= 1, "1-12")
check("Sizes", "open responses", nrow(open_resp), between(nrow(open_resp), 510, 570), "about 540")
check("Sizes", "hand-coded responses", nrow(open_coded), nrow(open_coded) == 200, "200")
check("Sizes", "counselling weeks", nrow(visits), nrow(visits) == 260, "260")

# 5.1 Descriptive picture --------------------------------------------------------

sl <- semesters$sleep_hours
check("5.1", "mean sleep (hours)", mean(sl, na.rm = TRUE), between(mean(sl, na.rm = TRUE), 6.2, 6.6), "about 6.4")
check("5.1", "SD of sleep", sd(sl, na.rm = TRUE), between(sd(sl, na.rm = TRUE), 0.8, 1.2), "about 1.0")
skew_caff <- psych::skew(semesters$caffeine_mg, na.rm = TRUE)
check("5.1", "caffeine skewness", skew_caff, skew_caff > 1, "strongly right-skewed (> 1)")
check("5.1", "share of zero caffeine", mean(semesters$caffeine_mg == 0, na.rm = TRUE),
      between(mean(semesters$caffeine_mg == 0, na.rm = TRUE), 0.04, 0.15), "some zeros")
skew_age <- psych::skew(students$age, na.rm = TRUE)
check("5.1", "age skewness", skew_age, skew_age > 0.5, "right-skewed")
r_sb <- cor(d$stress_score, d$burnout_score, use = "complete.obs")
check("5.1", "r(stress, burnout)", r_sb, between(r_sb, 0.5, 0.7), "about 0.6")
r_ss <- cor(d$stress_score, d$support_score, use = "complete.obs")
check("5.1", "r(stress, support)", r_ss, between(r_ss, -0.45, -0.25), "about -0.35")
extreme <- length(unique(semesters$student_id[which(semesters$sleep_hours <= 4.5 & semesters$caffeine_mg >= 600)]))
check("5.1", "students with extreme low sleep and high caffeine", extreme, between(extreme, 3, 15), "a handful")

# 5.2 Group comparisons ----------------------------------------------------------

tt <- t.test(students_sleep <- aggregate(sleep_hours ~ student_id, semesters, mean)$sleep_hours, mu = 7)
check("5.2", "one-sample t: mean sleep vs 7 (p)", tt$p.value, tt$p.value < 0.001, "clearly below 7")

inv <- s2$wellbeing[s2$workshop == "Invited"]
not <- s2$wellbeing[s2$workshop == "Not invited"]
diff2 <- mean(inv) - mean(not)
d2 <- diff2 / sqrt((var(inv) + var(not)) / 2)
check("5.2", "workshop: semester-2 wellbeing difference", diff2, between(diff2, 3.5, 7), "about +5 points")
check("5.2", "workshop: Cohen's d", d2, between(d2, 0.25, 0.55), "about 0.45")
check("5.2", "workshop: two-sample t (p)", t.test(inv, not)$p.value, t.test(inv, not)$p.value < 0.01, "p < .01")

paired <- merge(semesters[semesters$semester == 1, c("student_id", "wellbeing")],
                semesters[semesters$semester == 2, c("student_id", "wellbeing")],
                by = "student_id", suffixes = c("_1", "_2"))
paired <- paired[paired$student_id %in% students$student_id[students$workshop == "Invited"], ]
gain <- mean(paired$wellbeing_2 - paired$wellbeing_1)
check("5.2", "paired: invited group, semester 1 -> 2", gain, between(gain, 3, 7.5), "about +5 points")
check("5.2", "paired t (p)", t.test(paired$wellbeing_2, paired$wellbeing_1, paired = TRUE)$p.value,
      t.test(paired$wellbeing_2, paired$wellbeing_1, paired = TRUE)$p.value < 0.001, "p < .001")

s1$male <- s1$gender == "Male"
mw <- wilcox.test(caffeine_mg ~ gender, data = s1)
check("5.2", "Mann-Whitney: caffeine by gender (p)", mw$p.value, TRUE, "small difference (reported only)")

ct <- table(students$employment, students$considering_dropout)
rate <- prop.table(ct, 1)[, "Yes"]
check("5.2", "dropout rate: full-time job", rate[["Full-time job"]],
      between(rate[["Full-time job"]], 0.18, 0.35), "about 25%")
check("5.2", "dropout rate: no job", rate[["None"]], between(rate[["None"]], 0.07, 0.16), "about 12%")
check("5.2", "chi-square employment x dropout (p)", chisq.test(ct)$p.value, chisq.test(ct)$p.value < 0.05, "p < .05")

av <- aov(stress_score ~ faculty, data = d)
p_av <- summary(av)[[1]][["Pr(>F)"]][1]
ss <- summary(av)[[1]][["Sum Sq"]]
check("5.2", "ANOVA stress ~ faculty (p)", p_av, p_av < 0.05, "p < .05")
check("5.2", "ANOVA eta squared", ss[1] / sum(ss), between(ss[1] / sum(ss), 0.015, 0.06), "small (about 0.03)")
tk <- TukeyHSD(av)$faculty
sig_pairs <- rownames(tk)[tk[, "p adj"] < 0.05]
check("5.2", "Tukey: significant pairs", paste(sig_pairs, collapse = "; "),
      identical(sig_pairs, "Humanities-Health Sciences"), "only Health Sciences vs Humanities")

tw <- summary(aov(wellbeing ~ programme * study_mode, data = s1))[[1]]
check("5.2", "two-way: study mode (p)", tw["study_mode", "Pr(>F)"], tw["study_mode", "Pr(>F)"] < 0.05, "p < .05")
check("5.2", "two-way: interaction (p)", tw["programme:study_mode", "Pr(>F)"],
      tw["programme:study_mode", "Pr(>F)"] > 0.05, "no interaction (p > .05)")
check("5.2", "null: GPA by gender (p)", t.test(gpa ~ gender, data = s1)$p.value,
      t.test(gpa ~ gender, data = s1)$p.value > 0.05, "no difference (p > .05)")

# 5.3 Explaining GPA -------------------------------------------------------------

m <- lm(gpa ~ sleep_hours + study_hours + stress_score + support_score, data = s1)
cf <- summary(m)$coefficients
check("5.3", "GPA ~ sleep: coefficient", cf["sleep_hours", 1], between(cf["sleep_hours", 1], 0.05, 0.15), "about +0.10 per hour")
check("5.3", "GPA ~ sleep: p", cf["sleep_hours", 4], cf["sleep_hours", 4] < 0.05, "p < .05")
check("5.3", "GPA model R-squared", summary(m)$r.squared, between(summary(m)$r.squared, 0.2, 0.4), "about 0.25")

m_c1 <- summary(lm(gpa ~ caffeine_mg, data = s1))$coefficients
m_c2 <- summary(lm(gpa ~ caffeine_mg + sleep_hours, data = s1))$coefficients
check("5.3", "confounding: caffeine alone (coef < 0, p)", m_c1["caffeine_mg", 4],
      m_c1["caffeine_mg", 1] < 0 && m_c1["caffeine_mg", 4] < 0.05, "negative, p < .05")
check("5.3", "confounding: caffeine with sleep (p)", m_c2["caffeine_mg", 4],
      m_c2["caffeine_mg", 4] > 0.05, "no effect (p > .05)")

m_q <- summary(lm(gpa ~ study_hours + I(study_hours^2), data = s1))$coefficients
check("5.3", "diminishing returns: study^2 (coef < 0, p)", m_q["I(study_hours^2)", 4],
      m_q["I(study_hours^2)", 1] < 0 && m_q["I(study_hours^2)", 4] < 0.05, "negative, p < .05")

m_i <- summary(lm(gpa ~ support_score * programme + sleep_hours + study_hours, data = s1))$coefficients
check("5.3", "interaction: support x PhD (coef > 0, p)", m_i["support_score:programmePhD", 4],
      m_i["support_score:programmePhD", 1] > 0 && m_i["support_score:programmePhD", 4] < 0.10,
      "support matters more for PhD")

# 5.4 Questionnaire structure ----------------------------------------------------

for (s in c("stress", "burnout", "support", "satisfaction")) {
  a <- suppressWarnings(psych::alpha(q[scale_items(s)], check.keys = FALSE)$total$raw_alpha)
  check("5.4", paste("Cronbach's alpha:", s), a, between(a, 0.72, 0.90), "0.75-0.88")
}
raw_items <- questionnaire[-1]
fa4 <- suppressWarnings(suppressMessages(psych::fa(raw_items, nfactors = 4, rotate = "oblimin", fm = "ml")))
L <- unclass(fa4$loadings)
scale_of <- sub("_[0-9]+$", "", rownames(L))
# Name each factor after the scale whose items load most strongly on it
factor_name <- vapply(seq_len(ncol(L)), function(f) {
  names(which.max(tapply(abs(L[, f]), scale_of, mean)))
}, character(1))
colnames(L) <- factor_name
own <- vapply(seq_len(nrow(L)), function(r) colnames(L)[which.max(abs(L[r, ]))] == scale_of[r], logical(1))
check("5.4", "four factors match the four scales", paste(sort(factor_name), collapse = ", "),
      length(unique(factor_name)) == 4, "stress, burnout, support, satisfaction")
check("5.4", "items loading on their own scale", sum(own), sum(own) >= 21, "21-22 of 22")
check("5.4", "stress_4 loads negatively (before reversing)", L["stress_4", "stress"], L["stress_4", "stress"] < -0.3, "negative")
check("5.4", "burnout_3 cross-loads on stress", L["burnout_3", "stress"], L["burnout_3", "stress"] > 0.2, "> 0.2")

# 5.5 Student profiles -----------------------------------------------------------

person <- aggregate(cbind(sleep_hours, study_hours, caffeine_mg, exercise_days) ~ student_id,
                    semesters, mean)
person <- merge(person, d[c("student_id", "stress_score", "support_score", "satisfaction_score")],
                by = "student_id")
person <- person[complete.cases(person), ]
X <- scale(person[-1])
set.seed(1)
km <- kmeans(X, centers = 4, nstart = 25)
tru <- truth$profile[match(person$student_id, students$student_id)]
ari <- function(a, b) {
  tab <- table(a, b); n2 <- function(x) sum(choose(x, 2))
  idx <- n2(tab); ea <- n2(rowSums(tab)); eb <- n2(colSums(tab)); tot <- choose(sum(tab), 2)
  (idx - ea * eb / tot) / ((ea + eb) / 2 - ea * eb / tot)
}
a_k <- ari(km$cluster, tru)
check("5.5", "k-means (4 clusters) agreement with true profiles (ARI)", a_k, between(a_k, 0.25, 0.85),
      "clear but overlapping profiles")

# 5.6 Change over time and supervisors -------------------------------------------

m0 <- lmer(wellbeing ~ 1 + (1 | supervisor_id), data = s1)
vc <- as.data.frame(VarCorr(m0))
icc <- vc$vcov[1] / sum(vc$vcov)
check("5.6", "ICC of wellbeing within supervisors", icc, between(icc, 0.04, 0.20), "about 0.10")

long <- merge(semesters, students[c("student_id", "workshop", "supervisor_id")], by = "student_id")
long$time <- long$semester - 1
mm <- suppressMessages(lmer(wellbeing ~ time * workshop + (time | student_id), data = long))
fe <- fixef(mm)
check("5.6", "average change per semester (not invited)", fe["time"], fe["time"] < 0, "slight decline")
by_sem <- tapply(long$wellbeing, list(long$semester, long$workshop), mean)
gap <- by_sem[, "Invited"] - by_sem[, "Not invited"]
check("5.6", "workshop gap by semester (1, 2, 3, 4)", paste(round(gap, 1), collapse = ", "),
      gap[2] > gap[4] && gap[4] > gap[1], "about 0, +5, +4, +3 (fading)")
slope_sd <- attr(VarCorr(mm)$student_id, "stddev")["time"]
check("5.6", "students differ in their slopes (SD)", slope_sd, slope_sd > 0.4, "random slopes present")
meet_mean <- mean(semesters$supervisor_meetings)
check("5.6", "mean supervisor meetings per semester", meet_mean, between(meet_mean, 2, 6), "a count outcome")

# 5.7 Considering dropout ---------------------------------------------------------

prev <- mean(students$considering_dropout == "Yes")
check("5.7", "share considering dropout", prev, between(prev, 0.12, 0.18), "about 15%")

dm <- merge(d, aggregate(cbind(sleep_hours, study_hours, wellbeing) ~ student_id,
                         semesters[semesters$semester == 1, ], mean), by = "student_id")
dm$y <- as.integer(dm$considering_dropout == "Yes")
dm <- dm[complete.cases(dm[c("y", "stress_score", "support_score", "financial_worry",
                              "burnout_score", "employment", "study_mode")]), ]
set.seed(2)
train <- sample(nrow(dm), round(0.7 * nrow(dm)))
fml <- y ~ stress_score + support_score + financial_worry + burnout_score + employment + study_mode
lg <- glm(fml, data = dm[train, ], family = binomial)
pred <- predict(lg, dm[-train, ], type = "response")
auc <- function(p, y) {
  r <- rank(p); n1 <- sum(y == 1); n0 <- sum(y == 0)
  (sum(r[y == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}
a_test <- auc(pred, dm$y[-train])
check("5.7", "logistic regression AUC on test data", a_test, between(a_test, 0.70, 0.88), "about 0.78")
or <- exp(coef(glm(fml, data = dm, family = binomial)))
check("5.7", "odds ratio: stress score", or["stress_score"], or["stress_score"] > 1.3, "> 1")
check("5.7", "odds ratio: support score", or["support_score"], or["support_score"] < 0.8, "< 1")
check("5.7", "odds ratio: financial worry", or["financial_worry"], or["financial_worry"] > 1.2, "> 1")

# 5.8 Attrition and missing data ---------------------------------------------------

left_ids <- setdiff(students$student_id, semesters$student_id[semesters$semester == 3])
left_rate <- length(left_ids) / 600
check("5.8", "share leaving after year 1", left_rate, between(left_rate, 0.04, 0.09), "about 6%")
left_yes <- mean(students$student_id[students$considering_dropout == "Yes"] %in% left_ids)
left_no  <- mean(students$student_id[students$considering_dropout == "No"] %in% left_ids)
check("5.8", "leaving: considered dropout vs not", paste(round(left_yes, 2), "vs", round(left_no, 2)),
      left_yes > 3 * left_no, "much more common after considering dropout")
miss_items <- mean(is.na(questionnaire[-1]))
check("5.8", "missing questionnaire answers", miss_items, between(miss_items, 0.012, 0.03), "about 2%")
miss_fw <- mean(is.na(students$financial_worry))
check("5.8", "missing financial worry", miss_fw, between(miss_fw, 0.03, 0.08), "about 5%")

# 5.9 The messy raw file -----------------------------------------------------------

raw <- read_excel("data/wellbeing_raw.xlsx", col_types = "text")
check("5.9", "raw file rows x columns", paste(nrow(raw), "x", ncol(raw)), nrow(raw) == 615, "615 rows")
check("5.9", "duplicate rows (ignoring Response ID)", sum(duplicated(raw[-1])),
      sum(duplicated(raw[-1])) == 12, "12")
check("5.9", "test responses", sum(toupper(raw[["Q1_Student ID"]]) %in% c("TEST", "TEST2")),
      sum(toupper(raw[["Q1_Student ID"]]) %in% c("TEST", "TEST2")) == 3, "3")
check("5.9", "gender spellings", length(unique(raw[["Q3_Gender"]])), length(unique(raw[["Q3_Gender"]])) >= 6, "inconsistent")
check("5.9", "impossible age present", any(raw[["Q2_Age"]] == "250", na.rm = TRUE),
      any(raw[["Q2_Age"]] == "250", na.rm = TRUE), "age 250")
sleep_cols <- unlist(raw[grep("^Sleep_S", names(raw))])
check("5.9", "sleep stored as text (e.g. '7 hrs', '6,5')",
      sum(grepl("[a-z]|,", sleep_cols)), sum(grepl("[a-z]|,", sleep_cols)) > 50, "many")
sav <- read_sav("data/wellbeing.sav")
check("5.9", "SPSS file has value labels", !is.null(attr(sav$faculty, "labels")),
      !is.null(attr(sav$faculty, "labels")) && !is.null(attr(sav$stress_1, "label")), "labels present")

# 5.10 Counselling visits -------------------------------------------------------------

visits$week_start <- as.Date(visits$week_start)
visits$year <- (seq_len(nrow(visits)) - 1) %/% 52 + 1
wk <- (seq_len(nrow(visits)) - 1) %% 52 + 1
yearly <- tapply(visits$visits, visits$year, mean)
check("5.10", "yearly mean visits", paste(round(yearly, 1), collapse = ", "),
      cor(seq_along(yearly), yearly) > 0.8, "upward trend")
pre_exam <- mean(visits$visits[wk %in% c(16, 17, 37, 38)])
teaching <- mean(visits$visits[wk %in% c(3:15, 21:28, 30:36)])
summer <- mean(visits$visits[wk %in% 41:52])
check("5.10", "pre-exam vs teaching vs summer weeks",
      paste(round(pre_exam), round(teaching), round(summer), sep = " / "),
      pre_exam > 1.25 * teaching && summer < 0.5 * teaching, "seasonal pattern")

# 4.5 Open answers --------------------------------------------------------------------

check("4.5", "themes in the hand-coded subset", length(unique(open_coded$theme)),
      length(unique(open_coded$theme)) == 7, "7 themes")
sup_low <- open_coded$student_id %in% d$student_id[d$support_score < quantile(d$support_score, 0.25, na.rm = TRUE)]
share_sup <- mean(open_coded$theme[sup_low] == "Supervision") - mean(open_coded$theme[!sup_low] == "Supervision")
check("4.5", "low support -> more 'Supervision' answers", share_sup, share_sup > 0.05, "themes follow the data")

# Report ----------------------------------------------------------------------------

old <- options(width = 200)
print(results, right = FALSE, row.names = FALSE)
options(old)
cat("\n", sum(results$ok), "of", nrow(results), "checks passed\n")
if (!all(results$ok)) {
  cat("FAILED:\n")
  print(results[!results$ok, c("section", "check", "value", "target")], row.names = FALSE)
}
