# From Data to Thesis: Research Data Analysis with R

A practical guide to analysing research data with R, for researchers with no programming or statistics background. The book follows Elaf, a Master's student, through her thesis on graduate student wellbeing, introducing each method as the answer to one of her research questions.

**Read it online:** https://polla-fattah.github.io/R4NTR

## Repository layout

| Folder | Contents |
|---|---|
| `book/` | The book (Quarto book project): one `.qmd` file per chapter and appendix |
| `site/` | The website around the book (Quarto website project): landing page and playground |
| `data/` | Elaf's dataset (generated), its specification, and the built `data2thesis` package |
| `data-raw/` | Scripts that generate and check the data, build the package, and build the playground projects |
| `data2thesis/` | Source of the `data2thesis` R package |
| `playground-src/` | Source of the downloadable playground project for each chapter |
| `archive/jekyll/` | The earlier Jekyll version of the site, including the first chapter drafts (source material for the rewrites) |
| `plan.md` | The revision plan: decisions, instructions for every chapter, and the order of work |

## Building the site

Requires [Quarto](https://quarto.org) and R. Build the website first, then the book, which goes inside it:

```bash
cd site && quarto render && cd ../book && quarto render
```

The result is in `_site/`. To look at it locally:

```bash
python -m http.server 4200 --directory _site
```

Code results are stored in `site/_freeze/` and `book/_freeze/`. Commit them after changing any code, so the site can be published by GitHub Actions (`.github/workflows/publish.yml`) without R.

## Outline

*Every chapter ends with a chapter review: a short summary and a list of key terms, which are collected in the glossary (Appendix B).*

## **Part 1: Foundations of R Programming and Data Handling**

### **Chapter 1: Getting Started with R**

- Why researchers use R; installing R and RStudio (Positron as an alternative).
- A tour of RStudio: Source, Console, Environment, and Files/Plots/Packages/Help panes.
- R as a calculator, objects and assignment, and the basic types of data, including missing values (`NA`).
- Functions, arguments, and getting help.
- Writing scripts; organizing work with RStudio Projects and reliable file paths (`here`).
- Installing and loading packages, including the `data2thesis` data package.
- A first look at Elaf's data.

### **Chapter 2: Data Structures in R**

- Vectors: working with whole vectors, logical indexing, and changing values.
- Factors for categories, with ordered levels.
- Data frames: structure, selecting rows and columns, and adding columns.
- Matrices and lists, met as results (correlation matrices, test results).
- Importing CSV, Excel (`readxl`), and SPSS (`haven`) files, keeping variable and value labels; exporting data.
- Coming from SPSS or Excel: how familiar tasks map to R.
- Reading common error messages; a first summary of the data.

### **Chapter 3: Data Manipulation with dplyr and tidyr**

- The tidyverse, tidy data, and the native pipe `|>`.
- dplyr verbs: `filter()`, `select()`, `arrange()`, `mutate()`, `case_when()`, and `summarise()` with `.by`.
- Reshaping with `pivot_longer()` and `pivot_wider()`.
- Joining tables with `left_join()` and `anti_join()` (`join_by()`).
- Case study: cleaning Elaf's survey export (test and duplicate rows, names, categories, missing codes, text to numbers, impossible values), computing scale scores with a reversed item, and reshaping the semester records; checked against the clean data.

### **Chapter 4: Data Visualization with ggplot2**  

- The grammar of graphics: data, aesthetic mappings, and geoms.
- Histograms, bar charts, box plots, scatter plots with trend lines, and line charts of change over time.
- Mapping versus setting colours.
- Labels, scales, colour-blind-friendly palettes, themes, annotations, and honest axis ranges.
- Facets, density plots, and correlation heat maps.
- Exporting publication-quality figures with `ggsave()`.

## **Part 2: Statistical Analysis for Research**

### **Chapter 5: Descriptive Statistics and Exploratory Data Analysis (EDA)**

- Exploratory, inferential, and predictive analysis, and the analysis workflow.
- Centre (mean, median, mode) and spread (SD, variance, IQR), and when to report which.
- Shape: skewness, modality, the normal distribution and the 68–95–99.7 rule, z-scores, and Q-Q plots.
- Unusual values: the box plot and z-score rules, and what (not) to do with outliers.
- Missing data: how much, and why (missing completely at random, at random, not at random); attrition in Elaf's study.
- Correlation, scatter plot matrices, and why correlation is not causation.
- Describing the sample in a thesis.

### **Chapter 6: Hypothesis Testing and Statistical Inference**

- Populations and samples; sampling distributions by simulation, the standard error, and the central limit theorem.
- Confidence intervals, including bootstrap confidence intervals.
- The logic of hypothesis testing: null and alternative hypotheses, p-values, Type I and II errors, one- and two-tailed tests, statistical versus practical significance.
- One-sample, two-sample (Welch), and paired t-tests, with Cohen's *d*.
- Checking assumptions (and the trap of normality tests in large samples).
- Chi-square tests of goodness of fit and independence.
- Non-parametric tests: Mann-Whitney U and Wilcoxon signed-rank.
- Choosing the right test, and reporting results in a thesis.

### **Chapter 7: ANOVA and Regression**

- One-way ANOVA, eta squared, Tukey post-hoc tests, Levene's test, and Kruskal-Wallis.
- Two-way ANOVA: main effects, interactions, and interaction plots.
- Simple and multiple linear regression; reading `summary()`; R-squared; categorical predictors.
- Separating an effect from a confounder (caffeine and sleep); curved relationships; interactions with centred predictors.
- Diagnostic plots, and tidy reporting with broom.
- Logistic regression: odds, odds ratios, and predicted probabilities for considering dropout.

### **Chapter 8: Multivariate Statistical Methods**

- Exploring many correlations at once (sorted correlation plots).
- Principal component analysis: components, eigenvalues, scree plots, the Kaiser rule, and parallel analysis.
- PCA versus factor analysis; exploratory factor analysis of Elaf's questionnaire (loadings, oblique rotation, a reversed item, a cross-loading).
- Reliability with Cronbach's alpha.
- Cluster analysis: scaling, k-means, choosing the number of clusters (elbow, silhouette), describing clusters, and hierarchical clustering with dendrograms.

### **Chapter 9: Mixed-Effects Models**

- Repeated measures and nested data, and why ordinary regression gets the uncertainty wrong (in either direction).
- Random intercepts and random slopes with `lme4`, starting from the real `sleepstudy` data; the intraclass correlation (ICC).
- Confidence intervals, likelihood ratio tests, and p-values with `lmerTest`.
- Change over time in Elaf's study: the decline in wellbeing, the fading workshop effect, and stable GPA (and what a singular fit means).
- Students within supervisors: variance at each level.
- Generalised linear mixed models for counts (supervisor meetings) and binary outcomes.
- Reporting a mixed-effects model.

## **Part 3: Machine Learning with R**

### **Chapter 10: Introduction to Machine Learning in R**

- Supervised and unsupervised learning; prediction versus explanation.
- The tidymodels framework: splitting (rsample), recipes, model specifications (parsnip), workflows, tuning, and yardstick.
- Predicting which students will consider dropout: a stratified split, a recipe (imputation, dummy variables, normalisation), and data leakage.
- Evaluating a classifier: why accuracy misleads for imbalanced outcomes, and the ROC AUC.
- Overfitting, cross-validation, hyperparameter tuning (tree depth), and the final test with `last_fit()`.
- Fairness and responsible use of predictions about people.

### **Chapter 11: Classification Models**

- Decision trees (how splits are chosen, reading a tree) and random forests (bootstrap samples, `mtry`, permutation importance).
- k-nearest neighbours (distances, why normalisation matters, tuning k) and support vector machines (margins, linear and RBF kernels).
- Comparing models fairly with workflow sets: on Elaf's data, logistic regression predicts as well as any flexible model.
- The confusion matrix: sensitivity (recall), specificity, precision, and the F1 score.
- Choosing the classification threshold with the ROC curve and cross-validated predictions, and reporting it.
- Imbalanced outcomes: upsampling, downsampling, SMOTE, and class weights with themis, and what they do (and do not) change.

### **Chapter 12: Predictive Regression**

- Predicting Elaf's final GPA from year-one information: wide-format predictors with `pivot_wider()`, and the limits of a model trained only on students who stayed.
- Measuring numeric predictions: MAE, RMSE, and R², always against a baseline that predicts the mean.
- Why ordinary regression overfits with many correlated predictors (a 60-student experiment).
- Regularised regression with glmnet: ridge, lasso, and elastic net; tuning the penalty; coefficient paths; why selected predictors are not causes.
- Boosting: building a model from many small trees, and tuning XGBoost.
- Comparing models with cross-validation, the final test, and what year-one GPA alone achieves.

### **Chapter 13: Advanced Clustering**

- What k-means assumes: hard assignments, round clusters of similar size, and no room for outliers.
- Gaussian mixture models with mclust: membership probabilities, covariance structures, and choosing the number of clusters with BIC; three student profiles and the students who fit none clearly.
- DBSCAN: clusters as dense regions, core points and noise, and choosing `eps` with the k-nearest-neighbour distance plot; finding students who fit no profile.
- Evaluating a clustering: silhouette, BIC, agreement between methods (adjusted Rand index), stability, and relevance to outcomes such as considering dropout.
- Reporting clustering choices in a thesis.

### **Chapter 14: Neural Networks**

- How a neural network works: neurons, layers, weights, and activation functions.
- Fitting and tuning a neural network with tidymodels (`mlp()` with the `nnet` engine) on the dropout question.
- Comparing it fairly with the models of Chapters 10 and 11.
- Deep learning: what it is, when it helps, and where to go next (`keras3`, `torch`).

### **Chapter 15: Time Series Forecasting**

- Time series data in R with `tsibble`, and time plots.
- Trend and seasonality: decomposition and seasonal plots with `feasts`.
- Simple benchmark forecasts, exponential smoothing (ETS), and ARIMA with `fable`.
- Judging forecasts: training and test periods, accuracy measures, and prediction intervals.
- Case study: forecasting next year's weekly visits to the university counselling service.

## **Part 4: Reproducible Research and Applications**

### **Chapter 16: Reproducible Research**

- What reproducible research is, and why copying results by hand goes wrong.
- Quarto documents: YAML header, Markdown text, code chunks, inline code, chunk options, numbered tables and figures, citations from a BibTeX file, and LaTeX equations; rendering to HTML, Word, and PDF; parameterised reports. A note on R Markdown for older projects.
- Keeping package versions with renv, and reporting and citing software.
- Shiny: inputs, outputs, and reactivity, with a complete wellbeing dashboard.
- Open science: sharing data and code with a DOI and a licence, protecting participants (small cells), preregistration and registered reports.
- Optional: keeping a project's history with git and GitHub.

### **Chapter 17: Using AI with R**

- How large language models work, and why they make confident mistakes (hallucinations, outdated knowledge).
- Using AI assistants to write, explain, and debug R code, and checking what they produce; AI inside RStudio and Positron.
- Coding Elaf's open-ended answers: a keyword dictionary as a baseline, then a language model called from R with `ellmer` (system prompt with a codebook, structured output, `parallel_chat_structured()`).
- Validating AI coding against human coding: accuracy, confusion matrix, Cohen's kappa, reading disagreements, and consistency between runs.
- Responsible use: checking, data privacy and local models, reproducibility (models, prompts, saved outputs), disclosure, and bias.

### **Chapter 18: Putting It All Together**

- The path of a research project, and how to organise one: read-only raw data, numbered scripts, relative paths, a README, and a Quarto results document.
- Elaf's complete pipeline, from the raw survey export to clean data (checked against the package), a sample table, and three research questions answered with the methods of the book.
- Reporting: helper functions for means, percentages, and p-values; broom for model tables; reporting sentences with inline numbers; combined figures with patchwork.
- Choosing a method: a decision guide and a map of Elaf's research questions to the chapters.
- Challenges every researcher meets, and where to go next (further methods, free books, and the R community).

### **Appendices:**

- **Appendix A:** Installation and Setup: R on Windows, macOS, and Linux; RStudio (and Positron); recommended settings; the book's packages and the data2thesis package; common problems and keeping R up to date.
- **Appendix B:** Glossary: every key term from the chapter reviews with a plain-language definition and chapter references, and a table of frequently used R functions.
- **Appendix C:** Recommended R Packages and Libraries.
- **Appendix D:** Common Errors in R and How to Fix Them.
- **Appendix E:** Further Learning Resources: videos and courses, including Arabic-language resources.
