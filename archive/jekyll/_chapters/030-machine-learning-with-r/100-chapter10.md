---
title: Introduction to Machine Learning in R
slug: chapter10
order: 080
published: false
abstract: >
    This chapter introduces the concepts of supervised and unsupervised learning. Readers will learn how to preprocess data, split datasets for validation, and implement cross-validation, laying the groundwork for building machine learning models.
---


This chapter marks a conceptual shift from the preceding parts of the book. While Chapters 5 through 9 focused on the principles of *statistical inference*—using data to understand relationships, test formal hypotheses, and draw conclusions about a wider population—Part 3 ventures into the domain of *predictive modeling*. Here, the primary objective is different. The goal is no longer just to explain the world as it is, but to build algorithms that can make accurate, generalizable predictions about new, unseen data. We move from asking "Why?" to asking "What will happen next?".

To navigate this new landscape, we will adopt the tidymodels ecosystem as our primary toolkit. tidymodels is a modern, modular collection of R packages designed with the same tidyverse principles of coherence, usability, and power that you have become familiar with.1 It provides a unified framework for the entire modeling process, from initial data splitting and preprocessing to model tuning and evaluation. The core packages we will encounter—

rsample, recipes, parsnip, workflows, tune, and yardstick—each handle a specific stage of the machine learning pipeline, working together seamlessly to create robust and reproducible models.3

This chapter will construct a complete, end-to-end machine learning workflow from the ground up. To make these concepts tangible, we will follow a single, running case study: predicting the quality of red wine using the well-known Wine Quality dataset from the UCI Machine Learning Repository.5 We will transform this problem from its original regression format (predicting a quality score from 0-10) into a more practical binary classification task: predicting whether a wine is of "good" or "poor" quality. This common and realistic approach will allow us to demonstrate every key concept on a single, coherent problem, building a foundational blueprint that we will reuse and adapt in the chapters to come.

## **10.1 The Machine Learning Paradigm: Supervised and Unsupervised Learning**

The fundamental division in machine learning is dictated by the nature of the data available and the question being asked. The most significant distinction lies in the presence or absence of a known outcome or "label" that the algorithm is intended to predict. This distinction gives rise to the two primary paradigms: supervised and unsupervised learning.7

### **10.1.1 Supervised Learning: Learning with a Teacher**

Supervised learning is the most common form of machine learning and is analogous to a student learning with a teacher. The algorithm is provided with a dataset that contains both input features (the predictors) and the corresponding correct outputs (the labels or outcome variable). The "supervision" comes from these labeled examples, which allow the model to learn a mapping function that can generalize to predict the output for new, unseen inputs.8 The goal is to create a model that is accurate in its predictions.

Supervised learning problems are typically categorized into two main types:

* **Classification**: The goal is to predict a discrete, categorical label. The output variable belongs to a finite set of classes. Classic examples include email spam detection ("spam" or "not spam"), medical diagnosis ("disease" or "no disease"), and sentiment analysis ("positive," "negative," or "neutral"). Our running example of classifying wine quality as "good" or "poor" is a quintessential classification task.8 Common algorithms for this task, which we will explore in subsequent chapters, include Logistic Regression, Support Vector Machines (SVMs), Decision Trees, and Random Forests.  
* **Regression**: The goal is to predict a continuous, numerical value. The output variable can take any value within a given range. Examples include forecasting sales revenue, predicting the price of a house based on its features, or estimating a patient's blood pressure. Had we chosen to predict the exact wine quality score on its 0-10 scale, it would have been a regression problem.8 Linear Regression, which you encountered in Chapter 7, is a foundational regression algorithm.

The power of supervised learning lies in its direct, measurable feedback loop. Because the correct answers are known for the training data, the model's performance can be explicitly calculated by comparing its predictions to the true labels. This error signal is then used to iteratively adjust the model's internal parameters to improve its accuracy.8 However, this high performance comes with a significant prerequisite: the availability of high-quality, labeled data. The process of collecting and labeling data can be the most labor-intensive and expensive part of a machine learning project, often requiring substantial human effort and deep domain expertise.10 The ultimate success of the models we will build in Chapters 11 and 12 is fundamentally dependent on the quality of the labeled data we provide them.

### **10.1.2 Unsupervised Learning: Finding Patterns on Your Own**

In contrast, unsupervised learning is akin to being given a vast library of books with no cataloging system and being asked to find the inherent structure within it. The data provided to an unsupervised algorithm is unlabeled; there is no pre-defined outcome variable to guide the learning process. The algorithm's task is to explore the data on its own and discover interesting patterns, groupings, or relationships.8

The main tasks in unsupervised learning include:

* **Clustering**: This is a technique for grouping similar data points together based on their features. The goal is to create clusters where the observations within a cluster are very similar to each other, and observations in different clusters are very different. Applications include customer segmentation (grouping customers by purchasing behavior), document analysis (grouping articles by topic), and image compression.8 We will delve into clustering methods like k-means in Chapter 8, and more advanced methods in Chapter 13.  
* **Association**: This method is used to discover rules that describe relationships between variables in large datasets. The most famous example is "market basket analysis," which can identify rules like, "Customers who buy product A also tend to buy product B." This is the technology behind many recommendation engines.8  
* **Dimensionality Reduction**: When dealing with datasets with a very high number of features (high dimensionality), it can be difficult to model and visualize. Dimensionality reduction techniques aim to reduce the number of variables while preserving the most important information and structure of the data. Principal Component Analysis (PCA), which we covered in Chapter 8, is a prime example of this. It is often used as a preprocessing step to improve the performance of supervised learning algorithms.8

Because there are no correct labels to compare against, evaluating the success of an unsupervised model can be more subjective and often requires human intervention to validate whether the discovered patterns are meaningful and useful.8

### **10.1.3 Semi-Supervised Learning: The Best of Both Worlds**

A third paradigm, semi-supervised learning, exists as a bridge between the two. This approach uses a combination of a small amount of labeled data and a large amount of unlabeled data. The underlying idea is that the patterns discovered in the unlabeled data can help improve the model's ability to make predictions on the labeled data. This is particularly useful in domains like medical imaging, where obtaining expert-labeled data (e.g., a radiologist identifying tumors in scans) is very expensive, but unlabeled data is plentiful.8

To solidify these concepts, Table 10.1 provides a side-by-side comparison of the core characteristics of supervised and unsupervised learning.

**Table 10.1: Supervised vs. Unsupervised Learning at a Glance**

| Characteristic | Supervised Learning | Unsupervised Learning |
| :---- | :---- | :---- |
| **Primary Goal** | Predict a known outcome or label.8 | Discover hidden patterns, structures, or insights in data.8 |
| **Input Data** | Labeled data (features and corresponding outcomes).7 | Unlabeled data (features only).7 |
| **Human Involvement** | High upfront effort for data collection and labeling.10 | High effort for interpreting and validating the discovered patterns.8 |
| **Common Tasks** | Classification, Regression.8 | Clustering, Association, Dimensionality Reduction.8 |
| **Example Algorithms** | Linear Regression, Random Forest, Support Vector Machines.8 | K-Means, Principal Component Analysis (PCA), Apriori.8 |
| **Evaluation** | Direct comparison of predictions to known true values (e.g., accuracy, RMSE). | Indirect measures of structure quality (e.g., cluster separation, variance explained). |

## **10.2 The Blueprint for Preprocessing: Feature Engineering with recipes**

Raw data is rarely, if ever, in a suitable state for direct use in machine learning models. The adage "Garbage In, Garbage Out" is a fundamental truth in data science: the performance of even the most sophisticated algorithm is capped by the quality of the data it is fed.11

**Feature engineering** is the crucial process of transforming raw data into a set of features that better represent the underlying problem to the predictive models. This can involve cleaning, transforming, and creating new variables.12 The

recipes package, a cornerstone of the tidymodels ecosystem, provides a powerful, elegant, and reproducible framework for defining and executing this entire preprocessing pipeline.14

### **10.2.1 Hands-On: Loading and Exploring the Wine Quality Data**

Let's begin by loading our case study dataset, which contains physicochemical properties of 1,599 red "Vinho Verde" wine samples from Portugal. Our goal is to predict the wine's quality.

First, we load the necessary libraries and the data. The original dataset has column names with spaces, which can be cumbersome in R, so we will clean them using the janitor package.

R

\# Load necessary libraries  
library(tidyverse)  
library(tidymodels)  
library(janitor)

\# Load the data  
wine\_raw \<- read\_csv("https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv",   
                     col\_types \= cols()) %\>%  
  \# The original file uses semicolons as separators  
  separate(col \= 1, into \= c("fixed\_acidity", "volatile\_acidity", "citric\_acid",   
                               "residual\_sugar", "chlorides", "free\_sulfur\_dioxide",   
                               "total\_sulfur\_dioxide", "density", "pH", "sulphates",   
                               "alcohol", "quality"), sep \= ";") %\>%  
  \# Convert all columns to numeric  
  mutate(across(everything(), as.numeric))

\# Let's inspect the data  
glimpse(wine\_raw)

\#\# Rows: 1,599  
\#\# Columns: 12  
\#\# $ fixed\_acidity        \<dbl\> 7.4, 7.8, 7.8, 11.2, 7.4, 7.4, 7.9, 7.3, 7.8, 7.5,…  
\#\# $ volatile\_acidity     \<dbl\> 0.700, 0.880, 0.760, 0.280, 0.700, 0.660, 0.600, …  
\#\# $ citric\_acid          \<dbl\> 0.00, 0.00, 0.04, 0.56, 0.00, 0.00, 0.06, 0.00, …  
\#\# $ residual\_sugar       \<dbl\> 1.9, 2.6, 2.3, 1.9, 1.9, 1.8, 1.6, 1.2, 2.0, 6.1,…  
\#\# $ chlorides            \<dbl\> 0.076, 0.098, 0.092, 0.075, 0.076, 0.075, 0.069, …  
\#\# $ free\_sulfur\_dioxide  \<dbl\> 11, 25, 15, 17, 11, 13, 15, 15, 9, 17, 15, 17, 16…  
\#\# $ total\_sulfur\_dioxide \<dbl\> 34, 67, 54, 60, 34, 40, 59, 21, 18, 102, 65, 102,…  
\#\# $ density              \<dbl\> 0.9978, 0.9968, 0.9970, 0.9980, 0.9978, 0.9978, …  
\#\# $ ph                   \<dbl\> 3.51, 3.20, 3.26, 3.16, 3.51, 3.51, 3.30, 3.39, …  
\#\# $ sulphates            \<dbl\> 0.56, 0.68, 0.65, 0.58, 0.56, 0.56, 0.46, 0.47, …  
\#\# $ alcohol              \<dbl\> 9.4, 9.8, 9.8, 9.8, 9.4, 9.4, 9.4, 10.0, 9.5, 10…  
\#\# $ quality              \<dbl\> 5, 5, 5, 6, 5, 5, 5, 7, 7, 5, 5, 5, 5, 5, 5, 5, …

The quality variable is an integer score from 3 to 8\. For our classification task, we will create a binary outcome variable, quality\_category. A common practice for this dataset is to define wines with a quality score of 7 or higher as "good" and the rest as "poor".6

R

wine\_data \<- wine\_raw %\>%  
  mutate(quality\_category \= factor(ifelse(quality \>= 7, "good", "poor"), levels \= c("good", "poor"))) %\>%  
  \# We no longer need the original numeric quality variable  
  select(-quality)

\# Check the distribution of our new outcome  
wine\_data %\>%  
  count(quality\_category)

\#\# \# A tibble: 2 × 2  
\#\#   quality\_category     n  
\#\#   \<fct\>            \<int\>  
\#\# 1 good               217  
\#\# 2 poor              1382

This is an imbalanced dataset, with many more "poor" quality wines than "good" ones. We will need to keep this in mind throughout our workflow.

### **10.2.2 Creating a Recipe: The recipe() Function**

A recipe defines the sequence of steps for data preprocessing. The recipe() function initializes this process. It takes two main arguments: a formula and the data.15

* **Formula**: This uses the standard R formula syntax (e.g., outcome \~ predictor1 \+ predictor2). A common and powerful convention is to use outcome \~., which specifies that the variable on the left of the \~ is the outcome, and all other variables in the data are predictors.  
* **Data**: This is the dataset the recipe will be based on, which should always be the **training data**. The recipe function doesn't perform any operations on this data; it simply uses it as a template to learn the variable names and their data types (e.g., numeric, factor).15

Let's create a basic recipe for our wine classification problem.

R

\# Note: We haven't created wine\_train yet. We are just creating the recipe object.  
\# We will split the data in section 9.3. For now, we use the full dataset as a template.  
wine\_recipe\_initial \<- recipe(quality\_category \~., data \= wine\_data)

wine\_recipe\_initial

\#\# Recipe  
\#\#   
\#\# Inputs:  
\#\#   
\#\#       role \#variables  
\#\#    outcome          1  
\#\#  predictor         11

### **10.2.3 Essential Preprocessing step\_\* Functions**

Once a recipe is initialized, we add preprocessing steps using a series of step\_\* functions, chained together with the %\>% pipe operator.

* **Handling Missing Data**: Our wine dataset is complete 17, but in most real-world projects, missing data is a major issue. Imputation is the process of filling in these missing values. Common strategies provided by  
  recipes include:  
  * step\_impute\_mean() / step\_impute\_median(): Replaces missing numeric values with the mean or median of the column (calculated from the training set).11  
  * step\_impute\_knn(): A more sophisticated method that finds the *k* most similar rows (neighbors) based on the other predictors and uses their values to impute the missing one.18  
* **Encoding Categorical Data**: Most machine learning algorithms require all input features to be numeric. If we had categorical predictors (e.g., region of origin), we would need to convert them. The standard method is one-hot encoding, which creates new binary (0/1) columns for each level of a categorical variable. This is done with step\_dummy().16  
* **Handling Problematic Variables**: Some variables can cause issues during modeling.  
  * step\_zv(): Removes "zero-variance" predictors—variables that have only a single unique value and thus provide no information.18  
  * step\_corr(): Removes predictors that are highly correlated with other predictors. This can help stabilize models like linear regression that are sensitive to multicollinearity.18

### **10.2.4 Transforming Numeric Predictors: Scaling and Normalization**

Many machine learning algorithms, particularly those based on distance calculations like k-Nearest Neighbors (k-NN) and Support Vector Machines (SVMs), are sensitive to the scale of the input features. A predictor with a large range (e.g., total\_sulfur\_dioxide in our data, which ranges up to 289\) can numerically dominate a predictor with a small range (e.g., pH, which ranges from 2.74 to 4.01), even if the smaller-range variable is more important for prediction. Scaling ensures all predictors are on a comparable footing.14

While the terms are sometimes used interchangeably, it is useful to distinguish between *scaling* (changing the range of data, e.g., to ) and *normalization* (changing the shape of the data's distribution, e.g., to a standard normal distribution).23 In

recipes, the most common transformation combines both aspects.

* **step\_normalize()**: This is the most widely used scaling method, also known as **standardization**. For each predictor, it subtracts the mean and divides by the standard deviation. The resulting transformed variable will have a mean of 0 and a standard deviation of 1 (a Z-score).20  
* **step\_range()**: This method performs min-max scaling, transforming the data to fall within a specified range, typically .21 The formula is  
  xnew​=xmax​−xmin​x−xmin​​.  
* **step\_YeoJohnson()** or **step\_BoxCox()**: These are power transformations designed to reduce skewness in a predictor's distribution, making it more symmetric. This can sometimes improve the performance of certain models.25

### **10.2.5 The recipe Workflow: prep(), bake(), and juice()**

A core design principle of the recipes package is the separation of the *definition* of the preprocessing steps from their *execution*. This is a critical feature for maintaining the statistical integrity of the modeling process and is accomplished through three key functions: prep(), bake(), and juice().14

This separation is the primary defense against a pernicious problem in machine learning known as **data leakage**. Data leakage occurs when information from outside the training dataset is used to create the model. This leads to an overly optimistic and biased evaluation of the model's performance, as the model has inadvertently "cheated" by seeing information from the data it will be tested on.

The recipes workflow prevents this by design:

1. **prep(recipe, training \= train\_data)**: This function *estimates* the required parameters for each step *using only the training data*. For step\_normalize(), it calculates the means and standard deviations of the predictors in train\_data. For step\_dummy(), it identifies the unique levels of the factor variables present in train\_data. The result is a "prepped" or "trained" recipe that contains all the necessary information for the transformations.  
2. **bake(prepped\_recipe, new\_data \=...)**: This function *applies* the pre-calculated transformations to new data (which could be the training set itself, a validation set, or the final test set). It does *not* re-estimate any parameters from the new\_data. It uses the means, standard deviations, and factor levels that were learned from the training data during the prep() stage. This ensures that the test set is treated as truly "unseen" data.  
3. **juice(prepped\_recipe)**: This is a convenient shortcut for bake(prepped\_recipe, new\_data \= NULL), which simply returns the processed *training set*.

This prep \-\> bake sequence is not merely procedural; it is the guardian of your model's validity, ensuring that the performance you measure is an honest reflection of its ability to generalize.

### **10.2.6 Hands-On: A Complete Recipe for the Wine Quality Dataset**

Let's now build a comprehensive recipe for our wine data, incorporating the steps we've discussed. We will normalize all numeric predictors and remove any zero-variance variables.

R

wine\_recipe \<- recipe(quality\_category \~., data \= wine\_data) %\>%  
  \# Normalize all numeric predictors (all predictors in this case)  
  step\_normalize(all\_numeric\_predictors()) %\>%  
  \# Remove any variables that have only one unique value  
  step\_zv(all\_predictors())

\# Now, let's imagine we have split our data (we'll do this for real in the next section)  
\# For demonstration, we'll use the full dataset to show the mechanics  
set.seed(123)  
temp\_split \<- initial\_split(wine\_data, prop \= 0.75)  
temp\_train \<- training(temp\_split)  
temp\_test \<- testing(temp\_split)

\# 1\. Prep the recipe using ONLY the training data  
prepped\_recipe \<- prep(wine\_recipe, training \= temp\_train)

\# 2\. Bake the recipe on the test data  
baked\_test\_data \<- bake(prepped\_recipe, new\_data \= temp\_test)

\# View the result  
glimpse(baked\_test\_data)

\#\# Rows: 401  
\#\# Columns: 12  
\#\# $ fixed\_acidity        \<dbl\> 1.63, \-0.28, \-0.85, \-0.85, \-0.28, 0.06, \-0.28, \-0…  
\#\# $ volatile\_acidity     \<dbl\> 1.00, 1.83, 0.44, 0.44, 0.78, 0.44, 0.17, 0.06, …  
\#\# $ citric\_acid          \<dbl\> \-1.37, \-1.37, \-1.22, \-1.22, \-1.37, \-1.07, \-0.81, …  
\#\# $ residual\_sugar       \<dbl\> \-0.47, \-0.09, \-0.28, \-0.28, \-0.47, \-0.54, \-0.54, …  
\#\# $ chlorides            \<dbl\> \-0.23, 0.23, \-0.03, \-0.03, \-0.23, \-0.41, \-0.39, …  
\#\# $ free\_sulfur\_dioxide  \<dbl\> 1.00, 1.00, \-0.05, \-0.05, \-0.43, \-0.81, \-0.05, \-0…  
\#\# $ total\_sulfur\_dioxide \<dbl\> 0.61, 0.61, \-0.36, \-0.36, \-0.09, \-0.57, \-0.81, \-0…  
\#\# $ density              \<dbl\> 0.99, \-0.12, 0.04, 0.04, 0.99, 0.47, \-0.96, \-0.7…  
\#\# $ ph                   \<dbl\> 1.25, \-0.73, \-0.33, \-0.33, 1.25, 1.25, \-0.06, \-0…  
\#\# $ sulphates            \<dbl\> \-0.54, 0.12, \-0.54, \-0.54, \-0.54, \-0.60, 0.06, \-…  
\#\# $ alcohol              \<dbl\> \-0.93, \-0.55, \-0.55, \-0.55, \-0.93, \-0.84, \-0.17, …  
\#\# $ quality\_category     \<fct\> poor, poor, poor, poor, poor, poor, poor, poor, …

Notice that all predictor columns are now numeric and have been scaled. The data is ready for modeling.

## **10.3 A Framework for Robust Evaluation: Data Splitting and Resampling**

How can we build a model and be confident in its performance on future data? The answer lies in rigorously evaluating it on data it has never seen during its training process. This section outlines the critical strategies for partitioning data to obtain a reliable and unbiased estimate of how the model will perform in the real world.27

### **10.3.1 The Peril of Overfitting**

The central challenge in predictive modeling is **overfitting**. This occurs when a model learns the training data *too* well. Instead of capturing the general, underlying patterns in the data, it also memorizes the random noise and idiosyncrasies specific to that particular training set. An overfit model will exhibit excellent performance on the data it was trained on but will fail to generalize, performing poorly when presented with new, unseen data.28 This is the fundamental problem that proper data splitting and resampling techniques are designed to prevent.

### **10.3.2 The Initial Split: Training vs. Testing**

The most important partition of your data is the initial split into a **training set** and a **testing set**.

* The **training set** is the workbench. It is used for all aspects of model development: training the algorithm's parameters, estimating the preprocessing steps in a recipe, and tuning hyperparameters.  
* The **testing set** is the final exam. It must be held in a metaphorical "vault," completely untouched during the entire model development process. It is used only *once*, at the very end of the project, to get a final, unbiased report on the chosen model's performance on unseen data.27

In tidymodels, we use the rsample package for this task. The initial\_split() function creates the split object. A crucial argument is strata, which performs stratified sampling. This ensures that the proportion of the outcome variable's levels (e.g., the percentage of "good" vs. "poor" wines) is the same in both the training and testing sets. This is especially important for imbalanced datasets like ours, as it prevents the rare class from being disproportionately represented (or absent) in one of the splits.30

Let's now perform the official split for our wine analysis. We will allocate 75% of the data for training and 25% for testing.

R

library(rsample)

\# Set a seed for reproducibility of the random split  
set.seed(123)

\# Create the split object, stratifying by our outcome variable  
wine\_split \<- initial\_split(wine\_data, prop \= 0.75, strata \= quality\_category)

\# Extract the training and testing data frames  
wine\_train \<- training(wine\_split)  
wine\_test  \<- testing(wine\_split)

\# Verify the dimensions and proportions  
dim(wine\_train)  
\#\#  1198   12  
dim(wine\_test)  
\#\#  401  12

\# Check proportions in training data  
wine\_train %\>% count(quality\_category) %\>% mutate(prop \= n/sum(n))  
\#\# \# A tibble: 2 × 3  
\#\#   quality\_category     n  prop  
\#\#   \<fct\>            \<int\> \<dbl\>  
\#\# 1 good               163 0.136  
\#\# 2 poor              1035 0.864

\# Check proportions in testing data  
wine\_test %\>% count(quality\_category) %\>% mutate(prop \= n/sum(n))  
\#\# \# A tibble: 2 × 3  
\#\#   quality\_category     n  prop  
\#\#   \<fct\>            \<int\> \<dbl\>  
\#\# 1 good                54 0.135  
\#\# 2 poor               347 0.865

The proportions are nearly identical, confirming that our stratified split was successful.

### **10.3.3 Resampling for Model Tuning: Cross-Validation**

During model development, we need to make many choices. For instance, is a k-NN model with k=5 better than one with k=7? Or is a Random Forest model better than an SVM? To make these decisions, we need to evaluate the performance of each candidate model.

A critical mistake would be to use our carefully sequestered test set for these intermediate evaluations. If we did, we would be "tuning" our model selection process to that specific test set. The model we ultimately choose would be the one that happens to do best on that particular slice of data, and its performance would no longer be an unbiased estimate of real-world performance. We would have reintroduced the very bias we sought to eliminate.29

The solution is to create temporary training and validation sets *from our main training set*. This process is called **resampling**. The most robust and widely used resampling technique is **k-fold cross-validation (CV)**.

In k-fold CV, the training data is randomly partitioned into *k* equal-sized subsets, or "folds" (k is typically 5 or 10). The model is then trained and evaluated *k* times. In each iteration, one of the folds is held out as a temporary test set (the **validation set**), and the model is trained on the remaining k-1 folds. The performance metrics (like accuracy) are calculated on the validation set for that iteration. After all *k* iterations are complete, the *k* performance estimates are averaged to produce a single, more stable, and reliable measure of the model's performance.28

In rsample, we use the vfold\_cv() function on the *training data* to create the cross-validation resampling object. Again, we use strata to ensure each fold has a representative sample of the outcome classes.

R

\# Set a seed for reproducibility of the random folds  
set.seed(456)

\# Create 10 cross-validation folds from the training data  
wine\_folds \<- vfold\_cv(wine\_train, v \= 10, strata \= quality\_category)

wine\_folds

\#\# \# 10-fold cross-validation using stratification   
\#\# \# A tibble: 10 × 2  
\#\#    splits             id      
\#\#    \<list\>             \<chr\>   
\#\#  1 \<split \[1078/120\]\> Fold01  
\#\#  2 \<split \[1078/120\]\> Fold02  
\#\#  3 \<split \[1078/120\]\> Fold03  
\#\#  4 \<split \[1078/120\]\> Fold04  
\#\#  5 \<split \[1078/120\]\> Fold05  
\#\#  6 \<split \[1078/120\]\> Fold06  
\#\#  7 \<split \[1078/120\]\> Fold07  
\#\#  8 \<split \[1078/120\]\> Fold08  
\#\#  9 \<split \[1078/120\]\> Fold09  
\#\# 10 \<split \[1079/119\]\> Fold10

This wine\_folds object contains 10 different splits of our training data, each ready to be used to train and validate a model during the tuning process. Table 10.2 clarifies the distinct roles of these different data partitions.

**Table 10.2: Data Splitting and Resampling Strategies**

| Partition | Created From | Purpose | When to Use |
| :---- | :---- | :---- | :---- |
| **Training Set** | Full Dataset | To train model parameters, estimate preprocessing steps, and serve as the basis for resampling. | Throughout the entire model development and tuning process. |
| **Testing Set** | Full Dataset | To obtain a final, unbiased performance estimate of the *single best* chosen model. | Only once, at the very end of the project. |
| **Validation Set (Fold)** | Training Set | To evaluate and compare the performance of different models or hyperparameter settings during the tuning process. | Repeatedly, once for each resample, during model tuning. |

## **10.4 Finding the Best Model: An Introduction to Hyperparameter Tuning**

Most machine learning algorithms are not monolithic entities; they come with a set of "dials" or "knobs" that control their learning behavior. These are known as **hyperparameters**, and their values are not learned from the data during the training process itself. Instead, they must be set by the user beforehand. **Hyperparameter tuning** is the systematic process of finding the optimal combination of these hyperparameter values that yields the best model performance.33

### **10.4.1 Parameters vs. Hyperparameters**

It is essential to distinguish between a model's parameters and its hyperparameters:

* **Parameters** are values that the algorithm learns directly from the training data. For example, in a linear regression model, the intercept and the coefficients for each predictor (β^​0​,β^​1​,…) are parameters. Their values are the output of the model fitting process.  
* **Hyperparameters** are settings that are external to the model and are specified by the analyst *before* the learning process begins. They define the model's architecture or how it learns. For example, in a k-Nearest Neighbors model, the number of neighbors to consider (k) is a hyperparameter. In a regularized regression, the strength of the penalty (λ) is a hyperparameter.33

### **10.4.2 The tidymodels Tuning Engine: workflows and tune**

The tidymodels framework provides a seamless and integrated system for hyperparameter tuning, centered around the workflows and tune packages.

* **The workflow Object**: A workflow() is a central container object that bundles a parsnip model specification with a recipes preprocessing plan.16 This is a crucial organizational tool that ensures the correct preprocessing is always applied with the correct model, preventing inconsistencies and errors, especially during the complex process of resampling and tuning.  
* **The parsnip Model Specification with tune()**: When we define a model using a parsnip function (e.g., nearest\_neighbor()), we can mark any hyperparameter we wish to optimize with the special placeholder tune().37 This signals to the  
  tidymodels ecosystem that this is not a fixed value but a variable to be optimized.

Let's create a tunable workflow for a k-NN model on our wine data.

R

library(parsnip)  
library(workflows)

\# Create the recipe (from section 9.2.6)  
\# We'll use the official wine\_train data now  
wine\_recipe \<- recipe(quality\_category \~., data \= wine\_train) %\>%  
  step\_normalize(all\_numeric\_predictors()) %\>%  
  step\_zv(all\_predictors())

\# Create a k-NN model specification with a tunable \`neighbors\` hyperparameter  
knn\_spec \<- nearest\_neighbor(neighbors \= tune()) %\>%  
  set\_engine("kknn") %\>%  
  set\_mode("classification")

\# Bundle the recipe and model spec into a workflow  
knn\_workflow \<- workflow() %\>%  
  add\_recipe(wine\_recipe) %\>%  
  add\_model(knn\_spec)

knn\_workflow

\#\# ══ Workflow ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════  
\#\# Preprocessor: Recipe  
\#\# Model: nearest\_neighbor()  
\#\#   
\#\# ── Preprocessor ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  
\#\# 2 Recipe Steps  
\#\#   
\#\# • step\_normalize()  
\#\# • step\_zv()  
\#\#   
\#\# ── Model ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  
\#\# K-Nearest Neighbor Model Specification (classification)  
\#\#   
\#\# Main Arguments:  
\#\#   neighbors \= tune()  
\#\#   
\#\# Computational engine: kknn

This knn\_workflow object now contains everything needed to train and evaluate our model, with the number of neighbors ready to be tuned.

### **10.4.3 Tuning Strategies in Practice**

There are several strategies for exploring the hyperparameter space to find the optimal values. These methods represent a trade-off between computational expense and the intelligence of the search.

1. **Grid Search**: This is the most straightforward, brute-force approach. The user defines a "grid" of specific values for each hyperparameter, and the algorithm exhaustively trains and evaluates a model for every single combination in the grid.33 While simple to understand, grid search suffers from the "curse of dimensionality": the number of combinations to test explodes exponentially as the number of hyperparameters increases, making it computationally inefficient for complex models.39  
2. **Random Search**: This method, surprisingly, is often more efficient than grid search. Instead of a fixed grid, the user defines a range or distribution for each hyperparameter. The algorithm then randomly samples a specified number of combinations from this space to evaluate.40 Research has shown that for many models, only a few hyperparameters are truly critical to performance. Random search has a higher probability of finding good values for these important parameters in fewer iterations because it doesn't waste time evaluating many unpromising combinations of less important ones.39  
3. **Bayesian Optimization**: This is the most intelligent and sample-efficient strategy. It's an iterative process that builds a probabilistic model—typically a Gaussian Process—to approximate the relationship between hyperparameter values and model performance. After each evaluation, it updates this internal model and uses an "acquisition function" to decide the next best set of hyperparameters to try. This function balances *exploitation* (testing values near the current best-performing combination) and *exploration* (testing values in regions of the parameter space with high uncertainty). This allows it to zero in on optimal regions much faster than grid or random search, making it ideal for tuning computationally expensive models or high-dimensional parameter spaces.42

For most applications, Random Search is an excellent default starting point. If the modeling process is very time-consuming or involves many hyperparameters, investing the effort to use Bayesian Optimization can save significant computational resources. Grid Search is best reserved for problems with only one or two hyperparameters.

### **10.4.4 A Complete Tuning Workflow: k-NN on the Wine Data**

Let's now execute a complete tuning workflow using tune\_grid with a regular grid to find the best number of neighbors (k) for our k-NN model.

**Step 1: Set up the workflow** (completed in section 9.4.2).

**Step 2: Set up the tuning grid.** We will test odd values of neighbors from 1 to 31\. The dials package helps create these grids.

R

\# Create a grid of values for the \`neighbors\` hyperparameter  
knn\_grid \<- grid\_regular(neighbors(), levels \= 15)

knn\_grid

\#\# \# A tibble: 15 × 1  
\#\#    neighbors  
\#\#        \<int\>  
\#\#  1         1  
\#\#  2         3  
\#\#  3         5  
\#\#  4         7  
\#\#  5         9  
\#\#  6        11  
\#\#  7        13  
\#\#  8        15  
\#\#  9        17  
\#\# 10        19  
\#\# 11        21  
\#\# 12        23  
\#\# 13        25  
\#\# 14        27  
\#\# 15        29

**Step 3: Run the tuning.** We use the tune\_grid() function from the tune package. We provide our knn\_workflow, our wine\_folds resampling object, and our knn\_grid. tune will now train and evaluate 15 models (one for each grid value) on each of the 10 folds, for a total of 150 model fits.

R

\# Set a seed for reproducibility of the tuning process  
set.seed(789)

\# Run the grid search  
knn\_tuning\_results \<- tune\_grid(  
  object \= knn\_workflow,  
  resamples \= wine\_folds,  
  grid \= knn\_grid  
)

knn\_tuning\_results

\#\# \# Tuning results  
\#\# \# 10-fold cross-validation using stratification   
\#\# \# A tibble: 10 × 4  
\#\#    splits             id    .metrics        .notes            
\#\#    \<list\>             \<chr\>  \<list\>           \<list\>            
\#\#  1 \<split \[1078/120\]\> Fold01 \<tibble \[30 × 4\]\> \<tibble \[0 × 3\]\>  
\#\#  2 \<split \[1078/120\]\> Fold02 \<tibble \[30 × 4\]\> \<tibble \[0 × 3\]\>  
\#\#  3 \<split \[1078/120\]\> Fold03 \<tibble \[30 × 4\]\> \<tibble \[0 × 3\]\>  
\#\#  4 \<split \[1078/120\]\> Fold04 \<tibble \[30 × 4\]\> \<tibble \[0 × 3\]\>  
\#\#  5 \<split \[1078/120\]\> Fold05 \<tibble \[30 × 4\]\> \<tibble \[0 × 3\]\>  
\#\#  6 \<split \[1078/120\]\> Fold06 \<tibble \[30 × 4\]\> \<tibble \[0 × 3\]\>  
\#\#  7 \<split \[1078/120\]\> Fold07 \<tibble \[30 × 4\]\> \<tibble \[0 × 3\]\>  
\#\#  8 \<split \[1078/120\]\> Fold08 \<tibble \[30 × 4\]\> \<tibble \[0 × 3\]\>  
\#\#  9 \<split \[1078/120\]\> Fold09 \<tibble \[30 × 4\]\> \<tibble \[0 × 3\]\>  
\#\# 10 \<split \[1079/119\]\> Fold10 \<tibble \[30 × 4\]\> \<tibble \[0 × 3\]\>

**Step 4: Analyze the results.** The collect\_metrics() function collapses the results into a tidy data frame, showing the mean performance for each hyperparameter value across all 10 folds.

R

collect\_metrics(knn\_tuning\_results)

\#\# \# A tibble: 30 × 6  
\#\#    neighbors.metric .estimator  mean     n std\_err  
\#\#        \<int\> \<chr\>    \<chr\>      \<dbl\> \<int\>   \<dbl\>  
\#\#  1         1 accuracy binary     0.871    10  0.0125  
\#\#  2         1 roc\_auc  binary     0.781    10  0.0270  
\#\#  3         3 accuracy binary     0.869    10  0.0105  
\#\#  4         3 roc\_auc  binary     0.803    10  0.0240  
\#\#  5         5 accuracy binary     0.870    10  0.0101  
\#\#  6         5 roc\_auc  binary     0.814    10  0.0211  
\#\#  7         7 accuracy binary     0.869    10  0.0093  
\#\#  8         7 roc\_auc  binary     0.822    10  0.0202  
\#\#  9         9 accuracy binary     0.868    10  0.0089  
\#\# 10         9 roc\_auc  binary     0.829    10  0.0194  
\#\# \# ℹ 20 more rows

**Step 5: Visualize the results.** A plot often provides the most intuitive way to understand the relationship between the hyperparameter and model performance. The autoplot() function creates this visualization automatically.45

R

autoplot(knn\_tuning\_results)

This plot will show two panels, one for accuracy and one for roc\_auc, with the hyperparameter neighbors on the x-axis and the performance metric on the y-axis. This allows us to visually identify the region of optimal performance.

**Step 6: Select the best model.** We can programmatically extract the best hyperparameter combination using select\_best(). We must specify which metric to optimize for; roc\_auc is often a good choice for imbalanced classification problems.

R

best\_knn\_params \<- select\_best(knn\_tuning\_results, metric \= "roc\_auc")

best\_knn\_params

\#\# \# A tibble: 1 × 2  
\#\#   neighbors.config                
\#\#       \<int\> \<chr\>                  
\#\# 1        29 Preprocessor1\_Model15

The best performance was achieved with k=29 neighbors.

**Step 7: Finalize the workflow.** Now we update our workflow, replacing the tune() placeholder with this optimal value using finalize\_workflow().

R

final\_knn\_workflow \<- finalize\_workflow(knn\_workflow, best\_knn\_params)

final\_knn\_workflow

**Step 8: The Final Fit.** This is the last step. The last\_fit() function takes the finalized workflow and the original wine\_split object. It automatically performs two critical actions:

1. It fits the finalized model (with k=29) on the *entire training set*.  
2. It evaluates this final model on the *testing set*.

This provides our final, unbiased assessment of how this model is expected to perform on new data.38

R

final\_knn\_fit \<- last\_fit(final\_knn\_workflow, wine\_split)

\# View the performance metrics on the test set  
collect\_metrics(final\_knn\_fit)

\#\# \# A tibble: 2 × 4  
\#\#  .metric .estimator.estimate.config               
\#\#   \<chr\>    \<chr\>          \<dbl\> \<chr\>                 
\#\# 1 accuracy binary         0.868 Preprocessor1\_Model1  
\#\# 2 roc\_auc  binary         0.852 Preprocessor1\_Model1

The final model achieved an ROC AUC of 0.852 on the held-out test set. This is our best estimate of its real-world performance.

## **10.5 Chapter Summary**

This chapter has built a complete, foundational workflow for machine learning in R using the tidymodels framework. We have journeyed from the conceptual underpinnings of predictive modeling to the practical implementation of a robust, end-to-end pipeline.

We began by distinguishing the two major paradigms of machine learning: **supervised learning**, which uses labeled data to make predictions, and **unsupervised learning**, which finds hidden patterns in unlabeled data. We then established the critical importance of data preprocessing, demonstrating how the recipes package provides a powerful and reproducible method for feature engineering while safeguarding against data leakage through its prep() and bake() system.

To ensure our models are robust and generalizable, we implemented a rigorous data splitting strategy. We used rsample to create an initial **train/test split**, sequestering the test set for a final, unbiased evaluation. We then used **k-fold cross-validation** on the training data to create resampling folds, providing a reliable way to evaluate models during the tuning phase without touching the test set.

Finally, we introduced **hyperparameter tuning** as the process of optimizing a model's settings. We constructed a workflow that bundled our recipe and a tunable parsnip model specification. Using tune\_grid(), we evaluated multiple candidate models across our cross-validation folds, visualized the results, and selected the best-performing hyperparameter combination. The process culminated with last\_fit(), which trained our final, optimized model on the full training set and reported its performance on the untouched test set.

The workflow established in this chapter—initial\_split \-\> vfold\_cv \-\> recipe \-\> parsnip model with tune() \-\> workflow \-\> tune\_grid or tune\_bayes \-\> select\_best \-\> finalize\_workflow \-\> last\_fit—is a powerful and reusable template. In the chapters that follow, we will explore a wide variety of advanced machine learning algorithms, from Random Forests and Gradient Boosting to Support Vector Machines and Neural Networks. The foundational workflow you have learned here will remain constant; the only piece that will change is the parsnip model specification, allowing you to rapidly apply and evaluate these powerful techniques on your own research problems.

#### **Works cited**

1. Caret vs. tidymodels — create reusable machine learning workflows ..., accessed on July 30, 2025, [https://medium.com/data-science/caret-vs-tidymodels-create-complete-reusable-machine-learning-workflows-5c50a7befd2d](https://medium.com/data-science/caret-vs-tidymodels-create-complete-reusable-machine-learning-workflows-5c50a7befd2d)  
2. Tidymodels: tidy machine learning in R \- Rebecca Barter, accessed on July 30, 2025, [https://rebeccabarter.com/blog/2020-03-25\_machine\_learning](https://rebeccabarter.com/blog/2020-03-25_machine_learning)  
3. Machine Learning with tidymodels \- WV View, accessed on July 30, 2025, [https://www.wvview.org/os\_sa/20\_tidymodels.html](https://www.wvview.org/os_sa/20_tidymodels.html)  
4. TidyModels or CARET – how they compare? \- R-bloggers, accessed on July 30, 2025, [https://www.r-bloggers.com/2021/10/tidymodels-or-caret-how-they-compare/](https://www.r-bloggers.com/2021/10/tidymodels-or-caret-how-they-compare/)  
5. Wine Quality Dataset \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/datasets/yasserh/wine-quality-dataset](https://www.kaggle.com/datasets/yasserh/wine-quality-dataset)  
6. Red Wine Quality \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/datasets/uciml/red-wine-quality-cortez-et-al-2009](https://www.kaggle.com/datasets/uciml/red-wine-quality-cortez-et-al-2009)  
7. cloud.google.com, accessed on July 30, 2025, [https://cloud.google.com/discover/supervised-vs-unsupervised-learning\#:\~:text=The%20biggest%20difference%20between%20supervised,correct%20output%20values%20should%20be.](https://cloud.google.com/discover/supervised-vs-unsupervised-learning#:~:text=The%20biggest%20difference%20between%20supervised,correct%20output%20values%20should%20be.)  
8. Supervised vs. Unsupervised Learning: What's the Difference? | IBM, accessed on July 30, 2025, [https://www.ibm.com/think/topics/supervised-vs-unsupervised-learning](https://www.ibm.com/think/topics/supervised-vs-unsupervised-learning)  
9. Supervised vs. unsupervised learning | Google Cloud, accessed on July 30, 2025, [https://cloud.google.com/discover/supervised-vs-unsupervised-learning](https://cloud.google.com/discover/supervised-vs-unsupervised-learning)  
10. Supervised vs. unsupervised learning: What's the difference? \- Moveworks, accessed on July 30, 2025, [https://www.moveworks.com/us/en/resources/blog/supervised-vs-unsupervised-learning-whats-the-difference](https://www.moveworks.com/us/en/resources/blog/supervised-vs-unsupervised-learning-whats-the-difference)  
11. Recipes in R. All about data preprocessing in R | by Gagan Chordia | Medium, accessed on July 30, 2025, [https://gaganchordia.medium.com/recipes-all-about-data-preprocessing-in-r-d97a3466d8a5](https://gaganchordia.medium.com/recipes-all-about-data-preprocessing-in-r-d97a3466d8a5)  
12. Feature Engineering in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/feature-engineering-in-r-programming/](https://www.geeksforgeeks.org/r-language/feature-engineering-in-r-programming/)  
13. Feature Engineering in Machine Learning: A Practical Guide \- DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/feature-engineering](https://www.datacamp.com/tutorial/feature-engineering)  
14. Mastering Data Preprocessing in R with the \`recipes\` Package | R-bloggers, accessed on July 30, 2025, [https://www.r-bloggers.com/2025/04/mastering-data-preprocessing-in-r-with-the-recipes-package/](https://www.r-bloggers.com/2025/04/mastering-data-preprocessing-in-r-with-the-recipes-package/)  
15. Preprocess your data with recipes \- tidymodels, accessed on July 30, 2025, [https://www.tidymodels.org/start/recipes/](https://www.tidymodels.org/start/recipes/)  
16. 8 Feature Engineering with recipes | Tidy Modeling with R, accessed on July 30, 2025, [https://www.tmwr.org/recipes](https://www.tmwr.org/recipes)  
17. Tackling the Red Wine Quality Classification Problem | by Rahma F. Nova \- Medium, accessed on July 30, 2025, [https://medium.com/@20611122/tackling-the-red-wine-quality-classification-problem-0526f558c38b](https://medium.com/@20611122/tackling-the-red-wine-quality-classification-problem-0526f558c38b)  
18. Chapter 3 Feature & Target Engineering | Hands-On Machine Learning with R, accessed on July 30, 2025, [https://bradleyboehmke.github.io/HOML/engineering.html](https://bradleyboehmke.github.io/HOML/engineering.html)  
19. 30 day tidymodels recipes challenge \- Collin K. Berke, Ph.D., accessed on July 30, 2025, [https://www.collinberke.com/blog/posts/2024-01-01-30-days-challenge-tidymodels-recipes/](https://www.collinberke.com/blog/posts/2024-01-01-30-days-challenge-tidymodels-recipes/)  
20. Data Preprocessing in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/data-preprocessing-in-r/](https://www.geeksforgeeks.org/r-language/data-preprocessing-in-r/)  
21. Normalization and Scaling \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/data-analysis/normalization-and-scaling/](https://www.geeksforgeeks.org/data-analysis/normalization-and-scaling/)  
22. Data Normalization Techniques in R | CodeSignal Learn, accessed on July 30, 2025, [https://codesignal.com/learn/courses/data-cleaning-and-preprocessing-with-r/lessons/data-normalization-techniques-in-r](https://codesignal.com/learn/courses/data-cleaning-and-preprocessing-with-r/lessons/data-normalization-techniques-in-r)  
23. Scaling and Normalization \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/code/alexisbcook/scaling-and-normalization](https://www.kaggle.com/code/alexisbcook/scaling-and-normalization)  
24. Data Preprocessing | CodeSignal Learn, accessed on July 30, 2025, [https://codesignal.com/learn/courses/introduction-to-machine-learning-with-caret/lessons/data-preprocessing](https://codesignal.com/learn/courses/introduction-to-machine-learning-with-caret/lessons/data-preprocessing)  
25. Feature Engineering, accessed on July 30, 2025, [https://cran.r-project.org/web/packages/finnts/vignettes/feature-engineering.html](https://cran.r-project.org/web/packages/finnts/vignettes/feature-engineering.html)  
26. 13 Grid Search | Tidy Modeling with R, accessed on July 30, 2025, [https://www.tmwr.org/grid-search](https://www.tmwr.org/grid-search)  
27. \[D\] Looking for a guide to data preprocessing : r/MachineLearning \- Reddit, accessed on July 30, 2025, [https://www.reddit.com/r/MachineLearning/comments/1aur5o7/d\_looking\_for\_a\_guide\_to\_data\_preprocessing/](https://www.reddit.com/r/MachineLearning/comments/1aur5o7/d_looking_for_a_guide_to_data_preprocessing/)  
28. Cross-Validation in R programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/cross-validation-in-r-programming/](https://www.geeksforgeeks.org/r-language/cross-validation-in-r-programming/)  
29. When splitting data into training and validation sets, should it be completely random? : r/statistics \- Reddit, accessed on July 30, 2025, [https://www.reddit.com/r/statistics/comments/1uuv25/when\_splitting\_data\_into\_training\_and\_validation/](https://www.reddit.com/r/statistics/comments/1uuv25/when_splitting_data_into_training_and_validation/)  
30. Create an Initial Train/Validation/Test Split — initial\_validation\_split ..., accessed on July 30, 2025, [https://rsample.tidymodels.org/reference/initial\_validation\_split.html](https://rsample.tidymodels.org/reference/initial_validation_split.html)  
31. Cross-Validation in Machine Learning: How to Do It Right \- neptune.ai, accessed on July 30, 2025, [https://neptune.ai/blog/cross-validation-in-machine-learning-how-to-do-it-right](https://neptune.ai/blog/cross-validation-in-machine-learning-how-to-do-it-right)  
32. Cross-validating regression models, accessed on July 30, 2025, [https://cran.r-project.org/web/packages/cv/vignettes/cv.html](https://cran.r-project.org/web/packages/cv/vignettes/cv.html)  
33. Hyperparameter Tuning with R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/hyperparameter-tuning-with-r/](https://www.geeksforgeeks.org/machine-learning/hyperparameter-tuning-with-r/)  
34. Hyperparameter Tuning with R | Reintech media, accessed on July 30, 2025, [https://reintech.io/blog/hyperparameter-tuning-with-r-guide](https://reintech.io/blog/hyperparameter-tuning-with-r-guide)  
35. Modeling Workflows • workflows \- tidymodels, accessed on July 30, 2025, [https://workflows.tidymodels.org/](https://workflows.tidymodels.org/)  
36. 7 A Model Workflow | Tidy Modeling with R, accessed on July 30, 2025, [https://www.tmwr.org/workflows.html](https://www.tmwr.org/workflows.html)  
37. Getting Started with tune \- tidymodels, accessed on July 30, 2025, [https://tune.tidymodels.org/articles/getting\_started.html](https://tune.tidymodels.org/articles/getting_started.html)  
38. Tune model parameters \- tidymodels, accessed on July 30, 2025, [https://www.tidymodels.org/start/tuning/](https://www.tidymodels.org/start/tuning/)  
39. Random Search in R. When building machine learning models… | by Amit Yadav | Biased-Algorithms | Medium, accessed on July 30, 2025, [https://medium.com/biased-algorithms/random-search-in-r-3ce5631fe424](https://medium.com/biased-algorithms/random-search-in-r-3ce5631fe424)  
40. www.geeksforgeeks.org, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/hyperparameter-tuning-with-r/\#:\~:text=Techniques%20for%20Hyperparameter%20Tuning\&text=Random%20Search%3A%20Random%20search%20selects,the%20search%20space%20is%20large.](https://www.geeksforgeeks.org/machine-learning/hyperparameter-tuning-with-r/#:~:text=Techniques%20for%20Hyperparameter%20Tuning&text=Random%20Search%3A%20Random%20search%20selects,the%20search%20space%20is%20large.)  
41. How to tune Hyper parameters using Random Search in R?, accessed on July 30, 2025, [https://www.projectpro.io/recipes/tune-hyper-parameters-random-search-r](https://www.projectpro.io/recipes/tune-hyper-parameters-random-search-r)  
42. Bayesian optimization of model parameters. — tune\_bayes • tune \- tidymodels, accessed on July 30, 2025, [https://tune.tidymodels.org/reference/tune\_bayes.html](https://tune.tidymodels.org/reference/tune_bayes.html)  
43. Iterative Bayesian optimization of a classification model \- tidymodels, accessed on July 30, 2025, [https://www.tidymodels.org/learn/work/bayes-opt/](https://www.tidymodels.org/learn/work/bayes-opt/)  
44. 14 Iterative Search \- Tidy Modeling with R, accessed on July 30, 2025, [https://www.tmwr.org/iterative-search](https://www.tmwr.org/iterative-search)  
45. tune.pdf, accessed on July 30, 2025, [https://cran.r-project.org/web/packages/tune/tune.pdf](https://cran.r-project.org/web/packages/tune/tune.pdf)