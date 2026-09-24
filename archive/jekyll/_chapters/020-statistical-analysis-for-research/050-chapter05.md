---
title:  Descriptive Statistics and Exploratory Data Analysis
slug: chapter05
order: 055
published: false
abstract: >
    This chapter provides tools and techniques for summarizing data, identifying patterns, and detecting anomalies. Descriptive statistics, visualizations, and exploratory methods are presented as essential steps in understanding datasets before formal analysis.
---


## **Introduction: A Conversation with Your Data**

The preceding chapters have equipped you with the foundational mechanics of R: loading, structuring, and manipulating data. You have learned to command R to perform specific tasks—to filter(), mutate(), and arrange() your datasets with precision. Now, the journey shifts from the mechanical to the intellectual. This chapter introduces Exploratory Data Analysis (EDA), a process that transforms data handling from a monologue of commands into a rich, iterative dialogue with your data.

EDA is not a rigid protocol with a fixed sequence of steps; rather, it is a state of mind, a philosophy of analytical curiosity.1 Its primary goal is to develop a deep, intuitive understanding of a dataset's main characteristics before any formal modeling or hypothesis testing begins.3 The process is fundamentally creative, driven by a simple yet powerful engine: asking questions.1 When you ask a question, you focus your attention on a specific part of your dataset, which in turn helps you decide which graphs to create, which statistics to compute, or which transformations to apply.4

The objectives of EDA are manifold and form the bedrock of any sound data analysis project 3:

* **Maximize insight** into the dataset and understand its underlying structure.  
* **Detect anomalies and outliers**—observations that deviate markedly from the norm and may require special attention.  
* **Visualize potential relationships** between variables, assessing their direction and approximate magnitude.  
* **Check assumptions** that underpin formal statistical models, such as normality and linearity.  
* **Generate and refine hypotheses** that can be rigorously tested in later stages of the research process.

This chapter is structured around the two complementary pillars of exploration: numerical summaries and graphical techniques. First, we will delve into **descriptive statistics**, the quantitative language used to summarize the core features of the data, such as its center, spread, and shape.6 Second, we will explore

**graphical methods**, primarily using the ggplot2 package, to create visualizations that reveal patterns, trends, and deviations that numbers alone can obscure.3

Embarking on a data analysis project without a thorough EDA is akin to navigating a new city without a map. You might eventually reach a destination, but you risk getting lost, making wrong turns, and missing important landmarks along the way. The most profound discoveries often arise not from complex algorithms but from the disciplined, insightful act of looking at the data first. EDA is the essential practice that prevents analysts from fitting a sophisticated but fundamentally inappropriate model to data they do not truly understand. It is, in essence, a form of risk management for the scientific process.

## **The Language of Data: Numerical Summaries**

Before we can visualize our data, it is essential to understand its fundamental properties through numerical summaries. Descriptive statistics provide a concise, quantitative summary of a dataset's main features. These are not merely abstract numbers; they are powerful descriptors that begin to tell the story of our data, providing a framework for deeper investigation.

### **Finding the Center: Measures of Central Tendency**

Measures of central tendency describe the "typical" or "central" value in a dataset. R provides straightforward functions for calculating the three most common measures.

#### **The Mean**

The **mean**, or arithmetic average, is the most common measure of central tendency. It is calculated by summing all values in a dataset and dividing by the number of observations.7 In R, the

mean() function performs this calculation. Conceptually, the mean represents the "balancing point" of the data; if the data points were weights on a seesaw, the mean would be the fulcrum.8

Let's use the palmerpenguins dataset, a modern and excellent dataset for demonstration purposes. We will focus on the body\_mass\_g variable.

R

\# Ensure the necessary packages are loaded  
\# install.packages(c("palmerpenguins", "tidyverse"))  
library(palmerpenguins)  
library(tidyverse)

\# Calculate the mean body mass, removing NA values  
mean\_body\_mass \<- mean(penguins$body\_mass\_g, na.rm \= TRUE)  
print(mean\_body\_mass)

 4201.754

The na.rm \= TRUE argument is crucial; it instructs the function to remove any missing values (NA) before computation. Without it, the function would return NA if any missing values were present.10

#### **The Median**

The **median** is the middle value of a dataset when the values are arranged in ascending order. It represents the 50th percentile, effectively dividing the distribution into two equal halves.7 The

median() function calculates this value.

R

\# Calculate the median body mass  
median\_body\_mass \<- median(penguins$body\_mass\_g, na.rm \= TRUE)  
print(median\_body\_mass)

 4050

#### **The Mode**

The **mode** is the value that appears most frequently in a dataset. Unlike the mean and median, base R does not have a built-in function to calculate the mode.11 This is partly because the mode is most useful for categorical data and can be ambiguous for continuous data (e.g., a dataset can have multiple modes or no mode at all).13

We can, however, easily create a custom function to find the mode:

R

get\_mode \<- function(x) {  
  \# Remove NA values to avoid them being a potential mode  
  x \<- x\[\!is.na(x)\]  
  \# Find unique values  
  unique\_vals \<- unique(x)  
  \# Find the unique value that occurs most frequently  
  unique\_vals\[which.max(tabulate(match(x, unique\_vals)))\]  
}

\# Calculate the mode for the species variable  
mode\_species \<- get\_mode(penguins$species)  
print(mode\_species)

 "Adelie"

#### **Key Concept: Robustness and the Mean vs. Median Dilemma**

A critical concept in descriptive statistics is **robustness**. A statistic is considered "robust" if it is not heavily influenced by outliers—extreme values that lie far from the rest of the data.14 The median is a robust measure of central tendency, while the mean is not.

Consider a dataset of salaries where most employees earn a moderate income, but the CEO's salary is exceptionally high. This single extreme value can dramatically inflate the mean salary, giving a misleading impression of the "typical" employee's earnings. The median, however, being the middle value, would remain largely unaffected and provide a more representative figure.16

Let's demonstrate this with a simple R example:

R

\# A vector of nine salaries  
salaries \<- c(50000, 52000, 48000, 60000, 55000, 51000, 49000, 58000, 53000)

\# Now, add an outlier (the CEO's salary)  
salaries\_with\_outlier \<- c(salaries, 5000000)

\# Calculate mean and median for both datasets  
mean\_original \<- mean(salaries)  
median\_original \<- median(salaries)

mean\_outlier \<- mean(salaries\_with\_outlier)  
median\_outlier \<- median(salaries\_with\_outlier)

cat("Original Mean:", mean\_original, "\\nOriginal Median:", median\_original, "\\n")  
cat("With Outlier Mean:", mean\_outlier, "\\nWith Outlier Median:", median\_outlier, "\\n")

Original Mean: 52888.89   
Original Median: 52000   
With Outlier Mean: 524600   
With Outlier Median: 54000 

The addition of a single outlier caused the mean to increase nearly tenfold, from approximately 53,000 to over 524,000. The median, however, only shifted slightly from 52,000 to 54,000.

This illustrates a profound point: the choice between the mean and the median is not merely technical but a decision about which aspect of "centrality" is most meaningful for a given dataset. For skewed distributions, such as income, housing prices, or reaction times, the median often provides a more accurate and representative picture of the typical value.16 If your initial EDA reveals a heavily skewed distribution or the presence of significant outliers, you should immediately question whether the mean is the most appropriate summary statistic for your analysis and subsequent reports.

### **Quantifying the Spread: Measures of Variability**

While central tendency tells us about the typical value, measures of variability (or dispersion) describe how spread out or clustered together the data points are.17

#### **Range, Variance, and Standard Deviation**

* **Range:** The simplest measure of spread, calculated as the difference between the maximum and minimum values. The range() function in R returns the minimum and maximum values themselves.11  
* **Variance:** A measure of how far each value in the dataset is from the mean. It is calculated as the average of the squared differences from the mean. A larger variance indicates greater spread.17 In R, this is computed with  
  var().  
* **Standard Deviation:** This is simply the square root of the variance and is the most commonly reported measure of spread. A key advantage is that it is expressed in the same units as the original data, making it more interpretable than the variance.7 It is calculated with  
  sd().

R

\# Calculate variability measures for body mass  
body\_mass\_range \<- range(penguins$body\_mass\_g, na.rm \= TRUE)  
body\_mass\_var \<- var(penguins$body\_mass\_g, na.rm \= TRUE)  
body\_mass\_sd \<- sd(penguins$body\_mass\_g, na.rm \= TRUE)

print(body\_mass\_range)  
print(body\_mass\_var)  
print(body\_mass\_sd)

 2700 6300  
 643131.1  
 801.9545

#### **Conceptual Link: Standard Deviation and the Normal Distribution**

The standard deviation is a powerful concept, especially when data follows a **normal distribution** (a symmetric, bell-shaped curve). For such distributions, the **Empirical Rule** (or the 68-95-99.7 rule) provides a highly intuitive framework for interpretation 19:

* Approximately **68%** of the data falls within **1 standard deviation** of the mean.  
* Approximately **95%** of the data falls within **2 standard deviations** of the mean.  
* Approximately **99.7%** of the data falls within **3 standard deviations** of the mean.

For the penguins' body mass, the mean is 4201.8 g and the standard deviation is 802.0 g. Assuming a roughly normal distribution, this rule implies that about 68% of the penguins have a body mass between 3399.8 g (4201.8−802.0) and 5003.8 g (4201.8+802.0). This mental model transforms the standard deviation from an abstract number into a tangible descriptor of the data's spread.18

#### **The Interquartile Range (IQR)**

Just as the median is a robust measure of center, the **Interquartile Range (IQR)** is a robust measure of spread.14 It is calculated as the difference between the third quartile (Q3, the 75th percentile) and the first quartile (Q1, the 25th percentile). The IQR represents the range of the middle 50% of the data and is less sensitive to outliers than the standard deviation.17 It can be calculated in R using the

IQR() function.

R

\# Calculate the IQR for body mass  
body\_mass\_iqr \<- IQR(penguins$body\_mass\_g, na.rm \= TRUE)  
print(body\_mass\_iqr)

 1200

### **Characterizing the Shape: Skewness and Kurtosis**

Beyond center and spread, we can also numerically describe the shape of a distribution.

* **Skewness:** Measures the asymmetry of the distribution.  
  * A value of zero indicates a perfectly symmetric distribution.  
  * A positive value indicates a **right-skewed** distribution (a long tail to the right).  
  * A negative value indicates a **left-skewed** distribution (a long tail to the left).  
* **Kurtosis:** Measures the "tailedness" of the distribution compared to a normal distribution.  
  * A normal distribution has a kurtosis of 3 (or an "excess kurtosis" of 0).  
  * **Leptokurtic** distributions (kurtosis \> 3\) are more peaked with heavier tails, meaning outliers are more likely.  
  * **Platykurtic** distributions (kurtosis \< 3\) are flatter with lighter tails, meaning outliers are less likely.22

The moments package provides easy-to-use functions for these calculations. It is worth noting that different statistical software and R packages may use slightly different formulas for these calculations (e.g., sample vs. population estimators), so consulting the documentation is always wise.23

R

\# install.packages("moments")  
library(moments)

\# Calculate skewness and kurtosis for flipper length  
flipper\_skew \<- skewness(penguins$flipper\_length\_mm, na.rm \= TRUE)  
flipper\_kurt \<- kurtosis(penguins$flipper\_length\_mm, na.rm \= TRUE)

print(flipper\_skew)  
print(flipper\_kurt)

 0.345252  
 2.138943

The skewness of 0.35 suggests a slight right skew in flipper length. The kurtosis of 2.14 (less than 3\) indicates a platykurtic distribution, with slightly thinner tails than a normal distribution.

### **Efficient Summaries with the Tidyverse and skimr**

Calculating statistics one by one is instructive, but for practical analysis, more efficient methods are needed. The tidyverse provides powerful tools for this.

#### **Grouped Summaries**

A core task in EDA is comparing descriptive statistics across different groups. The combination of dplyr::group\_by() and summarise() is the idiomatic tidyverse way to achieve this. This approach allows for the calculation of multiple statistics for multiple groups in a single, readable pipeline.8

R

\# Calculate mean and sd of body mass for each species  
penguin\_summary \<- penguins %\>%  
  group\_by(species) %\>%  
  summarise(  
    mean\_body\_mass \= mean(body\_mass\_g, na.rm \= TRUE),  
    sd\_body\_mass \= sd(body\_mass\_g, na.rm \= TRUE),  
    n \= n()  
  )

print(penguin\_summary)

\# A tibble: 3 × 4  
  species   mean\_body\_mass sd\_body\_mass     n  
  \<fct\>              \<dbl\>        \<dbl\> \<int\>  
1 Adelie             3701\.        458\.    152  
2 Chinstrap          3733\.        384\.     68  
3 Gentoo             5076\.        504\.    124

This summary table immediately reveals that Gentoo penguins are, on average, substantially larger than Adelie and Chinstrap penguins.

#### **A Superior summary(): The skimr Package**

While base R's summary() function provides a quick overview, the skimr package offers a far more powerful and informative alternative. The skim() function produces a rich, console-friendly summary that separates variables by data type (e.g., numeric, factor) and provides a more comprehensive set of statistics, including missing value counts, quantiles, and a small inline histogram for a quick visual check of the distribution.25

R

\# install.packages("skimr")  
library(skimr)

\# Get a comprehensive summary of the penguins dataset  
skim(penguins)

\-- Data summary \--------------------------------------------------------------------------------------------------  
                           Values  
Name                       penguins  
Number of rows             344  
Number of columns          8  
\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_  
Column type frequency:  
  factor                   3  
  numeric                  5  
\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_  
Group variables            None

\-- Variable type: factor \-----------------------------------------------------------------------------------------  
  skim\_variable n\_missing complete\_rate ordered n\_unique top\_counts  
1 species               0             1 FALSE          3 Ade: 152, Gen: 124, Chi: 68  
2 island                0             1 FALSE          3 Bis: 168, Dre: 124, Tor: 52  
3 sex                  11         0.968 FALSE          2 Mal: 168, Fem: 165

\-- Variable type: numeric \----------------------------------------------------------------------------------------  
  skim\_variable     n\_missing complete\_rate    mean      sd    p0     p25    p50     p75   p100 hist  
1 bill\_length\_mm            2         0.994   43.9    5.46   32.1   39.2    44.4    48.5   59.6 ▆▇▇▅▂  
2 bill\_depth\_mm             2         0.994   17.2    1.97   13.1   15.6    17.3    18.7   21.5 ▃▇▇▅▂  
3 flipper\_length\_mm         2         0.994  201\.    14.1   172    190     201     213    231  ▇▃ ▇▇  
4 body\_mass\_g               2         0.994 4202\.   802\.   2700   3550    4050    4750   6300  ▇▅ ▇▆  
5 year                      0         1     2008\.     0.817 2007   2007    2008    2009   2009  ▇ ▇ ▇

This single command provides a wealth of information, making skim() an indispensable tool for the initial phase of any exploratory analysis.

## **Confronting Reality: Identifying and Handling Data Imperfections**

Real-world datasets are rarely perfect. They often contain missing values, errors, or observations that deviate from the norm. A crucial part of EDA is to act as a detective, identifying these imperfections and understanding their potential impact on the analysis. This section focuses on the two most common issues: missing data and outliers.

### **The Case of the Missing Data**

Missing data, represented in R as NA (Not Available), is a frequent challenge in research. Simply ignoring it can lead to biased results and flawed conclusions. The first step is to understand the extent and pattern of the missingness.

#### **Detection and Quantification**

Base R provides simple functions to identify and count NA values. The is.na() function returns a logical vector (or matrix) indicating the location of NAs. This can be combined with sum() to count the total number of missing values or colSums() to get a per-column count.26

R

\# Count total missing values in the penguins dataset  
total\_missing \<- sum(is.na(penguins))  
print(total\_missing)

\# Count missing values in each column  
col\_missing \<- colSums(is.na(penguins))  
print(col\_missing)

 19  
species              island     bill\_length\_mm      bill\_depth\_mm flipper\_length\_mm      body\_mass\_g              sex             year  
      0                   0                  2                  2                 2                  2               11                0

This tells us there are 19 missing values in total, with the sex variable having the most.

#### **Visualizing Missingness with naniar**

While counting is useful, visualizing the pattern of missing data provides much deeper understanding. The naniar package is the modern standard for this task in R.25 Its functions integrate seamlessly with

ggplot2 and provide intuitive displays of missingness.

The vis\_miss() function creates a heatmap-like plot of the entire dataset, showing exactly where the NAs are located. This is excellent for spotting patterns, such as whether missing values in one variable tend to co-occur with missing values in another.28

R

\# install.packages("naniar")  
library(naniar)

\# Visualize the overall missingness pattern  
vis\_miss(penguins)

The gg\_miss\_var() function creates a bar chart showing the number (or percentage) of missing values for each variable, making it easy to see which variables are most affected.30

R

\# Create a bar chart of missing values per variable  
gg\_miss\_var(penguins)

#### **Understanding the "Why": Missing Data Mechanisms**

Detecting *that* data is missing is the first step; understanding *why* it is missing is critical for deciding how to handle it. Statisticians classify missing data into three main mechanisms 32:

1. **Missing Completely at Random (MCAR):** The probability of a value being missing is completely random and does not depend on any other variable, observed or unobserved. For example, a lab sample is accidentally dropped and destroyed. This is the ideal (but rare) scenario, as the remaining observed data is still a random subsample of the full dataset.  
2. **Missing at Random (MAR):** The probability of a value being missing depends on other *observed* variables in the dataset, but not on the missing value itself. For example, if men are less likely to answer a survey question about depression than women, the missingness in the depression variable is conditional on the observed gender variable.  
3. **Missing Not at Random (MNAR):** The probability of a value being missing depends on the value of the variable itself. For example, individuals with very high incomes may be less likely to report their income. This is the most problematic scenario, as the missingness is systematic and related to the unobserved values.

The visual patterns revealed by naniar can provide clues about the underlying mechanism. For instance, if vis\_miss() shows that missing values in an income variable are heavily concentrated within a specific education\_level group, this suggests a MAR pattern. If you suspect that high-income earners are selectively not responding, that points toward MNAR. This inference is crucial because the choice of how to handle missing data depends heavily on the likely mechanism. Naively deleting rows with missing data (listwise deletion) is generally acceptable under MCAR, but it can introduce significant bias under MAR or MNAR scenarios, as it would systematically remove certain subgroups from the analysis, leading to skewed and unreliable results.34

**Table 5.1: A Practical Guide to Missing Data Mechanisms**

| Mechanism | Description | Example | Implication for Analysis |
| :---- | :---- | :---- | :---- |
| **MCAR** | Missingness is unrelated to any data, observed or unobserved. | A participant's response is lost due to a random computer glitch. | Listwise deletion is generally safe, though it reduces statistical power. |
| **MAR** | Missingness is related to other *observed* variables. | Men are less likely to fill out a depression survey than women. | Listwise deletion can introduce bias. More advanced methods like multiple imputation are preferred. |
| **MNAR** | Missingness is related to the *unobserved* value itself. | People with the highest incomes are most likely to not report their income. | Most difficult to handle. Deletion leads to severe bias. Requires advanced modeling or careful justification of assumptions. |

### **Unmasking the Outliers**

Outliers are observations that deviate significantly from the other observations in a dataset. They can arise from data entry mistakes, measurement errors, or they can be genuine but extreme values from the population.36 Identifying them is a key EDA task, as they can disproportionately influence statistical summaries (like the mean) and the results of many modeling techniques.

#### **Visual Detection with Boxplots**

As introduced in Chapter 4, boxplots (geom\_boxplot()) are an excellent first line of defense for spotting potential outliers. The visualization is based on a simple, robust statistical rule :

* The central **box** spans the Interquartile Range (IQR), from Q1 to Q3.  
* The **whiskers** extend from the box to the farthest data point that is still within **1.5 times the IQR** from the edge of the box.  
* Any data points that fall **beyond the whiskers** are plotted as individual points and flagged as potential outliers.

R

\# Create a boxplot of flipper length by species  
ggplot(penguins, aes(x \= species, y \= flipper\_length\_mm, fill \= species)) \+  
  geom\_boxplot() \+  
  labs(title \= "Flipper Length Distribution by Species", x \= "Species", y \= "Flipper Length (mm)") \+  
  theme\_minimal()

#### **The 1.5 \* IQR Rule: A Statistical Justification**

The choice of the 1.5 multiplier in the boxplot's whisker rule is not arbitrary. It was proposed by the statistician John Tukey as a reasonable rule of thumb. For data that follows a normal distribution, the range defined by Q1−1.5×IQR and Q3+1.5×IQR covers approximately 99.3% of the data. Therefore, an observation falling outside this range is a genuinely rare event, occurring with a probability of only about 0.7% (or about 1 in 150 observations).38 This provides a sound statistical basis for flagging these points for further investigation.

#### **Numerical Detection: Z-Scores**

For a single continuous variable, another common method for identifying outliers is the **Z-score**. The Z-score quantifies how many standard deviations a data point is from the mean of the distribution. It is calculated as:

Z=σx−μ​  
where x is the data point, μ is the mean, and σ is the standard deviation. A common rule of thumb is to consider any data point with an absolute Z-score greater than 3 to be a potential outlier.40

R

\# Calculate Z-scores for body mass  
penguins\_no\_na \<- penguins %\>% drop\_na(body\_mass\_g)  
penguins\_no\_na$body\_mass\_z \<- scale(penguins\_no\_na$body\_mass\_g)

\# Find penguins with a Z-score \> 3 or \< \-3  
outliers\_z \<- penguins\_no\_na %\>%  
  filter(abs(body\_mass\_z) \> 3)

print(outliers\_z)

#### **Advanced Topic: Multivariate Outliers**

An observation may not be an outlier on any single variable but can be an outlier when considering multiple variables together. For example, a person who is 7 feet tall is unusual but not an outlier. A person who weighs 100 pounds is also not an outlier. However, a person who is 7 feet tall *and* weighs 100 pounds is a clear **multivariate outlier**.

The **Mahalanobis distance** is a statistical measure used to detect such outliers. It measures the distance of a point from the center of a multivariate distribution, accounting for the correlation between the variables.42 A larger Mahalanobis distance indicates that a data point is more unusual. In R, the

mahalanobis() function from the stats package can compute this. The resulting distances can then be compared to a chi-squared distribution to formally identify outliers.43

### **Initial Strategies for Imperfect Data**

The goal of EDA is primarily *diagnosis*. Once you have identified missing values or outliers, the question becomes what to do about them. While the definitive treatment of these issues (e.g., via sophisticated imputation methods) is a topic for later chapters, here are some initial strategies to consider during the exploratory phase:

1. **Deletion:** The simplest approach is to remove rows with missing values (na.omit()) or outliers. This is quick but can be problematic. Deleting missing data can introduce bias if the data are not MCAR, and deleting outliers can remove genuinely important information about the tails of a distribution.1  
2. **Imputation (for Missing Values):** This involves replacing missing values with plausible estimates. During EDA, a simple approach like replacing NAs with the mean or median of the column can be used to allow visualizations to run without errors. However, be aware that this artificially reduces the variance of the data and should be done with caution.36  
3. **Transformation or Capping (for Outliers):** Instead of removing outliers, their influence can be reduced. **Capping** involves replacing extreme values with a certain percentile (e.g., replacing all values above the 99th percentile with the value of the 99th percentile). **Transformation**, such as applying a logarithmic transform (log()), can also compress the scale of the data and pull in extreme values, making patterns easier to see. These are forms of feature engineering informed directly by your EDA findings.

## **Visual Inquiry: Uncovering Patterns with ggplot2 and Friends**

Numerical summaries provide a solid foundation, but to truly understand the stories hidden in the data, we must visualize it. Graphical exploration can reveal patterns, relationships, trends, and anomalies that are difficult or impossible to detect with numbers alone. The ggplot2 package provides a powerful and flexible grammar for creating a vast array of plots.

### **Understanding Individual Variables (Univariate Visualization)**

Univariate visualizations focus on the distribution of a single variable at a time.

#### **Histograms and Density Plots**

For continuous variables, the **histogram** is the most fundamental tool for visualizing a distribution. It groups data into bins of equal width and plots the frequency (count) of observations in each bin. The geom\_histogram() layer in ggplot2 creates histograms. A related plot is the **density plot**, created with geom\_density(), which provides a smoothed estimate of the distribution's shape.45

R

\# Histogram of penguin body mass  
ggplot(penguins, aes(x \= body\_mass\_g)) \+  
  geom\_histogram(binwidth \= 200, color \= "black", fill \= "lightblue") \+  
  labs(title \= "Distribution of Penguin Body Mass", x \= "Body Mass (g)", y \= "Frequency")

\# Density plot of the same variable  
ggplot(penguins, aes(x \= body\_mass\_g)) \+  
  geom\_density(fill \= "lightblue", alpha \= 0.5) \+  
  labs(title \= "Density of Penguin Body Mass", x \= "Body Mass (g)", y \= "Density")

#### **Interpreting Histogram Shapes**

The shape of a histogram provides crucial clues about the underlying data 47:

* **Symmetric (Bell-Shaped):** Indicates a normal or near-normal distribution. The mean, median, and mode are approximately equal. This is a key assumption for many statistical tests.  
* **Skewed Right (Positively Skewed):** A long tail extends to the right. Most values are clustered on the left. In this case, mean \> median. This is common for variables that cannot be negative, like income or counts.48  
* **Skewed Left (Negatively Skewed):** A long tail extends to the left. Most values are clustered on the right. Here, mean \< median. This can occur with data that has a natural upper bound, like exam scores.48  
* **Bimodal:** Has two distinct peaks, suggesting the presence of two different underlying subgroups in the data. For example, a histogram of heights in a population of men and women might be bimodal.50  
* **Uniform:** All bins have roughly the same frequency. This may indicate that the data is randomly distributed or that the number of bins is too small.48

#### **Boxplots**

Revisiting the boxplot (geom\_boxplot()), it serves as an excellent compact summary for univariate distributions. Its true power in EDA, however, lies in comparing the distributions of a continuous variable across different levels of a categorical variable.1

R

\# Comparing body mass across the three islands  
ggplot(penguins, aes(x \= island, y \= body\_mass\_g, fill \= island)) \+  
  geom\_boxplot() \+  
  labs(title \= "Body Mass Distribution by Island", x \= "Island", y \= "Body Mass (g)") \+  
  theme\_minimal() \+  
  guides(fill \= "none") \# Remove redundant legend

### **Exploring Relationships Between Variables (Bivariate Visualization)**

After understanding individual variables, the next step is to explore how they relate to one another.

#### **Correlation Analysis**

Correlation measures the strength and direction of a linear relationship between two continuous variables. The Pearson correlation coefficient, r, ranges from \-1 to \+1.

To analyze correlations among multiple numeric variables, one can first compute a **correlation matrix** using the cor() function. Since a matrix of numbers can be difficult to interpret, visualizing it as a heatmap is highly effective. The corrplot package is an excellent tool for this purpose. It can represent correlations with colored squares or circles and can reorder the matrix to group highly correlated variables together, making it easier to spot patterns.51

R

\# install.packages("corrplot")  
library(corrplot)

\# Select only numeric columns and remove NAs  
penguins\_numeric \<- penguins %\>%  
  select(where(is.numeric)) %\>%  
  drop\_na()

\# Compute the correlation matrix  
cor\_matrix \<- cor(penguins\_numeric)

\# Visualize the correlation matrix  
corrplot(cor\_matrix, method \= "color", order \= "hclust", addCoef.col \= "black")

The order \= "hclust" argument uses hierarchical clustering to group similar variables, which can reveal underlying structures in the data.

**Table 5.2: A Heuristic for Interpreting Correlation Coefficients**

| Coefficient Range (∣r∣) | Strength | Interpretation |  
| :--- | :--- | :--- |  
| 0.80 \- 1.00 | Very Strong | Variables move in near-perfect unison. |  
| 0.60 \- 0.79 | Strong | A clear and substantial linear relationship exists. |  
| 0.40 \- 0.59 | Moderate | A noticeable but not overwhelming linear relationship. |  
| 0.20 \- 0.39 | Weak | A slight, but discernible, linear relationship. |  
| 0.00 \- 0.19 | Very Weak | The linear relationship is negligible or non-existent. |  
*Note: This table provides general guidelines. The practical significance of a correlation always depends on the research context*.54

#### **The Scatterplot Matrix: The Ultimate EDA Tool**

For a rapid, comprehensive overview of all pairwise relationships in a dataset, the **scatterplot matrix** (or pair plot) is an indispensable tool. The GGally::ggpairs() function creates a sophisticated matrix of plots that is arguably one of the most powerful single functions for EDA.52

By default, ggpairs() generates a grid with:

* **Scatterplots** for each pair of continuous variables in the lower triangle.  
* **Correlation coefficients** for each pair in the upper triangle.  
* **Density plots** for each continuous variable along the diagonal.  
* **Boxplots** for continuous vs. categorical variable combinations.

Its real power is unlocked when a categorical variable is mapped to an aesthetic like color. This reveals group-specific patterns and relationships across the entire dataset in one view.

R

\# install.packages("GGally")  
library(GGally)

\# Create a comprehensive pair plot, colored by species  
ggpairs(penguins, aes(color \= species, alpha \= 0.5))

This single plot allows for the simultaneous investigation of distributions, correlations, and group differences, embodying the efficiency and depth of a well-executed EDA.

## **The EDA Workflow in Practice: A Case Study with palmerpenguins**

Having covered the individual tools and concepts, this section synthesizes them into a cohesive, narrative-driven workflow. We will demonstrate how to "think" during EDA, moving from broad questions to specific insights through a cycle of summarization and visualization. The palmerpenguins dataset will serve as our subject.6

### **Step 1: The First Look \- Getting Acquainted**

The first step is always to get a high-level sense of the data's structure and content.

**Questions:** What variables are included? What are their data types? How many observations are there? Are there any obvious missing values?

**Tools:** glimpse() for structure, skim() for a rich summary.

R

\# Load all necessary libraries for the case study  
library(tidyverse)  
library(palmerpenguins)  
library(skimr)  
library(naniar)  
library(GGally)

\# Glimpse the data structure  
glimpse(penguins)

\# Get a detailed summary  
skim(penguins)

**Findings:** The dataset contains 344 observations and 8 variables, including factors (species, island, sex) and numeric variables (bill dimensions, flipper length, body mass, year). The skim() output immediately flags that sex and the four primary numeric measurements have missing values.

### **Step 2: Diving into Distributions (Univariate Analysis)**

Next, we examine the distribution of key individual variables to understand their characteristics.

**Questions:** How are the penguins distributed across species? What is the shape of the body mass distribution?

**Tools:** geom\_bar() for categorical variables, geom\_histogram() for continuous variables.

R

\# Distribution of species  
ggplot(penguins, aes(x \= fct\_infreq(species), fill \= species)) \+  
  geom\_bar() \+  
  labs(title \= "Penguin Count by Species", x \= "Species", y \= "Count") \+  
  theme\_minimal()

\# Distribution of body mass  
ggplot(penguins, aes(x \= body\_mass\_g)) \+  
  geom\_histogram(binwidth \= 250, color \= "black", fill \= "steelblue") \+  
  labs(title \= "Distribution of Penguin Body Mass", x \= "Body Mass (g)", y \= "Frequency")

**Narrative:** The bar chart shows a relatively balanced number of Adelie and Gentoo penguins, with fewer Chinstrap penguins. The histogram of body mass appears somewhat bimodal, with two distinct peaks. This pattern is a strong clue that there might be underlying subgroups influencing body mass. This could be due to species or sex, a hypothesis we can now investigate.

### **Step 3: Data Quality Check**

Before exploring relationships, we must formally address the imperfections noted in Step 1\.

**Questions:** Where exactly are the missing values? Are there any extreme outliers that might distort our analysis?

**Tools:** vis\_miss() from naniar, geom\_boxplot().

R

\# Visualize the pattern of missing data  
vis\_miss(penguins)

\# Check for outliers in body mass across species  
ggplot(penguins, aes(x \= species, y \= body\_mass\_g, fill \= species)) \+  
  geom\_boxplot() \+  
  labs(title \= "Body Mass Outlier Check", x \= "Species", y \= "Body Mass (g)")

**Narrative:** The vis\_miss() plot confirms that missingness is sparse and primarily affects the sex variable. The boxplots do not flag any extreme outliers based on the 1.5 \* IQR rule. The distributions appear distinct for each species, reinforcing our earlier hypothesis. For the subsequent relationship analysis, we will filter out the few rows with missing data to ensure the functions run correctly, while noting that a more formal analysis would require imputation.

### **Step 4: Uncovering Relationships (Bivariate & Multivariate Analysis)**

Now we move to the core of the exploration: understanding how variables interact.

**Questions:** Is there a relationship between bill length and bill depth? How do physical measurements relate to body mass? Do these relationships differ by species?

**Tools:** corrplot() for a quick overview, ggpairs() for a deep dive.

R

\# Create a ggpairs plot to explore all relationships, colored by species  
\# We will drop NA values for this visualization  
penguins\_complete \<- penguins %\>% drop\_na()

ggpairs(penguins\_complete,   
        columns \= c("bill\_length\_mm", "bill\_depth\_mm", "flipper\_length\_mm", "body\_mass\_g"),  
        aes(color \= species, alpha \= 0.6)) \+  
  labs(title \= "Pairwise Relationships of Penguin Measurements by Species")

**Narrative:** The ggpairs plot is incredibly revealing. We observe a strong positive correlation between flipper\_length\_mm and body\_mass\_g, which is biologically intuitive—larger penguins have longer flippers. More importantly, the scatterplots clearly show that the three species form distinct clusters in the measurement space. For example, in the bill\_length\_mm vs. bill\_depth\_mm plot, Adelie penguins tend to have shorter, deeper bills, while Gentoo penguins have longer, shallower bills. This visual separation is a powerful finding.

### **Step 5: Synthesis and Hypothesis Generation**

The final step of EDA is to summarize the findings and translate them into formal, testable hypotheses for the next stage of analysis.

**Summary of Findings:**

* The dataset contains three penguin species, with Gentoo penguins being significantly larger and heavier on average.  
* The physical measurements (bill dimensions, flipper length, body mass) are all positively correlated with each other.  
* The three species are highly separable based on their physical measurements, forming distinct clusters in multivariate space.  
* The data quality is high, with very few missing values and no extreme outliers.

**Generated Hypotheses:**

1. **Hypothesis for Statistical Testing (Chapter 6 & 7):** The mean body mass of Gentoo penguins is significantly greater than that of Adelie and Chinstrap penguins.  
2. **Hypothesis for Modeling (Part 3):** A classification model (such as a decision tree or logistic regression) using bill length, bill depth, and flipper length as predictors can accurately classify a penguin's species.

This case study demonstrates that a structured EDA workflow is a narrative process. It is not a random collection of plots but a story uncovered by asking progressively deeper questions, letting the data provide answers, and using those answers to formulate the next, more specific inquiry. The tools are the grammar, but the analyst is the author of this story.

## **Chapter Summary & Key Takeaways**

This chapter has guided you through the philosophy and practice of Exploratory Data Analysis, the critical first step in any data-driven research project. It is a process of inquiry and discovery that builds a deep, foundational understanding of your data.

* **Core Principles of EDA:** EDA is a mindset of curiosity, driven by asking questions. Its goals are to summarize data, detect imperfections, visualize patterns, and generate hypotheses before formal modeling.  
* **Numerical Summaries:** Descriptive statistics quantify the data's central tendency (mean, median, mode), variability (standard deviation, IQR), and shape (skewness, kurtosis). The choice of statistic (e.g., mean vs. median) should be informed by the data's distribution.  
* **Data Imperfections:** Real-world data is often messy. Identifying the extent and pattern of missing values (using naniar) and detecting outliers (using boxplots and the 1.5 \* IQR rule) are essential diagnostic steps.  
* **Visual Exploration:** Graphical methods are paramount for uncovering patterns. Histograms and density plots reveal the shape of distributions, while correlation plots and scatterplot matrices (corrplot, ggpairs) expose relationships between variables.  
* **The EDA Workflow:** A successful EDA follows a narrative structure: start with a broad overview, drill down into individual variable distributions, check for data quality issues, explore relationships between variables, and conclude by synthesizing findings into testable hypotheses.

**Key R Functions and Packages:**

* **Descriptive Statistics:** mean(), median(), sd(), IQR(), moments::skewness()  
* **Efficient Summaries:** dplyr::summarise(), skimr::skim()  
* **Missing Data:** is.na(), naniar::vis\_miss()  
* **Visualization (ggplot2):** geom\_histogram(), geom\_density(), geom\_boxplot(), geom\_point()  
* **Relationship Visualization:** corrplot::corrplot(), GGally::ggpairs()

Ultimately, a thorough EDA is the cornerstone of robust, reliable, and reproducible research. It ensures that the subsequent statistical analyses and models you build are not just technically correct but are also meaningfully and appropriately applied to the data at hand.

#### **Works cited**

1. 7 Exploratory Data Analysis \- R for Data Science \- Hadley Wickham, accessed on July 30, 2025, [https://r4ds.had.co.nz/exploratory-data-analysis.html](https://r4ds.had.co.nz/exploratory-data-analysis.html)  
2. What is Exploratory Data Analysis? \- IBM, accessed on July 30, 2025, [https://www.ibm.com/think/topics/exploratory-data-analysis](https://www.ibm.com/think/topics/exploratory-data-analysis)  
3. Exploratory Data Analysis \- Secondary Analysis of Electronic Health Records \- NCBI, accessed on July 30, 2025, [https://www.ncbi.nlm.nih.gov/books/NBK543641/](https://www.ncbi.nlm.nih.gov/books/NBK543641/)  
4. 10 Exploratory data analysis \- R for Data Science (2e) \- Hadley Wickham, accessed on July 30, 2025, [https://r4ds.hadley.nz/EDA.html](https://r4ds.hadley.nz/EDA.html)  
5. Chapter 4 Exploratory Data Analysis, accessed on July 30, 2025, [https://www.stat.cmu.edu/\~hseltman/309/Book/chapter4.pdf](https://www.stat.cmu.edu/~hseltman/309/Book/chapter4.pdf)  
6. Exploratory Data Analysis in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/exploratory-data-analysis-in-r-programming/](https://www.geeksforgeeks.org/r-language/exploratory-data-analysis-in-r-programming/)  
7. 1.4: Central Tendency and Variability \- Statistics LibreTexts, accessed on July 30, 2025, [https://stats.libretexts.org/Bookshelves/Applied\_Statistics/Basic\_Statistics\_Using\_R\_for\_Crime\_Analysis\_(Choi)/01%3A\_Chapters/1.04%3A\_Central\_Tendency\_and\_Variability](https://stats.libretexts.org/Bookshelves/Applied_Statistics/Basic_Statistics_Using_R_for_Crime_Analysis_\(Choi\)/01%3A_Chapters/1.04%3A_Central_Tendency_and_Variability)  
8. 2 Descriptives | Reproducible statistics for psychologists with R, accessed on July 30, 2025, [https://www.crumplab.com/rstatsforpsych/descriptives.html](https://www.crumplab.com/rstatsforpsych/descriptives.html)  
9. Chapter 1 Introduction: Measurement, Central Tendency, Dispersion \- GitHub Pages, accessed on July 30, 2025, [https://qmul-spir.github.io/POLM083/seminar1.html](https://qmul-spir.github.io/POLM083/seminar1.html)  
10. R Mean, Median, Mode \- Tutorialspoint, accessed on July 30, 2025, [https://www.tutorialspoint.com/r/r\_mean\_median\_mode.htm](https://www.tutorialspoint.com/r/r_mean_median_mode.htm)  
11. Central Tendency and Spread in R Programming \- MAKE ME ANALYST, accessed on July 30, 2025, [https://makemeanalyst.com/statistics-with-r/central-tendency-and-spread-in-r-programming/](https://makemeanalyst.com/statistics-with-r/central-tendency-and-spread-in-r-programming/)  
12. Finding the Mode in R: A Step-By-Step Guide \- DEV Community, accessed on July 30, 2025, [https://dev.to/rapp2043/finding-the-mode-in-r-a-step-by-step-guide-49h1](https://dev.to/rapp2043/finding-the-mode-in-r-a-step-by-step-guide-49h1)  
13. How to Calculate the Mode in R (With Examples) \- Statology, accessed on July 30, 2025, [https://www.statology.org/mode-in-r/](https://www.statology.org/mode-in-r/)  
14. Outliers in Data Analysis: Examples and Strategies \- QuantHub, accessed on July 30, 2025, [https://www.quanthub.com/what-are-outliers/](https://www.quanthub.com/what-are-outliers/)  
15. Robust Statistics / Estimation (Robustness) & Breakdown Point, accessed on July 30, 2025, [https://www.statisticshowto.com/robust-statistics/](https://www.statisticshowto.com/robust-statistics/)  
16. Outliers: Handling Outliers with the Median as a Robust Measure \- FasterCapital, accessed on July 30, 2025, [https://fastercapital.com/content/Outliers--Handling-Outliers-with-the-Median-as-a-Robust-Measure.html](https://fastercapital.com/content/Outliers--Handling-Outliers-with-the-Median-as-a-Robust-Measure.html)  
17. Variability in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/variability-in-r-programming/](https://www.geeksforgeeks.org/r-language/variability-in-r-programming/)  
18. Standard deviation \- Wikipedia, accessed on July 30, 2025, [https://en.wikipedia.org/wiki/Standard\_deviation](https://en.wikipedia.org/wiki/Standard_deviation)  
19. The Standard Normal Distribution | Introduction to Statistics \- Lumen Learning, accessed on July 30, 2025, [https://courses.lumenlearning.com/introstats1/chapter/the-standard-normal-distribution/](https://courses.lumenlearning.com/introstats1/chapter/the-standard-normal-distribution/)  
20. Normal distributions review (article) | Khan Academy, accessed on July 30, 2025, [https://www.khanacademy.org/math/statistics-probability/modeling-distributions-of-data/normal-distributions-library/a/normal-distributions-review](https://www.khanacademy.org/math/statistics-probability/modeling-distributions-of-data/normal-distributions-library/a/normal-distributions-review)  
21. The Connection between Standard Deviation and Normal Distribution, accessed on July 30, 2025, [https://www.standarddeviationcalculator.io/blog/the-connection-between-standard-deviation-and-normal-distribution-](https://www.standarddeviationcalculator.io/blog/the-connection-between-standard-deviation-and-normal-distribution-)  
22. How to Calculate Skewness & Kurtosis in R \- Statology, accessed on July 30, 2025, [https://www.statology.org/skewness-kurtosis-in-r/](https://www.statology.org/skewness-kurtosis-in-r/)  
23. Skewness/Kurtosis \- GitHub Pages, accessed on July 30, 2025, [https://psiaims.github.io/CAMIS/R/summary\_skew\_kurt.html](https://psiaims.github.io/CAMIS/R/summary_skew_kurt.html)  
24. 17 Descriptive tables \- The Epidemiologist R Handbook, accessed on July 30, 2025, [https://www.epirhandbook.com/en/new\_pages/tables\_descriptive.html](https://www.epirhandbook.com/en/new_pages/tables_descriptive.html)  
25. Exploratory Data Analysis in R \- Cosima Meyer, accessed on July 30, 2025, [https://cosimameyer.com/post/exploratory-data-analysis-in-r/](https://cosimameyer.com/post/exploratory-data-analysis-in-r/)  
26. Dealing with Missing Values · UC Business Analytics R ..., accessed on July 30, 2025, [https://uc-r.github.io/missing\_values](https://uc-r.github.io/missing_values)  
27. Handling Missing Values in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/handling-missing-values-in-r-programming/](https://www.geeksforgeeks.org/r-language/handling-missing-values-in-r-programming/)  
28. Dealing with Missing Data in R, naniar \- RPubs, accessed on July 30, 2025, [https://rpubs.com/lumpen95/1269163](https://rpubs.com/lumpen95/1269163)  
29. What's Missing with {naniar} – DaSL Data Snacks, accessed on July 30, 2025, [https://hutchdatascience.org/data\_snacks/r\_snacks/naniar.html](https://hutchdatascience.org/data_snacks/r_snacks/naniar.html)  
30. Getting Started with naniar, accessed on July 30, 2025, [https://cran.r-project.org/web/packages/naniar/vignettes/getting-started-w-naniar.html](https://cran.r-project.org/web/packages/naniar/vignettes/getting-started-w-naniar.html)  
31. Gallery of Missing Data Visualisations, accessed on July 30, 2025, [https://cran.r-project.org/package=naniar/vignettes/naniar-visualisation.html](https://cran.r-project.org/package=naniar/vignettes/naniar-visualisation.html)  
32. Missing data, accessed on July 30, 2025, [https://cran.r-project.org/web/packages/finalfit/vignettes/missing.html](https://cran.r-project.org/web/packages/finalfit/vignettes/missing.html)  
33. 5 Essential Insights on Missing Completely at Random Data \- Number Analytics, accessed on July 30, 2025, [https://www.numberanalytics.com/blog/5-essential-insights-MCAR-data](https://www.numberanalytics.com/blog/5-essential-insights-MCAR-data)  
34. Introduction to Handling Missing Values \- Aptech, accessed on July 30, 2025, [https://www.aptech.com/blog/introduction-to-handling-missing-values/](https://www.aptech.com/blog/introduction-to-handling-missing-values/)  
35. Can I ignore the NMAR assumption when missing data is very negligible? \- ResearchGate, accessed on July 30, 2025, [https://www.researchgate.net/post/Can\_I\_ignore\_the\_NMAR\_assumption\_when\_missing\_data\_is\_very\_negligible](https://www.researchgate.net/post/Can_I_ignore_the_NMAR_assumption_when_missing_data_is_very_negligible)  
36. Outlier Treatment With R | Multivariate Outliers \- R-Statistics.co, accessed on July 30, 2025, [http://r-statistics.co/Outlier-Treatment-With-R.html](http://r-statistics.co/Outlier-Treatment-With-R.html)  
37. A Guide to Data Exploration, Steps Data Analysis \- Analytics Vidhya, accessed on July 30, 2025, [https://www.analyticsvidhya.com/blog/2016/01/guide-data-exploration/](https://www.analyticsvidhya.com/blog/2016/01/guide-data-exploration/)  
38. Why 1.5 Is Used in the IQR Rule for Outlier Detection \- Built In, accessed on July 30, 2025, [https://builtin.com/articles/1-5-iqr-rule](https://builtin.com/articles/1-5-iqr-rule)  
39. Why John Tukey set 1.5 IQR to detect outliers instead of 1 or 2? \- Math Stack Exchange, accessed on July 30, 2025, [https://math.stackexchange.com/questions/966331/why-john-tukey-set-1-5-iqr-to-detect-outliers-instead-of-1-or-2](https://math.stackexchange.com/questions/966331/why-john-tukey-set-1-5-iqr-to-detect-outliers-instead-of-1-or-2)  
40. How to Find Outliers in R (3 Methods) \- Statology, accessed on July 30, 2025, [https://www.statology.org/find-outliers-in-r/](https://www.statology.org/find-outliers-in-r/)  
41. Outliers detection in R \- Stats and R, accessed on July 30, 2025, [https://statsandr.com/blog/outliers-detection-in-r/](https://statsandr.com/blog/outliers-detection-in-r/)  
42. Mahalanobis Distance & Multivariate Outlier Detection in R \- Built In, accessed on July 30, 2025, [https://builtin.com/data-science/mahalanobis-distance](https://builtin.com/data-science/mahalanobis-distance)  
43. Compute Mahalanobis Distance and Flag Multivariate Outliers — mahalanobis\_distance, accessed on July 30, 2025, [https://rpkgs.datanovia.com/rstatix/reference/mahalanobis\_distance.html](https://rpkgs.datanovia.com/rstatix/reference/mahalanobis_distance.html)  
44. How to Handle Missing Data in R \- KDnuggets, accessed on July 30, 2025, [https://www.kdnuggets.com/how-to-handle-missing-data-in-r](https://www.kdnuggets.com/how-to-handle-missing-data-in-r)  
45. Plotting distributions (ggplot2) \- Cookbook for R, accessed on July 30, 2025, [http://cookbook-r.com/Graphs/Plotting\_distributions\_(ggplot2)/](http://cookbook-r.com/Graphs/Plotting_distributions_\(ggplot2\)/)  
46. Plotting distributions (ggplot2) \- Cookbook for R, accessed on July 30, 2025, [http://www.cookbook-r.com/Graphs/Plotting\_distributions\_(ggplot2)/](http://www.cookbook-r.com/Graphs/Plotting_distributions_\(ggplot2\)/)  
47. How to Interpret Histograms \- LabXchange, accessed on July 30, 2025, [https://www.labxchange.org/library/items/lb:LabXchange:10d3270e:html:1](https://www.labxchange.org/library/items/lb:LabXchange:10d3270e:html:1)  
48. Histogram: Study the shape \- Advantive, accessed on July 30, 2025, [https://www.advantive.com/solutions/spc-software/quality-advisor/data-analysis-tools/histogram-study-the-shape/](https://www.advantive.com/solutions/spc-software/quality-advisor/data-analysis-tools/histogram-study-the-shape/)  
49. How to Interpret the Shape of Statistical Data in a Histogram \- Dummies.com, accessed on July 30, 2025, [https://www.dummies.com/article/academics-the-arts/math/statistics/how-to-interpret-the-shape-of-statistical-data-in-a-histogram-169003/](https://www.dummies.com/article/academics-the-arts/math/statistics/how-to-interpret-the-shape-of-statistical-data-in-a-histogram-169003/)  
50. Exploring Histogram Shapes: A Comprehensive Guide with Illustrations, accessed on July 30, 2025, [https://statisticseasily.com/histogram-shapes/](https://statisticseasily.com/histogram-shapes/)  
51. An Introduction to corrplot Package, accessed on July 30, 2025, [https://cran.r-project.org/package=corrplot/vignettes/corrplot-intro.html](https://cran.r-project.org/package=corrplot/vignettes/corrplot-intro.html)  
52. Correlogram \- The R Graph Gallery, accessed on July 30, 2025, [https://r-graph-gallery.com/correlogram.html](https://r-graph-gallery.com/correlogram.html)  
53. An Introduction to corrplot Package, accessed on July 30, 2025, [https://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html](https://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html)  
54. statisticsbyjim.com, accessed on July 30, 2025, [https://statisticsbyjim.com/basics/correlations/\#:\~:text=Correlation%20Coefficient%20%3D%20%2B1%3A%20A,Coefficient%20%3D%200%3A%20No%20relationship.](https://statisticsbyjim.com/basics/correlations/#:~:text=Correlation%20Coefficient%20%3D%20%2B1%3A%20A,Coefficient%20%3D%200%3A%20No%20relationship.)  
55. Correlation Analysis and Interpretation | Statistical Methods for Data Science Class Notes, accessed on July 30, 2025, [https://library.fiveable.me/statistical-methods-for-data-science/unit-7/correlation-analysis-interpretation/study-guide/qra9VNWffns7VWty](https://library.fiveable.me/statistical-methods-for-data-science/unit-7/correlation-analysis-interpretation/study-guide/qra9VNWffns7VWty)  
56. Interpreting Correlation Coefficients \- Statistics By Jim, accessed on July 30, 2025, [https://statisticsbyjim.com/basics/correlations/](https://statisticsbyjim.com/basics/correlations/)  
57. Pairs plot in ggplot2 with ggpairs | R CHARTS, accessed on July 30, 2025, [https://r-charts.com/correlation/ggpairs/](https://r-charts.com/correlation/ggpairs/)  
58. Chapter 1 Exploratory Data Analysis | Statistics for Data Science R Code Guide \- Bookdown, accessed on July 30, 2025, [https://bookdown.org/ajsage/statistics\_for\_data\_science\_r\_code\_guide/exploratory-data-analysis.html](https://bookdown.org/ajsage/statistics_for_data_science_r_code_guide/exploratory-data-analysis.html)  
59. Chapter 4 Exploratory Data Analysis \- Bookdown, accessed on July 30, 2025, [https://bookdown.org/steve\_midway/DAR/exploratory-data-analysis.html](https://bookdown.org/steve_midway/DAR/exploratory-data-analysis.html)