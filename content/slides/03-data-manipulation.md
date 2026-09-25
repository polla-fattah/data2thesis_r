---
title: Data Manipulation with dplyr and tidyr
---

# Data Manipulation with dplyr and tidyr

<div class="pt-12">
  <span @click="$slidev.nav.next" class="px-2 py-1 rounded cursor-pointer" hover="bg-white bg-opacity-10">
    Press Space for next page <carbon:arrow-right class="inline"/>
  </span>
</div>

---

# Introduction

- Data manipulation is crucial for data analysis and research.
- Manual data manipulation can be tedious and error-prone.
- **Tidyverse** offers a collection of R packages to simplify data manipulation.
- This chapter focuses on **dplyr** and **tidyr**.

---

# The Tidyverse

- A collection of R packages for data manipulation, visualization, and analysis.
- Key packages:
  - **dplyr:** Data manipulation
  - **tidyr:** Data reshaping
  - **ggplot2:** Data visualization
  - **readr:** Data import
  - **tibble:** Enhanced data frames
  - **stringr:** String manipulation
  - **lubridate:** Date and time manipulation


---

# Tibbles

- Enhanced data frames.
- Improved printing format.
- Consistent behavior during subsetting.
- Better compatibility with messy data.

---

# Creating Tibbles

- **`tibble()`:** Create from scratch.
  ```r
  student_data <- tibble(
    Name = c("Alice", "Bob", "Charlie"),
    Age = c(24, 22, 23),
    Grade = c("A", "B", "A+")
  )
  ```
- **`tribble()`:** Create row-wise.
  ```r
  student_data_tribble <- tribble(
    ~Name,     ~Age, ~Grade,
    "Alice",     24, "A",
    "Bob",       22, "B",
    "Charlie",   23, "A+"
  )
  ```
- **`as_tibble()`:** Convert existing data structures.
  ```r
  student_data_tibble <- as_tibble(df)
  ```

---

# Accessing Tibble Elements

- Access columns using `$` or ``.
  ```r
  ages <- student_data$Age
  grades <- student_data[["Grade"]]
  ```
- Access rows using numeric indices.
  ```r
  second_row <- student_data[2, ]
  ```

---

# Consistent Behavior of Tibbles

- **Subsetting:** Always returns a tibble.
- **Preserves column data types.**
- **Protection against partial matching.**
- **Improved printing for large data.**

---

# Data Manipulation with dplyr

- **`filter()`:** Select rows based on conditions.
- **`select()`:** Select specific columns.
- **`arrange()`:** Sort rows by column values.
- **`mutate()`:** Create or transform columns.
- **`summarize()`:** Calculate summary statistics.
- **`group_by()`:** Perform grouped operations.

---

# `filter()`

- Selects rows based on conditions.

**Example:**

```r
df_filtered <- df %>% filter(Age > 25)
```

---

# `select()`

- Selects specific columns.

**Example:**

```r
df_selected <- df %>% select(Name, Age)
```

---

# `arrange()`

- Sorts rows by column values.

**Example:**

```r
df_sorted <- df %>% arrange(Age)
```

---

# `mutate()`

- Creates or transforms columns.

**Example:**

```r
df_mutated <- df %>% mutate(AgeInMonths = Age * 12)
```

---

# `summarize()`

- Calculates summary statistics.

**Example:**

```r
df_summary <- df %>% summarize(MeanAge = mean(Age))
```

---

# `group_by()`

- Performs grouped operations.

**Example:**

```r
df_grouped <- df %>% 
  group_by(City) %>% 
  summarize(MeanAge = mean(Age))
```

---

# The Pipe Operator (`%>%`)

- Chains multiple operations together.

**Example:**

```r
df_result <- df %>% 
  filter(Age > 25) %>% 
  mutate(AgeInMonths = Age * 12) %>% 
  summarize(MeanAgeInMonths = mean(AgeInMonths))
```

---

# Joining Datasets

- Combining rows from two or more tables based on a common column.
- **`inner_join()`:** Returns only the rows that have matching values in both tables.
- **`left_join()`:** Returns all rows from the left table and the matching rows from the right table.
- **`right_join()`:** Returns all rows from the right table and the matching rows from the left table.
- **`full_join()`:** Returns all rows from both tables, regardless of whether there is a match.

**Example:**

```r
# Inner join: only matching rows
inner_joined <- students %>%
  inner_join(scores, by = "StudentID")
print(inner_joined)
```

---

# Combining Datasets

- **`bind_rows()`:** Stack rows on top of each other.

**Example:**

```r
# Combine students with new_students
all_students <- bind_rows(students, new_students)
print(all_students)
```

---

# Combining Datasets (cont.)

- **`bind_cols()`:** Add columns side by side.

**Example:**

```r
# Combine students with addresses
students_with_addresses <- bind_cols(students, addresses)
print(students_with_addresses)
```

```markdown
---

# Data Cleaning and Preparation

- Real-world data is often messy and needs to be cleaned and prepared for analysis.
- This involves handling missing values, removing duplicates, transforming variables, etc.
- We'll use the **Wine Quality** dataset as an example.

---

# Wine Quality Example

- Fetched data from UCI Machine Learning Repository.
- Performed EDA to understand data characteristics.
  - Summary statistics
  - Visualizations (histograms, boxplots)
- Applied various data cleaning and preparation techniques.
- Exported cleaned data to a new CSV file.

---

# Data Cleaning Steps

- **Handling missing values:** Imputation, removal, or keeping as is.
- **Removing duplicate rows:** `distinct()`
- **Renaming columns:** `rename_with()`
- **Transforming variables:** e.g., log transformation for skewed data.
- **Reformatting categorical variables:** `as.factor()`
- **Creating new variables:** e.g., binary variable for high/low quality.
- **Handling outliers:** e.g., IQR method for removing outliers.
- **Standardizing numerical variables:** `scale()`
- **Exporting cleaned data:** `write_csv()`
```
