# R4NTR Revision Plan

Working plan for revising *R for Non-Technical Researchers*. The chapter outline lives in [README.md](README.md); this file holds the instructions that apply across the book, the known defects, and the order of work.

Most chapters are first drafts from 2025, and many sections were generated with AI tools. Treat every chapter as a draft to be restructured, fact-checked, and updated, not as finished text.

---

## 1. Book structure (17 chapters)

| Part | Ch | Title | File | Status |
|---|---|---|---|---|
| 1 | 1 | Getting Started with R | `010-r-programming/010-chapter01.md` | Draft |
| 1 | 2 | Data Structures in R | `010-r-programming/020-chapter02.md` | Draft, needs trimming |
| 1 | 3 | Data Manipulation | `010-r-programming/030-chapter03.md` | Draft |
| 1 | 4 | Data Visualization | `010-r-programming/040-chapter04.md` | Draft, duplicated content |
| 2 | 5 | Descriptive Statistics and EDA | `020-…/050-chapter05.md` | Draft |
| 2 | 6 | Hypothesis Testing and Statistical Inference | `020-…/060-chapter06.md` | Draft |
| 2 | 7 | ANOVA and Regression | `020-…/070-chapter07.md` | Draft |
| 2 | 8 | Multivariate Statistical Methods | `020-…/080-chapter08.md` | Draft |
| 2 | 9 | Mixed-Effects Models | `020-…/090-chapter09.md` | **New, not written** |
| 3 | 10 | Introduction to Machine Learning in R | `030-…/100-chapter10.md` | Draft |
| 3 | 11 | Classification Models | `030-…/110-chapter11.md` | Draft |
| 3 | 12 | Predictive Regression | `030-…/120-chapter12.md` | Draft |
| 3 | 13 | Advanced Clustering | `030-…/130-chapter13.md` | Draft |
| 3 | 14 | Advanced Machine Learning Techniques | `030-…/140-chapter14.md` | Draft, overlaps earlier chapters |
| 4 | 15 | Reproducible Research | `040-…/150-chapter15.md` | Draft |
| 4 | 16 | Using AI with R | `040-…/160-chapter16.md` | **New, not written** |
| 4 | 17 | Putting It All Together | `040-…/170-chapter17.md` | **Not written** |
| – | A–E | Appendices | `999-back/` | A drafted; B–E not written (E is new) |

Chapter order comes from the file-name prefix; the website address comes from `slug:`. Keep both in step with the chapter number if chapters move again.

---

## 2. Instructions for every chapter

### 2.1 Restructure
- Each chapter follows the same template:
  1. Short introduction: why this matters to a researcher.
  2. Learning objectives (3–5 bullets).
  3. Main sections, numbered `N.1`, `N.2`, … (sub-sections `N.1.1`).
  4. A worked case study or hands-on project.
  5. **Chapter review**: a short summary and a list of **key terms** (key terms are also added to the glossary in Appendix B).
  6. Exercises.
  7. References / further reading.
- Remove repetition between chapters (see section 4); teach each idea once and refer back to it.
- Keep chapters a manageable length; split material that has grown beyond the chapter's topic.

### 2.2 Check the information
- Many passages were auto-generated. Check every factual claim, statistical explanation, function name, argument, and printed result.
- Run every code block in a clean R session and confirm that the output shown matches.
- Replace the auto-generated reference lists (541 entries, all "accessed on July 30, 2025") with sources suitable for an academic book: textbooks, peer-reviewed papers, official package documentation, and CRAN vignettes. Avoid GeeksforGeeks, Medium, Reddit, Stack Overflow, and similar sites as citations.
- Remove the stray citation numbers attached to words (e.g. "graphics.1 As…"); use a consistent citation style instead.

### 2.3 Update the information
- Bring content up to date with current R (4.5+) and current package versions.
- Prefer current tools and idioms:
  - Native pipe `|>` instead of `%>%` (mention `%>%` once, for reading older code).
  - `pivot_longer()` / `pivot_wider()`, not `gather()` / `spread()`.
  - dplyr 1.1+ features: `.by =`, `join_by()`.
  - **tidymodels** throughout Part 3, not caret (caret is in maintenance mode).
  - `bake(new_data = NULL)` instead of `juice()`.
  - `keras3` instead of `keras`; check installation steps.
  - Replace or reduce Prophet (no longer actively developed); consider `fable` / `forecast`.
  - Check all ggplot2 code against ggplot2 4.x.
  - Quarto alongside, or instead of, R Markdown in Chapter 15.
  - Mention Positron as an alternative editor to RStudio.

### 2.4 Diagrams and figures
- Convert any ASCII diagrams to **Mermaid** (the site already loads `jekyll-mermaid`). Note that `jekyll-mermaid` is not on the GitHub Pages plugin allow-list, so either build the site with GitHub Actions or render Mermaid with the client-side script.
- The book currently has no diagrams or figures. Add diagrams where they explain a process, for example:
  - The data analysis workflow (Ch 5).
  - Choosing the right statistical test (Ch 6).
  - The machine learning pipeline: split → recipe → fit → tune → evaluate (Ch 10).
  - Cross-validation folds (Ch 10).
  - The `.Rmd` / Quarto rendering pipeline and Shiny reactivity (Ch 15).
- Add plot images to the visualization and analysis chapters, so readers can see what the code produces. Every image needs alt text.

### 2.5 Code standards
- Every code block is fenced and labeled: ```` ```r ````. Output goes in its own block, not as bare text.
- No Markdown escape characters inside code (`\<-`, `\=`, `\_`, `\#`).
- Load packages at the start of each chapter in one setup block; list installation commands in Appendix A rather than scattered through the text.
- Use `set.seed()` before every random step (sampling, splitting, resampling, clustering, model fitting).
- Use RStudio Projects and `here::here()` for file paths; never assume a working directory.

### 2.6 Datasets
- Prefer datasets that ship with R or install as packages (`palmerpenguins`, `datasets`, `mlbench`, `modeldata`, …), so readers need no downloads or accounts.
- Where an external file is necessary, give a stable download link and instructions, or include the file with the book.
- Avoid Kaggle datasets that need a login (Titanic, WHO life expectancy, retail sales), or provide a copy.
- Replace the `Boston` housing dataset (it contains a race-based variable and has been dropped by many textbooks).

### 2.7 Style
- One consistent voice across the book, written for non-technical researchers: plain language, explain terms when first used.
- Headings without bold markup (`## N.1 Title`, not `## **Title**`).
- Consistent section and table numbering (`Table N.1`, in order of appearance).
- Remove leftover reviewer notes in HTML comments (`<!-- … -->`) after acting on them.

---

## 3. Known defects

### Critical (fix first)
- [ ] **Chapters 4–15: code is not formatted as code.** About 180 code blocks are plain paragraphs under a lone `R` line, with escaped characters and output pasted as text. Inline code formatting was lost, leaving broken sentences (e.g. Ch 5: "mean() function performs this calculation.").
- [ ] **Chapter 4 contains the chapter twice.** Lines 10–202 are an older, garbled copy (R comments render as headings); the real chapter starts at line 208 after a dashed separator.

### Chapter-specific
- [ ] Ch 2: import/export comes before vectors; move it after data frames. Remove duplicated "Exporting Data" and "Aggregating Data" sections. Reduce the "Basic Exploratory Analysis" and missing-data sections, which overlap Chapters 3 and 5.
- [ ] Ch 2–3: act on, then delete, 9 reviewer notes in HTML comments.
- [ ] Ch 1–3: 255 code fences have no language label.
- [ ] Ch 8: first section numbered "1." instead of "8.1".
- [ ] Ch 11: Table 11.2 appears before Table 11.1.
- [ ] Ch 12: add a plain linear model as a baseline in the life expectancy project.
- [ ] Ch 14: section 14.1 (ensembles) repeats bagging (Ch 11.2) and boosting (Ch 12). Remove or reduce it, then retitle the chapter (e.g. "Neural Networks and Time Series Forecasting"), or split it into two chapters.
- [ ] Ch 15: no chapter summary.
- [ ] Unused stub `010-r-programming/005-chapter00.md` ("Tempo"): delete or merge into the time series material.
- [ ] Part index pages have no titles, and Parts 2–4 are `published: false`; check whether this is intended.

---

## 4. Repetition to resolve

| Topic | Appears in | Keep in |
|---|---|---|
| Exploratory analysis | Ch 2, Ch 5 | Ch 5 |
| Missing data | Ch 2, Ch 3, Ch 5 | Recognising `NA` in Ch 2; handling in Ch 3/5 |
| Clustering basics | Ch 8, Ch 13 | Basics in Ch 8, advanced methods in Ch 13 (as planned) |
| Ensembles (bagging, boosting) | Ch 11, Ch 12, Ch 14 | Ch 11 (random forests), Ch 12 (boosting) |
| Classification metrics | Ch 7, Ch 11 | Ch 11; brief mention in Ch 7 |

---

## 5. Content to add

Already in the README outline:
- **Ch 1:** RStudio Projects and file paths (`here`).
- **Ch 2:** importing Excel (`readxl`) and SPSS (`haven`) with labels; a "coming from SPSS or Excel" guide.
- **Ch 6:** sampling distributions by simulation and bootstrap confidence intervals, before the tests.
- **Ch 9:** Mixed-Effects Models (new chapter).
- **Ch 16:** Using AI with R (new chapter).
- **Every chapter:** chapter review with summary and key terms.
- **Appendix E:** further learning resources, including Arabic-language videos.

Proposed, not yet in the outline:
- Ch 1: Positron; the native pipe.
- Ch 2 or 3: writing your own functions (not taught anywhere).
- Ch 3: duckdb / arrow for data too large for memory.
- Ch 4: combining plots with `patchwork`.
- Ch 5: publication "Table 1" with `gtsummary`.
- Ch 6: effect sizes, power analysis and sample size (`pwr`), multiple-testing corrections.
- Ch 7: model tables (`gtsummary`, `broom`) and `marginaleffects`.
- Ch 15: Quarto, `targets`, open-science practices (data and code sharing, preregistration, ethics).
- Optional chapters depending on readers: text analysis (`tidytext`), survival analysis, Bayesian statistics (`brms`), meta-analysis (`metafor`), spatial data (`sf`).

---

## 6. Order of work

1. [ ] **Fix formatting** in Chapters 4–15 (code blocks, escapes, broken inline code) and remove Chapter 4's duplicate. Partly scripted, then reviewed by hand chapter by chapter.
2. [ ] **Fact-check and replace references**, one chapter at a time.
3. [ ] **Restructure and update** each chapter using the template in 2.1, adding figures, diagrams, exercises, and chapter reviews.
4. [ ] **Write the new chapters** (9, 16, 17) and appendices B–E.
5. [ ] **Unify style** across the whole book.
6. [ ] **Publish**: set `published: true` chapter by chapter as each one is finished.

---

## 7. Decisions log

- **Chapter titles** (short form where it fits): Ch 1 "Getting Started with R", Ch 7 "ANOVA and Regression", Ch 12 "Predictive Regression", Ch 13 "Advanced Clustering". Abstracts rewritten to match content.
- **Mixed-Effects Models** placed as Ch 9, at the end of Part 2 (after Multivariate Methods), so Chapters 1–8 keep their numbers.
- **Using AI with R** placed as Ch 16, before the final chapter, because its section on disclosing AI use builds on Reproducible Research.
- **Renumbering** of files, slugs, section numbers, table numbers, and cross-references was done in one pass (chapters 9+ were unpublished, so no live links broke).
- **Outside material** (the "Internet Links" bookmarks folder, EPIB607 course notes, YouTube channels) is used as suggestions, not as instructions.
