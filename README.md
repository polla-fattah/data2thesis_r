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

- Installing and setting up R and RStudio.
- Exploring the RStudio interface: Source, Console, Environment, and Plots panes.
- Writing and executing R scripts.
- Organizing your work with RStudio Projects and reliable file paths (`here`).
- Overview of R libraries and packages.

### **Chapter 2: Data Structures in R**

- Understanding vectors, matrices, lists, and data frames.
- Indexing, subsetting, and modifying data structures.
- Handling Errors Gracefully
- Packages and Libraries in R.
- Importing and exporting data: CSV, Excel (`readxl`), and SPSS (`haven`), keeping variable and value labels.
- Coming from SPSS or Excel: how familiar tasks map to R.
- Basic exploratory analysis: summary statistics and data visualization.

### **Chapter 3: Data Manipulation with dplyr and tidyr**

- Filtering, arranging, and summarizing data.
- Grouped operations with the `%>%` pipeline.
- Reshaping data: pivoting and joining datasets.
- Hands-on data cleaning and preparation techniques.

### **Chapter 4: Data Visualization with ggplot2**  

- Creating basic visualizations: bar plots, histograms, scatter plots, and box plots.
- Customizing plots: themes, annotations, and advanced styling.
- Advanced visualizations: heatmaps, faceting, and density plots.
- Exporting publication-quality plots.

## **Part 2: Statistical Analysis for Research**

### **Chapter 5: Descriptive Statistics and Exploratory Data Analysis (EDA)**

- Central tendency, variability, and distribution.
- Identifying missing data and outliers.
- Visualizing relationships with correlation plots and pairplots.

### **Chapter 6: Hypothesis Testing and Statistical Inference**

- Sampling distributions by simulation, and bootstrap confidence intervals.
- Basics of hypothesis testing: p-values and confidence intervals.
- One-sample, two-sample, and paired t-tests.
- Chi-square tests for categorical data.
- Non-parametric tests: Wilcoxon and Mann-Whitney U tests.

### **Chapter 7: ANOVA and Regression**

- ANOVA (one-way and two-way) and post hoc testing.
- Linear regression: simple and multiple.
- Logistic regression for binary outcomes.
- Case study: Predicting outcomes using regression models.

### **Chapter 8: Multivariate Statistical Methods**

- Principal Component Analysis (PCA) for dimensionality reduction.
- Factor analysis for latent variable identification.
- Clustering methods: k-means and hierarchical clustering.
- Case study: Identifying patterns in complex datasets.

### **Chapter 9: Mixed-Effects Models**

- Why ordinary regression fails with repeated measures and nested data.
- Random intercepts and random slopes with `lme4`.
- Interpreting and reporting mixed models: p-values with `lmerTest` and the intraclass correlation (ICC).
- Generalized linear mixed models for binary and count outcomes.
- Case study: Analyzing repeated measurements from a longitudinal study.

## **Part 3: Machine Learning with R**

### **Chapter 10: Introduction to Machine Learning in R**

- Supervised vs. unsupervised learning: An overview.
- Preprocessing data: scaling, normalization, and feature engineering.
- Splitting datasets into training, testing, and validation sets.
- Cross-validation and hyperparameter tuning.

### **Chapter 11: Classification Models**

- Decision trees and random forests.
- k-Nearest Neighbors (k-NN).
- Support Vector Machines (SVMs).
- Evaluating classification performance: confusion matrix, precision, recall, and F1 score.
- Case study: Classifying observations in a research dataset.

### **Chapter 12: Predictive Regression**

- Ridge, Lasso, and Elastic Net regression.
- Boosting methods: Gradient Boosting, XGBoost.
- Evaluating regression models: RMSE, MAE, and R².
- Hands-on project: Regression modeling on real-world data.

### **Chapter 13: Advanced Clustering**

- Advanced clustering: DBSCAN and Gaussian Mixture Models.
- Evaluating clustering performance metrics.
- Case study: Grouping data points for pattern discovery.

### **Chapter 14: Advanced Machine Learning Techniques**

- Ensemble methods: Bagging and Boosting.
- Introduction to neural networks using R (`keras` and `tensorflow`).
- Time series forecasting with ARIMA and Prophet.
- Hands-on project: Applying advanced ML techniques to research data.

## **Part 4: Reproducible Research and Applications**

### **Chapter 15: Reproducible Research with R Markdown, Shiny, and LaTeX**

- Writing dynamic documents with R Markdown.
- Exporting to PDF, Word, and HTML.
- Integrating LaTeX for equations and professional formatting.
- Introduction to Shiny for creating interactive dashboards and tools.
- Best practices for reproducibility in research.

### **Chapter 16: Using AI with R**

- How AI assistants work, and what they are good and bad at when writing R code.
- Using ChatGPT, Claude, and Copilot to write, explain, and debug R code, and verifying what they produce.
- AI inside the editor: GitHub Copilot in RStudio and Positron Assistant.
- Calling language models from R with `ellmer`: classifying text, coding open-ended survey responses, and extracting structured data.
- Responsible use: invented functions, data privacy, reproducibility, and disclosing AI use in publications.
- Hands-on project: Coding qualitative survey responses with a language model and validating them against human coding.

### **Chapter 17: Putting It All Together: Final Projects and Advanced Tools**

- Building a complete research project in R: Data wrangling, analysis, and visualization.
- Presenting results with R Markdown and Shiny.
- Overcoming challenges in domain-specific research applications.
- Future directions and advanced resources for learning R.

### **Appendices:**

- **Appendix A:** Installation and Setup Guide for R and RStudio.
- **Appendix B:** Glossary of Key Terms, R Functions, and Commands.
- **Appendix C:** Recommended R Packages and Libraries.
- **Appendix D:** Common Errors in R and How to Fix Them.
- **Appendix E:** Further Learning Resources: videos and courses, including Arabic-language resources.
