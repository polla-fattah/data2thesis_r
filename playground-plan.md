# Playground plan

A plan for rebuilding the playground so that every chapter has more practice than the book itself, including tasks that readers carry out on their own, without starter code. The author's decisions (2026-09-25) are recorded in Section 6 and applied throughout. The Chapter 7 pilot is the first step.

---

## 1. Where the playground stands

Every chapter has a browser page (`site/playground/chapterNN.qmd`, running R in the browser with webR) and a download project (`playground-src/chapterNN/`, zipped for RStudio). They were written for the first version of the book, before the second revision.

| Ch | Browser exercises | Download exercises | Book exercises not yet in the playground |
|---|---|---|---|
| 1 | 6 | 6 | 6 (decisions without a written record) |
| 2 | 8 | 9 | 6 (unit of analysis of each table) |
| 3 | 7 | 8 | 5 (why reverse `stress_4`), 6 (qualities of clean data) |
| 4 | 6 | 7 | 6 (redraw the misleading faculty graph) |
| 5 | 6 | 7 | - (new chapter, up to date) |
| 6 | 6 | 7 | 6 (choose a summary for each variable) |
| 7 | 8 | 9 | - (pilot, up to date) |
| 8 | 6 | 7 | 6 (draw a confounder diagram) |
| 9 | 5 | 6 | 5 (justify the number of clusters), 6 (noisier items simulation) |
| 10 | 5 | 6 | 5 (supervisor simulation), 6 (explain non-independence) |
| 11 | 5 | 5 | 2, 4, 5, 6 (polynomial simulation) |
| 12 | 6 | 7 | 7 (cost analysis) |
| 13 | 6 | 6 | 6 (explain an RMSE) |
| 14 | 6 | 6 | 7 (group-definition simulation) |
| 15 | 6 | 6 | 6 (learning rate in gradient descent) |
| 16 | 6 | 6 | 7 (noise in the artificial series) |
| 17 | 6 | project | 6 (forking paths) |
| 18 | 6 | 6 | 6 (kappa with a coder who always says Workload) |
| 19 | 6 | project | 6 (chain of reasoning for RQ2) |

Other gaps, across all chapters:

- **Only the book's own examples.** Almost every exercise repeats a chapter example with a small change. Few ask readers to apply a method to new variables, new data, or a question of their own.
- **No open tasks.** Every exercise has starter code with blanks (`______`). Readers never practise starting from an empty script, which is what a thesis requires.
- **No conceptual checks.** The conceptual exercises added to the book in the second revision (interpretation, choosing a method, explaining a result) have no playground counterpart.
- **Few hints.** Seven pages have no hints at all; most have one or two.
- **Style.** Many exercise headings are questions ("Is wellbeing different from 60?"), which the writing rules of revision-plan-2.md Section 6 now exclude.

---

## 2. The shape of every playground chapter

Each chapter gets four kinds of practice, in this order on the page and in the download project. There is no fixed number of items: each chapter gets as many as its content needs (decision 1).

| Part | Name on the page | What it is | Starter code | Answers |
|---|---|---|---|---|
| A | **Practise the chapter** | Every book exercise, in the book's order and numbering | Yes, with blanks | Solution with explanation, shown on request |
| B | **Go further** | New tasks beyond the book: other variables of the study data, a built-in R dataset, or a twist that tests understanding (change a setting, predict the result, then check) | Partial | Solution with explanation, shown on request |
| C | **Check your understanding** | Short conceptual questions: interpret an output, spot an error, choose a method, explain in a sentence | - | Short answer, hidden until clicked (decision 3) |
| D | **Do it yourself** | Several open questions, each with an empty code space in the browser (and an empty section in the download script): a small analysis from question to reported result, as in a thesis | None | None: open tasks, no answers (decision 2) |

Principles for all four parts:

1. **The book's exercises come first and keep their numbers**, so a reader can move between book and playground without confusion.
2. **"Go further" goes beyond the book.** Each chapter uses at least one variable the chapter did not analyse and, where it helps, a dataset built into R.
3. **"Check your understanding" comes before "Do it yourself"** (decision 3), so readers test the ideas before they apply them on their own.
4. **"Do it yourself" starts from a blank code space.** Each question states a research question, the data, and what to produce (usually a graph or table and a reporting sentence). No hints, solutions, or checklists are given: the aim is independent work (decision 2).
5. **Data** (decision 4): the study data and datasets built into R (or installed with the book's packages) only. The exception is Chapter 2, which teaches importing, and may use data files in several formats.
6. **Every Part A and B exercise has a hint.** Hints point to the idea or the function, not the answer.
7. **A blank tests an idea, never memory of the data.** Column and object names are written out in full. A blank stands only where the missing piece is the method's key choice: the function that fits the question (`t.test()`, `chisq.test()`, `wilcox.test()` for the Mann-Whitney test), an argument that carries the idea (`paired = TRUE`, `replace = TRUE`, `mu = 60`, `p.adjust.method`), a number the reader must reason about (a sample size), or the column whose labels a permutation test shuffles. One or two blanks per exercise, and a function is blanked once per exercise, not at every use.
8. **Every solution is run before publishing.** A script runs every solution file and checks that the numbers quoted in the explanations match, following the review checklist of revision-plan-2.md Section 6B.
9. **The writing rules apply** (revision-plan-2.md Section 6A): headings as statements, no questions as headings, prose explanations in the solutions.
9. **Browser or download.** Exercises that need only packages that run in webR (base R, dplyr, tidyr, ggplot2, stringr, lme4, rpart, nnet, knitr) go on the browser page. Exercises that need tidymodels, glmnet, xgboost, fable, psych, factoextra, mclust, dbscan, readxl, haven, shiny, or ellmer go in the download project, and the browser page lists them under "In the download project". Parts C and D appear on both; in the download project, the answers to Part C are in `solutions.R`, and Part D has no solutions.

---

## 3. Chapter by chapter

For each chapter: the book exercises (Part A), new items (Parts B, C, D), and extra data. **B** = browser page, **D** = download project. The item counts are what each chapter's content suggests, not a quota; the "Do it yourself" items listed are the core, and the pages may add more open questions of the same kind.

### Chapter 1: Getting Started with R

- **A. Practise** (6): book exercises 1-6. Exercise 6 is conceptual and becomes a written answer with a model answer. (B + D)
- **B. Go further** (4):
  1. Convert the week's sleep from hours to minutes and find the difference between the longest and shortest night (vector arithmetic before Chapter 2 formally introduces it).
  2. Find the number of students in each programme and the share of PhD students, using `table()` and division.
  3. Deliberately cause three common errors (an unquoted word, a misspelled object, a missing bracket), read each message, and fix it.
  4. Explore the built-in `PlantGrowth` data: its size, the mean weight, and the number of plants per group.
- **C. Check your understanding** (click to reveal): what `[1]` means in the Console; why `mean()` returns `NA`; the difference between the Console and a script; what `library()` does that `install.packages()` does not; why a script is a record of decisions.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Write a short script, with comments, that stores your own sleep for seven nights and reports the mean, the shortest night, and the number of nights under 7 hours.
  2. Using `students`, report three facts about the sample (for example the number of faculties, the share of women, the median age), each from one line of code.
  3. Set up an RStudio Project for your own thesis, with a `data/` folder and a first script (download only).
- **Extra data:** `PlantGrowth`, `women`.

### Chapter 2: Data Structures in R

- **A. Practise** (6): book exercises 1-6, with 5 (SPSS labels) in the download project only (haven). (B + D)
- **B. Go further** (4):
  1. Build a small data frame of five invented students with one variable of each kind (nominal, ordinal, numeric, logical), and check each type with `str()`.
  2. Find the students whose age is missing, and show their faculty and programme (logical indexing with `is.na()`).
  3. From the `semesters` table, count the records of one student and explain why there are four (unit of analysis).
  4. Build a codebook for `ToothGrowth` as a data frame: variable, meaning, type, possible values.
- **C. Check your understanding** (click to reveal): why `c(6.5, "seven")` becomes text; the difference between `[2]` and `[-2]`; what a factor's levels are for; why a question about students should count each student once; what a codebook adds to a data file.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Import the semester CSV file from the project folder, check its structure, and report how many rows, students, and semesters it contains.
  2. Choose three variables from `students`, decide whether each should be a factor, an ordered factor, or a number, convert them, and justify each choice in one sentence.
  3. Build the codebook of the SPSS file and save it as a CSV file (download only).
- **Extra data:** `ToothGrowth`, `esoph`; as the chapter on importing, it may also use data files in several formats (CSV, Excel, SPSS), such as the study's files and small practice files made for the exercises.

### Chapter 3: Data Manipulation

- **A. Practise** (6): book exercises 1-6; 5 and 6 are conceptual with model answers. (B + D)
- **B. Go further** (4):
  1. A missing-code trap: given a small vector with `99` as the missing code, compute the mean with and without recoding, and explain the difference.
  2. Find each supervisor's number of students and the average wellbeing of their students (join and group).
  3. Reshape the `questionnaire` table to long format (one row per student per item), then compute the mean of each item.
  4. Clean a small messy data frame with inconsistent spellings of faculty and numbers stored as text ("6,5", "7 hrs").
- **C. Check your understanding** (click to reveal): what each of the five qualities of clean data guards against; why the raw file is never edited; what tidy data is; the difference between `left_join()` and `anti_join()`; why a `99` should not be replaced everywhere.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Clean the full survey export from scratch and compare your result with the package's clean tables (download only).
  2. Write the methods paragraph reporting your cleaning, with every number from code (counts of test rows, duplicates, impossible values).
  3. Answer a question the chapter did not ask: which faculty has the largest share of students who live away from family, and how does that share differ between Master's and PhD students?
- **Extra data:** `airquality` (missing values), `warpbreaks`.

### Chapter 4: Data Visualization

- **A. Practise** (6): book exercises 1-6; 5 (saving a file) in the download project only. (B + D)
- **B. Go further** (4):
  1. The same data three ways: show average wellbeing by faculty as a pie chart, a bar chart, and a dot plot, and say which comparison is easiest to read.
  2. A misleading line chart: redraw the workshop line chart with the y axis from 0 to 100, and write a caption for each version.
  3. Anscombe's quartet: compute the summaries of the four sets yourself, then plot them.
  4. Graph a relationship the chapter did not show: exercise days against wellbeing, with transparency and a trend line.
- **C. Check your understanding** (click to reveal): why position is read better than angle; when a zoomed axis is acceptable; mapping versus setting a colour; which palette for categories and which for quantities; what an exploratory graph is for.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Choose a question about two variables of the study, choose the graph with the chapter's decision table, and make an explanatory version ready for a thesis, with a caption.
  2. Improve a deliberately poor graph (given as code with default colours, no labels, a truncated axis, unordered categories) and list each change and why.
  3. Make a two-panel figure for a report on one of the built-in datasets (`ChickWeight`), and save it at journal size (download).
- **Extra data:** `anscombe`, `ChickWeight`, `mpg` (ggplot2).

### Chapter 5: From Research Question to Data

- **A. Practise** (6): book exercises 1-6, already in place; exercise 1 and 2 kept as written answers. (B + D)
- **B. Go further** (4):
  1. Classify five published-style questions (given) as descriptive, relational, or causal.
  2. Rewrite three unfalsifiable hypotheses (given) so that they could be wrong.
  3. A sampling simulation with stratified sampling: draw samples of 50 stratified by faculty and compare their spread with simple random samples.
  4. Power for a correlation: use a simulation to find how many students are needed to detect a correlation of 0.2 (base R only).
- **C. Check your understanding** (click to reveal): why a hypothesis must be stated before the analysis; what rejecting the null hypothesis does not show; the difference between reliability and validity; why a bigger biased sample is still biased; what randomisation balances that measurement cannot.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. For a topic of your own, go from topic to problem to research question to hypothesis, null hypothesis, and "what would count against it" (template).
  2. Write an analysis plan table (like the chapter's) for two hypotheses of your own.
  3. Check the balance of the workshop invitation on every baseline variable, and write the sentence for a thesis.
- **Extra data:** `ToothGrowth` (design questions), `sleep` (paired design).

### Chapter 6: Descriptive Statistics and EDA

- **A. Practise** (6): book exercises 1-6. (B + D)
- **B. Go further** (4):
  1. Build the standard deviation by hand for a small vector (deviations, squares, mean, square root) and compare with `sd()`.
  2. Compare mean and median of `age` and explain the difference with a histogram.
  3. Count missing values in every column of `semesters` by semester, and describe the pattern.
  4. The `faithful` data: describe the bimodal distribution of waiting times, and why one mean misleads.
- **C. Check your understanding** (click to reveal): which summary for an ordinal variable; what the SD means in words; why an outlier is not deleted; missing at random versus not at random; why r = 0 does not mean no relationship.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Produce a complete Table 1 for the study (n, mean and SD or median and IQR as appropriate, missing counts), and the sample sentence with inline numbers.
  2. Describe a variable the chapter did not describe (`supervisor_meetings`), including its shape and unusual values.
  3. Describe `airquality` for a report: centre, spread, shape, missing data, and one relationship.
- **Extra data:** `faithful`, `airquality`, `precip`.

### Chapter 7: Hypothesis Testing and Statistical Inference

- **A. Practise** (6): book exercises 1-6, already in place (plus the chi-square expected counts). (B + D)
- **B. Go further** (4):
  1. A confidence interval simulation: draw 100 samples of 30 from the study, compute each 95% interval, and count how many contain the true mean.
  2. A permutation test for a difference in medians (sleep by gender).
  3. Multiple testing: test wellbeing differences between every pair of faculties and count "significant" results before and after a Bonferroni correction.
  4. A paired test on the built-in `sleep` data, and the same data analysed wrongly as two independent groups.
- **C. Check your understanding** (click to reveal): what a p-value is and is not; why a non-significant result in a small study says little; what the standard error measures; one-tailed versus two-tailed; why the permutation test and the t-test agree.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Test a hypothesis of your choice from Chapter 5's table (not RQ2 or RQ3): state H0 and H1, check assumptions, run the test, report with an effect size and interval.
  2. Plan a study: use simulation to find the group size needed to detect a 0.3 SD difference with 80% power, and write the sample-size justification.
  3. Analyse `chickwts` (feed type and weight) for two feeds of your choice, from graph to reporting sentence.
- **Extra data:** `sleep`, `chickwts`, `InsectSprays`.

### Chapter 8: ANOVA and Regression

- **A. Practise** (6): book exercises 1-6; 6 is a written answer. (B + D)
- **B. Go further** (4):
  1. Build F by hand for the three-group example: between and within sums of squares, then compare with `aov()`.
  2. Conditional means: group sleep into bands and compare the average GPA per band with the regression line.
  3. Simpson's paradox with `UCBAdmissions`: the admission rate by gender overall and within departments.
  4. Residual plots for a model with a missed curve (study hours without the squared term), and how the plot changes when the term is added.
- **C. Check your understanding** (click to reveal): what F compares; what "holding the others constant" means; what a confounder is; reading a funnel in a residual plot; odds ratio versus probability.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Build a regression for wellbeing (not GPA) with predictors of your choice, check the diagnostics, and write the reporting paragraph.
  2. Test whether the effect of support on wellbeing differs between full-time and part-time students (an interaction), with an interaction plot.
  3. Fit a logistic regression for `lives_away` or another yes/no variable, and report odds ratios and two predicted probabilities.
- **Extra data:** `UCBAdmissions`, `trees`, `swiss`.

### Chapter 9: Multivariate Statistical Methods

- **A. Practise** (6): book exercises 1-6; factor analysis and alpha in the download project (psych). (B, partly + D)
- **B. Go further** (4):
  1. The latent-variable simulation with correlated noise: what happens to reliability when two items share extra noise.
  2. PCA of the four scale scores (base R `prcomp()`), and what the first component represents.
  3. Clustering random data: run k-means on random points and compute the silhouette, compared with the real profiles.
  4. PCA of `USArrests` or `swiss`: interpret the first two components.
- **C. Check your understanding** (click to reveal): why several items per construct; PCA versus factor analysis; what a cross-loading means; why high alpha is not validity; why clusters are not natural groups.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Check the burnout scale fully: item correlations, alpha, alpha if an item is dropped, and a one-sentence report (download).
  2. Cluster the students on a different set of variables of your choice, describe the clusters, and argue whether they are useful.
  3. Write the questionnaire paragraph of a methods section for one scale, with the numbers from code.
- **Extra data:** `attitude`, `swiss`, `USArrests`.

### Chapter 10: Mixed-Effects Models

- **A. Practise** (6): book exercises 1-6. (B + D, lme4 runs in the browser)
- **B. Go further** (4):
  1. The design effect for GPA and for sleep, and what each says about the information in the records.
  2. Averaging each student's records and running an ordinary regression, compared with the mixed model.
  3. `sleepstudy` with random slopes only for the first five days: how the estimates change.
  4. `Orange` or `ChickWeight`: a random-slope growth model, and what the random effects mean.
- **C. Check your understanding** (click to reveal): why repeated records are not independent; what the ICC measures; fixed versus random effects; what a singular fit means; why the simulation's ordinary regression gave false alarms.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Model change in exercise days over the semesters, choose the random effects with a likelihood ratio test, and report.
  2. Test whether the workshop effect differs between Master's and PhD students with a three-way interaction, and describe the result with predictions.
  3. Write the mixed-model reporting paragraph for GPA, including the random effects.
- **Extra data:** `sleepstudy`, `ChickWeight`, `Orange`.

### Chapter 11: Introduction to Machine Learning in R

- **A. Practise** (6): book exercises 1-6; tidymodels exercises in the download project, the polynomial simulation and exercise 5 in the browser. (B + D)
- **B. Go further** (4):
  1. Data leakage demonstration: normalise before splitting, and compare the test result with the correct order.
  2. Cross-validation by hand in base R: five folds for a logistic regression, with `glm()` only.
  3. The bias-variance curve with different amounts of noise.
  4. Predict species in `penguins` (modeldata) or survival in `Titanic`, with a train/test split (download).
- **C. Check your understanding** (click to reveal): prediction versus explanation; why the test set is used once; what cross-validation estimates; overfitting in one sentence; what data leakage is.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Build a predictive model for `lives_away` or another outcome, from split to test AUC, with a baseline comparison (download).
  2. Write the prediction section of a methods chapter: data used, split, model, cross-validation, final test.
  3. Explain, with numbers from your model, why accuracy is misleading for your outcome.
- **Extra data:** `penguins` (modeldata), `Titanic`, `infert`.

### Chapter 12: Classification Models

- **A. Practise** (7): book exercises 1-7. (tiny examples in the browser, tidymodels in the download)
- **B. Go further** (4):
  1. Confusion matrices by hand for three thresholds on a small invented set of predicted probabilities.
  2. The cost curve with your own costs, and the decision-theory threshold.
  3. Sensitivity and precision by faculty at a chosen threshold (fairness check).
  4. Classify `iris` or `penguins` species with a tree and a k-NN, and compare confusion matrices.
- **C. Check your understanding** (click to reveal): precision versus recall; why the threshold is a value judgement; what a random forest averages; why k-NN needs normalised predictors; what upsampling does and does not change.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Choose a threshold for a scenario of your own (for example, a screening questionnaire with a costly follow-up), justify the costs, and report recall and precision.
  2. Compare three classifiers on a new outcome with workflow sets, and argue for one (download).
  3. Write the paragraph that reports a classifier for a thesis, including the threshold and its justification.
- **Extra data:** `iris`, `penguins`, `infert`.

### Chapter 13: Predictive Regression

- **A. Practise** (6): book exercises 1-6; glmnet and xgboost in the download project. (B + D)
- **B. Go further** (4):
  1. Ridge regression by hand for two correlated predictors with `MASS::lm.ridge()` (base R), and the shrinking coefficients.
  2. The 60-student experiment repeated with 10 different random samples: how much the ordinary and lasso test errors vary.
  3. Boosting by hand for 20 rounds with stumps (rpart), and the training error after each round.
  4. Predict `trees` volume or `swiss` fertility with lm and a lasso (download).
- **C. Check your understanding** (click to reveal): why ordinary regression overfits with many predictors; ridge versus lasso; what the penalty does; boosting versus random forests; why predictions are pulled towards the average.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Predict final wellbeing (not GPA) from year-one information, compare lasso and XGBoost, and report the test error (download).
  2. Explain which predictors the lasso kept and why that list is not a list of causes.
  3. Write two sentences for advisers on what your model's RMSE means for one student.
- **Extra data:** `trees`, `swiss`, `concrete` (modeldata).

### Chapter 14: Advanced Clustering

- **A. Practise** (7): book exercises 1-7; mclust and dbscan in the download project unless they run in webR **(test)**. (B + D)
- **B. Go further** (4):
  1. The group-definition simulation with three groups of different sizes.
  2. Membership probabilities by hand for one variable with two normal groups (`dnorm()`).
  3. DBSCAN on `faithful` (two variables) and the effect of `eps`.
  4. `quakes` with k-means and DBSCAN, and why they disagree.
- **C. Check your understanding** (click to reveal): three definitions of a group; soft versus hard membership; what BIC compares; why DBSCAN found one cluster; how to judge a clustering without an answer key.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Find profiles of students with a mixture model on variables of your choice, report the share of clear members, and describe the uncertain students.
  2. Check the stability of the three profiles on bootstrap samples (download).
  3. Write the clustering paragraph of a methods section, reporting every choice.
- **Extra data:** `faithful`, `quakes`, `iris` (external validation).

### Chapter 15: Neural Networks

- **A. Practise** (6): book exercises 1-6; gradient descent and neurons in the browser, tidymodels in the download. (B + D)
- **B. Go further** (4):
  1. Gradient descent with two predictors (stress and support), compared with `glm()`.
  2. A hidden layer by hand: two neurons with given weights and an output neuron, for three students.
  3. The effect of weight decay with `nnet` in the browser on a small sample.
  4. A regression network on `trees` or `airquality` with `nnet`.
- **C. Check your understanding** (click to reveal): why a single sigmoid neuron is a logistic regression; what the learning rate controls; what weight decay prevents; why seeds matter; when neural networks win.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Tune a network for a different outcome and compare it fairly with a regression model (download).
  2. Explain, for a non-specialist, what training does, using your own gradient-descent loop.
  3. Decide, for three research scenarios (given), whether a neural network is worth using, and why.
- **Extra data:** `trees`, `airquality`, `iris`.

### Chapter 16: Time Series Forecasting

- **A. Practise** (7): book exercises 1-7; fable in the download project, the artificial series and benchmarks in the browser (base R). (B + D)
- **B. Go further** (4):
  1. Build a series from trend, season, and noise of your choice, and forecast it with a seasonal naive method by hand.
  2. Autocorrelation by hand at lags 1 and 52 with `cor()`, compared with `ACF()`.
  3. The monthly `AirPassengers` series: time plot, log scale, and why the seasonal swings grow.
  4. `co2` or `nottem`: seasonal naive forecasts and their error.
- **C. Check your understanding** (click to reveal): why time series observations are not independent; trend versus season versus noise; why the test period comes last; what a prediction interval is; why forecasts need benchmarks.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Forecast one of the built-in series (`nottem`, `UKgas`, `ldeaths`) for two years with benchmarks and ETS, evaluate on a held-out period, and report with intervals (download).
  2. Write the one-page report to the counselling service, with the numbers from code.
  3. Describe what could make the forecast wrong next year, and how the service would notice.
- **Extra data:** `AirPassengers`, `co2`, `nottem`, `ldeaths`, `UKgas`.

### Chapter 17: Reproducible Research

- **A. Practise** (6): book exercises 1-6; Quarto and Shiny in the download project, forking paths and small cells in the browser. (B + D)
- **B. Go further** (4):
  1. Forking paths with a different number of analyses (2, 5, 10) and a plot of the false-positive rate.
  2. A parameterised report for each programme instead of each faculty (download).
  3. Protect small cells by grouping categories, and check that no cell below 5 remains.
  4. Record the session: `sessionInfo()` and the versions of five packages, formatted as a methods sentence.
- **C. Check your understanding** (click to reveal): reproducible versus replicable; why numbers are not typed by hand; what renv records; why removing names is not anonymisation; what preregistration protects against.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Turn one analysis from Chapters 6-10 into a Quarto report with a numbered table, a figure, inline numbers, and one citation, and render it to Word (download).
  2. Add a second input to the Shiny dashboard (study mode or programme) and explain the reactive links (download).
  3. Write a preregistration for a study of your own: hypotheses, design, planned analyses, and what counts as support (template).
- **Extra data:** the study data only.

### Chapter 18: Using AI with R

- **A. Practise** (6): book exercises 1-6; language-model exercises in the download project (Ollama or an API key). (B + D)
- **B. Go further** (4):
  1. Kappa by hand for a three-theme example, and how it changes as one theme becomes more common.
  2. Find the keyword dictionary's most common confusion with a confusion matrix.
  3. Answer length and theme: the average number of words by hand-coded theme (stringr).
  4. Spot the error in three pieces of AI-written code (given), each with a different kind of mistake.
- **C. Check your understanding** (click to reveal): why raw agreement can mislead; what a hallucination is; why temperature 0 is used; what must be recorded for reproducibility; when data must not be sent to an online model.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. Write a codebook for a new open question (given sample answers), code 20 answers yourself, and have a partner or a model code them; report kappa.
  2. Code the answers with a local model using a changed codebook and compare the agreement (download).
  3. Write the disclosure paragraph for AI use in a thesis of your own.
- **Extra data:** the study's open answers only.

### Chapter 19: Putting It All Together

- **A. Practise** (6): book exercises 1-6; the project in the download, the reporting helpers and the chain of reasoning in the browser. (B + D)
- **B. Go further** (4):
  1. A helper that formats a confidence interval, used in three sentences.
  2. The chain-of-reasoning table for RQ4 (faculties and stress).
  3. Table 1 by faculty instead of programme, with the same `describe()` function.
  4. Choose a method for five research questions (given) with the chapter's decision guide.
- **C. Check your understanding** (click to reveal): why every number is traced to code; what separates a result from a conclusion; why only the workshop conclusion is causal; what a limitation section is for; what reporting standards are for.
- **D. Do it yourself** (open questions, empty code spaces, no answers):
  1. A capstone: choose a research question that the book did not answer (for example, whether exercise is associated with wellbeing, allowing for sleep), and carry it through the whole chain, from hypothesis to limitation, in a Quarto report (download).
  2. Check your report against the JARS checklist items for participants, measures, and results.
  3. Review a partner's report using the chain of reasoning, and write three constructive comments.
- **Extra data:** the study data only.

---

## 4. Beyond the chapters

- **A playground index that shows the parts.** The index page lists, for each chapter, the number of items in each part and which need the download project.
- **Mini-projects after Parts 1 to 3** (recommended, see decision 6). Three longer projects that combine the chapters of a part, each on a built-in dataset: after Part 1, `airquality` (inspect, clean, describe, and graph); after Part 2, `ChickWeight` (from hypothesis to a mixed-effects model and a reported result); after Part 3, `penguins` (a predictive model with a fair test and an honest comparison). Each is a page of its own, built like "Do it yourself": a short brief, several open questions, empty code spaces, and no answers. Part 4 needs none, because Chapter 19's capstone plays that role.
- **A solutions check script.** `data-raw/check_playground.R` runs every solution file and every browser solution, and fails if code errors or a quoted number no longer matches.

---

## 5. Order of work

| Step | Work | Size |
|---|---|---|
| 1 | Test which extra packages run in webR (mclust, dbscan, fable, psych) and fix the browser/download split | Small |
| 2 | Pilot Chapter 7 with all four parts, browser page and download project, for the author to judge the format | Medium |
| 3 | Revise the format from the author's comments | Small |
| 4 | Roll out to the remaining chapters in book order, each with its solutions run and its page rendered | Large (about 18 chapters × 18 items) |
| 5 | The solutions check script, the index page, and the zips rebuilt | Small |
| 6 | The three mini-projects (Section 4) | Medium |
| 7 | Browser test of a sample of pages (one per part of the book), then a full site render | Small |

The work keeps the rules of the book revision: every number computed, every claim checked, no code removed, and no commit or push without the author's instruction.

---

## 6. Decisions (the author, 2026-09-25)

1. **Number of items:** no quota; each chapter gets as many as its content needs.
2. **"Do it yourself":** several open questions with no answers, no hints, and no checklists, each with an empty code space where the reader can write and run code.
3. **"Check your understanding":** click-to-reveal answers are enough, and this part comes *before* "Do it yourself".
4. **Data:** only datasets built into R (and the study data), except in the chapter that teaches importing (Chapter 2), which may use data files in several formats.
5. **Pilot:** Chapter 7.
6. **Mini-projects:** the author asked for a recommendation. Recommended: three mini-project pages, after Parts 1, 2, and 3, built like "Do it yourself" (brief, open questions, empty code spaces, no answers, built-in data); none after Part 4, where Chapter 19's capstone serves. To be confirmed by the author.
7. **Blanks** (the author, 2026-09-25): a blank tests an idea, never memory of the data (rule 7 in Section 2); function names may be blanked when choosing the function is the point.

---

## 7. Status (2026-09-25)

| Step | Status |
|---|---|
| 1. Package test | Not possible from the browser pane (the webR package site is blocked, and the pane stopped drawing). Chosen split: dplyr, tidyr, stringr, readr, ggplot2, lme4, rpart, and nnet in the browser (all were already on working pages, or are recommended packages); tidymodels, glmnet, xgboost, ranger, kknn, themis, mclust, dbscan, psych, and fable in the download projects only. Chapter 14's page runs DBSCAN with a base R `dbscan_by_hand()`, checked to give identical clusters to the dbscan package. |
| 2-3. Pilot and revision | Done: Chapter 7 approved; editor styling fixed; the blank rule added. |
| 4. Roll-out | Done: all 19 chapters in the four-part format, pages and download projects. Chapters 11-16 use base R on the page and the chapter's packages in the download project, with the numbers of both given in the solutions. Chapters 17 and 19 keep their Quarto projects and gain `exercises.R` and `solutions.R` for the R parts. Chapter 18 includes the saved language-model results (`ai_coding_results.csv`). |
| 5. Check script, index, zips | Done: `data-raw/check_playground.R` runs every `solutions.R` in a copy of its project (all 19 pass); the index page describes the four parts; all zips rebuilt. |
| 6. Mini-projects | Waiting for the author's decision. |
| 7. Browser test and full render | Open: the browser pane was not drawing, so the pages were checked by rendering and structure only; the author is to check pages in a browser. A full `.\build.ps1` render is still to do. |

Points raised for the book, not yet changed (the author to decide): Chapter 3's `case_when()` example does not warn that `.default` catches missing values; Chapter 15, Exercise 6 (a learning rate of 10 does not fail on the chapter's six-student example; 100 does).
