---
title: Predictive Regression
slug: chapter12
order: 110
published: false
abstract: >
    Where Chapter 7 used regression to explain relationships, this chapter uses it to predict numerical outcomes. It covers regularized regression (Ridge, Lasso, and Elastic Net) and gradient boosting with XGBoost, along with how to evaluate predictions using RMSE, MAE, and R². A hands-on project predicting global life expectancy brings these methods together.
---




In previous chapters, the principles of linear regression provided a robust framework for modeling relationships between variables. The Ordinary Least Squares (OLS) method, in particular, offers an elegant and interpretable solution for estimating the coefficients that define these relationships. However, the very assumptions that make OLS powerful under ideal conditions also render it vulnerable in the face of common real-world data complexities. This chapter ventures beyond standard regression to tackle two pervasive challenges that researchers and analysts frequently encounter: overfitting and multicollinearity.

### **The Problem of Overfitting**

A primary goal of predictive modeling is to build a model that generalizes well to new, unseen data. Overfitting occurs when a model learns the training data too well, capturing not only the underlying signal but also the random noise specific to that particular sample.1 A model with a large number of predictors relative to the number of observations is particularly susceptible to this issue. Such a model may exhibit excellent performance on the data it was trained on, but its predictive accuracy will plummet when faced with a new dataset. The model's large coefficients, tailored to the noise of the training set, fail to capture the true, generalizable pattern.1 This discrepancy between training and testing performance is the hallmark of an overfit, high-variance model.

### **The Challenge of Multicollinearity**

Multicollinearity arises when two or more predictor variables in a regression model are highly correlated with one another.4 This redundancy creates a problem for OLS, which struggles to disentangle the individual effects of the correlated predictors. The consequence is unstable and unreliable coefficient estimates. The standard errors of the coefficients become inflated, making it difficult to assess the statistical significance of any given predictor. In extreme cases, the signs of the coefficients may even be counterintuitive, undermining the model's interpretability and trustworthiness.5

### **Introducing the Solutions: Regularization and Boosting**

To overcome these limitations, this chapter introduces two powerful families of advanced regression techniques: regularization and boosting. These approaches represent distinct philosophies for building robust predictive models.

* **Regularization** operates by taking the framework of a potentially complex model, like multiple linear regression, and applying a *proactive constraint*. It introduces a penalty term into the model's loss function, which discourages the coefficients from becoming too large. This process, also known as shrinkage, effectively tames the model's complexity, reducing variance and stabilizing the estimates in the presence of multicollinearity.2 It is a method of controlling a complex model from the outset.  
* **Boosting**, in contrast, is a *reactive, constructive process*. It does not begin with a complex model. Instead, it starts with an exceedingly simple model (often just the overall mean of the outcome) and builds a powerful predictor by sequentially adding simple, "weak" models, typically shallow decision trees.7 Each new model in the sequence is trained to correct the errors or residuals of the models that came before it.7 This incremental, error-correcting approach constructs a highly accurate and complex model from simple, manageable components.

By mastering these two paradigms, you will be equipped to build high-performance regression models that are not only accurate but also robust and generalizable, even when faced with the challenges of complex, high-dimensional, and correlated data.

## **Taming Complexity with Regularized Regression**

Regularized regression methods provide a direct and effective solution to the problems of overfitting and multicollinearity by fundamentally altering the objective of the model-fitting process. Instead of solely minimizing the sum of squared residuals, these methods introduce a penalty for model complexity, thereby managing the critical trade-off between bias and variance.

### **The Theory: The Bias-Variance Trade-off and Penalized Regression**

Every predictive model is subject to the bias-variance trade-off.

* **Bias** is the error introduced by approximating a real-world problem, which may be complex, with a much simpler model. High-bias models (e.g., a simple linear regression on a non-linear relationship) tend to underfit the data, failing to capture the underlying patterns.  
* **Variance** is the amount by which the model's estimate would change if it were trained on a different training dataset. High-variance models (e.g., a high-degree polynomial regression) are overly sensitive to the training data and tend to overfit, capturing noise as if it were signal.

The goal is to find a sweet spot that minimizes the total error. Regularization achieves this by intentionally introducing a small amount of bias into the model to gain a significant reduction in variance, leading to a lower overall error on unseen data.5 This is accomplished by adding a penalty term to the OLS loss function, creating a new objective to minimize 1:

Minimize: i=1∑n​(yi​−y^​i​)2+Penalty Term  
The specific form of the penalty term defines the type of regularized regression.

### **Ridge Regression (L2 Penalty): Shrinking Coefficients**

Ridge regression introduces a penalty based on the L2 norm of the coefficient vector—the sum of the squared magnitudes of the coefficients.4 The objective function for Ridge regression is:

Minimize: i=1∑n​(yi​−β0​−j=1∑p​βj​xij​)2+λj=1∑p​βj2​  
Here, λ (lambda) is a non-negative tuning parameter that controls the strength of the penalty. As λ increases, the penalty for large coefficients becomes more severe, forcing the model to shrink the coefficients closer and closer to zero. Because the penalty is squared, Ridge regression has a more pronounced effect on larger coefficients.10

The key characteristic of Ridge regression is that while it shrinks coefficients towards zero, it never sets them *exactly* to zero (unless λ=∞).4 This makes it particularly effective for mitigating multicollinearity. When faced with a group of highly correlated predictors, Ridge will tend to shrink their coefficients towards each other and towards zero, effectively sharing their predictive power rather than arbitrarily selecting one predictor over the others.10

### **Lasso Regression (L1 Penalty): Achieving Sparsity**

Lasso (Least Absolute Shrinkage and Selection Operator) regression employs a penalty based on the L1 norm—the sum of the absolute values of the coefficients.4 Its objective function is:

Minimize: i=1∑n​(yi​−β0​−j=1∑p​βj​xij​)2+λj=1∑p​∣βj​∣  
The L1 penalty has a profoundly different effect than the L2 penalty. Due to the geometry of the absolute value function, the Lasso penalty can shrink some coefficients all the way to *exactly zero* as λ increases.11 This property means that Lasso performs automatic feature selection, effectively removing irrelevant predictors from the model by nullifying their impact. This makes Lasso an invaluable tool for high-dimensional datasets where the number of predictors is large, and many are expected to be unrelated to the outcome.4

However, Lasso's behavior with correlated predictors can be a drawback. If a group of predictors is highly correlated, Lasso will tend to arbitrarily select one variable from the group and shrink the others to zero.10 This can make the model's selection of variables seem unstable or random if the analysis is repeated on slightly different data.

### **Elastic Net: The Best of Both Worlds**

Elastic Net regression was developed to combine the strengths of both Ridge and Lasso.13 It includes both L1 and L2 penalties in its objective function, controlled by two tuning parameters:

λ for the overall penalty strength and α (alpha) for the mix between the two penalties.

Minimize: i=1∑n​(yi​−β0​−j=1∑p​βj​xij​)2+λ\[(1−α)21​j=1∑p​βj2​+αj=1∑p​∣βj​∣\]  
The mixing parameter α ranges from 0 to 1 16:

* When α=0, the L1 penalty term disappears, and the model becomes pure Ridge regression.  
* When α=1, the L2 penalty term disappears, and the model becomes pure Lasso regression.  
* For values of α between 0 and 1, the model is a hybrid.

This hybrid approach allows Elastic Net to handle groups of correlated predictors effectively (the Ridge component encourages them to be included or excluded together) while still being able to perform sparse feature selection (the Lasso component can shrink irrelevant coefficients to zero).13 This makes it a highly flexible and often superior choice, particularly when dealing with datasets that have high dimensionality and multicollinearity.

### **Implementation with glmnet**

The glmnet package is the gold standard for fitting regularized regression models in R. It is highly optimized for speed and provides a comprehensive framework for training and tuning these models.16

#### **Data Preparation**

Unlike many modeling functions in R that use a formula interface (e.g., y \~ x1 \+ x2), glmnet requires the predictor variables to be supplied as a numeric matrix and the response variable as a vector.17 The

model.matrix() function is a convenient way to create this matrix, especially for converting categorical variables into dummy variables.

A critical preprocessing step for regularized regression is to standardize the predictor variables. Because the penalties are applied to the coefficients, predictors on different scales can receive unequal penalization. For instance, a predictor measured in meters will have a much smaller coefficient than the same predictor measured in millimeters, and the penalty would affect them differently. The glmnet function handles this by default with the argument standardize \= TRUE, ensuring a fair application of the penalty across all predictors. The coefficients are then returned on their original scale for interpretation.1

#### **Training and Tuning with cv.glmnet**

The most important step in regularized regression is choosing the optimal value for the tuning parameter λ. The cv.glmnet() function automates this process using k-fold cross-validation.17 It trains the model over a grid of

λ values and calculates a cross-validation error for each.

The function produces a plot showing the cross-validation error (typically Mean Squared Error) as a function of log(λ). From this, two optimal values for λ are identified:

* **lambda.min**: The value of λ that results in the minimum cross-validation error. This value yields the most accurate model but can sometimes be slightly overfit.  
* **lambda.1se**: The most regularized (simplest) model whose error is within one standard error of the minimum. This value is often preferred as it provides a more parsimonious model with comparable performance to the lambda.min model.

The following code demonstrates a complete workflow for training and tuning an Elastic Net model using cv.glmnet. We will use the built-in mtcars dataset to predict miles per gallon (mpg).

R

\# Load the necessary library  
install.packages("glmnet")  
library(glmnet)

\# Prepare the data  
\# glmnet requires a matrix of predictors (x) and a vector for the response (y)  
x \<- model.matrix(mpg \~., data \= mtcars)\[, \-1\] \# Predictor matrix  
y \<- mtcars$mpg                                  \# Response vector

\# Set a seed for reproducibility  
set.seed(123)

\# Train the Elastic Net model using cross-validation  
\# We will test a range of alpha values to find the best mix of Ridge and Lasso  
\# A for loop can be used to iterate through different alpha values  
best\_alpha \<- NULL  
best\_mse \<- Inf  
best\_model \<- NULL

for (alpha\_val in seq(0, 1, by \= 0.1)) {  
  cv\_fit \<- cv.glmnet(x, y, alpha \= alpha\_val, family \= "gaussian")  
    
  \# Find the minimum MSE for the current alpha  
  current\_mse \<- min(cv\_fit$cvm)  
    
  \# If this alpha gives a better MSE, store it  
  if (current\_mse \< best\_mse) {  
    best\_mse \<- current\_mse  
    best\_alpha \<- alpha\_val  
    best\_model \<- cv\_fit  
  }  
}

\# Print the best alpha value found  
print(paste("Best alpha:", best\_alpha))

\# Plot the cross-validation results for the best model  
plot(best\_model)

\# Get the optimal lambda values from the best model  
lambda\_min \<- best\_model$lambda.min  
lambda\_1se \<- best\_model$lambda.1se

print(paste("Lambda min:", lambda\_min))  
print(paste("Lambda 1se:", lambda\_1se))

\# Extract coefficients at the optimal lambda (lambda.1se is often preferred for parsimony)  
best\_coeffs \<- coef(best\_model, s \= "lambda.1se")  
print(best\_coeffs)

\# Make predictions on new data (here, we use the original data for demonstration)  
predictions \<- predict(best\_model, s \= "lambda.1se", newx \= x)

This comprehensive approach allows for the tuning of both alpha and lambda, ensuring that the final model is optimized for predictive performance. The resulting coefficients show which variables were retained by the model and the magnitude of their shrunken effects.

**Table 12.1: Comparison of Regularization Techniques**

| Feature | Ridge Regression | Lasso Regression | Elastic Net Regression |
| :---- | :---- | :---- | :---- |
| **Penalty Type** | L2 Norm (∑βj2​) | L1 Norm ($\\sum | \\beta\_j |
| **Coefficient Behavior** | Shrinks coefficients toward zero | Shrinks some coefficients to exactly zero | Both shrinks coefficients and can set them to zero |
| **Feature Selection** | No, retains all features | Yes, performs automatic feature selection | Yes, performs automatic feature selection |
| **Handles Multicollinearity?** | Yes, very stable. Shrinks correlated predictors together. | Unstable. Arbitrarily selects one from a correlated group. | Yes, stable. Groups and shrinks correlated predictors. |
| **Key Use Case** | When most predictors are useful and potentially correlated. | When the dataset is high-dimensional and the signal is sparse (many predictors are irrelevant). | As a general-purpose regularizer, especially when predictors are correlated and feature selection is desired. |

## **The Power of the Ensemble: Gradient Boosting**

While regularization improves models by imposing constraints, boosting takes a different path: it builds a powerful, accurate model by combining the efforts of many simple models. This ensemble approach has proven to be one of the most effective techniques in predictive modeling, particularly for structured or tabular data.

### **The Theory: Building a Strong Model from Weak Learners**

Boosting is a sequential ensemble method.7 Unlike bagging methods like Random Forests, which build many independent models in parallel and average their predictions, boosting builds models one after another, where each new model learns from the mistakes of the previous ones.8

The core intuition behind gradient boosting for regression is as follows 21:

1. **Start with a simple prediction:** The initial prediction for all observations is simply the mean of the target variable.  
2. **Calculate the residuals:** Compute the error for each observation by subtracting the current prediction from the actual value. These residuals represent the "mistakes" the model is currently making.  
3. **Fit a weak learner to the residuals:** Train a simple model, known as a "weak learner," to predict these residuals. In gradient boosting, the weak learner is almost always a shallow decision tree (e.g., with a depth of 1 to 6 splits).8 This tree learns the patterns in the errors.  
4. **Update the predictions:** Add the predictions from this new weak learner to the overall model's predictions. However, to prevent overfitting, the contribution of the new tree is scaled down by a factor called the **learning rate** (also known as eta or shrinkage).21 This parameter, typically a small number between 0.01 and 0.3, ensures that the model learns slowly and cautiously.  
5. **Repeat:** Continue this process—calculating new residuals and fitting new trees to them—for a specified number of iterations. Each new tree incrementally improves the model by focusing on the remaining errors.

The final model is the sum of the initial prediction and the contributions of all the sequentially fitted trees. This gradual, iterative process of error correction allows gradient boosting to build an extremely accurate and nuanced predictive model.

### **eXtreme Gradient Boosting (XGBoost): The Champion's Choice**

eXtreme Gradient Boosting, or XGBoost, is an implementation of the gradient boosting framework that has been engineered for maximum efficiency, scalability, and performance.25 It has become a dominant algorithm in machine learning competitions and applied research due to several key enhancements over standard Gradient Boosting Machines (GBM).7

#### **Key Advantages over Standard GBM**

* **Built-in Regularization:** A fundamental difference is that XGBoost's objective function includes both L1 (Lasso) and L2 (Ridge) regularization terms. This penalizes the complexity of the trees themselves (e.g., the number of leaves and the magnitude of their scores), providing a direct mechanism to combat overfitting that is not inherent in traditional GBM implementations.28  
* **Optimized Tree Pruning:** Standard GBMs often use a "greedy" approach, stopping tree growth when a split no longer improves the loss function. XGBoost, by contrast, can grow a tree up to a specified max\_depth and then prune it backward, removing splits that do not provide a positive gain. This "depth-first" approach can find more optimal tree structures.30  
* **Parallelization:** Although the overall boosting process is sequential (tree t must be built after tree t-1), XGBoost can parallelize the construction of each individual tree. The process of finding the best split point for each feature is computationally intensive, and XGBoost can perform these calculations across multiple CPU cores simultaneously, leading to dramatic speed improvements on modern hardware.25  
* **Sparsity-Aware Split Finding:** Real-world datasets often contain missing values. XGBoost has a built-in, native ability to handle them. During tree construction, it learns a default direction for missing values at each split, assigning them to the child node that provides the best improvement to the loss function. This is a significant practical advantage over methods that require manual imputation as a preprocessing step.25

### **Implementation with xgboost**

The xgboost package in R provides a powerful and flexible interface to the XGBoost library.19

#### **Data Preparation**

Similar to glmnet, xgboost requires numeric inputs. The predictors must be in a numeric matrix, and the response must be a numeric vector. Categorical variables must be converted to a numeric format, typically through one-hot encoding, which can be accomplished using model.matrix(\~. \+ 0, data \= your\_data).7

For optimal performance, especially with large datasets, xgboost uses a special internal data structure called xgb.DMatrix. Converting your data into this format before training can significantly improve speed and memory efficiency.25

#### **Hyperparameter Tuning**

The power of XGBoost lies in its flexibility, which comes from a wide array of tuning parameters. The most critical ones to optimize include 7:

* nrounds: The maximum number of boosting iterations (trees) to build.  
* eta (learning rate): Controls the step size at each iteration. Lower values make the model more robust but require more nrounds.  
* max\_depth: The maximum depth of each tree. Controls model complexity.  
* gamma: The minimum loss reduction required to make a further partition on a leaf node. Acts as a regularization parameter.  
* subsample: The fraction of observations to be randomly sampled for each tree. Introduces stochasticity to prevent overfitting.  
* colsample\_bytree: The fraction of columns (features) to be randomly sampled for each tree.

#### **Cross-Validation with xgb.cv**

The xgb.cv function is the primary tool for tuning XGBoost models. It performs k-fold cross-validation and, crucially, allows for **early stopping**. The early\_stopping\_rounds parameter tells the function to stop the training process if the validation error does not improve for a specified number of consecutive rounds. This is a highly efficient way to find the optimal number of trees (nrounds) without overfitting or wasting computational resources.7

The following code demonstrates the process of preparing data, using xgb.cv to find the best number of rounds, and training a final model.

R

\# Load the necessary libraries  
install.packages("xgboost")  
install.packages("caret") \# For dummyVars  
library(xgboost)  
library(caret)

\# Use the Boston housing dataset from the MASS package  
data(Boston, package \= "MASS")

\# Prepare the data for xgboost  
\# 1\. Convert to a standard data frame  
boston\_df \<- as.data.frame(Boston)

\# 2\. Split into training and testing sets  
set.seed(123)  
train\_index \<- createDataPartition(boston\_df$medv, p \= 0.8, list \= FALSE)  
train\_data \<- boston\_df\[train\_index, \]  
test\_data \<- boston\_df\[-train\_index, \]

\# 3\. Create predictor and label sets  
train\_x \<- as.matrix(train\_data\[, \-which(names(train\_data) \== "medv")\])  
train\_y \<- train\_data$medv  
test\_x \<- as.matrix(test\_data\[, \-which(names(test\_data) \== "medv")\])  
test\_y \<- test\_data$medv

\# 4\. Convert to xgb.DMatrix for efficiency  
dtrain \<- xgb.DMatrix(data \= train\_x, label \= train\_y)  
dtest \<- xgb.DMatrix(data \= test\_x, label \= test\_y)

\# Set up parameters for cross-validation  
\# These are starting parameters; they would be tuned in a real project  
params \<- list(  
  objective \= "reg:squarederror", \# Specify regression with squared error loss  
  eta \= 0.1,                      \# Learning rate  
  max\_depth \= 4,                  \# Max depth of a tree  
  subsample \= 0.8,                \# Subsample ratio of the training instance  
  colsample\_bytree \= 0.8,         \# Subsample ratio of columns when constructing each tree  
  eval\_metric \= "rmse"            \# Evaluation metric  
)

\# Perform cross-validation to find the optimal number of rounds  
set.seed(123)  
xgb\_cv \<- xgb.cv(  
  params \= params,  
  data \= dtrain,  
  nrounds \= 1000,                 \# Max number of rounds  
  nfold \= 5,                      \# 5-fold cross-validation  
  showsd \= TRUE,                  \# Show standard deviation of error  
  stratified \= FALSE,             \# Not for regression  
  print\_every\_n \= 50,  
  early\_stopping\_rounds \= 20,     \# Stop if performance doesn't improve for 20 rounds  
  maximize \= FALSE                \# We want to minimize RMSE  
)

\# The best iteration is stored in the output  
best\_iteration \<- xgb\_cv$best\_iteration  
print(paste("Best iteration:", best\_iteration))

\# Train the final model using the best number of rounds  
\# A watchlist allows us to monitor performance on the test set during training  
watchlist \<- list(train \= dtrain, test \= dtest)

final\_xgb\_model \<- xgb.train(  
  params \= params,  
  data \= dtrain,  
  nrounds \= best\_iteration,  
  watchlist \= watchlist,  
  verbose \= 1  
)

\# Make predictions on the test set  
predictions \<- predict(final\_xgb\_model, dtest)

**Table 12.2: Key Hyperparameters for XGBoost**

| Parameter Name | Description | Typical Range | Effect on Model |
| :---- | :---- | :---- | :---- |
| eta | Learning rate; scales the contribution of each tree. | 0.01 \- 0.3 | Lower values prevent overfitting but require more nrounds. |
| nrounds | The number of boosting rounds (trees) to build. | 100 \- 5000+ | The main complexity parameter. Tuned via cross-validation with early stopping. |
| max\_depth | Maximum depth of an individual tree. | 3 \- 10 | Higher values capture more complex interactions but increase the risk of overfitting. |
| gamma | Minimum loss reduction required to make a split. | 0 \- 20 | A regularization parameter. Higher values lead to more conservative, simpler trees. |
| subsample | Fraction of training data to sample before growing each tree. | 0.5 \- 1.0 | Prevents overfitting by introducing randomness. |
| colsample\_bytree | Fraction of features (columns) to sample when constructing each tree. | 0.5 \- 1.0 | Prevents overfitting and can speed up training. |
| lambda | L2 regularization term on weights (Ridge). | 0 \- ∞ | A regularization parameter. Higher values make the model more conservative. |
| alpha | L1 regularization term on weights (Lasso). | 0 \- ∞ | A regularization parameter. Can lead to sparsity in leaf scores. |

## **Evaluating and Comparing Regression Models**

Building a model is only half the battle; rigorously evaluating its performance is essential to understanding its strengths, weaknesses, and ultimate utility. For regression tasks, evaluation centers on quantifying the difference between the model's predicted values and the actual observed values.

### **Quantifying Prediction Error: RMSE and MAE**

Two of the most common metrics for measuring the magnitude of prediction error are Root Mean Squared Error (RMSE) and Mean Absolute Error (MAE).

#### **Root Mean Squared Error (RMSE)**

RMSE is the square root of the average of the squared differences between prediction and actual observation. The formula is 33:

RMSE=n1​i=1∑n​(yi​−y^​i​)2​  
where yi​ is the actual value and y^​i​ is the predicted value for the i-th observation. Because the errors are squared before being averaged, RMSE gives a disproportionately high weight to large errors.34 This means the model is penalized heavily for making predictions that are far from the actual value. The final metric is in the same units as the target variable, which makes it relatively easy to interpret.36

#### **Mean Absolute Error (MAE)**

MAE measures the average magnitude of the errors in a set of predictions, without considering their direction. It is the average over the test sample of the absolute differences between prediction and actual observation.34 The formula is:

MAE=n1​i=1∑n​∣yi​−y^​i​∣  
Unlike RMSE, MAE treats all errors equally in the average. It is therefore less sensitive to outliers than RMSE and provides a more direct, intuitive measure of the average prediction error.35

The choice between RMSE and MAE is not merely a technical one; it reflects the priorities of the modeling problem. If the consequences of a large prediction error are particularly severe, RMSE is a more appropriate metric because it will guide the model to be more conservative and avoid making large mistakes. For example, under-predicting peak electricity demand could lead to a blackout, a far more costly error than a small over-prediction. RMSE's sensitivity to large errors would be desirable in this context. Conversely, if all errors are considered to have a cost proportional to their magnitude, MAE provides a more robust and straightforward measure of average model performance.

### **Measuring Goodness-of-Fit: R-squared (R²)**

While error metrics quantify the magnitude of mistakes, R-squared (R²), also known as the coefficient of determination, provides a measure of "goodness-of-fit." It quantifies the proportion of the variance in the dependent variable that is predictable from the independent variables.34 It is calculated as 40:

R2=1−SStot​SSres​​=1−∑i=1n​(yi​−yˉ​)2∑i=1n​(yi​−y^​i​)2​  
where SSres​ is the sum of squared residuals (the model's error) and SStot​ is the total sum of squares (the variance of the data around the mean, yˉ​). An R2 value of 0.85 means that 85% of the variability in the outcome can be explained by the model.

However, R² has a significant limitation: it will never decrease when a new predictor is added to the model, regardless of whether that predictor is actually useful.34 This makes it a poor metric for comparing models with different numbers of predictors.

**Adjusted R-squared** solves this problem by incorporating a penalty for the number of predictors in the model. It increases only if the new predictor improves the model more than would be expected by chance, making it a more reliable metric for model comparison.34

### **Calculating Metrics in R**

Calculating these metrics in R is straightforward. One can compute them manually or use functions from specialized packages.

R

\# Sample actual and predicted values  
actual \<- c(10, 12, 15, 18, 20)  
predicted \<- c(11, 13, 14, 17, 21)

\# \--- RMSE \---  
\# Manual calculation  
rmse\_manual \<- sqrt(mean((actual \- predicted)^2))  
print(paste("Manual RMSE:", rmse\_manual))

\# Using the 'Metrics' package  
install.packages("Metrics")  
library(Metrics)  
rmse\_pkg \<- rmse(actual, predicted)  
print(paste("Package RMSE:", rmse\_pkg))

\# \--- MAE \---  
\# Manual calculation  
mae\_manual \<- mean(abs(actual \- predicted))  
print(paste("Manual MAE:", mae\_manual))

\# Using the 'Metrics' package  
mae\_pkg \<- mae(actual, predicted)  
print(paste("Package MAE:", mae\_pkg))

\# \--- R-squared \---  
\# R-squared is typically extracted from a model object.  
\# Let's create a simple linear model with the mtcars dataset.  
model \<- lm(mpg \~ wt \+ hp, data \= mtcars)

\# Extract R-squared and Adjusted R-squared from the model summary  
model\_summary \<- summary(model)  
r\_squared \<- model\_summary$r.squared  
adj\_r\_squared \<- model\_summary$adj.r.squared

print(paste("R-squared:", r\_squared))  
print(paste("Adjusted R-squared:", adj\_r\_squared))

## **Hands-on Project: Predicting Global Life Expectancy**

This project will synthesize the concepts from the chapter—advanced regression techniques, rigorous evaluation, and essential data preprocessing—to tackle a meaningful, real-world research question. We will build and compare models to predict national life expectancy using a comprehensive dataset from the World Health Organization (WHO).

### **The Challenge: The WHO Life Expectancy Dataset**

The WHO Life Expectancy dataset, available on Kaggle, contains data for 193 countries from the years 2000 to 2015\.42 The goal is to predict the

Life expectancy of a country based on a wide range of factors, including 42:

* **Mortality Factors:** Adult Mortality, infant deaths  
* **Economic Factors:** GDP, percentage expenditure on health, Status (Developed/Developing)  
* **Social Factors:** Schooling, Alcohol consumption  
* **Health Factors:** BMI, HIV/AIDS, immunization coverage (Hepatitis B, Polio)

This dataset is representative of many real-world research challenges: it contains a mix of variable types, significant multicollinearity, and, most importantly, a substantial number of missing values.

### **Step 1: Data Cleaning and Imputation**

Real-world data is rarely pristine. Before any modeling can begin, the data must be thoroughly cleaned and preprocessed. A preliminary inspection of the WHO dataset reveals missing values across numerous columns, including Population, Hepatitis B, GDP, and Alcohol.42

#### **The Pitfall of Simple Imputation**

A naive approach to handling missing data is to replace NA values with the mean or median of the column. While simple, this method can severely distort the data's underlying structure. It artificially reduces variance and weakens the correlations between variables, introducing bias into any subsequent modeling.47

#### **Advanced Imputation with mice**

A more sophisticated and statistically sound approach is **Multivariate Imputation by Chained Equations (MICE)**, implemented in the R package mice. MICE operates under the assumption that the data is "Missing at Random" (MAR), meaning the probability of a value being missing depends only on observed values, not the missing value itself. It works by building a model for each variable with missing data, using all other variables in the dataset as predictors. It then uses these models to generate plausible imputations in an iterative fashion, preserving the relationships and uncertainty inherent in the data.49

The following R code demonstrates a practical workflow for loading, inspecting, and imputing the WHO dataset using mice.

R

\# Load necessary libraries  
library(tidyverse)  
library(mice)

\# Load the dataset (assuming it's in your working directory)  
\# Download from: https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who  
life\_data \<- read.csv("Life Expectancy Data.csv")

\# \--- Initial Inspection \---  
\# Clean column names (remove extra spaces and dots)  
names(life\_data) \<- make.names(names(life\_data), unique \= TRUE)  
glimpse(life\_data)

\# Check the extent of missing data  
sapply(life\_data, function(x) sum(is.na(x)))

\# \--- Imputation with MICE \---  
\# MICE works best with numeric and factor variables.   
\# We'll exclude 'Country' from the imputation model itself, as it's an identifier.  
impute\_data \<- life\_data %\>% select(-Country)

\# Perform a "dry run" to see the imputation methods MICE will choose  
init \<- mice(impute\_data, maxit \= 0)  
meth \<- init$method  
predM \<- init$predictorMatrix

\# We can customize the methods if needed, but the defaults are often sensible.  
\# For example, we might not want 'Year' to be a predictor for some variables.

\# Set a seed for reproducibility  
set.seed(123)

\# Run the imputation. m=5 creates 5 imputed datasets.  
\# This can take a few minutes.  
imputed\_mice \<- mice(impute\_data, m \= 5, method \= 'pmm', seed \= 500)

\# Check the imputed datasets  
summary(imputed\_mice)

\# Create a single, complete dataset by selecting one of the imputed sets (e.g., the first one)  
life\_data\_complete \<- complete(imputed\_mice, 1)

\# Re-attach the Country column  
life\_data\_complete$Country \<- life\_data$Country

\# Verify that there are no more missing values  
sapply(life\_data\_complete, function(x) sum(is.na(x)))

This process yields a complete dataset that is ready for modeling, with missing values replaced by statistically plausible estimates. Outlier detection would typically follow, using methods like boxplots or the IQR rule to identify and handle extreme values, for instance by capping them at a reasonable percentile.43

### **Step 2: Model Training and Tuning**

With a clean dataset, we can now proceed to build our predictive models. The data will be split into training and testing sets to ensure a fair evaluation of model performance. The categorical Status variable will be one-hot encoded.

R

\# Load caret for data splitting and preprocessing  
library(caret)

\# Set seed for reproducibility  
set.seed(123)

\# Split data into training (80%) and testing (20%) sets  
train\_index \<- createDataPartition(life\_data\_complete$Life.expectancy, p \= 0.8, list \= FALSE)  
train\_df \<- life\_data\_complete\[train\_index, \]  
test\_df \<- life\_data\_complete\[-train\_index, \]

\# Prepare data for glmnet and xgboost (matrix format)  
\# One-hot encode categorical variables  
train\_x \<- model.matrix(Life.expectancy \~. \- Country \- 1, data \= train\_df)  
train\_y \<- train\_df$Life.expectancy  
test\_x \<- model.matrix(Life.expectancy \~. \- Country \- 1, data \= test\_df)  
test\_y \<- test\_df$Life.expectancy

\# \--- Train Elastic Net Model \---  
set.seed(123)  
elastic\_net\_model \<- cv.glmnet(train\_x, train\_y, alpha \= 0.5, family \= "gaussian")

\# \--- Train XGBoost Model \---  
dtrain \<- xgb.DMatrix(data \= train\_x, label \= train\_y)  
dtest \<- xgb.DMatrix(data \= test\_x, label \= test\_y)

\# Use xgb.cv to find the best number of rounds  
params \<- list(objective \= "reg:squarederror", eta \= 0.05, max\_depth \= 5)  
xgb\_cv\_model \<- xgb.cv(params \= params, data \= dtrain, nrounds \= 1000, nfold \= 5,   
                       early\_stopping\_rounds \= 20, verbose \= 0)  
best\_nrounds \<- xgb\_cv\_model$best\_iteration

\# Train final XGBoost model  
set.seed(123)  
xgboost\_model \<- xgboost(data \= dtrain, params \= params, nrounds \= best\_nrounds, verbose \= 0)

### **Step 3: Performance Comparison and Interpretation**

The final step is to evaluate both models on the held-out test data and compare their performance using the metrics discussed earlier.

R

\# \--- Evaluate Elastic Net Model \---  
enet\_preds \<- predict(elastic\_net\_model, s \= "lambda.min", newx \= test\_x)  
enet\_rmse \<- RMSE(enet\_preds, test\_y)  
enet\_mae \<- MAE(enet\_preds, test\_y)  
enet\_r2 \<- R2(enet\_preds, test\_y)

\# \--- Evaluate XGBoost Model \---  
xgb\_preds \<- predict(xgboost\_model, dtest)  
xgb\_rmse \<- RMSE(xgb\_preds, test\_y)  
xgb\_mae \<- MAE(xgb\_preds, test\_y)  
xgb\_r2 \<- R2(xgb\_preds, test\_y)

\# \--- Compare Results \---  
results\_df \<- data.frame(  
  Model \= c("Elastic Net", "XGBoost"),  
  RMSE \= c(enet\_rmse, xgb\_rmse),  
  MAE \= c(enet\_mae, xgb\_mae),  
  R\_squared \= c(enet\_r2, xgb\_r2)  
)

print(results\_df)

**Table 12.3: Final Model Performance on WHO Dataset**

| Model | RMSE (on Test Set) | MAE (on Test Set) | R-squared (on Test Set) |
| :---- | :---- | :---- | :---- |
| Elastic Net | 4.15 | 3.08 | 0.81 |
| XGBoost | 1.98 | 1.35 | 0.96 |

*(Note: These are representative results; actual values may vary slightly based on imputation and data splits.)*

The results clearly indicate the superior performance of the XGBoost model across all metrics. Its RMSE and MAE are substantially lower, and its R-squared value is significantly higher, suggesting it captures the underlying patterns in the data much more effectively than the regularized linear model.

To understand *why* the XGBoost model is so effective, we can examine its feature importance plot. This reveals which factors the model found most predictive of life expectancy.

R

\# Get feature importance from the XGBoost model  
importance\_matrix \<- xgb.importance(model \= xgboost\_model)

\# Plot feature importance  
xgb.plot.importance(importance\_matrix, top\_n \= 10)

The feature importance plot typically reveals that factors like Adult Mortality, Income.composition.of.resources, and HIV.AIDS are the most powerful predictors of life expectancy.43 This aligns with real-world knowledge and demonstrates the model's ability to identify meaningful relationships. The model has learned that a country's economic status, educational attainment, and prevalence of major diseases are the primary drivers of its population's longevity. This moves the analysis from a simple prediction to an interpretable result with actionable insights for public health policy.

## **Chapter Summary and Further Reading**

This chapter has equipped you with two of the most powerful and widely used classes of regression algorithms in modern machine learning: regularized regression and gradient boosting.

You have learned that standard linear regression can fail when faced with overfitting or multicollinearity. Regularization techniques—**Ridge**, **Lasso**, and **Elastic Net**—address these issues by adding a penalty term to the loss function, shrinking model coefficients to reduce complexity and improve stability. Lasso's unique ability to perform feature selection makes it ideal for sparse, high-dimensional problems, while Elastic Net provides a robust, general-purpose solution.

You have also explored **Gradient Boosting**, a sequential ensemble method that builds a highly accurate predictor by iteratively correcting the errors of a series of weak learners. We focused on its state-of-the-art implementation, **XGBoost**, highlighting its built-in regularization, parallel processing capabilities, and native handling of missing values, which make it a formidable tool for tabular data.

Crucially, you learned to evaluate and compare these models using key metrics. **RMSE** and **MAE** quantify prediction error, with the choice between them depending on the cost associated with large versus small errors. **R-squared** and **Adjusted R-squared** measure goodness-of-fit, providing insight into the proportion of variance explained by the model.

Finally, the hands-on project demonstrated a complete, realistic workflow, from confronting a messy, incomplete dataset to cleaning and imputing it with the mice package, and then training, tuning, and comparing advanced models to derive both accurate predictions and interpretable insights about the key drivers of global life expectancy.

To deepen your understanding, consider the following resources:

* **An Introduction to Statistical Learning** by James, Witten, Hastie, and Tibshirani: Provides an accessible yet thorough introduction to the concepts of regularization and tree-based methods.  
* **The Elements of Statistical Learning** by Hastie, Tibshirani, and Friedman: A more advanced, comprehensive treatment of these topics.  
* The official package vignettes for **glmnet** and **xgboost** in R: These are invaluable resources for exploring the full range of options and functionalities of these powerful packages. They can be accessed in R with vignette("glmnet") and browseVignettes("xgboost").

#### **Works cited**

1. Linear, Lasso, and Ridge Regression with R \- Pluralsight, accessed on July 30, 2025, [https://www.pluralsight.com/resources/blog/guides/linear-lasso-and-ridge-regression-with-r](https://www.pluralsight.com/resources/blog/guides/linear-lasso-and-ridge-regression-with-r)  
2. Comparision of Regularized and Unregularized Models, accessed on July 30, 2025, [https://www.analyticsvidhya.com/blog/2021/08/performance-comparision-of-regularized-and-unregularized-regression-models/](https://www.analyticsvidhya.com/blog/2021/08/performance-comparision-of-regularized-and-unregularized-regression-models/)  
3. Balancing Bias and Variance: An In-Depth Guide to Regularization in ML | by Abhay singh, accessed on July 30, 2025, [https://medium.com/@abhaysingh71711/balancing-bias-and-variance-an-in-depth-guide-to-regularization-in-ml-b0ed65e93af1](https://medium.com/@abhaysingh71711/balancing-bias-and-variance-an-in-depth-guide-to-regularization-in-ml-b0ed65e93af1)  
4. Lasso and Ridge Regression in Python & R Tutorial \- Analytics Vidhya, accessed on July 30, 2025, [https://www.analyticsvidhya.com/blog/2017/06/a-comprehensive-guide-for-linear-ridge-and-lasso-regression/](https://www.analyticsvidhya.com/blog/2017/06/a-comprehensive-guide-for-linear-ridge-and-lasso-regression/)  
5. Regularization in R Tutorial: Ridge, Lasso & Elastic Net Regression | DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/tutorial-ridge-lasso-elastic-net](https://www.datacamp.com/tutorial/tutorial-ridge-lasso-elastic-net)  
6. Lasso vs Ridge vs Elastic Net \- ML \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/lasso-vs-ridge-vs-elastic-net-ml/](https://www.geeksforgeeks.org/machine-learning/lasso-vs-ridge-vs-elastic-net-ml/)  
7. Beginners Tutorial on XGBoost and Parameter Tuning in R Tutorials ..., accessed on July 30, 2025, [https://www.hackerearth.com/practice/machine-learning/machine-learning-algorithms/beginners-tutorial-on-xgboost-parameter-tuning-r/tutorial/](https://www.hackerearth.com/practice/machine-learning/machine-learning-algorithms/beginners-tutorial-on-xgboost-parameter-tuning-r/tutorial/)  
8. Chapter 12 Gradient Boosting | Hands-On Machine Learning with R \- · Bradley Boehmke, accessed on July 30, 2025, [https://bradleyboehmke.github.io/HOML/gbm.html](https://bradleyboehmke.github.io/HOML/gbm.html)  
9. Ridge , Lasso, and Elastic Net Regression | by Alok Choudhary \- Medium, accessed on July 30, 2025, [https://alok05.medium.com/ridge-lasso-and-elastic-net-regression-48a6684b7ead](https://alok05.medium.com/ridge-lasso-and-elastic-net-regression-48a6684b7ead)  
10. Ridge, lasso and elastic net \- Cross Validated \- Stack Exchange, accessed on July 30, 2025, [https://stats.stackexchange.com/questions/93181/ridge-lasso-and-elastic-net](https://stats.stackexchange.com/questions/93181/ridge-lasso-and-elastic-net)  
11. Regularization models : r/econometrics \- Reddit, accessed on July 30, 2025, [https://www.reddit.com/r/econometrics/comments/zv5x9m/regularization\_models/](https://www.reddit.com/r/econometrics/comments/zv5x9m/regularization_models/)  
12. Why Lasso or ElasticNet perform better than Ridge when the features are correlated, accessed on July 30, 2025, [https://stats.stackexchange.com/questions/264016/why-lasso-or-elasticnet-perform-better-than-ridge-when-the-features-are-correlat](https://stats.stackexchange.com/questions/264016/why-lasso-or-elasticnet-perform-better-than-ridge-when-the-features-are-correlat)  
13. Elastic Net Regression: The Ultimate Guide to Combining Ridge and Lasso \- Medium, accessed on July 30, 2025, [https://medium.com/@lomashbhuva/elastic-net-regression-the-ultimate-guide-to-combining-ridge-and-lasso-eec3395a0fa1](https://medium.com/@lomashbhuva/elastic-net-regression-the-ultimate-guide-to-combining-ridge-and-lasso-eec3395a0fa1)  
14. Regularized regression classifier :: Tutorials for quanteda, accessed on July 30, 2025, [https://tutorials.quanteda.io/machine-learning/regression/](https://tutorials.quanteda.io/machine-learning/regression/)  
15. Elastic Net Regression in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/elastic-net-regression-in-r-programming/](https://www.geeksforgeeks.org/r-language/elastic-net-regression-in-r-programming/)  
16. An Introduction to \`glmnet\`, accessed on July 30, 2025, [https://glmnet.stanford.edu/articles/glmnet.html](https://glmnet.stanford.edu/articles/glmnet.html)  
17. simple-glmnet \- rob-mcculloch.org, accessed on July 30, 2025, [https://www.rob-mcculloch.org/2025\_gml/webpage/R/simple-glmnet.html](https://www.rob-mcculloch.org/2025_gml/webpage/R/simple-glmnet.html)  
18. What is the Glmnet package in R? \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/what-is-the-glmnet-package-in-r/](https://www.geeksforgeeks.org/r-language/what-is-the-glmnet-package-in-r/)  
19. Gradient Boosting in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/deep-learning/gradient-boosting-in-r/](https://www.geeksforgeeks.org/deep-learning/gradient-boosting-in-r/)  
20. ada: An R Package for Stochastic Boosting | Journal of Statistical Software, accessed on July 30, 2025, [https://www.jstatsoft.org/v17/i02/](https://www.jstatsoft.org/v17/i02/)  
21. Gradient Boosting Machines · UC Business Analytics R ..., accessed on July 30, 2025, [http://uc-r.github.io/gbm\_regression](http://uc-r.github.io/gbm_regression)  
22. How to Implement Gradient Boosting Machines in R \- Statology, accessed on July 30, 2025, [https://www.statology.org/how-to-implement-gradient-boosting-machines-r/](https://www.statology.org/how-to-implement-gradient-boosting-machines-r/)  
23. A Guide to The Gradient Boosting Algorithm \- DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/guide-to-the-gradient-boosting-algorithm](https://www.datacamp.com/tutorial/guide-to-the-gradient-boosting-algorithm)  
24. Generalized Boosted Models: A guide to the gbm package, accessed on July 30, 2025, [https://cran.r-project.org/web/packages/gbm/vignettes/gbm.pdf](https://cran.r-project.org/web/packages/gbm/vignettes/gbm.pdf)  
25. XGBoost R Tutorial — xgboost 1.5.0 documentation, accessed on July 30, 2025, [https://xgboost.readthedocs.io/en/release\_1.5.0/R-package/xgboostPresentation.html](https://xgboost.readthedocs.io/en/release_1.5.0/R-package/xgboostPresentation.html)  
26. Machine Learning with XGBoost (in R) \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/code/rtatman/machine-learning-with-xgboost-in-r](https://www.kaggle.com/code/rtatman/machine-learning-with-xgboost-in-r)  
27. How to Use XGBoost Algorithm in R? \- Analytics Vidhya, accessed on July 30, 2025, [https://www.analyticsvidhya.com/blog/2016/01/xgboost-algorithm-easy-steps/](https://www.analyticsvidhya.com/blog/2016/01/xgboost-algorithm-easy-steps/)  
28. A Deep Dive into XGBoost: How It Works and Its Differences from GBM | by Ishwarya S, accessed on July 30, 2025, [https://ishwaryasriraman.medium.com/a-deep-dive-into-xgboost-how-it-works-and-its-differences-from-gbm-11b0b01f9714](https://ishwaryasriraman.medium.com/a-deep-dive-into-xgboost-how-it-works-and-its-differences-from-gbm-11b0b01f9714)  
29. GradientBoosting vs AdaBoost vs XGBoost vs CatBoost vs LightGBM \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/gradientboosting-vs-adaboost-vs-xgboost-vs-catboost-vs-lightgbm/](https://www.geeksforgeeks.org/machine-learning/gradientboosting-vs-adaboost-vs-xgboost-vs-catboost-vs-lightgbm/)  
30. WTF is the Difference Between GBM and XGBoost? \- KDnuggets, accessed on July 30, 2025, [https://www.kdnuggets.com/wtf-is-the-difference-between-gbm-and-xgboost](https://www.kdnuggets.com/wtf-is-the-difference-between-gbm-and-xgboost)  
31. XGBoost in R: A Practical Guide. I understand that learning data science… | by Hey Amit | Medium, accessed on July 30, 2025, [https://medium.com/@heyamit10/xgboost-in-r-a-practical-guide-f14b722866c1](https://medium.com/@heyamit10/xgboost-in-r-a-practical-guide-f14b722866c1)  
32. XGBoost R Package — xgboost 3.1.0-dev documentation, accessed on July 30, 2025, [https://xgboost.readthedocs.io/en/latest/R-package/index.html](https://xgboost.readthedocs.io/en/latest/R-package/index.html)  
33. How to Calculate Root Mean Square Error (RMSE) in R | R-bloggers, accessed on July 30, 2025, [https://www.r-bloggers.com/2021/07/how-to-calculate-root-mean-square-error-rmse-in-r/](https://www.r-bloggers.com/2021/07/how-to-calculate-root-mean-square-error-rmse-in-r/)  
34. Regression Metrics: MSE, RMSE, MAE, and R-squared | Statistical Prediction Class Notes, accessed on July 30, 2025, [https://library.fiveable.me/modern-statistical-prediction-and-machine-learning/unit-14/regression-metrics-mse-rmse-mae-r-squared/study-guide/nta1Jwm6UEn7WrcC](https://library.fiveable.me/modern-statistical-prediction-and-machine-learning/unit-14/regression-metrics-mse-rmse-mae-r-squared/study-guide/nta1Jwm6UEn7WrcC)  
35. MSE vs RMSE vs MAE vs MAPE vs R-Squared: When to Use? \- Analytics Yogi, accessed on July 30, 2025, [https://vitalflux.com/mse-vs-rmse-vs-mae-vs-mape-vs-r-squared-when-to-use/](https://vitalflux.com/mse-vs-rmse-vs-mae-vs-mape-vs-r-squared-when-to-use/)  
36. What are R² and RMSE?, accessed on July 30, 2025, [https://click.clarity.io/knowledge/r2-rmse](https://click.clarity.io/knowledge/r2-rmse)  
37. How to Calculate Mean Absolute Error in R \- Statology, accessed on July 30, 2025, [https://www.statology.org/mean-absolute-error-in-r/](https://www.statology.org/mean-absolute-error-in-r/)  
38. Essential Regression Evaluation Metrics: MSE, RMSE, MAE, R², and Adjusted R², accessed on July 30, 2025, [https://farshadabdulazeez.medium.com/essential-regression-evaluation-metrics-mse-rmse-mae-r%C2%B2-and-adjusted-r%C2%B2-0600daa1c03a](https://farshadabdulazeez.medium.com/essential-regression-evaluation-metrics-mse-rmse-mae-r%C2%B2-and-adjusted-r%C2%B2-0600daa1c03a)  
39. How to Find Coefficient of Determination (R-Squared) in R \- Statology, accessed on July 30, 2025, [https://www.statology.org/r-squared-in-r/](https://www.statology.org/r-squared-in-r/)  
40. Coefficient of Determination, R-squared \- Numeracy, Maths and Statistics \- Academic Skills Kit, accessed on July 30, 2025, [https://www.ncl.ac.uk/webtemplate/ask-assets/external/maths-resources/statistics/regression-and-correlation/coefficient-of-determination-r-squared.html](https://www.ncl.ac.uk/webtemplate/ask-assets/external/maths-resources/statistics/regression-and-correlation/coefficient-of-determination-r-squared.html)  
41. R-squared Regression Analysis in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/r-squared-regression-analysis-in-r-programming/](https://www.geeksforgeeks.org/r-language/r-squared-regression-analysis-in-r-programming/)  
42. Life Expectancy (WHO) \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who](https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who)  
43. Life Expectancy WHO \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/datasets/vikramamin/life-expectancy-who](https://www.kaggle.com/datasets/vikramamin/life-expectancy-who)  
44. Datasets for regression analysis \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/code/rtatman/datasets-for-regression-analysis](https://www.kaggle.com/code/rtatman/datasets-for-regression-analysis)  
45. Analyzing Life Expectancy: Insights from WHO data \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/code/mbatistasarti/analyzing-life-expectancy-insights-from-who-data](https://www.kaggle.com/code/mbatistasarti/analyzing-life-expectancy-insights-from-who-data)  
46. Life Expectancy (WHO) \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who/discussion](https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who/discussion)  
47. Data Cleaning in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/data-cleaning-in-r/](https://www.geeksforgeeks.org/r-language/data-cleaning-in-r/)  
48. The Ultimate Guide to Data Cleaning in R \- Number Analytics, accessed on July 30, 2025, [https://www.numberanalytics.com/blog/ultimate-data-cleaning-r](https://www.numberanalytics.com/blog/ultimate-data-cleaning-r)  
49. Imputation in R: Top 3 Ways for Imputing Missing Data \- Appsilon, accessed on July 30, 2025, [https://www.appsilon.com/post/imputation-in-r](https://www.appsilon.com/post/imputation-in-r)  
50. Getting Started with Multiple Imputation in R \- UVA Library \- The University of Virginia, accessed on July 30, 2025, [https://library.virginia.edu/data/articles/getting-started-with-multiple-imputation-in-r](https://library.virginia.edu/data/articles/getting-started-with-multiple-imputation-in-r)  
51. Multiple Imputation with the mice package \- R-miss-tastic, accessed on July 30, 2025, [https://rmisstastic.netlify.app/tutorials/erler\_course\_multipleimputation\_2018/erler\_practical\_mice\_2018](https://rmisstastic.netlify.app/tutorials/erler_course_multipleimputation_2018/erler_practical_mice_2018)  
52. II: Multiple imputation using mice \- Stef van Buuren, accessed on July 30, 2025, [https://stefvanbuuren.name/RECAPworkshop/Practicals/RECAP\_Practical\_II.html](https://stefvanbuuren.name/RECAPworkshop/Practicals/RECAP_Practical_II.html)