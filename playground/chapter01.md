---
title: "Playground: Chapter 1"
subtitle: Getting Started with R
layout: page
permalink: /playground/chapter01.html
---

<link rel="stylesheet" href="{{ site.baseurl }}/assets/playground/playground.css">

These exercises practise the ideas from Chapter 1: using R as a calculator, storing values in objects, calling functions, and taking a first look at Elaf's data.

<div id="playground" data-base="{{ site.baseurl }}/data/" data-files="students.csv semesters.csv"></div>
<p id="playground-status" class="playground-status" data-state="loading">Loading…</p>

Edit the code in any box and press **Run** (or **Ctrl+Enter**). **Reset** brings back the original code.

## Warming up with a few numbers

<div class="r-exercise" markdown="0">
<h3>Exercise 1: R as a calculator</h3>
<p>Elaf kept a note of how long she slept on three nights: 6.5, 7, and 5.5 hours. Use R to work out her average sleep. Press <b>Run</b>, then try changing the numbers.</p>
<script type="text/x-r" data-role="starter">
(6.5 + 7 + 5.5) / 3
</script>
<script type="text/x-r" data-role="solution">
(6.5 + 7 + 5.5) / 3
# R follows the usual order of operations, so the brackets matter.
# Without them, R would divide only 5.5 by 3:
6.5 + 7 + 5.5 / 3
</script>
</div>

<div class="r-exercise" markdown="0">
<h3>Exercise 2: Storing values in an object</h3>
<p>Instead of typing the numbers every time, store them in an object called <code>sleep</code> with <code>c()</code>, which combines values. Then use the <code>mean()</code> function. Add a fourth night of 8 hours and run it again. What happens to the average?</p>
<script type="text/x-r" data-role="starter">
sleep <- c(6.5, 7, 5.5)
sleep
mean(sleep)
</script>
<script type="text/x-r" data-role="solution">
sleep <- c(6.5, 7, 5.5, 8)
sleep
mean(sleep)
# The average rises from 6.33 to 6.75 hours.
</script>
</div>

<div class="r-exercise" markdown="0">
<h3>Exercise 3: More functions</h3>
<p>R has many functions that work on a set of numbers. Find the shortest and longest night, and how many nights there are. Then round the average to one decimal place with <code>round()</code>.</p>
<script type="text/x-r" data-role="starter">
sleep <- c(6.5, 7, 5.5, 8)
min(sleep)
# Now try max(), length(), and round(mean(sleep), 1)
</script>
<script type="text/x-r" data-role="solution">
sleep <- c(6.5, 7, 5.5, 8)
min(sleep)
max(sleep)
length(sleep)
round(mean(sleep), 1)
</script>
</div>

## Elaf's data

Now the same ideas on the real case study. The file `students.csv` has one row for each of the 600 students in Elaf's study.

<div class="r-exercise" markdown="0">
<h3>Exercise 4: Opening the data</h3>
<p>Read the file into an object called <code>students</code>. How many students (rows) and variables (columns) are there? Use <code>head()</code> to see the first six rows.</p>
<script type="text/x-r" data-role="starter">
students <- read.csv("students.csv")
nrow(students)
ncol(students)
head(students)
</script>
<script type="text/x-r" data-role="solution">
students <- read.csv("students.csv")
nrow(students)   # 600 students
ncol(students)   # 14 variables
head(students)
names(students)  # the names of all the variables
</script>
</div>

<div class="r-exercise" markdown="0">
<h3>Exercise 5: A first question, and a first surprise</h3>
<p>What is the average age of the students? The <code>$</code> sign picks one column from the data. Run the code: the answer is <code>NA</code>, which means "not available". One student's age is missing, and R will not guess. Look up the <code>na.rm</code> argument of <code>mean()</code> and fix the code so R ignores the missing value.</p>
<script type="text/x-r" data-role="starter">
students <- read.csv("students.csv")
mean(students$age)
</script>
<script type="text/x-r" data-role="solution">
students <- read.csv("students.csv")
mean(students$age, na.rm = TRUE)
# na.rm = TRUE tells R to remove missing values before calculating.
# How many ages are missing?
sum(is.na(students$age))
</script>
</div>

<div class="r-exercise" markdown="0">
<h3>Exercise 6: Counting</h3>
<p><code>table()</code> counts how many times each value appears. How many students come from each faculty? Then find out how many students were invited to the wellbeing workshop.</p>
<script type="text/x-r" data-role="starter">
students <- read.csv("students.csv")
table(students$faculty)
# How many were invited to the workshop? (the variable is called workshop)
</script>
<script type="text/x-r" data-role="solution">
students <- read.csv("students.csv")
table(students$faculty)
table(students$workshop)
# Exactly half the students, 300, were invited: the invitation was random.
</script>
</div>

<div class="r-exercise" markdown="0">
<h3>Challenge: Your first plot</h3>
<p>Elaf's semester records are in <code>semesters.csv</code>. Draw a histogram of how many hours students sleep, using <code>hist()</code>. Can you add a title with the <code>main</code> argument?</p>
<script type="text/x-r" data-role="starter">
semesters <- read.csv("semesters.csv")
hist(semesters$sleep_hours)
</script>
<script type="text/x-r" data-role="solution">
semesters <- read.csv("semesters.csv")
hist(semesters$sleep_hours,
     main = "How long do graduate students sleep?",
     xlab = "Hours of sleep per night")
</script>
</div>

## Work on your own computer

<div class="playground-download" markdown="1">
**Download the Chapter 1 project** with the data, these exercises, and their solutions, ready to open in RStudio.

- [Download chapter01.zip]({{ site.baseurl }}/playground/chapter01.zip), unzip it, and double-click `chapter01.Rproj`.
- Or type this one line in RStudio's Console, and it will download, unzip, and open the project for you:

```r
usethis::use_course("https://polla-fattah.github.io/R4NTR/playground/chapter01.zip")
```

If R says there is no package called `usethis`, install it first with `install.packages("usethis")`.
</div>

<script type="module" src="{{ site.baseurl }}/assets/playground/playground.js"></script>
