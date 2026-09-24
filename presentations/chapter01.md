---
marp: true
title: Getting Started with R
author: Dr. Polla Fattah
theme: gaia
paginate: true
footer: "R Programming | Chapter 1"
---

# Getting Started with R

- Learn the fundamentals of R for data analysis and automation.
- Understand the tools and environment necessary to begin coding in R.
- Emphasize reproducibility and efficiency in research workflows.

---

# What You Will Learn

1. Why use R in research?
2. Setting up R and RStudio.
3. The RStudio interface.
4. Programming basics in R.
5. Variables and data types.
6. Basic operations and expressions.
7. Working with vectors.
8. Writing and using functions.

---

## Why Use R?

### Challenges in Manual Data Analysis

- Time-consuming.
- Repetitive tasks are time-consuming.
- Susceptible to human error.

### Advantages of R
- **Automation**: Simplifies repetitive tasks.
- **Reproducibility**: Scripts ensure consistency.
- **Visualization**: Generate high-quality plots and graphs.
- **Flexibility**: Wide range of libraries for different fields.

---

## Use Cases of R

- **Academia**: Statistical research, data visualization.
- **Healthcare**: Clinical trials, bioinformatics.
- **Business**: Customer segmentation, financial modeling.
- **Government**: Policy analysis, population studies.

---

## Setting Up R and RStudio

### Step 1: Installing R (Part 1)
1. **Download R**:
   - Visit [CRAN](https://cran.r-project.org/), the Comprehensive R Archive Network.
   - Choose a mirror site (preferably one geographically close to you) to download R.

2. **Install R**:
   - Follow the instructions specific to your operating system:
     - **Windows**: Run the `.exe` installer and follow the wizard.
     - **Mac**: Download the `.pkg` file and drag it to the Applications folder.

---

### Step 1: Installing R (Part 2 - cont.)
   - **Linux**: Use your package manager to install R:
     ```bash
     sudo apt install r-base
     ```

3. **Verify Installation**:
   - Open a terminal or command prompt.
   - Type `R` and hit Enter. You should see the R console, which indicates that R is ready for use.

---

### Step 2: Installing RStudio 
1. **Download RStudio**:
   - Visit [RStudio's website](https://rstudio.com/) and navigate to the download section.
   - Select the free version, **RStudio Desktop - Open Source Edition**.

2. **Install RStudio**:1
   - Download the appropriate installer for your operating system:
     - **Windows**: Run the `.exe` file and follow the installation prompts.
     - **Mac**: Drag the `.dmg` file into the Applications folder.

---

### Step 2: Installing RStudio cont.
   - **Linux**: Install using the `.deb` or `.rpm` package, depending on your distribution.

3. **Launch RStudio**:
   - Open RStudio, and it should detect your R installation automatically.
   - Explore the interface, including the **Console**, **Script Editor**, and **Environment tabs**.

---

### First Steps in RStudio
1. **Create a New Script**:
   - Go to **File > New File > R Script** to create a new script.

2. **Write and Run Code**:
   - Write your first line of R code:
     ```r
     print("Hello, RStudio!")
     ```
   - Run it using the Console to see the output.

3. **Explore Features**:
   - Familiarize yourself with key features like the Plots tab, Environment tab, and Help tab.



---

## Understanding RStudio Interface

1. **Console**:
   - Type and execute commands interactively.
2. **Script Editor**:
   - Write, edit, and save R scripts.
3. **Environment/History**:
   - Monitor variables and objects.
   - Review command history.
4. **Files/Plots/Packages/Help**:
   - Manage project files, plots, and packages.
   - Access help documentation.

---

## Basics of Programming in R

- **What is Programming?**
  - Writing instructions for the computer to perform tasks.
- **Core Concepts**:
  - Precision.
  - Structure.
  - Debugging.

### Why It Matters
- Automates repetitive tasks.
- Improves efficiency and reduces errors.

---

## Variables and Data Types

### Variables
- Named storage for data.
- Example:
  ```r
  x <- 42
  y <- "Hello"
  z <- TRUE
  ```

### Data Types in R
1. **Numeric**: Integers, doubles.
2. **Character**: Strings.
3. **Logical**: TRUE/FALSE.

---

## Naming Variables

- **Rules**:
  - Start with a letter.
  - Can contain letters, numbers, underscores.
  - Avoid special characters or reserved words.
  
- **Examples**:
  - Valid: `x`, `data_1`, `myVariable`.
  - Invalid: `1data`, `my-variable`.

---

## Basic Arithmetic Operations

- Addition: `+`
- Subtraction: `-`
- Multiplication: `*`
- Division: `/`
- Power: `^`

### Example
```r
x <- 10
y <- 5
z <- x + y  # Result: 15
```

---

## Relational Operators

- **Equal to**: `==`
- **Not equal to**: `!=`
- **Greater than**: `>`
- **Less than**: `<`
- **Greater or equal to**: `>=`
- **Less or equal to**: `<=`

### Example
```r
x <- 5
y <- 10
x < y  # Result: TRUE
```

---

## Logical Operators

- AND: `&`
- OR: `|`
- NOT: `!`

### Example
```r
x <- TRUE
y <- FALSE
x & y  # Result: FALSE
x | y  # Result: TRUE
!x     # Result: FALSE
```

---

## Working with Vectors

- **Definition**: A collection of elements of the same type.
- **Creation**:
  ```r
  v <- c(1, 2, 3, 4)
  ```

- **Operations**:
  ```r
  v * 2  # Multiplies each element by 2
  ```

- **Types**:
  - Numeric, Character, Logical.

---

## Vector Indexing

- Access specific elements using square brackets:
  ```r
  v <- c(10, 20, 30, 40)
  v[2]  # Access second element
  ```

- Modify elements:
  ```r
  v[2] <- 25
  ```

---

## Introduction to Functions

### What Are Functions?
- Blocks of reusable code.
- Perform specific tasks.

### Syntax
```
function_name <- function(arg1, arg2) {
  # Code
  return(result)
}
```

---

## Examples of Functions

### Built-in Function
```r
mean(c(1, 2, 3, 4, 5))  # Returns 3
```

### Custom Function
```r
add <- function(x, y) {
  return(x + y)
}
add(5, 10)  # Returns 15
```

---

## Control Structures

### If-Else Statements
```r
x <- 5
if (x > 0) {
  print("Positive")
} else {
  print("Non-positive")
}
```

---

## Loops in R

### For Loop
```r
for (i in 1:5) {
  print(i)
}
```

### While Loop
```r
x <- 1
while (x < 5) {
  print(x)
  x <- x + 1
}
```

---

## Getting Help in R

- **Accessing Help**:
  - Use `?function_name` or `help(function_name)`.
- **Community Support**:
  - RStudio forums.
  - Stack Overflow.

---

## Tips for Beginners

1. Start with simple scripts.
2. Use comments to document code.
3. Experiment with built-in datasets.
4. Explore packages like `ggplot2` and `dplyr`.

---

## Summary of Key Topics

1. Installing R and RStudio.
2. Navigating the RStudio interface.
3. Understanding variables and data types.
4. Performing basic operations.
5. Writing and using functions.
6. Implementing control structures.

---

# Thank You!

- Questions?
- Contact: polla.fattah@su.edu.krd
