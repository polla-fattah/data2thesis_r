---
title: Advanced Machine Learning Techniques
slug: chapter14
order: 130
published: false
abstract: >
    Expanding the machine learning toolkit, this chapter introduces ensemble methods, neural networks, and time series forecasting. Readers will gain insights into tackling complex research problems using advanced modeling techniques.
---



The preceding chapters have established a robust foundation in statistical analysis, focusing on building models to understand and explain relationships within data. We have explored techniques from descriptive statistics to hypothesis testing and regression, all of which are cornerstones of quantitative research. This chapter marks a pivotal transition from explanatory modeling to the domain of high-performance predictive modeling. Here, the primary objective shifts from interpreting coefficients to maximizing predictive accuracy.

We will venture into three of the most powerful and widely used areas of modern machine learning. First, we will explore **Ensemble Methods**, a class of algorithms built on the principle that a "committee" of models often makes better predictions than any single expert. We will dissect the two dominant philosophies: Bagging and Boosting. Second, we will demystify **Artificial Neural Networks**, drawing inspiration from the human brain to build deep learning models capable of capturing extraordinarily complex patterns, using the powerful keras and tensorflow libraries in R. Third, we will address the unique challenge of **Time Series Forecasting**, examining both the classical statistical approach of ARIMA and a modern, flexible alternative in Facebook's Prophet.

The chapter culminates in a comprehensive hands-on project that synthesizes these techniques. By applying these advanced methods to a real-world retail sales forecasting problem, we will not only see them in action but also compare their performance, providing a practical framework for model selection in complex research applications.

## **14.1 The Power of the Collective: Ensemble Methods**

Ensemble methods are meta-algorithms that combine the predictions from multiple machine learning models to produce a single, superior predictive model. The underlying principle is intuitive and powerful: by aggregating the "votes" or predictions of several models, the final prediction is often more accurate, stable, and robust than that of any individual model.

### **14.1.1 The Wisdom of Crowds in Machine learning**

The success of ensemble learning is rooted in the statistical concept of the bias-variance tradeoff. A single, complex model, such as a large decision tree, might fit the training data perfectly but fail to generalize to new, unseen data—a condition known as high variance. Conversely, a simple model might be too rigid to capture the underlying patterns in the data, leading to high bias. Ensemble methods provide a systematic framework for managing this tradeoff.1

The core idea is that if you build a committee of "weak learners"—models that are only slightly better than random guessing—their collective decision can be transformed into that of a "strong learner" with high predictive accuracy.1 This works because different models are likely to make different types of errors. When their predictions are combined, these individual errors tend to cancel each other out. The key to a successful ensemble is not just the quantity of models but their

**diversity**. The more varied the models in their structure and the errors they make, the more powerful the ensemble becomes. This principle explains why the two primary ensemble strategies, Bagging and Boosting, are so effective: they employ distinct mechanisms to foster this crucial model diversity.

### **14.1.2 Bagging: Reducing Variance with Bootstrap Aggregation**

**Bootstrap Aggregating**, or **Bagging**, is an ensemble technique designed primarily to reduce the variance of a predictive model.2 It is particularly effective for high-variance, low-bias models, with the canonical example being fully grown decision trees.

The process is conceptually straightforward and highly parallelizable 2:

1. **Bootstrap Sampling:** From the original training dataset of size N, B new training sets are created by sampling N observations *with replacement*. This process, known as bootstrapping, results in multiple, slightly different datasets. On average, each bootstrap sample will contain about 63.2% of the unique original observations, with the remaining 36.8% being left out.5 These left-out data points are referred to as the  
   **Out-of-Bag (OOB)** sample.  
2. **Independent Model Training:** A base model (e.g., a decision tree) is trained independently on each of the B bootstrap samples. Because each model sees a slightly different subset of the data, each learns a slightly different representation of the underlying patterns.  
3. **Aggregation:** To make a prediction for a new observation, the predictions from all B models are aggregated. For regression tasks, this is typically done by averaging the predictions. For classification tasks, a majority vote is used.2

This process of averaging over many decorrelated models effectively smooths out the predictions and reduces the overall variance, making the final model more stable and less prone to overfitting.6

**Random Forest: The Premier Bagging Algorithm**

The most popular and powerful implementation of bagging is the **Random Forest** algorithm.2 A Random Forest is an ensemble of decision trees that introduces an additional layer of randomness to the bagging process to further decorrelate the individual trees. In addition to training each tree on a different bootstrap sample of the data, a Random Forest also samples a random subset of the predictor variables at each split point in the tree. This prevents a few dominant predictors from consistently appearing at the top of all the trees, thereby increasing the diversity of the ensemble and generally improving its predictive performance.

**Implementation in R**

In R, bagging and random forests can be implemented using several packages. The ipred package provides a general bagging() function, while the randomForest package is the standard for fitting random forest models. The caret package also offers a unified interface for both.

Let's demonstrate using the randomForest package with the built-in iris dataset.

R

\# Install and load necessary packages  
\# install.packages("randomForest")  
\# install.packages("caret")  
\# install.packages("dplyr")  
library(randomForest)  
library(caret)  
library(dplyr)

\# Prepare the data  
data(iris)  
set.seed(123) \# for reproducibility  
trainIndex \<- createDataPartition(iris$Species, p \= 0.8, list \= FALSE)  
train\_data \<- iris\[trainIndex,\]  
test\_data  \<- iris\[-trainIndex,\]

\# Fit a Random Forest model  
\# ntree: number of trees to grow  
\# mtry: number of variables randomly sampled as candidates at each split  
rf\_model \<- randomForest(Species \~., data \= train\_data, ntree \= 500, mtry \= 2, importance \= TRUE)

\# Print the model summary  
print(rf\_model)

The output of print(rf\_model) shows the model call, the type of forest (classification), the number of trees, and the number of variables tried at each split (mtry). Critically, it also displays the **Out-of-Bag (OOB) estimate of error rate**. This error is calculated using the OOB samples for each tree, providing an unbiased estimate of the model's performance without the need for a separate validation set.7

One of the key advantages of Random Forest is its ability to calculate variable importance scores, which measure the contribution of each predictor to the model's accuracy.8

R

\# View variable importance  
importance(rf\_model)

\# Plot variable importance  
varImpPlot(rf\_model)

The importance() function returns a table showing the Mean Decrease in Accuracy and Mean Decrease in Gini for each predictor. These metrics help identify which variables are most influential in predicting the outcome.

Finally, we can use the trained model to make predictions on the test set.

R

\# Make predictions on the test data  
predictions \<- predict(rf\_model, test\_data)

\# Evaluate the model using a confusion matrix  
confusionMatrix(predictions, test\_data$Species)

### **14.1.3 Boosting: Learning from Mistakes Sequentially**

Boosting represents a fundamentally different philosophy from bagging. Instead of building models independently in parallel, boosting algorithms build models **sequentially**, where each new model is trained to correct the errors made by its predecessors.1 The primary goal of boosting is to reduce the model's

**bias**, combining many weak learners into a single, highly accurate strong learner.2

The general process works as follows:

1. A simple base model (a "weak learner," often a very shallow decision tree called a "stump") is trained on the data.  
2. The model's predictions are evaluated, and the errors (or residuals) are identified.  
3. A second model is then trained, with a specific focus on the instances where the first model performed poorly.  
4. This process is repeated for a specified number of iterations, with each successive model building upon the previous ones to incrementally improve the overall performance of the ensemble.  
5. The final prediction is a weighted combination of the predictions from all the models in the sequence.

**Gradient Boosting Machine (GBM)**

While early algorithms like AdaBoost focused on re-weighting misclassified instances 2, the

**Gradient Boosting Machine (GBM)** provides a more generalized framework. GBM frames the problem as an optimization task where the goal is to minimize a loss function. In each iteration, a new weak learner is trained to predict the **negative gradient** of the loss function with respect to the previous model's predictions. For regression with a squared error loss, this simplifies to fitting each new tree to the *residual errors* of the preceding ensemble.9

**XGBoost: Extreme Gradient Boosting**

**XGBoost (Extreme Gradient Boosting)** is an implementation of gradient boosting that has become dominant in applied machine learning and data science competitions due to its exceptional performance and efficiency.11 It builds upon the GBM framework with several key innovations, including:

* **Regularization:** It incorporates both L1 (Lasso) and L2 (Ridge) regularization terms into the objective function, which helps prevent overfitting.11  
* **Optimized Performance:** It is engineered for speed and efficiency, with features like parallelized tree construction and cache-aware access.11  
* **Built-in Handling of Missing Values:** XGBoost can automatically learn how to handle missing data.11

**Implementation in R**

The gbm package is the classic implementation for gradient boosting, while the xgboost package provides the more advanced algorithm.

Let's demonstrate fitting an XGBoost model for the iris classification task. XGBoost requires the data to be in a specific format called xgb.DMatrix and the class labels to be numeric, starting from 0\.

R

\# Install and load necessary packages  
\# install.packages("xgboost")  
\# install.packages("caTools")  
library(xgboost)  
library(caTools)

\# Prepare data for XGBoost  
\# Convert Species factor to numeric (0, 1, 2\)  
iris\_xgb \<- iris  
iris\_xgb$Species \<- as.numeric(iris\_xgb$Species) \- 1

\# Split data  
set.seed(123)  
split \<- sample.split(iris\_xgb$Species, SplitRatio \= 0.8)  
train\_xgb \<- subset(iris\_xgb, split \== TRUE)  
test\_xgb  \<- subset(iris\_xgb, split \== FALSE)

\# Create xgb.DMatrix  
train\_matrix \<- xgb.DMatrix(data \= as.matrix(train\_xgb\[, \-5\]), label \= train\_xgb$Species)  
test\_matrix  \<- xgb.DMatrix(data \= as.matrix(test\_xgb\[, \-5\]), label \= test\_xgb$Species)

\# Set XGBoost parameters  
\# For multiclass classification, we need to specify the objective and the number of classes  
params \<- list(  
  booster \= "gbtree",  
  objective \= "multi:softmax",  
  num\_class \= 3,  
  eta \= 0.1, \# learning rate  
  max\_depth \= 3  
)

\# Train the XGBoost model  
xgb\_model \<- xgb.train(  
  params \= params,  
  data \= train\_matrix,  
  nrounds \= 100, \# number of boosting rounds  
  watchlist \= list(train \= train\_matrix, test \= test\_matrix),  
  print\_every\_n \= 10,  
  early\_stopping\_rounds \= 10 \# Stop if performance doesn't improve for 10 rounds  
)

Tuning an XGBoost model involves finding the optimal combination of hyperparameters. The most critical are eta (the learning rate) and nrounds (the number of boosting iterations). A lower learning rate generally requires more rounds to achieve optimal performance but can lead to a more robust model.10

R

\# Make predictions  
predictions\_xgb \<- predict(xgb\_model, test\_matrix)

\# Evaluate the model  
\# The predictions are numeric class labels (0, 1, 2\)  
\# We can compare them directly to the test labels  
accuracy \<- sum(predictions\_xgb \== test\_xgb$Species) / length(test\_xgb$Species)  
print(paste("Accuracy:", accuracy))

| Feature | Bagging (e.g., Random Forest) | Boosting (e.g., XGBoost) |
| :---- | :---- | :---- |
| **Core Idea** | Train many independent models and average their predictions. | Train models sequentially, with each one correcting its predecessor's errors. |
| **Model Training** | Parallel; models are trained independently on bootstrap samples. | Sequential; each model is trained based on the performance of the previous ones. |
| **Primary Goal** | Reduce variance and improve model stability. | Reduce bias and build a highly accurate model. |
| **Base Learners** | Typically uses deep, complex models (e.g., fully grown decision trees). | Uses simple, "weak" models (e.g., shallow decision trees or "stumps"). |
| **Key Strength** | Highly robust to overfitting and requires less hyperparameter tuning. | Can achieve state-of-the-art performance on a wide range of tasks. |
| **Main Weakness** | May not be as accurate as a well-tuned boosting model if bias is the main issue. | More sensitive to noise and outliers; can overfit if not carefully tuned. |
| **Key R Packages** | randomForest, ipred, caret | gbm, xgboost, adabag, caret |

## **14.2 Emulating the Brain: An Introduction to Neural Networks with Keras**

Artificial Neural Networks (ANNs), often simply called neural networks, are a class of machine learning models inspired by the structure and function of the human brain.12 They are composed of interconnected nodes, or "neurons," organized in layers. By learning from data, these networks can identify intricate patterns and model highly complex, non-linear relationships, forming the foundation of modern deep learning.

### **14.2.1 From Biology to Algorithms: The Modern Neural Network**

At its core, a neural network is a computational model that processes information through a series of transformations. Its fundamental components are designed to work in concert to learn from data.14

* **The Neuron (Node):** This is the basic building block. A neuron receives one or more inputs, each multiplied by a **weight** that signifies its importance. The weighted inputs are summed together, and a **bias** term is added. This result is then passed through an **activation function**, which determines the neuron's final output.14 The weights and biases are the parameters that the network learns during the training process.  
* **Layers:** Neurons are organized into layers. A typical feedforward network has three types of layers 12:  
  1. **Input Layer:** This layer receives the raw data. Each neuron in the input layer corresponds to a single feature (or predictor variable) in the dataset.  
  2. **Hidden Layers:** These are the layers between the input and output layers where the majority of computation occurs. A network can have one or many hidden layers. Networks with multiple hidden layers are referred to as "deep" neural networks.  
  3. **Output Layer:** This is the final layer that produces the model's prediction. The structure of the output layer depends on the task (e.g., a single neuron for regression, or multiple neurons for multi-class classification).  
* **Activation Functions:** These functions are critical for introducing non-linearity into the network.17 Without them, a multi-layered network would be mathematically equivalent to a simple linear model, regardless of its depth. Common activation functions include:  
  * **ReLU (Rectified Linear Unit):** Outputs the input directly if it is positive, and zero otherwise. It is the most common choice for hidden layers due to its computational efficiency.19  
  * **Sigmoid:** Squeezes the output into a range between 0 and 1, making it suitable for the output layer in binary classification problems, where the output can be interpreted as a probability.17  
  * **Softmax:** Used in the output layer for multi-class classification. It transforms the outputs for each class into a probability distribution, where the probabilities sum to 1\.17

The power of deep learning arises from the hierarchical nature of these layers. The first hidden layer might learn to recognize simple, low-level features from the raw data. Each subsequent layer then combines the features from the previous layer to learn progressively more complex and abstract representations. For example, in image recognition, initial layers might detect edges, which are then combined by later layers to form shapes, then object parts, and finally, complete objects.21 This automatic, hierarchical feature extraction is what enables deep neural networks to achieve remarkable performance on complex tasks.

### **14.2.2 Setting Up Your Deep Learning Environment in R**

To build neural networks in R, we will use the keras package, which provides a high-level, user-friendly interface to the powerful **TensorFlow** backend developed by Google.22 A unique aspect of using these tools in R is that they are interfaces to the underlying Python libraries. Therefore, the setup involves installing both the R packages and their Python dependencies.

The keras R package simplifies this process significantly.

1. **Install the R Packages:** First, install the keras and tensorflow packages from CRAN.  
   R  
   install.packages("keras")  
   install.packages("tensorflow")

2. **Install Python Dependencies:** After installing the R packages, load the keras library and use the install\_keras() function. This function will automatically handle the installation of TensorFlow and other required Python libraries into an isolated Python environment called r-tensorflow.24 Using an isolated environment is highly recommended as it prevents conflicts with any other Python installations you may have on your system.25  
   R  
   library(keras)  
   install\_keras()

   This command may take several minutes to complete as it downloads and installs the necessary components.  
3. **Verify the Installation:** Once the installation is finished, you can verify that everything is working correctly by running a simple TensorFlow command in your R console.  
   R  
   library(tensorflow)  
   tf$constant("Hello TensorFlow\!")

   If the setup was successful, this will return a TensorFlow tensor object, confirming that R can communicate with the Python backend.

### **14.2.3 Building and Training a Neural Network in R**

Let's walk through the complete workflow of building, compiling, and training a neural network for a multi-class classification task using the iris dataset.

**1\. Data Preparation**

Neural networks require input data to be numeric and, for best performance, scaled. The target variable for classification should be one-hot encoded.

R

\# Load libraries  
library(keras)  
library(dplyr)  
library(tensorflow)

\# Prepare the data  
data \<- iris  
\# Features (predictors) must be a matrix  
x\_train \<- as.matrix(data\[, 1:4\])

\# Target variable must be numeric and one-hot encoded  
\# Convert factor to numeric (0, 1, 2\)  
y\_train\_labels \<- as.numeric(data$Species) \- 1  
\# One-hot encode the labels  
y\_train \<- to\_categorical(y\_train\_labels, num\_classes \= 3)

\# Scale the features (important for neural networks)  
x\_train \<- scale(x\_train)

**2\. Model Definition**

We will build a simple sequential model, which is a linear stack of layers.

R

\# Define the model architecture  
model \<- keras\_model\_sequential() %\>%  
  \# First hidden layer: 8 neurons, ReLU activation  
  \# input\_shape is required for the first layer  
  layer\_dense(units \= 8, activation \= 'relu', input\_shape \= c(4)) %\>%  
  \# Second hidden layer  
  layer\_dense(units \= 8, activation \= 'relu') %\>%  
  \# Output layer: 3 neurons (one for each class), softmax activation  
  layer\_dense(units \= 3, activation \= 'softmax')

\# Print a summary of the model  
summary(model)

The summary() provides a clear overview of the model's architecture, including the layers, their output shapes, and the number of trainable parameters (weights and biases) in each layer.

**3\. Model Compilation**

Before training, the model must be compiled. This step configures the learning process by specifying an optimizer, a loss function, and evaluation metrics.26

R

\# Compile the model  
model %\>% compile(  
  loss \= 'categorical\_crossentropy', \# For multi-class classification  
  optimizer \= optimizer\_adam(),      \# A popular and effective optimizer  
  metrics \= c('accuracy')            \# Metric to monitor during training  
)

* **Optimizer:** The algorithm used to update the network's weights based on the calculated error (e.g., optimizer\_adam()).  
* **Loss Function:** The function that the model will try to minimize during training (e.g., 'categorical\_crossentropy' is standard for multi-class classification).  
* **Metrics:** Used to monitor the training and testing steps (e.g., 'accuracy').

**4\. Model Training**

Now we train the model using the fit() function.

R

\# Train the model  
history \<- model %\>% fit(  
  x \= x\_train,  
  y \= y\_train,  
  epochs \= 50,          \# Number of passes through the entire dataset  
  batch\_size \= 5,       \# Number of samples per gradient update  
  validation\_split \= 0.2, \# Fraction of data to use for validation  
  verbose \= 1           \# Set to 0 for silent training  
)

\# Plot the training history  
plot(history)

The fit() function returns a history object that contains a record of the loss and metrics for both the training and validation sets at each epoch. Plotting this object is an essential diagnostic step to check for signs of overfitting (where training accuracy improves but validation accuracy stagnates or worsens).

**5\. Evaluation and Prediction**

Finally, you can evaluate the model's performance on new data and use it to make predictions.

R

\# In a real scenario, you would have a separate test set.  
\# Here we just demonstrate the functions.

\# Evaluate the model (returns loss and accuracy)  
model %\>% evaluate(x\_train, y\_train)

\# Make predictions (returns class probabilities)  
predictions\_prob \<- model %\>% predict(x\_train)

\# Get the predicted class label (the one with the highest probability)  
predictions\_class \<- model %\>% predict\_classes(x\_train)

| Component | R Function/Argument | Description | Common Use Case |
| :---- | :---- | :---- | :---- |
| **Layers** |  |  |  |
| Dense Layer | layer\_dense() | A standard, fully-connected neural network layer. | Core building block for most network architectures. |
| Dropout Layer | layer\_dropout() | Randomly sets a fraction of input units to 0 during training to prevent overfitting. | Regularization technique, often used between dense layers. |
| Flatten Layer | layer\_flatten() | Flattens a multi-dimensional input (e.g., an image) into a one-dimensional vector. | Used to transition from convolutional layers to dense layers in image models. |
| **Activation Functions** |  |  |  |
| ReLU | activation \= 'relu' | Rectified Linear Unit. Outputs max(0, x). | Default choice for hidden layers. Computationally efficient. |
| Sigmoid | activation \= 'sigmoid' | Outputs a value between 0 and 1\. | Output layer for binary classification (probability of the positive class). |
| Softmax | activation \= 'softmax' | Converts a vector of values into a probability distribution. | Output layer for multi-class classification. |
| Tanh | activation \= 'tanh' | Hyperbolic Tangent. Outputs a value between \-1 and 1\. | Can be used in hidden layers, especially in recurrent neural networks. |

## **14.3 Predicting the Future: Time Series Forecasting**

Time series forecasting is a specialized area of machine learning focused on predicting future values based on previously observed data points collected in chronological order. This section explores two distinct yet powerful approaches: the classical statistical method of ARIMA and the modern, flexible framework of Facebook's Prophet.

### **14.3.1 The Classic Approach: ARIMA Models**

The **AutoRegressive Integrated Moving Average (ARIMA)** model is a cornerstone of time series forecasting, providing a robust framework for modeling temporal structures in data.27 An ARIMA model is described by the notation

ARIMA(p, d, q), where each component addresses a different aspect of the time series structure.29

* **AR(p): Autoregressive Component:** This component models the relationship between an observation and a number (p) of its own lagged (i.e., previous) observations. It assumes that past values have a linear effect on the current value.  
* **I(d): Integrated Component:** This component relates to the differencing required to make the time series **stationary**. Stationarity is a critical assumption for ARIMA models, meaning that the statistical properties of the series—such as its mean, variance, and autocorrelation—are constant over time.31 Differencing, which involves subtracting the previous value from the current value, is a common technique to remove trends and stabilize the mean.30 The parameter  
  d represents the number of times the data needs to be differenced to achieve stationarity.  
* **MA(q): Moving Average Component:** This component models the relationship between an observation and the residual errors from a moving average model applied to q lagged observations. It helps the model account for random shocks or unexpected fluctuations from previous time points.

**Model Identification with ACF and PACF**

Before the advent of automated tools, identifying the appropriate p and q parameters for a stationary time series involved a manual inspection of the **Autocorrelation Function (ACF)** and **Partial Autocorrelation Function (PACF)** plots.34

* **ACF Plot:** Shows the correlation of the time series with its own lags.  
* **PACF Plot:** Shows the partial correlation of the time series with its own lags, after removing the effects of the intervening lags.

The patterns in these plots can suggest the order of the AR and MA components 35:

* **AR(p) Signature:** An AR process is typically characterized by an ACF plot that tails off gradually and a PACF plot that cuts off sharply after lag p.  
* **MA(q) Signature:** An MA process is characterized by a PACF plot that tails off and an ACF plot that cuts off sharply after lag q.

**Implementation in R with forecast**

The forecast package in R provides a comprehensive suite of tools for time series analysis, including a function that automates the challenging process of model selection.

Let's use the built-in AirPassengers dataset to demonstrate the workflow.

R

\# Install and load necessary packages  
\# install.packages("forecast")  
\# install.packages("tseries")  
library(forecast)  
library(tseries)

\# Load and plot the data  
data(AirPassengers)  
ts\_data \<- AirPassengers  
plot(ts\_data, main \= "Monthly Airline Passengers 1949-1960")

The plot clearly shows a trend and seasonality, indicating the series is non-stationary. We can confirm this with a statistical test like the Augmented Dickey-Fuller (ADF) test. The null hypothesis for the ADF test is that the series is non-stationary.35

R

\# Test for stationarity  
adf.test(ts\_data)  
\# A high p-value suggests we cannot reject the null hypothesis; the series is non-stationary.

While we could manually difference the data and analyze ACF/PACF plots, the auto.arima() function provides a much more efficient approach. It systematically searches through different combinations of p, d, and q (and their seasonal counterparts) and selects the model with the lowest Akaike Information Criterion (AICc), a measure of model fit that penalizes complexity.37

R

\# Fit an ARIMA model automatically  
fit\_arima \<- auto.arima(ts\_data)

\# Print the model summary  
summary(fit\_arima)

The summary() output reveals the chosen ARIMA model order and the estimated coefficients. A crucial next step is to check the model's residuals. If the model has captured the underlying structure of the data, the residuals should resemble white noise—that is, they should be uncorrelated with a mean of zero.37

R

\# Check residuals  
checkresiduals(fit\_arima)

The checkresiduals() function produces a time plot of the residuals, their ACF plot, and the results of a Ljung-Box test. A high p-value for the Ljung-Box test suggests that the residuals are independently distributed, indicating a good model fit.

Finally, we can use the fitted model to forecast future values.

R

\# Generate forecasts for the next 24 months  
forecast\_arima \<- forecast(fit\_arima, h \= 24)

\# Plot the forecast  
plot(forecast\_arima)

### **14.3.2 A Modern Approach: Facebook's Prophet**

**Prophet** is an open-source forecasting procedure developed by Facebook's Core Data Science team.39 It was specifically designed to handle the common features of business time series, such as multiple strong seasonalities, holiday effects, missing data, and trend changes, with intuitive and easily tunable parameters.40

Prophet is based on a **decomposable additive model** with three main components 42:

y(t)=g(t)+s(t)+h(t)+ϵ(t)

* **g(t) (Trend):** Prophet models the overall trend using either a piecewise linear or a logistic growth model. It automatically detects "changepoints" where the trend rate changes, providing significant flexibility.  
* **s(t) (Seasonality):** Periodic changes, such as yearly, weekly, and daily seasonality, are modeled using Fourier series. This allows Prophet to flexibly fit seasonal patterns of varying shapes.  
* **h(t) (Holidays):** The model can incorporate the impact of irregular events like holidays, which can be specified by the user.  
* **ϵ(t) (Error):** The error term represents any idiosyncratic changes not accommodated by the model.

One of Prophet's key advantages is its accessibility. It does not require the data to be stationary and automates many of the difficult aspects of forecasting, making it a powerful tool for both experts and non-experts.44

**Implementation in R with prophet**

Using Prophet in R is remarkably straightforward. The primary data requirement is a data frame with two specific columns: ds for the datestamp and y for the numeric value we want to forecast.45

Let's re-forecast the AirPassengers data using Prophet.

R

\# Install and load the prophet package  
\# install.packages("prophet")  
library(prophet)  
library(dplyr)

\# Prepare data for Prophet  
\# The data frame must have 'ds' and 'y' columns  
df \<- data.frame(  
  ds \= seq(as.Date('1949-01-01'), as.Date('1960-12-01'), by \= 'month'),  
  y \= as.vector(AirPassengers)  
)

\# The original data shows multiplicative seasonality (the seasonal swings grow with the trend).  
\# We can model this by first log-transforming the data.  
df$y \<- log(df$y)

\# Fit the Prophet model  
m \<- prophet(df)

\# Create a future dataframe for predictions  
future \<- make\_future\_dataframe(m, periods \= 24, freq \= 'month')

\# Generate the forecast  
forecast\_prophet \<- predict(m, future)

\# Plot the forecast  
plot(m, forecast\_prophet)

The resulting plot shows the historical data points, the forecast (yhat), and the uncertainty interval.

A powerful feature of Prophet is its ability to decompose the forecast and visualize the individual components.

R

\# Plot the forecast components  
prophet\_plot\_components(m, forecast\_prophet)

This command generates plots for the trend, yearly seasonality, and weekly seasonality (if applicable), providing clear insights into the patterns learned by the model.

To incorporate holidays, one simply creates a data frame with holiday and ds columns and passes it to the holidays argument in the prophet() function.47 This makes modeling the impact of special events straightforward.

| Feature | ARIMA | Prophet |
| :---- | :---- | :---- |
| **Underlying Philosophy** | Statistical model based on autocorrelation in a stationary series. | Decomposable time series model (trend \+ seasonality \+ holidays). |
| **Data Requirements** | Requires a stationary (or differenced to be stationary) univariate time series. | Requires a data frame with ds (date) and y (value) columns. Handles non-stationarity automatically. |
| **Handling of Seasonality** | Handles seasonality through seasonal differencing and seasonal AR/MA terms (SARIMA). | Models multiple seasonalities (e.g., weekly, yearly) explicitly using Fourier series. |
| **Handling of Holidays** | Requires manual creation of dummy variables as external regressors. | Built-in functionality to incorporate custom holiday and event lists. |
| **Interpretability** | Coefficients can be statistically interpreted, but the overall model can be abstract. | Highly interpretable through component plots (trend, seasonality, holidays). |
| **Automation** | auto.arima() provides excellent automation for model selection. | Designed for high automation and ease of use with intuitive parameters. |
| **Best Suited For** | Univariate time series with clear autocorrelation structure, stable data, and where statistical rigor is paramount. | Business forecasting with multiple strong seasonalities, holiday effects, missing data, and where ease of use and interpretability are key.44 |

## **14.4 Hands-On Project: Forecasting Retail Store Sales**

This project serves as a capstone for the chapter, applying the advanced techniques we have learned—ensemble methods and time series forecasting—to a complex, real-world challenge. By tackling the same problem with different models, we can directly compare their strengths, weaknesses, and practical utility.

### **14.4.1 The Challenge and the Dataset**

**Problem Statement:** The goal is to accurately forecast the daily sales for thousands of items sold at a large Ecuadorian grocery retailer, Corporación Favorita. Accurate sales forecasting is critical for businesses to manage inventory, reduce waste, and ensure customer satisfaction.49

**Dataset:** We will use the "Store Sales \- Time Series Forecasting" dataset from Kaggle.49 This rich dataset is ideal for our purposes as it includes multiple time series, promotional information, and holiday effects. The main files are:

* train.csv: Contains the core training data, including date, store number, item family (category), sales, and promotion information.  
* holidays\_events.csv: Provides details on local, regional, and national holidays and events.  
* stores.csv: Contains metadata about the stores, such as city, state, and type.

For this project, we will focus on forecasting the total sales for a single store (Store \#1) to demonstrate the complete workflow.

### **14.4.2 Data Exploration and Feature Engineering**

First, we load and merge the relevant datasets into a single, analysis-ready data frame.

R

\# Load necessary libraries  
library(dplyr)  
library(lubridate)  
library(ggplot2)  
library(xgboost)  
library(prophet)  
library(forecast)

\# Load data  
train \<- read.csv("train.csv")  
holidays \<- read.csv("holidays\_events.csv")  
stores \<- read.csv("stores.csv")

\# Convert date columns to Date type  
train$date \<- as.Date(train$date)  
holidays$date \<- as.Date(holidays$date)

\# Filter for a single store (e.g., Store \#1) and aggregate sales across all families  
store1\_sales \<- train %\>%  
  filter(store\_nbr \== 1) %\>%  
  group\_by(date) %\>%  
  summarise(sales \= sum(sales))

\# Visualize the time series for Store \#1  
ggplot(store1\_sales, aes(x \= date, y \= sales)) \+  
  geom\_line() \+  
  labs(title \= "Daily Sales for Store \#1", x \= "Date", y \= "Total Sales") \+  
  theme\_minimal()

The plot reveals strong weekly seasonality (spikes and dips within each month) and a slight upward trend over time. There are also noticeable dips, likely corresponding to holidays.

For our tree-based model (XGBoost), we will engineer several time-based features from the date.

R

\# Feature Engineering  
store1\_sales \<- store1\_sales %\>%  
  mutate(  
    day\_of\_week \= wday(date, label \= TRUE),  
    month \= month(date, label \= TRUE),  
    year \= year(date),  
    day\_of\_year \= yday(date),  
    week\_of\_year \= week(date)  
  )

### **14.4.3 Modeling and Comparison**

We will now build and compare three different models to forecast sales. We will use data up to July 31, 2017, for training and reserve the final 16 days of the dataset for testing.

R

\# Split into training and test sets  
train\_set \<- store1\_sales %\>% filter(date \<= as.Date("2017-07-31"))  
test\_set \<- store1\_sales %\>% filter(date \> as.Date("2017-07-31"))

**Model 1: XGBoost**

We treat this as a standard regression problem, using our engineered features to predict sales.

R

\# Prepare data for XGBoost  
train\_features \<- as.matrix(select(train\_set, \-date, \-sales))  
train\_labels \<- train\_set$sales  
test\_features \<- as.matrix(select(test\_set, \-date, \-sales))

dtrain \<- xgb.DMatrix(data \= train\_features, label \= train\_labels)

\# Train XGBoost model  
xgb\_fit \<- xgboost(data \= dtrain, nrounds \= 100, objective \= "reg:squarederror", verbose \= 0)  
pred\_xgb \<- predict(xgb\_fit, test\_features)

**Model 2: ARIMA**

We use auto.arima on the univariate sales time series.

R

\# Create time series object for training  
sales\_ts \<- ts(train\_set$sales, frequency \= 7) \# Weekly seasonality

\# Fit auto.arima model  
arima\_fit \<- auto.arima(sales\_ts)  
forecast\_arima\_obj \<- forecast(arima\_fit, h \= nrow(test\_set))  
pred\_arima \<- as.vector(forecast\_arima\_obj$mean)

**Model 3: Prophet**

We leverage Prophet's ability to handle seasonality and holidays directly.

R

\# Prepare data for Prophet  
prophet\_train \<- train\_set %\>%  
  select(date, sales) %\>%  
  rename(ds \= date, y \= sales)

\# Prepare holidays data frame  
prophet\_holidays \<- holidays %\>%  
  filter(type\!= "Work Day") %\>% \# Exclude work days  
  select(date, holiday) %\>%  
  rename(ds \= date)

\# Fit Prophet model  
prophet\_fit \<- prophet(prophet\_train, holidays \= prophet\_holidays)  
future \<- make\_future\_dataframe(prophet\_fit, periods \= nrow(test\_set))  
forecast\_prophet\_obj \<- predict(prophet\_fit, future)

\# Extract predictions for the test period  
pred\_prophet \<- tail(forecast\_prophet\_obj$yhat, nrow(test\_set))

### **14.4.4 Evaluation and Final Insights**

We now evaluate all three models on the hold-out test set using Root Mean Squared Error (RMSE).

R

\# Calculate RMSE for each model  
rmse\_xgb \<- sqrt(mean((pred\_xgb \- test\_set$sales)^2))  
rmse\_arima \<- sqrt(mean((pred\_arima \- test\_set$sales)^2))  
rmse\_prophet \<- sqrt(mean((pred\_prophet \- test\_set$sales)^2))

\# Print results  
cat("XGBoost RMSE:", rmse\_xgb, "\\n")  
cat("ARIMA RMSE:", rmse\_arima, "\\n")  
cat("Prophet RMSE:", rmse\_prophet, "\\n")

| Model | Root Mean Squared Error (RMSE) | Implementation Complexity | Key Strengths in this Project |
| :---- | :---- | :---- | :---- |
| **XGBoost** | (Actual value depends on run) | Medium | Can incorporate many external features (e.g., promotions, weather); powerful for complex, non-linear relationships. |
| **ARIMA** | (Actual value depends on run) | Low (with auto.arima) | Provides a strong statistical baseline; excels at capturing autocorrelation. |
| **Prophet** | (Actual value depends on run) | Low | Easily handles multiple seasonalities and complex holiday effects with minimal feature engineering. Highly interpretable. |

The results demonstrate that there is no single "best" model for all forecasting problems. XGBoost, with its ability to incorporate external regressors, is a powerful choice when rich feature sets are available. ARIMA provides a robust statistical baseline, particularly for series with clear autocorrelation structures. Prophet shines in its ease of use and its specialized design for business time series with complex seasonal and holiday patterns, often providing excellent results with minimal effort. The choice of model should be guided by the specific characteristics of the data and the goals of the analysis.

## **14.5 Chapter Summary and Further Learning**

This chapter has navigated the transition from classical statistical modeling to advanced machine learning, equipping you with the theory and practical R skills to tackle complex predictive tasks.

We began with **Ensemble Methods**, revealing how combining multiple models can lead to superior performance. We contrasted the parallel, variance-reducing approach of **Bagging**, exemplified by Random Forests, with the sequential, bias-reducing strategy of **Boosting**, showcased by the powerful Gradient Boosting Machine and its state-of-the-art implementation, XGBoost.

Next, we journeyed into the world of **Neural Networks**, demystifying their architecture of neurons and layers. Using the keras and tensorflow packages, we constructed a complete workflow in R: from data preparation and model definition to compilation, training, and evaluation. We saw how these models, inspired by the brain, can learn hierarchical representations of data to model intricate patterns.

Finally, we addressed the specialized domain of **Time Series Forecasting**. We explored the rigorous statistical framework of **ARIMA**, understanding its components (AR, I, MA) and the importance of stationarity. We then contrasted this with **Prophet**, a modern, flexible tool designed to automatically handle the trend, seasonality, and holiday effects common in business time series.

The culminating hands-on project demonstrated that model selection is not a one-size-fits-all process. By applying these diverse techniques to a single, realistic forecasting problem, we underscored the importance of aligning the choice of algorithm with the specific structure of the data and the analytical goals at hand.

The techniques covered in this chapter represent the cutting edge of applied machine learning. To continue your journey and deepen your understanding, the following resources are highly recommended:

* **Books:**  
  * *An Introduction to Statistical Learning* by James, Witten, Hastie, and Tibshirani: An accessible yet rigorous introduction to many machine learning concepts, including tree-based methods and support vector machines.5  
  * *Applied Predictive Modeling* by Max Kuhn and Kjell Johnson: A practical, practitioner-focused guide to the entire modeling process, written by the creator of the caret package.5  
  * *Deep Learning with R* by François Chollet with J.J. Allaire: The definitive guide to using Keras in R, written by the creator of Keras.  
* **Package Vignettes:** The documentation and vignettes for the randomForest, xgboost, keras, forecast, and prophet packages are invaluable resources for exploring advanced features and arguments.

#### **Works cited**

1. Ensemble methods and boosting | Advanced R Programming Class Notes \- Fiveable, accessed on July 30, 2025, [https://library.fiveable.me/introduction-to-advanced-programming-in-r/unit-8/ensemble-methods-boosting/study-guide/CwLoBFZ9yJq71fZv](https://library.fiveable.me/introduction-to-advanced-programming-in-r/unit-8/ensemble-methods-boosting/study-guide/CwLoBFZ9yJq71fZv)  
2. Bagging vs Boosting in Machine Learning \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/bagging-vs-boosting-in-machine-learning/](https://www.geeksforgeeks.org/machine-learning/bagging-vs-boosting-in-machine-learning/)  
3. Perform Bagging in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/perform-bagging-in-r/](https://www.geeksforgeeks.org/machine-learning/perform-bagging-in-r/)  
4. Bagging, Boosting and Stacking: Ensemble Learning in ML Models \- Analytics Vidhya, accessed on July 30, 2025, [https://www.analyticsvidhya.com/blog/2023/01/ensemble-learning-methods-bagging-boosting-and-stacking/](https://www.analyticsvidhya.com/blog/2023/01/ensemble-learning-methods-bagging-boosting-and-stacking/)  
5. Bagging \- UB, accessed on July 30, 2025, [https://www.ub.edu/cursosR/files/bagging.html](https://www.ub.edu/cursosR/files/bagging.html)  
6. How to Perform Bagging in R \- Statology, accessed on July 30, 2025, [https://www.statology.org/how-to-perform-bagging-r/](https://www.statology.org/how-to-perform-bagging-r/)  
7. Random Forest in R \- Tutorialspoint, accessed on July 30, 2025, [https://www.tutorialspoint.com/r/r\_random\_forest.htm](https://www.tutorialspoint.com/r/r_random_forest.htm)  
8. How to Perform Bagging in R (Step-by-Step) \- Statology, accessed on July 30, 2025, [https://www.statology.org/bagging-in-r/](https://www.statology.org/bagging-in-r/)  
9. Chapter 12 Gradient Boosting | Hands-On Machine Learning with R \- · Bradley Boehmke, accessed on July 30, 2025, [https://bradleyboehmke.github.io/HOML/gbm.html](https://bradleyboehmke.github.io/HOML/gbm.html)  
10. Gradient Boosting in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/deep-learning/gradient-boosting-in-r/](https://www.geeksforgeeks.org/deep-learning/gradient-boosting-in-r/)  
11. Beginners Tutorial on XGBoost and Parameter Tuning in R Tutorials ..., accessed on July 30, 2025, [https://www.hackerearth.com/practice/machine-learning/machine-learning-algorithms/beginners-tutorial-on-xgboost-parameter-tuning-r/tutorial/](https://www.hackerearth.com/practice/machine-learning/machine-learning-algorithms/beginners-tutorial-on-xgboost-parameter-tuning-r/tutorial/)  
12. What is a Neural Network? \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/neural-networks-a-beginners-guide/](https://www.geeksforgeeks.org/machine-learning/neural-networks-a-beginners-guide/)  
13. What Are Neural Networks? A Beginner's Complete Guide, accessed on July 30, 2025, [https://www.pricefx.com/learning-center/what-are-neural-networks-a-beginners-complete-guide](https://www.pricefx.com/learning-center/what-are-neural-networks-a-beginners-complete-guide)  
14. Concepts — ML Glossary documentation \- Read the Docs, accessed on July 30, 2025, [https://ml-cheatsheet.readthedocs.io/en/latest/nn\_concepts.html](https://ml-cheatsheet.readthedocs.io/en/latest/nn_concepts.html)  
15. Machine Learning for Beginners: An Introduction to Neural Networks \- victorzhou.com, accessed on July 30, 2025, [https://victorzhou.com/blog/intro-to-neural-networks/](https://victorzhou.com/blog/intro-to-neural-networks/)  
16. Day 39: Basics of Neural Networks — Layers, Neurons, and Activation Functions, accessed on July 30, 2025, [https://ianclemence.medium.com/day-39-basics-of-neural-networks-layers-neurons-and-activation-functions-fa623acf9a9f](https://ianclemence.medium.com/day-39-basics-of-neural-networks-layers-neurons-and-activation-functions-fa623acf9a9f)  
17. Activation functions in Neural Networks \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/activation-functions-neural-networks/](https://www.geeksforgeeks.org/machine-learning/activation-functions-neural-networks/)  
18. Activation Functions in Neural Networks \[12 Types & Use Cases\], accessed on July 30, 2025, [https://www.v7labs.com/blog/neural-networks-activation-functions](https://www.v7labs.com/blog/neural-networks-activation-functions)  
19. Introduction to Activation Functions in Neural Networks \- DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/introduction-to-activation-functions-in-neural-networks](https://www.datacamp.com/tutorial/introduction-to-activation-functions-in-neural-networks)  
20. Neural networks: Activation functions | Machine Learning \- Google for Developers, accessed on July 30, 2025, [https://developers.google.com/machine-learning/crash-course/neural-networks/activation-functions](https://developers.google.com/machine-learning/crash-course/neural-networks/activation-functions)  
21. A Beginner's Guide to Neural Networks \- APIDNA, accessed on July 30, 2025, [https://apidna.ai/a-beginners-guide-to-neural-networks/](https://apidna.ai/a-beginners-guide-to-neural-networks/)  
22. Build a Neural Network Classifier in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/build-a-neural-network-classifier-in-r/](https://www.geeksforgeeks.org/machine-learning/build-a-neural-network-classifier-in-r/)  
23. CRAN: Package keras \- The Comprehensive R Archive Network, accessed on July 30, 2025, [https://cran.r-project.org/package=keras](https://cran.r-project.org/package=keras)  
24. Getting Started with Keras \- The Comprehensive R Archive Network, accessed on July 30, 2025, [https://cran.r-project.org/web/packages/keras/vignettes/](https://cran.r-project.org/web/packages/keras/vignettes/)  
25. Quick start \- TensorFlow for R, accessed on July 30, 2025, [https://tensorflow.rstudio.com/install/](https://tensorflow.rstudio.com/install/)  
26. Quick Start Guide to Neural Networks in R with Keras and Tensorflow, accessed on July 30, 2025, [https://dustysturner.com/post/2024-01-13-quick-start-guide-to-neural-networks-in-r-with-keras-and-tensorflow/](https://dustysturner.com/post/2024-01-13-quick-start-guide-to-neural-networks-in-r-with-keras-and-tensorflow/)  
27. Time Series Analysis using ARIMA model in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/time-series-analysis-using-arima-model-in-r-programming/](https://www.geeksforgeeks.org/r-language/time-series-analysis-using-arima-model-in-r-programming/)  
28. ARIMA for Beginners: A Practical Introduction \- Number Analytics, accessed on July 30, 2025, [https://www.numberanalytics.com/blog/arima-for-beginners](https://www.numberanalytics.com/blog/arima-for-beginners)  
29. Introduction to ARIMA Model. ARIMA (Auto-Regressive Integrated… | by Ritu Santra, accessed on July 30, 2025, [https://medium.com/@ritusantra/introduction-to-arima-model-c8925103f4c7](https://medium.com/@ritusantra/introduction-to-arima-model-c8925103f4c7)  
30. Autoregressive Integrated Moving Average (ARIMA) Prediction Model \- Investopedia, accessed on July 30, 2025, [https://www.investopedia.com/terms/a/autoregressive-integrated-moving-average-arima.asp](https://www.investopedia.com/terms/a/autoregressive-integrated-moving-average-arima.asp)  
31. Stationarity of Time Series Data using R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-machine-learning/stationarity-of-time-series-data-using-r/](https://www.geeksforgeeks.org/r-machine-learning/stationarity-of-time-series-data-using-r/)  
32. 1 Time Series Basics – STAT 510 | Applied Time Series Analysis \- STAT ONLINE, accessed on July 30, 2025, [https://online.stat.psu.edu/stat510/Lesson01.html](https://online.stat.psu.edu/stat510/Lesson01.html)  
33. ARIMA for Time Series Forecasting: A Complete Guide | DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/arima](https://www.datacamp.com/tutorial/arima)  
34. Identifying the orders of AR and MA terms in an ARIMA model, accessed on July 30, 2025, [https://people.duke.edu/\~rnau/411arim3.htm](https://people.duke.edu/~rnau/411arim3.htm)  
35. Time Series: Interpreting ACF and PACF \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/code/iamleonie/time-series-interpreting-acf-and-pacf](https://www.kaggle.com/code/iamleonie/time-series-interpreting-acf-and-pacf)  
36. Performing Time Series Analysis using ARIMA Model in R \- Analytics Vidhya, accessed on July 30, 2025, [https://www.analyticsvidhya.com/blog/2021/11/performing-time-series-analysis-using-arima-model-in-r/](https://www.analyticsvidhya.com/blog/2021/11/performing-time-series-analysis-using-arima-model-in-r/)  
37. 8.7 ARIMA modelling in R | Forecasting: Principles and Practice ..., accessed on July 30, 2025, [https://otexts.com/fpp2/arima-r.html](https://otexts.com/fpp2/arima-r.html)  
38. How Auto ARIMA Works in R, accessed on July 30, 2025, [https://mrinalcs.github.io/how-auto-arima-works](https://mrinalcs.github.io/how-auto-arima-works)  
39. Prophet | Forecasting at scale. \- Meta Open Source, accessed on July 30, 2025, [https://facebook.github.io/prophet/](https://facebook.github.io/prophet/)  
40. Time series forecasting using Facebook Prophet \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/code/nilaychauhan/time-series-forecasting-using-facebook-prophet](https://www.kaggle.com/code/nilaychauhan/time-series-forecasting-using-facebook-prophet)  
41. Generate Quick and Accurate Time Series Forecasts using Facebook's Prophet (with Python & R codes) \- Analytics Vidhya, accessed on July 30, 2025, [https://www.analyticsvidhya.com/blog/2018/05/generate-accurate-forecasts-facebook-prophet-python-r/](https://www.analyticsvidhya.com/blog/2018/05/generate-accurate-forecasts-facebook-prophet-python-r/)  
42. Time Series Analysis using Facebook Prophet in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/time-series-analysis-using-facebook-prophet-in-r-programming/](https://www.geeksforgeeks.org/r-language/time-series-analysis-using-facebook-prophet-in-r-programming/)  
43. ARIMA vs Prophet vs LSTM \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/deep-learning/arima-vs-prophet-vs-lstm/](https://www.geeksforgeeks.org/deep-learning/arima-vs-prophet-vs-lstm/)  
44. (PDF) A Comparative Study of ARIMA, Prophet and LSTM for Time ..., accessed on July 30, 2025, [https://www.researchgate.net/publication/387701628\_A\_Comparative\_Study\_of\_ARIMA\_Prophet\_and\_LSTM\_for\_Time\_Series\_Prediction](https://www.researchgate.net/publication/387701628_A_Comparative_Study_of_ARIMA_Prophet_and_LSTM_for_Time_Series_Prediction)  
45. Quick Start | Prophet \- Meta Open Source, accessed on July 30, 2025, [https://facebook.github.io/prophet/docs/quick\_start.html](https://facebook.github.io/prophet/docs/quick_start.html)  
46. Forecasting in R with Prophet | Reports \- Mode \- Mode Analytics, accessed on July 30, 2025, [https://mode.com/example-gallery/forecasting\_prophet\_r\_cookbook/](https://mode.com/example-gallery/forecasting_prophet_r_cookbook/)  
47. Seasonality, Holiday Effects, And Regressors | Prophet, accessed on July 30, 2025, [https://facebook.github.io/prophet/docs/seasonality,\_holiday\_effects,\_and\_regressors.html](https://facebook.github.io/prophet/docs/seasonality,_holiday_effects,_and_regressors.html)  
48. Facebook Prophet: Seasonality, Holiday Effects, And Regressors \- Nextjournal, accessed on July 30, 2025, [https://nextjournal.com/fb-prophet/facebook-prophet-seasonality-holiday-effects](https://nextjournal.com/fb-prophet/facebook-prophet-seasonality-holiday-effects)  
49. Store Sales \- Time Series Forecasting | Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/competitions/store-sales-time-series-forecasting](https://www.kaggle.com/competitions/store-sales-time-series-forecasting)  
50. Predictive modeling and machine learning in R with the caret ..., accessed on July 30, 2025, [http://zevross.com/blog/2017/09/19/predictive-modeling-and-machine-learning-in-r-with-the-caret-package/](http://zevross.com/blog/2017/09/19/predictive-modeling-and-machine-learning-in-r-with-the-caret-package/)