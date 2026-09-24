---
title: Data Manipulation
slug: chapter03
order: 040
published: true
abstract: >
    This chapter dives into modern data wrangling techniques using the tidyverse ecosystem. Topics include filtering, summarizing, reshaping, and joining datasets to prepare data for analysis. Practical examples demonstrate how to clean and transform messy data into usable formats.
---



## Introduction

Data manipulation is one of the most fundamental aspects of data analysis and research. It involves cleaning, organizing, and transforming raw data into a structured format suitable for analysis. However, as experienced in Chapter 2, performing these tasks manually or with base R functions can quickly become tedious and error-prone, especially when working with larger or messier datasets. This is where the tidyverse comes into play.

The tidyverse is a collection of R packages designed to simplify and streamline the process of data manipulation and visualization. Built around a consistent philosophy and grammar, the tidyverse enables researchers to perform complex data tasks with minimal code, while maintaining readability and reproducibility. In this chapter, the focus will be on two cornerstone tidyverse packages: **dplyr** and **tidyr**. These packages address the key challenges of data manipulation by offering intuitive, high-level functions tailored for filtering, reshaping, summarizing, and cleaning data.

In any research project, the majority of time is often spent on data manipulation rather than analysis. Tasks like cleaning missing values, reshaping data, and extracting meaningful subsets are essential but can be daunting, especially for complex datasets. In Chapter 2, base R functions like `subset()`, `merge()`, and manual loops were introduced to handle these operations. While these methods are effective, they often require verbose code and can be difficult to scale to larger datasets.

Manual data manipulation often presents several challenges, including the **complexity** of writing nested functions and loops even for simple tasks, which can make the process cumbersome and error-prone. Additionally, such code tends to lack **readability**, becoming difficult to understand and debug as projects grow in size. Finally, **scalability** can become a significant issue, as manual approaches are often inefficient when working with large datasets, limiting their practicality for real-world research applications. Recognizing these challenges, the tidyverse offers an ecosystem of tools specifically designed to address these pain points, enabling researchers to focus on insights rather than the mechanics of data processing.

The tidyverse is not a single package but a collection of related packages that work together seamlessly. These packages adhere to a shared design philosophy, making it easier to learn and apply them consistently across different tasks. Some of the most commonly used tidyverse packages include:

- **dplyr**: Designed for fast and elegant data manipulation, offering functions for filtering, summarizing, arranging, and grouping data.
- **tidyr**: Simplifies reshaping data between wide and long formats and handling missing values.
- **ggplot2**: A versatile package for creating publication-quality visualizations.
- **readr**: Provides fast and user-friendly functions for reading CSV and other flat files.
- **tibble**: Offers enhanced data frames with better default behaviors and printing.
- **stringr**: Simplifies working with character data, such as cleaning and transforming text.
- **lubridate**: Makes working with dates and times intuitive and straightforward.

Each of these packages addresses specific stages of the data analysis pipeline. While the tidyverse as a whole is powerful, this chapter focuses on **dplyr** and **tidyr**, as they are essential for efficient data manipulation and preparation.

In this chapter, the focus will be on **dplyr** and **tidyr** because they provide the core functionality for data manipulation and transformation:

The **dplyr** package simplifies the process of working with data by providing intuitive functions for filtering rows, selecting and renaming columns, creating new variables (mutating), arranging data, and summarizing it. It is designed to handle large datasets efficiently, leveraging its optimized backend and the ability to integrate seamlessly with databases. This makes dplyr a powerful tool for performing core data manipulation tasks with minimal code and maximum readability.

The **tidyr** package complements dplyr by focusing on the restructuring of data. It provides tools for converting data between wide and long formats, managing missing values, and uniting or separating columns to prepare data for analysis. With tidyr, tasks that would otherwise require intricate manual work become straightforward and reproducible.

Together, dplyr and tidyr empower researchers to clean, organize, and transform their datasets with efficiency and clarity. Mastering these two packages establishes a strong foundation for further analysis and visualization, enabling a more streamlined research workflow. This chapter begins by introducing **tibbles**, the enhanced data frames used across the tidyverse, before diving into the powerful functionalities of dplyr and tidyr for data manipulation tasks.

However, to start with tidyverse, it first needs to be installed. The tidyverse package serves as a convenient bundle that includes several essential R packages such as **dplyr**, **tidyr**, **ggplot2**, and **tibble**, among others. Installing it ensures that these packages are ready for use in your data manipulation and visualization tasks. To install the tidyverse, use the following command in your R console `install.packages("tidyverse")`. After installation, the tidyverse can be loaded into your R session using `library(tidyverse)`. This single command makes the entire collection of tidyverse packages available. Note that you can also load individual packages from the tidyverse (e.g., `library(dplyr)`) if you only need specific functionalities.

## Introduction to Tibbles

Tibbles are an enhanced version of data frames provided by the **tibble** package, part of the tidyverse ecosystem. They are designed to provide a cleaner, more user-friendly experience when working with tabular data in R. While tibbles share many characteristics with traditional data frames, they introduce features that make them more predictable and easier to use, especially for large datasets or complex workflows.

Tibbles offer several advantages that make them a preferred choice over traditional data frames in R. One key benefit is their improved printing format, which displays data in a concise and user-friendly manner. Unlike data frames that print the entire dataset to the console, tibbles show only the first 10 rows and as many columns as can fit on the screen, ensuring outputs remain readable and manageable.

Another advantage is their consistent behavior during subsetting operations. For instance, extracting a single column from a tibble still returns a tibble, rather than simplifying the result to a vector as data frames do. This consistency reduces unexpected behavior and simplifies data manipulation workflows.

Tibbles also offer better compatibility when dealing with messy datasets. They gracefully handle non-standard column names and data types, ensuring stability even with unconventional or problematic data. Additionally, as a part of the tidyverse, tibbles are designed for seamless integration with other tidyverse packages like dplyr and tidyr, enabling a cohesive and efficient workflow for data analysis.

### Creating and Working with Tibbles

Tibbles can be created in three primary ways, each suited to different scenarios and data requirements. The first method is using **`tibble()`**, which allows you to manually construct a tibble by specifying column names and their corresponding values. This is ideal for creating small datasets directly in R. The second method, **`tribble()`**, short for *transposed tibble*, is designed for creating tibbles in a row-wise format. It’s particularly useful when readability is important, as the data can be written in a structured, easy-to-understand layout. Lastly, **`as_tibble()`** is used to convert existing data structures, such as data frames or matrices, into tibbles, ensuring compatibility with tidyverse workflows while maintaining the original data's structure.

1. Creating Tibbles with `tibble()`

    The `tibble()` function allows you to create tibbles from scratch. Each argument represents a column, and the values are specified as vectors.

    ```r
    # Creating a tibble from scratch
    library(tibble)

    student_data <- tibble(
      Name = c("Alice", "Bob", "Charlie"),
      Age = c(24, 22, 23),
      Grade = c("A", "B", "A+")
    )

    print(student_data)
    ```

2. Creating Tibbles with `tribble()`

    The `tribble()` function (short for "transposed tibble") is a more intuitive way to create small tibbles for testing or manual entry. Columns are defined row by row, making the data entry process simpler.

    ```r
    # Creating a tibble with tribble()
    student_data_tribble <- tribble(
      ~Name,     ~Age, ~Grade,
      "Alice",     24, "A",
      "Bob",       22, "B",
      "Charlie",   23, "A+"
    )

    print(student_data_tribble)
    ```

3. Converting Data Frames to Tibbles with `as_tibble()`

    If you already have a traditional data frame, it can be converted to a tibble using the `as_tibble()` function.

    ```r
    # Converting a data frame to a tibble
    df <- data.frame(
      Name = c("Alice", "Bob", "Charlie"),
      Age = c(24, 22, 23),
      Grade = c("A", "B", "A+")
    )

    student_data_tibble <- as_tibble(df)
    print(student_data_tibble)
    ```

### Accessing and Manipulating Tibble Elements

Tibbles support the same methods for accessing and modifying elements as data frames but with consistent behavior.

1. Accessing Columns

    Columns can be accessed using the `$` operator or square brackets.

    ```r
    # Accessing the Age column
    ages <- student_data$Age
    print(ages)

    # Accessing the Grade column
    grades <- student_data[["Grade"]]
    print(grades)
    ```

2. Accessing Rows

    Rows can be accessed using numeric indices with square brackets.

    ```r
    # Accessing the second row
    second_row <- student_data[2, ]
    print(second_row)
    ```




### Consistent Behavior of Tibbles

Tibbles, as enhanced data frames in the tidyverse, offer a more predictable and user-friendly experience compared to base R data frames. This consistent behavior is crucial for writing reliable and maintainable code, especially when dealing with complex data manipulation tasks. Let's explore the key aspects of tibble's consistent behavior and how they address the shortcomings of traditional data frames.

#### 1. Subsetting: Always Returning the Same Type

One of the major frustrations when working with base R data frames is their inconsistent behavior during subsetting.  For example, extracting a single column can return either a vector or a data frame, depending on the method used. This inconsistency can lead to unexpected results and errors in your code.

**Example: Inconsistent Subsetting in Data Frames (The Pain!)**

```r
df <- data.frame(x = 1:5, y = 6:10)

# Extract column 'x' as a data frame
df_x_df <- df["x"] 
class(df_x_df)  # Output: "data.frame"

# Extract column 'x' as a vector
df_x_vec <- df[["x"]]
class(df_x_vec)  # Output: "integer"
```

See how confusing that is?  Sometimes you get a data frame, sometimes a vector. This makes it difficult to write code that works reliably in different situations.

Tibbles solve this problem by always returning a tibble when you subset a single column.  This consistent behavior makes your code more predictable and easier to reason about.

**Example: Consistent Subsetting in Tibbles**

```r
tb <- tibble(x = 1:5, y = 6:10)

# Extract column 'x' - always returns a tibble
tb_x <- tb["x"]
class(tb_x)  # Output: "tbl_df" "tbl" "data.frame" 
```

No more surprises! You can always rely on a tibble to behave the same way.

#### 2. Preservation of Column Data Types

Another pain point with base R data frames is that they can sometimes change the data type of a column during subsetting or other operations.  This can lead to subtle bugs and unexpected behavior in your analysis.

Tibbles, on the other hand, are designed to preserve the original data types of columns.  This ensures that your data remains consistent throughout your analysis, reducing the risk of errors.

#### 3. Protection Against Partial Matching

Base R data frames allow partial matching of column names, which can be a source of errors if you accidentally mistype a column name. Tibbles enforce strict matching, requiring you to use the exact column name. This helps prevent typos and ensures that you're always working with the intended column.

**Example: Partial Matching in Data Frames (The Pain!)**

```r
df <- data.frame(example_column = 1:3)

# Oops! Mistyped the column name
df$ex  # Output: 1 2 3 (still works due to partial matching)
```

In this example, the mistyped column name `ex` still works because of partial matching. This can be dangerous, as it can mask errors in your code.

**Example: Strict Matching in Tibbles**

```r
tb <- tibble(example_column = 1:3)

# Mistyped column name - throws an error
tb$ex  # Output: Error: Unknown column `ex`
```

Tibbles catch the error and prevent you from accidentally using the wrong column.

#### 4. Improved Printing for Large Data

When working with large datasets, printing a data frame to the console can be overwhelming. Tibbles address this by showing only the first 10 rows and as many columns as fit on the screen. This makes it much easier to inspect your data without being flooded with information.

## Data Manipulation with dplyr

The `dplyr` package is a cornerstone of the tidyverse, providing a powerful and intuitive set of tools for manipulating data in R. It's designed to make common data manipulation tasks, such as filtering rows, selecting columns, and calculating summary statistics, fast, efficient, and easy to read. In this section, we'll explore the core functions of `dplyr` and how they can simplify your data wrangling workflows.

### Filtering Rows with `filter()`

Filtering rows is a fundamental operation in data analysis, allowing you to focus on specific observations of interest. In base R, this is often done using the `subset()` function or logical indexing, which can be cumbersome and difficult to read, especially for complex conditions.

**Example: Filtering with Base R (The Pain!)**

```r
df <- data.frame(Name = c("Alice", "Bob", "Charlie", "David"),
                 Age = c(25, 30, 22, 28),
                 City = c("New York", "London", "New York", "Paris"))

# Filter rows where Age > 25
df_filtered <- subset(df, Age > 25)
print(df_filtered)

# Filter rows where City is "New York"
df_ny <- df[df$City == "New York", ]
print(df_ny)
```

`dplyr`'s `filter()` function provides a more elegant and readable way to achieve the same results.

**Example: Filtering with `dplyr`**

```r
library(dplyr)

# Filter rows where Age > 25
df_filtered <- df %>% filter(Age > 25)
print(df_filtered)

# Filter rows where City is "New York"
df_ny <- df %>% filter(City == "New York")
print(df_ny)
```

Notice how the `filter()` function is more concise and easier to read. You simply specify the data frame and the condition you want to filter by.

### Selecting Columns with `select()`

Selecting specific columns is another common task in data manipulation. In base R, this often involves using column indices or names within square brackets, which can be error-prone and less readable.

**Example: Selecting Columns with Base R (The Pain!)**

```r
# Select columns "Name" and "Age"
df_selected <- df[, c("Name", "Age")]
print(df_selected)
```

`dplyr`'s `select()` function offers a more streamlined and expressive way to select columns.

**Example: Selecting Columns with `dplyr`**

```r
# Select columns "Name" and "Age"
df_selected <- df %>% select(Name, Age)
print(df_selected)
```

With `select()`, you simply list the columns you want to keep. You can also use helper functions like `starts_with()`, `ends_with()`, and `contains()` to select columns based on patterns in their names.

### Arranging Rows with `arrange()`

Sorting data by one or more columns is essential for organizing and analyzing data. Base R's `order()` function can be used for sorting, but it can be less intuitive, especially for beginners.

**Example: Sorting with Base R (The Pain!)**

```r
# Sort by Age in ascending order
df_sorted <- df[order(df$Age), ]
print(df_sorted)
```

`dplyr`'s `arrange()` function provides a more user-friendly way to sort data.

**Example: Sorting with `dplyr`**

```r
# Sort by Age in ascending order
df_sorted <- df %>% arrange(Age)
print(df_sorted)

# Sort by City in descending order
df_sorted_desc <- df %>% arrange(desc(City))
print(df_sorted_desc)
```

`arrange()` allows you to specify the columns to sort by and the sorting order (ascending or descending).

### Creating and Transforming Columns with `mutate()`

Creating new variables or transforming existing ones is a crucial step in data preparation. Base R often requires writing complex expressions or using multiple functions to achieve this.

**Example: Transforming Columns with Base R (The Pain!)**

```r
# Create a new column "AgeInMonths"
df$AgeInMonths <- df$Age * 12
print(df)
```

`dplyr`'s `mutate()` function makes it much easier to create and transform columns.

**Example: Transforming Columns with `dplyr`**

```r
# Create a new column "AgeInMonths"
df_mutated <- df %>% mutate(AgeInMonths = Age * 12)
print(df_mutated)

# Create a new column "AgeGroup" based on Age
df_age_group <- df %>% 
  mutate(AgeGroup = ifelse(Age < 25, "Young", "Adult"))
print(df_age_group)
```

`mutate()` allows you to define new columns based on calculations or transformations of existing columns.

### Summarizing Data with `summarize()`

Calculating summary statistics is a core component of data analysis. Base R provides functions like `mean()`, `median()`, and `sum()`, but using them with data frames can be less efficient.

**Example: Summarizing with Base R (The Pain!)**

```r
# Calculate the mean age
mean_age <- mean(df$Age)
print(mean_age)
```

`dplyr`'s `summarize()` function is designed for efficient calculation of summary statistics.

**Example: Summarizing with `dplyr`**

```r
# Calculate the mean age
df_summary <- df %>% summarize(MeanAge = mean(Age))
print(df_summary)

# Calculate multiple summary statistics
df_summary_multiple <- df %>% 
  summarize(MeanAge = mean(Age), 
            MaxAge = max(Age), 
            NumPeople = n())
print(df_summary_multiple)
```

`summarize()` allows you to calculate various summary statistics for different columns in a single step.

### Performing Grouped Operations with `group_by()`

Analyzing data by groups is a common need in research. Base R often requires writing loops or using complex indexing to perform grouped operations.

**Example: Grouped Operations with Base R (The Pain!)**

```r
# Calculate the mean age for each city
mean_age_by_city <- aggregate(Age ~ City, data = df, FUN = mean)
print(mean_age_by_city)
```

`dplyr`'s `group_by()` function, combined with `summarize()`, provides a much more streamlined way to handle grouped operations.

**Example: Grouped Operations with `dplyr`**

```r
# Calculate the mean age for each city
df_grouped <- df %>% 
  group_by(City) %>% 
  summarize(MeanAge = mean(Age))
print(df_grouped)
```

`group_by()` allows you to group the data by one or more categorical variables, and then `summarize()` can be used to calculate summary statistics for each group.

### Combining Operations with the Pipe Operator (`%>%`)

The pipe operator (`%>%`) is a key component of the tidyverse, allowing you to chain multiple `dplyr` (and other tidyverse) functions together in a clean and readable way. This makes your code more expressive and easier to understand.

**Example: Chaining Operations with the Pipe Operator**

```r
# Filter, mutate, and summarize in a single pipeline
df_result <- df %>% 
  filter(Age > 25) %>% 
  mutate(AgeInMonths = Age * 12) %>% 
  summarize(MeanAgeInMonths = mean(AgeInMonths))
print(df_result)
```

In this example, the pipe operator passes the result of each function to the next one, creating a clear and efficient workflow.

## Reshaping Data with tidyr

Data often comes in formats that aren't ideal for analysis. Sometimes, you need to restructure your data to make it suitable for specific tasks or visualizations. The `tidyr` package provides a set of powerful tools for reshaping data, making it easier to tidy up messy datasets and prepare them for analysis. In this section, we'll explore two key `tidyr` functions: `pivot_longer()` and `pivot_wider()`, which allow you to convert data between wide and long formats.

### Pivoting Data with `pivot_longer()` and `pivot_wider()`

Data can be represented in either "wide" or "long" format. Wide format data has multiple columns representing the same type of measurement taken at different time points or under different conditions. Long format data, on the other hand, has a single column for the measurement and another column indicating the time point or condition.
<!-- Could also mention that wide format is generally more **readable** for humans, while long format is more **convenient** for analysis and visualization. This could help clarify when each format is preferred. -->
#### `pivot_longer()`

The `pivot_longer()` function is used to convert wide format data to long format. This is often necessary when you have multiple columns representing the same type of measurement, and you want to analyze the data across these different measurements.

**Example: Wide to Long Format with `pivot_longer()`**

Let's say you have a dataset with student scores in different subjects:

```r
library(tidyr)

# Sample data in wide format
scores_wide <- tibble(
  StudentID = c(1, 2, 3),
  Math = c(85, 90, 78),
  Science = c(92, 88, 95),
  English = c(76, 85, 89)
)

# Convert to long format
scores_long <- scores_wide %>%
  pivot_longer(cols = c(Math, Science, English),
               names_to = "Subject",
               values_to = "Score")

print(scores_long)
```

In this example, we use `pivot_longer()` to convert the `scores_wide` data to long format. The `cols` argument specifies the columns to be pivoted (in this case, `Math`, `Science`, and `English`). The `names_to` argument specifies the name of the new column that will contain the column names from the wide format data (`Subject`). The `values_to` argument specifies the name of the new column that will contain the values from the wide format data (`Score`).

#### `pivot_wider()`

The `pivot_wider()` function does the opposite of `pivot_longer()`. It converts long format data to wide format. This can be useful when you want to create a separate column for each unique value in a categorical variable.

**Example: Long to Wide Format with `pivot_wider()`**

Let's use the `scores_long` data from the previous example and convert it back to wide format:

```r
# Convert back to wide format
scores_wide_again <- scores_long %>%
  pivot_wider(names_from = "Subject",
              values_from = "Score")

print(scores_wide_again)
```

In this case, we use `pivot_wider()` to reshape the data. The `names_from` argument specifies the column in the long format data that contains the names for the new columns in the wide format data (`Subject`). The `values_from` argument specifies the column in the long format data that contains the values to fill the new columns (`Score`).

### Splitting and Combining Columns

Sometimes, a single column contains multiple pieces of information that need to be separated for analysis. Or, you might have multiple columns that you want to combine into one. `tidyr` provides functions for these tasks as well.

#### `separate()`

The `separate()` function splits a single column into multiple columns based on a separator.

**Example: Splitting a Column with `separate()`**

Let's say you have a dataset with a `FullName` column that you want to split into `FirstName` and `LastName`:

```r
# Sample data with combined names
names_combined <- tibble(
  FullName = c("Alice Smith", "Bob Johnson", "Charlie Brown")
)

# Separate the FullName column
names_separated <- names_combined %>%
  separate(col = FullName,
           into = c("FirstName", "LastName"),
           sep = " ")

print(names_separated)
```

In this example, we use `separate()` to split the `FullName` column into two new columns, `FirstName` and `LastName`, using a space as the separator.

#### `unite()`

The `unite()` function combines multiple columns into a single column.

**Example: Combining Columns with `unite()`**

Let's combine the `FirstName` and `LastName` columns from the previous example back into a `FullName` column:

```r
# Combine the FirstName and LastName columns
names_combined_again <- names_separated %>%
  unite(col = "FullName",
        c(FirstName, LastName),
        sep = " ")

print(names_combined_again)
```

Here, we use `unite()` to combine the `FirstName` and `LastName` columns into a new `FullName` column, using a space as the separator.


## Joining and Combining Datasets

In real-world data analysis, information is often spread across multiple tables or datasets. Combining these datasets is essential for gaining a complete understanding of the data and performing comprehensive analysis. `dplyr` provides a set of intuitive functions for joining datasets based on common columns, as well as for combining rows and columns from different datasets.

### Joining Datasets with `dplyr`

Joining datasets involves combining rows from two or more tables based on a common column or set of columns. `dplyr` offers four main types of joins, each with its own specific use case:

* **`inner_join()`:** Returns only the rows that have matching values in both tables.
* **`left_join()`:** Returns all rows from the left table and the matching rows from the right table.
* **`right_join()`:** Returns all rows from the right table and the matching rows from the left table.
* **`full_join()`:** Returns all rows from both tables, regardless of whether there is a match.

**Example: Joining Datasets with `dplyr`**

Let's say you have two datasets: one with student information and another with their exam scores.

```r
# Sample data: student information
students <- tibble(
  StudentID = c(1, 2, 3, 4),
  Name = c("Alice", "Bob", "Charlie", "David"),
  Age = c(25, 30, 22, 28)
)

# Sample data: exam scores
scores <- tibble(
  StudentID = c(1, 2, 4, 5),
  ExamScore = c(85, 90, 78, 92)
)

# Inner join: only matching rows
inner_joined <- students %>%
  inner_join(scores, by = "StudentID")
print(inner_joined)

# Left join: all rows from students, matching from scores
left_joined <- students %>%
  left_join(scores, by = "StudentID")
print(left_joined)

# Right join: all rows from scores, matching from students
right_joined <- students %>%
  right_join(scores, by = "StudentID")
print(right_joined)

# Full join: all rows from both tables
full_joined <- students %>%
  full_join(scores, by = "StudentID")
print(full_joined)
```

In this example, we demonstrate the different types of joins using the `students` and `scores` datasets. The `by` argument specifies the common column (`StudentID`) to use for the join.

### Combining Rows and Columns

`dplyr` also provides functions for combining datasets by row or column binding.

#### `bind_rows()`

The `bind_rows()` function combines two or more datasets by stacking their rows on top of each other. The datasets must have the same columns, but the order of the columns doesn't have to be the same.

**Example: Combining Rows with `bind_rows()`**

```r
# Sample data: more students
new_students <- tibble(
  StudentID = c(5, 6),
  Name = c("Emily", "Frank"),
  Age = c(24, 26)
)

# Combine students with new_students
all_students <- bind_rows(students, new_students)
print(all_students)
```

#### `bind_cols()`

The `bind_cols()` function combines two or more datasets by adding their columns side by side. The datasets must have the same number of rows.

**Example: Combining Columns with `bind_cols()`**

```r
# Sample data: student addresses
addresses <- tibble(
  City = c("New York", "London", "Paris", "Chicago"),
  Country = c("USA", "UK", "France", "USA")
)

# Combine students with addresses
students_with_addresses <- bind_cols(students, addresses)
print(students_with_addresses)
```

## Practical Data Cleaning and Preparation: A Deeper Dive

Real-world data is rarely clean and tidy. It often contains inconsistencies, errors, and missing values that can hinder analysis and lead to inaccurate conclusions. Data cleaning and preparation is the crucial process of transforming raw data into a reliable and usable format for analysis.

In this example, we'll use the "Wine Quality" dataset from the UCI Machine Learning Repository, focusing on the red wine data. This dataset provides a rich ground for exploring various data cleaning and preparation techniques, as it contains a mix of numerical and categorical variables, along with potential issues like outliers and inconsistencies.

Our goal is not just to clean the data but to understand its characteristics, identify potential issues, and make informed decisions about how to address them. We'll combine the power of `dplyr` and `tidyr` with exploratory data analysis (EDA) to gain insights into the data and guide our cleaning and preparation process.

### Fetching and Inspecting the Data

First, let's download the red wine data and load it into a tibble.

```r
library(tidyverse)

# URL of the red wine dataset
url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv"

# Read the data into a tibble
wine_data <- read_csv(url)

# Initial inspection
glimpse(wine_data)
```

The `glimpse()` function provides a concise overview of the data, showing the column names, data types, and a few sample values. This initial inspection gives us a sense of the data's structure and potential challenges.

### Exploratory Data Analysis (EDA)

Before diving into cleaning, let's perform some EDA to understand the data better.

#### Summary Statistics

```r
summary(wine_data)
```

This provides summary statistics for each column, including measures of central tendency (mean, median), dispersion (standard deviation, range), and distribution (quartiles). We can identify potential outliers or unusual values by examining these statistics.

#### Visualizations

Visualizations can reveal patterns and relationships that might not be apparent from summary statistics alone.

```r
# Histograms for numerical variables
wine_data %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
    facet_wrap(~ key, scales = "free") +
    geom_histogram()

# Boxplots for quality vs. numerical variables
wine_data %>%
  gather(-quality, key = "variable", value = "value") %>% 
  ggplot(aes(x = quality, y = value)) +
    facet_wrap(~ variable, scales = "free") +
    geom_boxplot()
```

These visualizations help us understand the distribution of each variable, identify potential outliers, and explore relationships between variables.

### Data Cleaning and Preparation

Based on our EDA, we can now make informed decisions about how to clean and prepare the data.

#### 1. Handling Missing Values

```r
# Check for missing values in each column
missing_counts <- colSums(is.na(wine_data))
print(missing_counts)
```

If there are missing values, we need to decide how to handle them.  Options include:

* **Imputation:** Replacing missing values with estimated values (e.g., mean, median, or more sophisticated methods).
* **Removal:** Removing rows or columns with missing values.
* **Keeping as is:**  Sometimes, missing values can be informative in themselves.

The best approach depends on the nature of the data and the research question.

#### 2. Removing Duplicate Rows

```r
# Remove duplicate rows
wine_data <- distinct(wine_data)
```

This ensures that each observation in the dataset is unique.

#### 3. Renaming Columns

```r
# Rename columns to snake_case
wine_data <- wine_data %>%
  rename_with(~ tolower(gsub("\\.", "_",.x)))
```

This improves consistency and readability.

#### 4. Transforming Variables

Based on our EDA, we might identify variables that need to be transformed. For example, if a variable has a skewed distribution, we might apply a log transformation to make it more normally distributed.

```r
# Example: log transform 'fixed acidity' if it's skewed
if (skewness(wine_data$fixed_acidity) > 1) {  # Check for skewness
  wine_data <- wine_data %>%
    mutate(fixed_acidity = log(fixed_acidity))
}
```

#### 5. Reformatting Categorical Variables

```r
# Convert quality to factor
wine_data <- wine_data %>%
  mutate(quality = as.factor(quality))
```

This ensures that `quality` is treated as a categorical variable in analyses.

#### 6. Creating New Variables

We might want to create new variables based on existing ones. For example, we could create a binary variable indicating whether the wine is high or low quality based on a threshold.

```r
# Create a binary variable 'high_quality'
wine_data <- wine_data %>%
  mutate(high_quality = ifelse(quality >= 7, "High", "Low"))
```

#### 7. Handling Outliers

Outliers can distort analyses and lead to misleading results. We can identify outliers using boxplots or other methods and decide how to handle them (e.g., removal, transformation, or using robust statistical methods).

```r
# Example: remove outliers in 'residual sugar' using IQR method
Q1 <- quantile(wine_data$residual_sugar, 0.25)
Q3 <- quantile(wine_data$residual_sugar, 0.75)
IQR <- Q3 - Q1
upper_bound <- Q3 + 1.5 * IQR
lower_bound <- Q1 - 1.5 * IQR

wine_data <- wine_data %>%
  filter(residual_sugar >= lower_bound & residual_sugar <= upper_bound)
```

#### 8. Standardizing Numerical Variables

```r
# Standardize numerical variables (excluding quality, which is a factor)
wine_data_standardized <- wine_data %>%
  mutate(across(where(is.numeric), scale))
```

This can be useful for some analyses, especially those involving distance-based calculations.

#### 9. Exporting Cleaned Data

```r
# Export cleaned data to CSV
write_csv(wine_data_standardized, "wine_data_cleaned.csv")
```

This saves the cleaned data for further analysis or sharing.

### Complete Code for Data Cleaning and Preparation

Here's the complete code for the data cleaning and preparation example, combining all the steps we've discussed in this chapter. You can run this code in your R environment to replicate the entire process.

```r
library(tidyverse)

# URL of the red wine dataset
url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv"

# Read the data into a tibble
wine_data <- read_csv(url)

# Initial inspection
glimpse(wine_data)

# Summary statistics
summary(wine_data)

# Histograms for numerical variables
wine_data %>%
  keep(is.numeric) %>%
  gather() %>%
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_histogram()

# Boxplots for quality vs. numerical variables
wine_data %>%
  gather(-quality, key = "variable", value = "value") %>%
  ggplot(aes(x = quality, y = value)) +
  facet_wrap(~ variable, scales = "free") +
  geom_boxplot()

# Check for missing values in each column
missing_counts <- colSums(is.na(wine_data))
print(missing_counts)

# Remove duplicate rows
wine_data <- distinct(wine_data)

# Rename columns to snake_case
wine_data <- wine_data %>%
  rename_with(~ tolower(gsub("\\.", "_",.x)))

# Convert quality to factor
wine_data <- wine_data %>%
  mutate(quality = as.factor(quality))

# Example: log transform 'fixed acidity' if it's skewed
if (skewness(wine_data$fixed_acidity) > 1) {  # Check for skewness
  wine_data <- wine_data %>%
    mutate(fixed_acidity = log(fixed_acidity))
}

# Create a binary variable 'high_quality'
wine_data <- wine_data %>%
  mutate(high_quality = ifelse(quality >= 7, "High", "Low"))

# Example: remove outliers in 'residual sugar' using IQR method
Q1 <- quantile(wine_data$residual_sugar, 0.25)
Q3 <- quantile(wine_data$residual_sugar, 0.75)
IQR <- Q3 - Q1
upper_bound <- Q3 + 1.5 * IQR
lower_bound <- Q1 - 1.5 * IQR

wine_data <- wine_data %>%
  filter(residual_sugar >= lower_bound & residual_sugar <= upper_bound)

# Standardize numerical variables (excluding quality, which is a factor)
wine_data_standardized <- wine_data %>%
  mutate(across(where(is.numeric), scale))

# Export cleaned data to CSV
write_csv(wine_data_standardized, "wine_data_cleaned.csv")
```

This code provides a comprehensive example of data cleaning and preparation using the `dplyr` and `tidyr` packages. It covers various aspects of data manipulation, including handling missing values, removing duplicates, renaming columns, transforming variables, and exporting the cleaned data.

Remember to adapt and modify this code to fit your specific data and research questions. The key is to understand the data, identify potential issues, and make informed decisions about how to clean and prepare it for analysis.
<!-- Consider leaving learning outcomes/table of contents at the start or the end of the chapter. -->
