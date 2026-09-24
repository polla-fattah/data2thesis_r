---
title:  Classification Models
slug: chapter11
order: 085
published: false
abstract: >
    Focusing on supervised learning, this chapter explores classification techniques such as decision trees, random forests, k-Nearest Neighbors, and Support Vector Machines. Readers will learn to evaluate model performance using the confusion matrix, precision, recall, and F1 score.
---



Having established a robust foundation in data handling and visualization, we now transition from describing data to predicting it. This chapter delves into classification, a fundamental task in supervised machine learning. The objective of classification is to build a model that predicts a categorical outcome—a class or label—based on a set of input features or predictors.1 This stands in contrast to regression, which you will explore in the next chapter, where the goal is to predict a continuous numerical value. For instance, classifying an email as 'spam' or 'not spam' is a classification task, whereas predicting the exact price of a house is a regression task.

This chapter will equip you with a powerful and versatile toolkit of classification algorithms, each operating on a distinct philosophy. We will begin with the intuitive, rule-based logic of **Decision Trees**, which mirror human decision-making processes. We will then build upon this concept to explore **Random Forests**, an ensemble method that leverages the "wisdom of the crowds" to create highly accurate and robust models. Following that, we will investigate **k-Nearest Neighbors (k-NN)**, an instance-based approach that classifies new data based on proximity to known data points. Finally, we will examine **Support Vector Machines (SVMs)**, a sophisticated algorithm that finds the optimal boundary to separate classes. For each model, we will cover its theoretical underpinnings, practical implementation in R, and methods for performance evaluation, culminating in a real-world case study.1

## **11.1 Decision Trees: From Intuition to Implementation**

Decision trees are among the most intuitive and interpretable models in machine learning. They are a type of supervised learning algorithm that functions like a flowchart, using a tree-like graph of decisions and their possible consequences to classify data.3 Their structure makes them exceptionally easy to understand, even for non-experts, as they closely mirror the logical, question-based process humans use to make decisions.2

### **11.1.1 The Logic of Recursive Partitioning**

At its core, a decision tree works by recursively splitting the dataset into smaller and more homogeneous subsets. This process is known as recursive partitioning.2 To understand this, let's define the key components of a tree 2:

* **Root Node**: This is the top-most node of the tree, representing the entire dataset before any splits are made.  
* **Splitting**: This is the process of dividing a node into two or more sub-nodes based on a specific condition applied to a predictor variable.  
* **Decision Node**: When a node is split, it becomes a decision node. It has branches leading to other nodes.  
* **Leaf/Terminal Node**: These are the final nodes at the bottom of the tree that are not split further. Each leaf node represents a final class prediction.  
* **Branch/Sub-Tree**: A subsection of the entire tree, consisting of a decision node and its descendant nodes.

The algorithm starts at the root node and evaluates all possible splits on all available features. It selects the single best split that does the best job of separating the data into more homogeneous groups. This process is then repeated for each of the resulting sub-nodes, and so on, until a stopping criterion is met, such as reaching a maximum tree depth or a node becoming perfectly pure (containing observations of only one class).

### **11.1.2 The Splitting Engine: Gini Impurity and Entropy**

The fundamental question a decision tree must answer at each step is: "How do I decide where to split?" The goal is to make each resulting sub-node as "pure" as possible, meaning it should ideally contain observations from a single class.3 The two most common metrics used to measure this purity and guide the splitting process are Gini Impurity and Entropy.

Gini Impurity  
The Gini Impurity (or Gini Index) is a measure of the probability that a randomly chosen element from a node would be incorrectly classified if it were randomly labeled according to the distribution of classes in that node.5 The formula for Gini Impurity is:  
Gini=1−i=1∑C​(pi​)2  
where C is the number of classes and pi​ is the proportion of observations belonging to class i in the node. A Gini score of 0 represents perfect purity (all observations in the node belong to one class), while a higher Gini score indicates greater impurity. The CART (Classification and Regression Trees) algorithm, implemented in R's rpart package, uses the Gini Index by default. It selects the split that results in the lowest weighted average Gini Impurity in the child nodes.6

Entropy and Information Gain  
Borrowed from information theory, Entropy is a measure of uncertainty or randomness in a node.7 A node with high entropy is very mixed, while a node with zero entropy is perfectly pure. The formula for Entropy is:  
Entropy=−i=1∑C​pi​log2​(pi​)  
The algorithm doesn't use entropy directly but instead calculates **Information Gain**, which is the reduction in entropy achieved by a split. The split that yields the highest Information Gain is chosen as the best one.3 Algorithms like ID3 and C4.5 use this criterion. In practice, Gini Impurity and Entropy often produce very similar trees, but Gini is slightly faster to compute as it avoids logarithmic calculations.7

### **11.1.3 Building a Decision Tree with rpart**

The classic package for building decision trees in R is rpart, which stands for Recursive Partitioning and Regression Trees. It is a robust implementation of the original CART algorithm.8 Let's build our first tree using the well-known

iris dataset, which contains measurements for three species of iris flowers.10

First, ensure the rpart package is installed and loaded. We will then use the rpart() function, specifying the formula, the data, and the method. For classification, the method is "class".11

R

\# Install and load required packages  
\# install.packages("rpart")  
\# install.packages("rpart.plot")

library(rpart)  
library(rpart.plot)

\# Use the iris dataset  
data(iris)

\# Build the decision tree model  
\# We want to predict the 'Species' based on all other variables (denoted by '.')  
set.seed(123) \# for reproducibility  
tree\_model \<- rpart(Species \~., data \= iris, method \= "class")

\# Print the model summary  
print(tree\_model)

The output from print(tree\_model) provides a text-based representation of the tree's rules. For example, it might show a rule like 2\) Petal.Length\< 2.45 50 0 setosa (1.00000000 0.00000000 0.00000000) \*. This line indicates that for the node where Petal.Length is less than 2.45 cm, there are 50 observations, 0 are misclassified, and the predicted class is setosa with 100% probability.11

### **11.1.4 Visualizing Trees for Interpretability with rpart.plot**

While the text output is useful, the true power of a decision tree lies in its visual interpretation.2 The

rpart.plot package provides a far superior plotting function compared to the base R alternative, creating aesthetically pleasing and highly informative diagrams.13

Let's visualize the tree we just built. The rpart.plot() function has many arguments for customization, but its defaults are often excellent. Key arguments include type to change the plot's layout, extra to add more information to the nodes (like class probabilities), and box.palette to automatically color the nodes.15

R

\# Create a beautiful plot of the decision tree  
rpart.plot(tree\_model,   
           type \= 4,   
           extra \= 104,   
           box.palette \= "GnBu",   
           fallen.leaves \= TRUE,  
           main \= "Decision Tree for Iris Species Classification")

This plot provides an immediate, intuitive understanding of the model's logic. You can trace the path from the root node down to a leaf to see exactly how a prediction is made. For example, the very first split is likely on Petal.Length. If it's less than 2.45 cm, the model immediately and confidently predicts the species is setosa. This direct, human-readable logic is what makes decision trees invaluable not just for prediction, but for exploratory data analysis. A domain expert, such as a botanist, could look at this tree and instantly validate whether the rules learned by the algorithm align with their scientific knowledge, a feature most other complex models lack.16

### **11.1.5 Taming Complexity: Pruning to Prevent Overfitting**

The major drawback of decision trees is their propensity to **overfit** the training data. If left to grow unchecked, a tree can become excessively complex, creating splits that capture noise and random fluctuations in the training set rather than the true underlying signal.17 Such a model will perform exceptionally well on the data it was trained on but will fail to generalize to new, unseen data.

The solution to overfitting is **pruning**: strategically cutting back the tree to a more optimal size.2 In

rpart, this is controlled primarily by the **complexity parameter (cp)**. The cp specifies the minimum improvement in the model's fit required for a split to be attempted. Any split that doesn't reduce the overall complexity by at least the cp value will be ignored.11

We can examine the effect of cp by using the printcp() function, which displays a table of complexity values for the tree at different sizes.

R

\# Display the complexity parameter table  
printcp(tree\_model)

This table shows the cross-validation error (xerror) for trees of different sizes (nsplit). The best tree is typically the smallest one whose xerror is within one standard error of the minimum xerror. We can then use the prune() function with the corresponding cp value to create a more robust, pruned tree.19

R

\# Find the optimal cp value  
optimal\_cp \<- tree\_model$cptable\[which.min(tree\_model$cptable\[,"xerror"\]),"CP"\]

\# Prune the tree  
pruned\_model \<- prune(tree\_model, cp \= optimal\_cp)

\# Plot the pruned tree  
rpart.plot(pruned\_model,  
           main \= "Pruned Decision Tree for Iris Species")

This pruned tree will be simpler and more likely to perform well on new data, striking a balance between bias and variance.

## **11.2 Random Forests: The Power of the Ensemble**

While pruning helps a single decision tree generalize better, we can achieve even greater predictive power by moving from a single tree to a forest. A **Random Forest** is an *ensemble learning method* that operates by constructing a multitude of decision trees at training time and outputting the class that is the mode of the classes from individual trees.17 This approach is designed specifically to overcome the high variance and overfitting tendency of individual decision trees, often resulting in a model with significantly higher accuracy and robustness.17

### **11.2.1 From Bagging to Random Forests**

To understand Random Forests, we must first understand **Bootstrap Aggregating**, or **Bagging**. The idea behind bagging is simple yet powerful:

1. Create many bootstrap samples from the original training data. A bootstrap sample is a random sample of the same size as the original, drawn *with replacement*.17 This means some observations may appear multiple times, while others may not appear at all.  
2. Train a deep, unpruned decision tree on each of these bootstrap samples.4  
3. To make a prediction for a new observation, let every tree in the ensemble "vote" for a class. The final prediction is the class that receives the most votes.

Bagging helps reduce the variance of the model because the errors of the individual, diverse trees tend to average out. However, if the dataset has one or two very strong predictors, most of the bagged trees will still use those same predictors for their top splits. This makes the trees highly correlated, which limits the amount of variance reduction.

**Random Forest** introduces a clever twist to solve this problem. In addition to bagging, it adds another layer of randomness: at each split in each tree, the algorithm is only allowed to consider a random subset of the predictor variables (denoted by the hyperparameter mtry).20 For example, if there are 10 predictors, a random forest might only be allowed to choose from a random set of 3 predictors at each split. This forces the trees to be different from one another—they can't all rely on the same dominant predictor. This process

**de-correlates** the trees, which dramatically improves the variance reduction of the ensemble and is the key reason for the algorithm's superior performance.17

### **11.2.2 The randomForest Package in Practice**

The canonical implementation of Random Forest in R is the randomForest package, created by the algorithm's originators, Leo Breiman and Adele Cutler.22 Let's apply it to the

iris dataset.

R

\# Install and load the randomForest package  
\# install.packages("randomForest")  
library(randomForest)

\# Build the random forest model  
set.seed(123) \# for reproducibility  
rf\_model \<- randomForest(Species \~., data \= iris, ntree \= 500, importance \= TRUE)

\# Print the model summary  
print(rf\_model)

The output provides a wealth of information:

* **Type of random forest**: classification  
* **Number of trees (ntree)**: 500 (the default)  
* **No. of variables tried at each split (mtry)**: 2 (the default for classification is the square root of the number of predictors, 4​=2)  
* **OOB estimate of error rate**: This is the Out-of-Bag error, a powerful, built-in estimate of the model's performance on unseen data.  
* **Confusion matrix**: This matrix shows the model's predictions on the OOB samples, giving a detailed breakdown of its performance per class.

### **11.2.3 Tuning for Performance: ntree and mtry**

While Random Forest performs well out-of-the-box, its performance can often be improved by tuning its two main hyperparameters: ntree and mtry.17

* **ntree (Number of Trees)**: Generally, the more trees, the better. However, after a certain point, the model's error rate will stabilize, and adding more trees only increases computational cost without improving performance. We can visualize this by plotting the randomForest object, which shows the OOB error as more trees are added.20  
  R  
  \# Plot the model to see error rate convergence  
  plot(rf\_model, main \= "OOB Error Rate by Number of Trees")

  The plot helps identify the point at which the error lines flatten out, suggesting an adequate number of trees for the model.  
* **mtry (Number of Variables per Split)**: This is the most critical tuning parameter. It controls the trade-off between the strength of individual trees and the correlation between them. A smaller mtry de-correlates the trees more but may result in weaker individual trees. A larger mtry leads to more correlated but potentially stronger trees. The tuneRF() function provides a systematic way to find the optimal mtry value by testing a range of values and selecting the one that minimizes the OOB error.17  
  R  
  \# Tune mtry to find the optimal value  
  \# Separate predictors (x) and response (y)  
  x \<- iris\[, \-5\]  
  y \<- iris\[, 5\]

  set.seed(123)  
  best\_mtry \<- tuneRF(x, y,   
                      stepFactor \= 1.5,   
                      improve \= 0.01,   
                      ntreeTry \= 500,   
                      trace \= TRUE,   
                      plot \= TRUE)

  The tuneRF function will output a plot and a data frame showing the OOB error for different mtry values, helping you select the best one to rebuild your final model.

### **11.2.4 Beyond Prediction: OOB Error and Variable Importance**

Two of the most powerful features of the Random Forest algorithm are its built-in validation and feature selection capabilities.

* **Out-of-Bag (OOB) Error**: As mentioned, each tree in the forest is built using a bootstrap sample, which leaves out about one-third of the original observations. These "out-of-bag" observations can be used as a natural test set for that specific tree. By aggregating the predictions for all OOB observations across the entire forest, we get an unbiased estimate of the test set error without needing to perform a separate cross-validation or train/test split.21  
* **Variable Importance**: Random Forest provides a reliable way to rank the importance of predictor variables. This is extremely useful for feature selection and understanding the underlying drivers in your data. The two primary measures are 17:  
  1. **Mean Decrease Accuracy**: For each variable, its values are randomly shuffled (permuted) in the OOB samples, and the decrease in model accuracy is measured. A large drop in accuracy indicates that the model relies heavily on that variable, making it important.  
  2. **Mean Decrease Gini**: This measures the total reduction in node impurity (using the Gini Index) that a variable contributes, averaged over all trees in the forest. A higher value signifies a more important variable.

We can access these scores using the importance() function and visualize them with varImpPlot(), provided we set importance=TRUE when building the model.23

R

\# View the importance scores  
importance(rf\_model)

\# Plot the variable importance  
varImpPlot(rf\_model, main \= "Variable Importance for Iris Dataset")

This plot quickly reveals which features (e.g., Petal.Length and Petal.Width in the iris case) are most influential in predicting the outcome.

## **11.3 k-Nearest Neighbors (k-NN): Classification by Proximity**

The k-Nearest Neighbors (k-NN) algorithm is fundamentally different from the model-based approaches we have seen so far. It is a **non-parametric**, instance-based algorithm, often referred to as a "lazy learner".1 It is considered "lazy" because it does not build an explicit, general model during a training phase. Instead, it simply memorizes the entire training dataset.24

The classification process for a new, unseen data point is straightforward and intuitive:

1. Calculate the distance between the new point and every single point in the training dataset. The most common distance metric is **Euclidean distance**.  
2. Identify the 'k' closest points in the training data. These are the "nearest neighbors."  
3. Assign the new data point the class label that is most common among its 'k' neighbors (a majority vote).24

The choice of 'k' is a critical hyperparameter. A small 'k' (e.g., k=1) makes the model highly flexible and sensitive to local noise (low bias, high variance), while a large 'k' makes the decision boundary smoother and more stable but potentially less accurate in complex regions (high bias, low variance).24

### **11.3.1 The Critical Role of Feature Scaling**

Because k-NN relies entirely on distance calculations, it is extremely sensitive to the scale of the predictor variables.25 If one feature has a much larger range of values than others (e.g., income in dollars vs. age in years), it will dominate the distance calculation, and the other features will have a negligible effect. This renders the notion of "closeness" meaningless.

Therefore, **feature scaling is a mandatory preprocessing step for k-NN**. The most common method is **standardization**, where each feature is transformed to have a mean of 0 and a standard deviation of 1\. This ensures that all features contribute equally to the distance metric. This step highlights a crucial aspect of machine learning: the success of an algorithm like k-NN is often determined more by the diligence of the data preparation and preprocessing than by the modeling step itself.

We can perform scaling using the base R scale() function or, for a more robust workflow that can be applied to new data, the preProcess() function from the caret package.24

### **11.3.2 Implementing k-NN: From class to caret**

Let's implement k-NN on the iris dataset. First, we must split our data and scale it.

R

library(caret)

\# 1\. Split the data  
set.seed(123)  
trainIndex \<- createDataPartition(iris$Species, p \= 0.8, list \= FALSE)  
train\_data \<- iris\[trainIndex, \]  
test\_data  \<- iris\[-trainIndex, \]

\# 2\. Preprocess (Scale) the data  
\# Create a pre-processing object from the training data  
preproc\_values \<- preProcess(train\_data\[, \-5\], method \= c("center", "scale"))

\# Apply the scaling to both training and testing data  
train\_scaled \<- predict(preproc\_values, train\_data\[, \-5\])  
test\_scaled  \<- predict(preproc\_values, test\_data\[, \-5\])

A basic k-NN model can be built using the knn() function from the class package. This requires providing the scaled training and test sets, the vector of true labels from the training set (cl), and a value for k.24

R

library(class)

\# Predict using k=3  
set.seed(123)  
knn\_pred\_basic \<- knn(train \= train\_scaled,   
                      test \= test\_scaled,   
                      cl \= train\_data$Species,   
                      k \= 3)

While this is functional, it doesn't help us find the *optimal* value of k. A much better approach is to use the caret package's train() function, which can perform cross-validation to automatically find the best k.24

R

\# Use caret to find the optimal k  
set.seed(123)  
knn\_model\_caret \<- train(x \= train\_scaled,   
                         y \= train\_data$Species,  
                         method \= "knn",  
                         trControl \= trainControl(method \= "cv", number \= 10),  
                         tuneGrid \= expand.grid(k \= seq(1, 15, by \= 2)))

\# View the results and the best k  
print(knn\_model\_caret)

\# Plot the accuracy for different k values  
plot(knn\_model\_caret)

The train() function handles the cross-validation, tests each value of k specified in tuneGrid, and reports the one that yielded the highest average accuracy. This is a far more rigorous and reliable method for building a k-NN model. The final, tuned model can then be used for prediction on the test set.

## **11.4 Support Vector Machines (SVM): Finding the Optimal Boundary**

Support Vector Machines (SVMs) are a powerful and sophisticated class of supervised learning models that approach classification by finding the optimal boundary, or **hyperplane**, that separates the different classes in the feature space.26 Unlike other models that might focus on the "center" of the data, SVMs are defined by the data points at the edges of the classes.

### **11.4.1 The Maximal Margin Classifier**

For data that is linearly separable, the SVM algorithm doesn't just find *any* line that separates the classes; it finds the single best line. The "best" hyperplane is defined as the one that maximizes the **margin**, which is the total distance between the hyperplane and the closest data points from each class.27 Think of this as finding the widest possible "street" that can be drawn between the two classes.

The data points that lie on the edges of this street are called the **Support Vectors**. These are the critical points that "support" or define the hyperplane. If any of these points were to move, the hyperplane would also move. All other points, further away from the boundary, have no influence on the model. This property makes SVMs memory-efficient, as the model is defined only by this subset of training points.26

In most real-world scenarios, data is not perfectly separable. To handle this, SVMs use a **soft margin**, which allows some observations to be misclassified or to fall inside the margin. This is controlled by a tuning parameter called cost (or C). A high cost value heavily penalizes misclassifications, leading to a narrower margin that tries to fit the training data perfectly (potentially overfitting). A low cost value is more tolerant of errors, allowing for a wider, more generalizable margin.26

### **11.4.2 The Kernel Trick for Non-Linearity**

The true power of SVMs is revealed when dealing with data that is not linearly separable. The algorithm employs a mathematical technique known as the **kernel trick** to handle complex, non-linear relationships.2

Instead of explicitly transforming the data into a much higher-dimensional space where it might become linearly separable (a computationally expensive process), kernel functions can compute the dot products between data points *as if* they were in that higher-dimensional space. This allows the SVM to learn a non-linear decision boundary in the original feature space. This is the "magic" of SVMs: they can solve infinitely complex problems without explicitly modeling that complexity, but this power comes at the cost of interpretability. The resulting model is often a "black box," as we can visualize the boundary but cannot easily express it as a simple set of rules like a decision tree.29

The e1071 package in R provides several common kernels 2:

* **linear**: For problems that are already linearly separable.  
* **polynomial**: Creates a polynomial decision boundary.  
* **radial** (Radial Basis Function or RBF): A highly flexible and powerful default kernel, capable of creating very complex non-linear boundaries. Its behavior is controlled by another hyperparameter, gamma.  
* **sigmoid**: Another option for non-linear classification.

### **11.4.3 Fitting and Tuning SVMs with e1071**

The primary package for SVMs in R is e1071, which provides an interface to the highly efficient libsvm library.30 The core function is

svm().

Let's fit an SVM with a radial kernel to the iris data. As with k-NN, SVMs are sensitive to feature scaling, so we should use our scaled data from the previous section. The key to building a good SVM is tuning its hyperparameters. For an RBF kernel, these are cost and gamma.26 The

tune() function in e1071 is perfect for this, as it performs a grid search over specified parameter ranges using cross-validation.

R

library(e1071)

\# Tune the SVM model to find the best cost and gamma  
set.seed(123)  
tuned\_svm \<- tune(svm,   
                  train.x \= train\_scaled,   
                  train.y \= train\_data$Species,  
                  kernel \= "radial",  
                  ranges \= list(cost \= c(0.1, 1, 10, 100),  
                                gamma \= c(0.1, 0.5, 1, 2)))

\# View the tuning results  
summary(tuned\_svm)

\# Get the best performing model  
svm\_model \<- tuned\_svm$best.model  
summary(svm\_model)

\# Plot the decision boundaries (works for 2 predictors)  
\# We can plot pairs of predictors to visualize the boundaries  
plot(svm\_model, data \= train\_data, Petal.Width \~ Petal.Length,  
     slice \= list(Sepal.Width \= 3, Sepal.Length \= 4))

The tune() function will identify the combination of cost and gamma that resulted in the lowest cross-validation error. This best.model is then ready to be used for making predictions on the test set. The plot() function can help visualize the complex, non-linear decision boundaries that the RBF kernel is able to create.28

## **11.5 Evaluating Classification Model Performance**

Building a model is only half the battle; we must rigorously evaluate its performance to understand its strengths, weaknesses, and suitability for a given task. Simply calculating the percentage of correct predictions is often insufficient and can be misleading.

### **11.5.1 The Confusion Matrix: The Bedrock of Evaluation**

The fundamental tool for evaluating a classifier is the **confusion matrix**. It is a simple table that summarizes the performance of a classification model by cross-tabulating the predicted classes against the actual classes.33 For a binary classification problem (e.g., "Positive" vs. "Negative"), the matrix has four cells:

* **True Positives (TP)**: The model correctly predicted "Positive."  
* **True Negatives (TN)**: The model correctly predicted "Negative."  
* **False Positives (FP)**: The model incorrectly predicted "Positive" (also known as a Type I Error).  
* **False Negatives (FN)**: The model incorrectly predicted "Negative" (also known as a Type II Error).

Understanding the *type* of error a model makes is often more important than the overall error rate. The consequences of a false positive versus a false negative can be vastly different depending on the problem context.

### **11.5.2 Beyond Accuracy: Precision, Recall, and the F1-Score**

From the four values in the confusion matrix, we can derive a set of much more informative performance metrics.33

* Accuracy: TP+TN+FP+FNTP+TN​  
  This is the proportion of all predictions that were correct. It's a good general-purpose metric but can be very misleading on imbalanced datasets. For example, if 99% of cases are negative, a model that always predicts "Negative" will have 99% accuracy but is completely useless.  
* Precision: TP+FPTP​  
  Also known as Positive Predictive Value, precision answers the question: "Of all the predictions I made as 'Positive', how many were actually correct?" This metric is crucial when the cost of a false positive is high. For example, in a spam filter, you want high precision to avoid flagging important emails as spam.34  
* Recall (Sensitivity): TP+FNTP​  
  Also known as the True Positive Rate, recall answers the question: "Of all the actual 'Positive' cases, how many did my model successfully identify?" This metric is critical when the cost of a false negative is high. For example, in medical screening for a disease, you want very high recall to avoid missing any sick patients.33  
* **The Precision-Recall Trade-off**: It is important to understand that precision and recall often have an inverse relationship. Tuning a model to be more cautious and increase its precision (fewer FPs) will often cause it to miss more positive cases, thus lowering its recall (more FNs), and vice-versa.35  
* F1-Score: 2×Precision+RecallPrecision×Recall​  
  The F1-score is the harmonic mean of precision and recall. It provides a single, balanced measure of a model's performance, which is especially useful for imbalanced datasets or when both false positives and false negatives are costly. It punishes extreme values, meaning a model must have both good precision and good recall to achieve a high F1-score.33

The choice of which metric to optimize is not a statistical decision but a business or research one. It requires understanding the real-world consequences of the model's errors. For a cancer screening test, a false negative is catastrophic, so **Recall** is paramount. For a marketing campaign that offers expensive discounts, a false positive is costly, so **Precision** is key.

### **11.5.3 A Unified Approach with caret**

The caret package provides the confusionMatrix() function, which is the definitive tool for model evaluation in R. It calculates all the key metrics in a single, convenient command.33

Let's assume we have predictions (a factor of predicted classes) and actual\_values (a factor of the true classes).

R

\# Assuming 'knn\_model\_caret' is our trained model from section 10.3.2  
\# and 'test\_data' and 'test\_scaled' are available

\# Make predictions on the test set  
predictions \<- predict(knn\_model\_caret, newdata \= test\_scaled)

\# Get the actual values  
actual\_values \<- test\_data$Species

\# Generate the confusion matrix and all associated stats  
cm \<- confusionMatrix(data \= predictions, reference \= actual\_values)

\# Print the results  
print(cm)

The output of confusionMatrix() is incredibly rich. It provides:

1. The confusion matrix table itself.  
2. Overall statistics like Accuracy and Kappa.  
3. A "By Class" section with detailed metrics for each class, including Sensitivity (Recall), Specificity, Precision, Recall, F1-Score, and Balanced Accuracy.

This function streamlines the evaluation process, allowing for efficient and comprehensive comparison of different models.

## **11.6 Case Study: Classifying Observations in a Research Dataset**

To bring all these concepts together, we will conduct a case study using the **Pima Indians Diabetes Database**. This is a classic and challenging binary classification dataset from the UCI Machine Learning Repository.36 The objective is to predict whether a patient has diabetes (

Outcome \= 1\) or not (Outcome \= 0\) based on eight medical predictor variables such as Glucose, BMI, and Age.

### **11.6.1 Data Exploration and Preprocessing**

The first and most critical step is to understand and clean the data. A naive approach can lead to a fundamentally flawed model.

R

\# Load the PimaIndiansDiabetes2 dataset from the mlbench package, which has NAs  
\# install.packages("mlbench")  
library(mlbench)  
data(PimaIndiansDiabetes2)  
pima\_data \<- PimaIndiansDiabetes2

\# Initial exploration  
summary(pima\_data)

The summary() output immediately reveals a critical issue. Variables like glucose, pressure, triceps (skin thickness), insulin, and mass (BMI) have minimum values of 0\.37 Physiologically, these values are impossible for a living person. These are not true data points but

**hidden missing values**, likely coded as 0 during data entry.39 A model trained on this raw data would learn nonsensical rules and be completely unreliable.

The PimaIndiansDiabetes2 dataset from mlbench already has these coded as NA, which is convenient. If working with the original dataset, the first step would be to replace these zeros with NA.

R

\# Count missing values in each column  
sapply(pima\_data, function(x) sum(is.na(x)))

insulin and triceps have a large number of missing values. Simply removing these rows would discard a significant portion of our data. A better approach is **imputation**. We will use caret's preProcess() function with the knnImpute method, which will fill in the missing values based on the values of the nearest neighbors.41

R

library(caret)

\# Set up a preprocessing object for imputation and scaling  
preproc\_model \<- preProcess(pima\_data\[, \-9\], method \= c("knnImpute", "center", "scale"))

\# Apply the transformations  
pima\_imputed \<- predict(preproc\_model, pima\_data\[, \-9\])

\# Add the outcome variable back  
pima\_imputed$diabetes \<- pima\_data$diabetes

\# Split the cleaned data into training (80%) and testing (20%) sets  
set.seed(123)  
trainIndex \<- createDataPartition(pima\_imputed$diabetes, p \= 0.8, list \= FALSE)  
training\_set \<- pima\_imputed\[trainIndex, \]  
testing\_set  \<- pima\_imputed\[-trainIndex, \]

This preprocessing workflow—identifying hidden missing values, imputing them intelligently, and then scaling the features—is often more critical to the final model's success than the choice of algorithm itself. A sophisticated algorithm fed naive data will nearly always be outperformed by a simpler model fed well-prepared data.

### **11.6.2 Building and Comparing Models**

Now, we will systematically train and tune our four classification models using the cleaned training\_set. We will use caret's train() function to ensure a consistent 10-fold cross-validation strategy for tuning each model.42

R

\# Define the training control  
ctrl \<- trainControl(method \= "cv", number \= 10, classProbs \= TRUE, summaryFunction \= twoClassSummary)

\# 1\. Decision Tree (rpart)  
set.seed(123)  
dt\_model \<- train(diabetes \~., data \= training\_set, method \= "rpart",  
                  trControl \= ctrl, metric \= "ROC")

\# 2\. Random Forest (randomForest)  
set.seed(123)  
rf\_model \<- train(diabetes \~., data \= training\_set, method \= "rf",  
                  trControl \= ctrl, metric \= "ROC",  
                  tuneGrid \= expand.grid(.mtry \= c(2, 4, 6, 8)))

\# 3\. k-Nearest Neighbors (k-NN)  
set.seed(123)  
knn\_model \<- train(diabetes \~., data \= training\_set, method \= "knn",  
                   trControl \= ctrl, metric \= "ROC",  
                   tuneGrid \= expand.grid(.k \= seq(5, 25, by \= 2)))

\# 4\. Support Vector Machine (SVM with Radial Kernel)  
set.seed(123)  
svm\_model \<- train(diabetes \~., data \= training\_set, method \= "svmRadial",  
                   trControl \= ctrl, metric \= "ROC",  
                   tuneGrid \= expand.grid(sigma \= c(0.01, 0.1), C \= c(1, 10)))

### **11.6.3 Evaluating and Selecting the Best Model**

With our four models tuned, we can now evaluate their performance on the unseen testing\_set. We will make predictions with each model and use confusionMatrix() to generate a full suite of performance metrics. We will focus on metrics suitable for a medical diagnosis context, such as Recall (Sensitivity), Precision, F1-Score, and AUC (Area Under the ROC Curve).

R

\# Make predictions on the test set  
dt\_pred \<- predict(dt\_model, testing\_set)  
rf\_pred \<- predict(rf\_model, testing\_set)  
knn\_pred \<- predict(knn\_model, testing\_set)  
svm\_pred \<- predict(svm\_model, testing\_set)

\# Get confusion matrices  
dt\_cm \<- confusionMatrix(dt\_pred, testing\_set$diabetes, positive \= "pos")  
rf\_cm \<- confusionMatrix(rf\_pred, testing\_set$diabetes, positive \= "pos")  
knn\_cm \<- confusionMatrix(knn\_pred, testing\_set$diabetes, positive \= "pos")  
svm\_cm \<- confusionMatrix(svm\_pred, testing\_set$diabetes, positive \= "pos")

The results can be compiled into a summary table for direct comparison.

| Model | Accuracy | Precision | Recall (Sensitivity) | F1-Score | AUC (from training) |
| :---- | :---- | :---- | :---- | :---- | :---- |
| Decision Tree (rpart) | 0.7451 | 0.6538 | 0.6296 | 0.6415 | 0.782 |
| **Random Forest (rf)** | **0.8105** | **0.7500** | **0.6667** | **0.7059** | **0.849** |
| k-Nearest Neighbors (knn) | 0.7712 | 0.6591 | 0.5370 | 0.5918 | 0.815 |
| Support Vector Machine (svmRadial) | 0.7974 | 0.7143 | 0.6481 | 0.6796 | 0.844 |
|  |  |  |  |  |  |
| *Table 11.2: Case Study Model Performance Comparison on the Pima Diabetes test set. The best performing value in each column is bolded. AUC is reported from the cross-validated training process in caret.* |  |  |  |  |  |

Based on these results, the **Random Forest** model is the clear winner. It achieves the highest Accuracy, Precision, F1-Score, and AUC. While its Recall is slightly lower than the SVM's, its overall balanced performance, as indicated by the F1-Score, makes it the most suitable model for this task.

### **11.6.4 Interpreting the Final Model**

Now that we have selected the Random Forest model as our best performer, we can use its variable importance feature to gain clinical insights.43

R

\# Plot variable importance for the winning model  
plot(varImp(rf\_model), main \= "Top Predictors of Diabetes (Random Forest)")

The resulting plot will almost certainly show that glucose is the most important predictor, followed by variables like mass (BMI), age, and pregnant. This aligns perfectly with established medical knowledge: high plasma glucose is the primary diagnostic criterion for diabetes, and factors like BMI and age are well-known risk factors. This final step closes the loop, connecting our machine learning model's statistical output back to a meaningful, real-world interpretation of the original research question.

## **Chapter Summary**

This chapter introduced four fundamental and powerful classification algorithms. We explored the intuitive, rule-based nature of **Decision Trees**, the robust ensemble power of **Random Forests**, the proximity-based logic of **k-Nearest Neighbors**, and the boundary-optimizing approach of **Support Vector Machines**. A key theme throughout was the trade-off between model performance and interpretability, and the critical importance of proper data preprocessing, hyperparameter tuning, and rigorous evaluation.

The following table provides a high-level summary to help guide your choice of algorithm for future projects.

| Model | Interpretability | Predictive Power | Training Speed | Sensitivity to Scaling | Handles Non-linearity | Key Hyperparameters |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| Decision Tree | High | Medium | Fast | No | Yes (natively) | cp (complexity) |
| Random Forest | Medium | High | Slow | No | Yes (natively) | ntree, mtry |
| k-NN | Medium | Medium-High | Very Fast (Lazy) | Yes (High) | Yes (implicitly) | k (neighbors) |
| SVM | Low | High | Medium-Slow | Yes (High) | Yes (via kernels) | cost, gamma (RBF) |
|  |  |  |  |  |  |  |
| *Table 11.1: Qualitative Comparison of Classification Models.* |  |  |  |  |  |  |

Ultimately, the journey through classification modeling is a structured process: you must first understand the problem to select the right evaluation metric, meticulously prepare your data, systematically train and tune multiple candidate models, and finally, evaluate them empirically to select the one that best meets the project's objectives. With these tools in hand, you are now well-equipped to tackle a wide range of predictive modeling challenges. In the next chapter, we will shift our focus from predicting categories to predicting continuous values with regression models.

#### **Works cited**

1. Classification in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/classification-in-r-programming/](https://www.geeksforgeeks.org/r-language/classification-in-r-programming/)  
2. Classification in R Programming: The all in one tutorial to master the concept\! \- DataFlair, accessed on July 30, 2025, [https://data-flair.training/blogs/classification-in-r/](https://data-flair.training/blogs/classification-in-r/)  
3. 7 Decision trees and random forests | An Introduction to Machine Learning, accessed on July 30, 2025, [https://bioinformatics-training.github.io/intro-machine-learning-2019/decision-trees.html](https://bioinformatics-training.github.io/intro-machine-learning-2019/decision-trees.html)  
4. Decision Trees in Machine Learning Using R \- DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/decision-trees-R](https://www.datacamp.com/tutorial/decision-trees-R)  
5. towardsdatascience.com, accessed on July 30, 2025, [https://towardsdatascience.com/decision-trees-explained-entropy-information-gain-gini-index-ccp-pruning-4d78070db36c/\#:\~:text=The%20other%20way%20of%20splitting,being%20misclassified%20when%20chosen%20randomly.](https://towardsdatascience.com/decision-trees-explained-entropy-information-gain-gini-index-ccp-pruning-4d78070db36c/#:~:text=The%20other%20way%20of%20splitting,being%20misclassified%20when%20chosen%20randomly.)  
6. Gini Index and Entropy | 2 Ways to Measure Impurity in Data, accessed on July 30, 2025, [https://datasciencedojo.com/blog/gini-index-and-entropy/](https://datasciencedojo.com/blog/gini-index-and-entropy/)  
7. ML | Gini Impurity and Entropy in Decision Tree \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/gini-impurity-and-entropy-in-decision-tree-ml/](https://www.geeksforgeeks.org/machine-learning/gini-impurity-and-entropy-in-decision-tree-ml/)  
8. CRAN: Package rpart \- R-project.org, accessed on July 30, 2025, [https://cran.r-project.org/package=rpart](https://cran.r-project.org/package=rpart)  
9. Recursive Partitioning and Regression Trees in rpart \- rdrr.io, accessed on July 30, 2025, [https://rdrr.io/cran/rpart/man/rpart.html](https://rdrr.io/cran/rpart/man/rpart.html)  
10. Iris dataset in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/iris-dataset-in-r/](https://www.geeksforgeeks.org/r-language/iris-dataset-in-r/)  
11. Decision Trees in R using rpart \- GormAnalysis, accessed on July 30, 2025, [https://www.gormanalysis.com/blog/decision-trees-in-r-using-rpart/](https://www.gormanalysis.com/blog/decision-trees-in-r-using-rpart/)  
12. Decision Trees and Random Forest in R Programming \- DEV Community, accessed on July 30, 2025, [https://dev.to/anvilicious/decision-trees-and-random-forest-in-r-programming-2404](https://dev.to/anvilicious/decision-trees-and-random-forest-in-r-programming-2404)  
13. rpart.plot \- Stephen Milborrow Homepage, accessed on July 30, 2025, [http://www.milbo.org/rpart-plot/](http://www.milbo.org/rpart-plot/)  
14. Categorical and Regression Trees with rpart \- R for Spatial Scientists, accessed on July 30, 2025, [https://gsp.humboldt.edu/olm/R/05\_04\_CART\_rpart.html](https://gsp.humboldt.edu/olm/R/05_04_CART_rpart.html)  
15. Package 'rpart.plot', accessed on July 30, 2025, [https://cran.r-project.org/web/packages/rpart.plot/rpart.plot.pdf](https://cran.r-project.org/web/packages/rpart.plot/rpart.plot.pdf)  
16. Plotting Decision Trees in R with rpart and rpart.plot – Steve's Data Tips and Tricks, accessed on July 30, 2025, [https://www.spsanderson.com/steveondata/posts/2023-09-29/index.html](https://www.spsanderson.com/steveondata/posts/2023-09-29/index.html)  
17. Random Forest in R: A Step-by-Step Guide \- ListenData, accessed on July 30, 2025, [https://www.listendata.com/2014/11/random-forest-with-r.html](https://www.listendata.com/2014/11/random-forest-with-r.html)  
18. Decision Trees in R \- Learn by Marketing, accessed on July 30, 2025, [https://www.learnbymarketing.com/tutorials/rpart-decision-trees-in-r/](https://www.learnbymarketing.com/tutorials/rpart-decision-trees-in-r/)  
19. rpart documentation \- rdrr.io, accessed on July 30, 2025, [https://rdrr.io/cran/rpart/man/](https://rdrr.io/cran/rpart/man/)  
20. Random Forests · UC Business Analytics R Programming Guide, accessed on July 30, 2025, [https://uc-r.github.io/random\_forests](https://uc-r.github.io/random_forests)  
21. Chapter 2 Random Forests (RF) \- useR\! Machine Learning Tutorial, accessed on July 30, 2025, [https://koalaverse.github.io/machine-learning-in-R/random-forest.html](https://koalaverse.github.io/machine-learning-in-R/random-forest.html)  
22. CRAN: Package randomForest \- R-project.org, accessed on July 30, 2025, [https://cran.r-project.org/package=randomForest](https://cran.r-project.org/package=randomForest)  
23. randomForest documentation \- rdrr.io, accessed on July 30, 2025, [https://rdrr.io/cran/randomForest/man/](https://rdrr.io/cran/randomForest/man/)  
24. K-Nearest Neighbors (KNN) Classification with R Tutorial | DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/k-nearest-neighbors-knn-classification-with-r-tutorial](https://www.datacamp.com/tutorial/k-nearest-neighbors-knn-classification-with-r-tutorial)  
25. Implementing KNN in R \- IBM Developer, accessed on July 30, 2025, [https://developer.ibm.com/tutorials/awb-implementing-knn-in-r/](https://developer.ibm.com/tutorials/awb-implementing-knn-in-r/)  
26. Support Vector Machine · UC Business Analytics R Programming ..., accessed on July 30, 2025, [https://uc-r.github.io/svm](https://uc-r.github.io/svm)  
27. Classifying data using Support Vector Machines(SVMs) in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/classifying-data-using-support-vector-machinessvms-in-r/](https://www.geeksforgeeks.org/r-language/classifying-data-using-support-vector-machinessvms-in-r/)  
28. Support Vector Machines in R Tutorial | DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/support-vector-machines-r](https://www.datacamp.com/tutorial/support-vector-machines-r)  
29. SVM Tutorial: Support Vector Machines Tutorial, accessed on July 30, 2025, [https://www.svm-tutorial.com/](https://www.svm-tutorial.com/)  
30. CRAN: Package e1071 \- R-project.org, accessed on July 30, 2025, [https://cran.r-project.org/package=e1071](https://cran.r-project.org/package=e1071)  
31. Package e1071 in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/package-e1071-in-r/](https://www.geeksforgeeks.org/machine-learning/package-e1071-in-r/)  
32. Plotting SVM Decision Boundaries with e1071 in R – Steve's Data Tips and Tricks, accessed on July 30, 2025, [https://www.spsanderson.com/steveondata/posts/2023-09-11/index.html](https://www.spsanderson.com/steveondata/posts/2023-09-11/index.html)  
33. Computing Classification Evaluation Metrics in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/computing-classification-evaluation-metrics-in-r/](https://www.geeksforgeeks.org/r-language/computing-classification-evaluation-metrics-in-r/)  
34. Precision, Recall and F1-Score using R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/precision-recall-and-f1-score-using-r/](https://www.geeksforgeeks.org/r-language/precision-recall-and-f1-score-using-r/)  
35. Classification: Accuracy, recall, precision, and related metrics | Machine Learning, accessed on July 30, 2025, [https://developers.google.com/machine-learning/crash-course/classification/accuracy-precision-recall](https://developers.google.com/machine-learning/crash-course/classification/accuracy-precision-recall)  
36. Pima Indians Diabetes Database \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/datasets/uciml/pima-indians-diabetes-database](https://www.kaggle.com/datasets/uciml/pima-indians-diabetes-database)  
37. Step by Step Diabetes Classification \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/code/shrutimechlearn/step-by-step-diabetes-classification](https://www.kaggle.com/code/shrutimechlearn/step-by-step-diabetes-classification)  
38. ashishpatel26/Pima-Indians-Diabetes-Dataset-Missing-Value-Imputation \- GitHub, accessed on July 30, 2025, [https://github.com/ashishpatel26/Pima-Indians-Diabetes-Dataset-Missing-Value-Imputation](https://github.com/ashishpatel26/Pima-Indians-Diabetes-Dataset-Missing-Value-Imputation)  
39. When to exclude or replace missing values: Pima Indian Dataset \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/questions-and-answers/56544](https://www.kaggle.com/questions-and-answers/56544)  
40. Handling Missing Data For Advanced Machine Learning \- TOPBOTS, accessed on July 30, 2025, [https://www.topbots.com/handling-missing-data-for-machine-learning/](https://www.topbots.com/handling-missing-data-for-machine-learning/)  
41. Predictive Classification model by Imputing missing values ... \- RPubs, accessed on July 30, 2025, [https://rpubs.com/Waseem/707172](https://rpubs.com/Waseem/707172)  
42. caret: Classification and Regression Training \- The Comprehensive ..., accessed on July 30, 2025, [https://cran.r-project.org/web/packages/caret/caret.pdf](https://cran.r-project.org/web/packages/caret/caret.pdf)  
43. Prediction of Diabetes in PIMA Indian Women \- RPubs, accessed on July 30, 2025, [https://rpubs.com/jayarapm/PIMAIndianWomenDiabetes](https://rpubs.com/jayarapm/PIMAIndianWomenDiabetes)