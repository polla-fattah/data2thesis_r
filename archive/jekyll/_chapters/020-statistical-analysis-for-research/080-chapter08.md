---
title: Multivariate Statistical Methods
slug: chapter08
order: 070
published: false
abstract: >
    This chapter delves into multivariate analysis techniques, including PCA, factor analysis, and clustering. These methods enable readers to handle complex datasets with multiple variables, uncovering patterns and relationships that inform research insights.
---


## **1. Introduction to Multivariate Analysis**

Modern research across disciplines—from genetics and finance to sociology and marketing—is characterized by the collection of vast and complex datasets. It is no longer sufficient to analyze variables in isolation or in pairs. Datasets often contain dozens, hundreds, or even thousands of variables, many of which are correlated. This high dimensionality presents a significant challenge known as the "curse of dimensionality," where the complexity of analysis and the risk of spurious findings increase exponentially with the number of variables. Simple bivariate analyses, such as plotting one variable against another, are often inadequate for revealing the true, underlying structure of the data. The intricate web of relationships among multiple variables requires a more sophisticated set of tools.

Multivariate statistical analysis provides these tools. It is a collection of methods designed to analyze data where multiple measurements are made on each observation, and the relationships among these measurements are of primary interest. This chapter provides a comprehensive guide to some of the most powerful and widely used multivariate techniques in R, equipping you with the knowledge to move beyond single-variable statistics and uncover the hidden patterns within your complex data.

### **A Roadmap for This Chapter**

This chapter will explore two fundamental families of multivariate techniques, each addressing a different type of analytical question:

1. **Dimensionality Reduction:** These techniques aim to simplify a dataset by reducing the number of variables while preserving as much of the original information as possible. This is particularly useful when dealing with a large number of correlated variables, a condition known as multicollinearity, which can destabilize statistical models. We will cover two cornerstone methods:  
   * **Principal Component Analysis (PCA):** A technique that transforms a set of correlated variables into a smaller set of new, uncorrelated variables (principal components) that capture the maximum possible variance from the original data.1  
   * **Factor Analysis (FA):** A statistical model that seeks to explain the correlations among observed variables in terms of a smaller number of unobserved, underlying latent factors or constructs.2  
2. **Clustering (Unsupervised Classification):** These techniques are used to identify natural groupings or segments within a dataset based on the similarity of observations, without relying on any pre-existing labels or categories. This is a form of unsupervised learning.4 We will examine the two most prevalent approaches:  
   * **K-Means Clustering:** A partitioning method that divides observations into a pre-specified number (k) of clusters by minimizing the distance of each observation to its cluster's center.5  
   * **Hierarchical Clustering:** An approach that builds a hierarchy of clusters, represented as a tree-like structure called a dendrogram, without requiring the number of clusters to be specified in advance.6

By mastering these four techniques, you will be ableto reduce the complexity of high-dimensional data, identify latent constructs driving your observations, and discover meaningful segments within your population, unlocking deeper and more nuanced insights from your research.

## **8.2 Principal Component Analysis (PCA): Reducing Dimensions, Maximizing Variance**

Principal Component Analysis (PCA) is an unsupervised statistical technique used for dimensionality reduction. Its primary goal is to transform a dataset with a large number of potentially correlated variables into a smaller, more manageable set of uncorrelated variables, known as principal components, while retaining the maximum amount of information—or variance—from the original data.2

### **8.2.1 The Theory and Intuition of PCA**

At its core, PCA seeks to find a new coordinate system for the data. The axes of this new system are the principal components. Each component is a linear combination of the original variables, and they are constructed to be orthogonal (uncorrelated) to one another. The key idea is that these new dimensions are ordered by the amount of variance they explain.2

The process of performing PCA can be broken down into five conceptual steps 8:

1. **Data Normalization (Standardization):** Each variable is transformed so that it has a mean of 0 and a standard deviation of 1\. This step is crucial and will be discussed in detail below.  
2. **Covariance Matrix Computation:** A symmetric matrix is calculated from the normalized data, where each element represents the covariance between two variables. This matrix summarizes the inter-relationships within the data.  
3. **Eigenvector and Eigenvalue Calculation:** The covariance matrix is decomposed to find its eigenvectors and eigenvalues. In geometric terms, an eigenvector represents a direction in the data space, while its corresponding eigenvalue represents the magnitude of the variance in that direction. The eigenvectors of the covariance matrix are the principal components.2  
4. **Selection of Principal Components:** The eigenvectors are sorted in descending order based on their corresponding eigenvalues. The first principal component (PC1) is the eigenvector with the highest eigenvalue, meaning it captures the largest possible variance in the data. The second principal component (PC2) is the eigenvector with the second-highest eigenvalue and is orthogonal to PC1, capturing the next largest amount of variance, and so on.8  
5. **Data Transformation:** The original data is projected onto the new subspace defined by the selected principal components. This is achieved by multiplying the original data by the eigenvectors, resulting in a new dataset with fewer dimensions but containing most of the original information.8

#### **The Criticality of Data Scaling**

One of the most important, and sometimes overlooked, steps in PCA is the initial standardization of the data. PCA is an analysis of variance; it seeks to create components that maximize the variance they explain.2 If the original variables are measured on different scales (e.g., one variable is income in dollars, ranging from 20,000 to 200,000, while another is age, ranging from 18 to 65), the variable with the larger numerical range will inherently have a much larger variance.

Without scaling, the PCA algorithm will be disproportionately influenced by the variable with the largest variance simply due to its units of measurement, not because it is more important in explaining the data's structure. The first principal component would be almost entirely dominated by this single variable, leading to a biased and misleading result.2

By scaling the data (typically by setting center \= TRUE and scale. \= TRUE in R's prcomp function), each variable is transformed to have a mean of zero and a standard deviation of one.7 This puts all variables on an equal footing, ensuring that the principal components are derived from the correlational structure of the data, not from arbitrary scaling artifacts. Therefore, unless all variables are measured in the same units and have similar variances, scaling is a conceptual prerequisite for a valid PCA.

### **8.2.2 Performing PCA in R with prcomp**

R's built-in stats package provides the prcomp() function, a robust and straightforward tool for performing PCA.9 We will use the

USArrests dataset, which is included with R, as our working example. This dataset contains statistics on arrests per 100,000 residents for Assault, Murder, and Rape, along with the percentage of the population living in urban areas (UrbanPop) for each of the 50 US states in 1973\.11

First, let's load and inspect the data.

R

\# Load and inspect the USArrests dataset  
data("USArrests")  
head(USArrests)

The output shows variables with vastly different scales (e.g., Assault ranges into the hundreds, while Murder is in the single or double digits). This confirms the necessity of scaling the data before analysis.

Now, we perform PCA using prcomp(). The key arguments are:

* x: The data frame or matrix containing the numeric variables for analysis.  
* center \= TRUE: A logical value indicating whether the variables should be shifted to be zero-centered. This is the default and is almost always recommended.9  
* scale. \= TRUE: A logical value indicating whether the variables should be scaled to have unit variance. This is crucial when variables are on different scales.7

R

\# Perform PCA on the USArrests dataset  
\# Setting center \= TRUE and scale. \= TRUE is crucial for variables with different units  
pca\_result \<- prcomp(USArrests, center \= TRUE, scale. \= TRUE)

The pca\_result object now contains all the information from our analysis.

### **8.2.3 Interpreting PCA Results**

The object returned by prcomp() is a list containing several components. Understanding these components is key to interpreting the analysis.

**Table 8.1: Key Components of a prcomp Object**

| Component Name | Description |
| :---- | :---- |
| sdev | The standard deviations of the principal components (the square roots of the eigenvalues). Useful for understanding the variance explained by each component.12 |
| rotation | The matrix of variable loadings. Each column is a principal component, and the rows are the original variables. The values are the coefficients of the linear combination (eigenvectors) that define the component.2 |
| center | The mean of each original variable that was used for centering the data.12 |
| scale | The standard deviation of each original variable that was used for scaling the data.12 |
| x | The matrix of principal component scores. Each row corresponds to an original observation (e.g., a US state), and each column is a principal component. These are the coordinates of the observations in the new, lower-dimensional space.12 |

To get a quick overview of the results, we can use the summary() function.

R

\# Get a summary of the PCA results  
summary(pca\_result)

The output of summary(pca\_result) provides three crucial pieces of information for each principal component (PC):

* **Standard deviation:** This is the sdev value, representing the component's eigenvalue's square root.  
* **Proportion of Variance:** This indicates the percentage of the total variance in the original data that is captured by that component. For example, PC1 typically explains the largest proportion.  
* **Cumulative Proportion:** This shows the cumulative percentage of variance explained by the components up to that point. This is useful for deciding how many components to retain to explain a significant portion of the data's variability (e.g., 80% or 90%).7

#### **The Scree Plot**

A scree plot is a graphical representation of the variance explained by each principal component. It helps in deciding how many components to retain for further analysis. The "elbow" of the plot—the point where the curve flattens—suggests the point of diminishing returns, where adding more components does not significantly increase the explained variance.10

R

\# Create a scree plot  
plot(pca\_result, type \= "l", main \= "Scree Plot for USArrests PCA")

#### **Component Loadings (rotation)**

The loadings, found in pca\_result$rotation, are perhaps the most important part of the interpretation. They tell us what each principal component represents in terms of the original variables.2

R

\# View the principal component loadings  
print(pca\_result$rotation)

To interpret the loadings:

* **Magnitude:** The absolute value of the loading indicates the strength of the variable's contribution to the component. Larger absolute values mean the variable is more important for that component.  
* **Sign:** The sign (+ or \-) indicates the direction of the relationship. Variables with the same sign on a component are positively correlated in that dimension, while variables with opposite signs are negatively correlated.2

For the USArrests data, one would typically find that Murder, Assault, and Rape all have high positive loadings on PC1, suggesting PC1 represents an overall "serious crime rate." PC2 might show UrbanPop with a high positive loading and the crime variables with negative loadings, suggesting it represents a contrast between urban areas and crime rates.2

#### **Component Scores (x)**

The scores, found in pca\_result$x, give the position of each original observation in the new principal component space. They allow us to compare observations along these new dimensions.2

R

\# View the first few principal component scores  
head(pca\_result$x)

A state with a high positive score on PC1 would be a state with a high value on the construct PC1 represents (i.e., a high overall crime rate). A score near zero means the state is average on that dimension.

### **8.2.4 Visualizing PCA with factoextra**

While base R plots are functional, the factoextra package provides a suite of functions for creating elegant and informative ggplot2-based visualizations of PCA results.13

R

\# Install and load the factoextra package if you haven't already  
\# install.packages("factoextra")  
library(factoextra)

#### **Visualizing Eigenvalues (Scree Plot)**

The fviz\_eig() function (also aliased as fviz\_screeplot()) creates a more polished scree plot that clearly shows the percentage of variance explained by each component.

R

\# Create an enhanced scree plot  
fviz\_eig(pca\_result, addlabels \= TRUE, ylim \= c(0, 70))

#### **Visualizing Variables (Correlation Circle)**

The fviz\_pca\_var() function creates a "correlation circle" plot of the variable loadings. This plot helps to visualize the relationships between variables and their contributions to the principal components.13

* **Interpretation:**  
  * Variables with long arrows are well-represented on the first two PCs.  
  * The angle between arrows indicates their correlation: a small angle implies positive correlation, a 90-degree angle implies no correlation, and a 180-degree angle implies negative correlation.  
  * The direction of the arrow shows how the variable contributes to the PCs.

R

\# Create a variable correlation circle plot  
fviz\_pca\_var(pca\_result, col.var \= "contrib",  
             gradient.cols \= c("\#00AFBB", "\#E7B800", "\#FC4E07"),  
             repel \= TRUE) \# Avoid text overlapping

#### **Visualizing Individuals (Observations)**

The fviz\_pca\_ind() function plots the scores of the individual observations (the states). This helps to identify which observations are similar and which are different along the principal component dimensions.13

R

\# Create a plot of individuals  
fviz\_pca\_ind(pca\_result, col.ind \= "cos2",  
             gradient.cols \= c("\#00AFBB", "\#E7B800", "\#FC4E07"),  
             repel \= TRUE) \# Avoid text overlapping

Here, cos2 (squared cosine) represents the quality of representation of the individuals on the factor map. Individuals with high cos2 values are well-represented.

#### **The Biplot: A Unified View**

The biplot, created with fviz\_pca\_biplot(), is one of the most powerful visualizations for PCA. It overlays the variable loadings (as arrows) and the individual scores (as points) onto a single plot. This allows for a comprehensive interpretation of how individual observations relate to the underlying variable structure.2

R

\# Create a biplot of individuals and variables  
fviz\_pca\_biplot(pca\_result, repel \= TRUE,  
                col.var \= "\#2E9FDF", \# Variables color  
                col.ind \= "\#696969"  \# Individuals color  
                )

By examining the biplot, one can simultaneously see which states (e.g., Florida, California) are characterized by high crime rates (pulled in the direction of the Murder, Assault, Rape vectors) and which states (e.g., North Dakota, Vermont) are characterized by low crime rates. This single plot effectively summarizes the dominant patterns in the USArrests dataset.

## **8.3 Factor Analysis (FA): Discovering Latent Structures**

While often confused with PCA, Factor Analysis (FA) is a distinct and conceptually different technique. Where PCA is a data transformation method aimed at explaining total variance, FA is a statistical modeling technique designed to identify unobservable, or "latent," factors that are believed to cause the correlations among a set of observed variables.1

### **8.3.1 Conceptual Distinction: PCA vs. Factor Analysis**

Understanding the difference between PCA and FA is crucial for selecting the appropriate method for a given research question. The choice depends on the analyst's goal: data reduction versus theory testing.16

* **PCA's Goal: Summarization.** PCA aims to reduce a set of variables to a smaller number of components that account for the maximum possible *total variance* in the original data. The components are direct linear combinations of the observed variables. PCA assumes that all variance is common variance and does not model measurement error explicitly.1 An analogy is creating a "total health score" component from variables like blood pressure, cholesterol, and heart rate.  
* **FA's Goal: Explanation.** FA aims to explain the *covariance or correlation* among observed variables by postulating that they are influenced by one or more underlying latent factors. FA partitions the variance of each variable into two parts: *communality* (the variance shared with other variables through the common factors) and *uniqueness* (the variance specific to that variable, including error variance).16 An analogy is hypothesizing that an unobserved factor like "intelligence" is the cause of observed correlations among test scores in math, logic, and vocabulary.

The following table provides a definitive summary of their differences.

**Table 8.2: PCA vs. Factor Analysis \- A Comparative Summary**

| Criterion | Principal Component Analysis (PCA) | Factor Analysis (FA) |
| :---- | :---- | :---- |
| **Primary Goal** | Data reduction and summarization.16 | Identify underlying latent structure and explain correlations.18 |
| **Model** | Components are linear combinations of observed variables.1 | Observed variables are linear combinations of latent factors plus an error term.19 |
| **Variance Analyzed** | Accounts for the *total variance* in the observed variables.1 | Accounts for the *common variance* (covariance) among variables.1 |
| **Key Question** | "What is the best way to summarize a set of variables into a smaller number of composite scores?" | "What are the unobserved latent constructs that are causing my observed variables to be correlated?" 16 |
| **Error** | Assumes no measurement error; all variance is considered. | Explicitly models unique variance for each variable, which includes measurement error.17 |
| **Output** | Components are real, calculated values. Component scores are precise.16 | Factors are hypothetical constructs. Factor scores are estimated, not precisely calculated.16 |
| **Typical Use Case** | Reducing the number of predictors for a machine learning model to avoid multicollinearity.17 | Developing and validating psychological scales or testing a theory about underlying constructs.3 |

### **8.3.2 The Theory of Factor Analysis**

The formal model for factor analysis posits that each observed variable (Xj​) in a dataset is a linear function of a smaller number of common factors (Fm​) and a unique factor (ej​).19 For a set of

p variables and k factors, the model can be expressed as:

Xj​=λj1​F1​+λj2​F2​+⋯+λjk​Fk​+ej​  
Where:

* λjm​ is the **factor loading** of variable j on factor m. It represents the strength of the relationship between the variable and the factor.  
* Fm​ is the m-th **common factor**, an unobserved latent variable.  
* ej​ is the **unique factor** for variable j, representing the portion of its variance not shared with other variables.

This model leads to two critical concepts:

* **Uniqueness (ψj​):** The variance of the unique factor, Var(ej​), is called the uniqueness. It is the proportion of a variable's variance that is *not* explained by the common factors. A high uniqueness suggests the variable does not fit well within the proposed factor structure.21  
* **Communality (hj2​):** This is the proportion of a variable's variance that *is* accounted for by the common factors. It is calculated as 1−ψj​. High communality is desirable, as it indicates the variable is well-explained by the model.22

#### **Factor Rotation**

A key challenge in FA is that the initial solution for the factor loadings is mathematically arbitrary; there are infinite solutions that can explain the data equally well. To address this, a process called **rotation** is used to transform the loading matrix into a more interpretable form, known as a "simple structure." The goal of simple structure is to have each variable load strongly on only one factor and have near-zero loadings on the others.3 There are two main types of rotation:

1. **Orthogonal Rotation (e.g., "varimax"):** This method rotates the factors while keeping them uncorrelated (orthogonal) with each other. varimax is the default rotation in R's factanal function and is a very common choice.3  
2. **Oblique Rotation (e.g., "promax"):** This method allows the resulting factors to be correlated. This is often more realistic in fields like psychology or social sciences, where underlying constructs (like anxiety and depression) are expected to be related.3

### **8.3.3 Exploratory Factor Analysis (EFA) in R with factanal**

Exploratory Factor Analysis (EFA) is used when the researcher does not have a strong a priori theory about which variables will load on which factors. The goal is to explore the data to discover the underlying factor structure.3 R's

stats package includes the factanal() function for performing EFA using the maximum likelihood method.21

#### **Choosing the Number of Factors**

The most critical decision in EFA is determining the number of factors to extract. This is a notoriously difficult problem with no single correct answer.21 Common heuristics include:

* **Kaiser's Rule:** Retain factors with eigenvalues greater than 1\. This can be assessed by running a preliminary PCA on the data.21  
* **Scree Plot:** Examine the scree plot from a preliminary PCA and look for the "elbow" or point of inflection.27  
* **Theoretical Grounds:** The number of factors may be dictated by the theory underlying the research.  
* **Model Fit Test:** Use the hypothesis test provided by factanal() to see if the chosen number of factors is sufficient (more on this below).

Let's perform a factor analysis on a subset of the iris dataset, focusing on the four measurement variables. First, we can run a PCA to help decide on the number of factors.

R

\# Use the numeric part of the iris dataset  
iris\_numeric \<- iris\[, 1:4\]

\# Run a preliminary PCA to check eigenvalues  
pca\_iris \<- prcomp(iris\_numeric, scale. \= TRUE)  
summary(pca\_iris)

The summary would likely show one very dominant eigenvalue and a second one that might be near 1, suggesting that one or two factors might be appropriate.

Now, we run the factor analysis using factanal(). Key arguments include factors (the number of factors to extract), rotation (e.g., "varimax"), and scores (to compute factor scores).24

R

\# Perform factor analysis with 2 factors  
\# The default rotation is "varimax" (orthogonal)  
fa\_result \<- factanal(iris\_numeric, factors \= 2, scores \= "regression")

\# Print the results  
print(fa\_result, digits \= 2, cutoff \= 0.3, sort \= TRUE)

The print function options help make the output more readable: cutoff hides loadings below a certain threshold, and sort reorders the variables to make the factor structure clearer.

### **8.3.4 Interpreting factanal Output**

The output of factanal() contains several key sections that must be interpreted carefully.21

* **Uniquenesses:** This is the first section. As explained before, these values represent the proportion of each variable's variance that is *not* explained by the common factors. We look for low uniqueness values, as they indicate the variables are well-represented by the factor model.21  
* **Loadings:** This is the core of the output. The loading matrix shows the correlation between each observed variable and the latent factors. By examining which variables have high loadings on a given factor, we can interpret what that factor represents.21 For the  
  iris data, one might find that Petal.Length and Petal.Width load highly on Factor 1, while Sepal.Length and Sepal.Width load on Factor 2\. This would allow us to name Factor 1 "Petal Dimensions" and Factor 2 "Sepal Dimensions."  
* **Variance Explained:** Below the loadings, a table shows the SS loadings (sum of squared loadings), Proportion Var, and Cumulative Var. These indicate how much variance in the entire set of variables is accounted for by each factor and by the model cumulatively.21  
* **Hypothesis Test and p-value:** The final part of the output is a chi-square test of model adequacy. This is a frequent source of confusion for new users.

#### **The Counter-Intuitive p-value in factanal**

In most statistical tests (like a t-test or ANOVA), a small p-value (e.g., p\<0.05) is desirable, as it allows for the rejection of the null hypothesis and suggests a "significant" finding. In the context of factanal(), the logic is reversed. The null hypothesis (H0​) is that the specified number of factors *is sufficient* to reproduce the observed correlation matrix.21

* **If p-value is LOW (p\<0.05):** We *reject* the null hypothesis. This means our model is *not sufficient*. The chosen number of factors does not adequately capture the data's correlational structure, and we should likely re-run the analysis with more factors (e.g., factors \= k+1).21  
* **If p-value is HIGH (p\>0.05):** We *fail to reject* the null hypothesis. This is the **desired outcome**. It suggests that our model with k factors is a plausible and adequate representation of the data structure.21

A common mistake is for a researcher to see a significant p-value, conclude their model is "good," and proceed with a poor-fitting, underspecified model. It is essential to remember that for the factanal goodness-of-fit test, a non-significant result is the goal.

## **8.4 Clustering: Identifying Homogeneous Groups**

Clustering is a family of unsupervised learning techniques designed to discover natural groupings in data. The objective is to partition a dataset into clusters such that observations within the same cluster are highly similar to one another (high intra-class similarity), while observations in different clusters are dissimilar (low inter-class similarity).5 This section covers the two most prominent clustering methods: k-means and hierarchical clustering.

### **8.4.1 K-Means Clustering**

K-means is a partitioning algorithm that aims to divide a dataset into a pre-specified number of clusters, k. It is one of the most popular and computationally efficient clustering algorithms.4

#### **The K-Means Algorithm**

The k-means algorithm works iteratively to assign each data point to one of k groups based on the features provided. The process is intuitive and can be summarized in the following steps 4:

1. **Specify the Number of Clusters (k):** The analyst must first decide how many clusters to create. This is the most critical parameter in the model.  
2. **Initialize Centroids:** The algorithm randomly selects k data points from the dataset to serve as the initial cluster centers, or "centroids."  
3. **Assign Points to Closest Centroid:** Each observation in the dataset is assigned to the cluster whose centroid is nearest to it. The "nearness" is typically calculated using Euclidean distance.  
4. **Recalculate Centroids:** Once all points are assigned to a cluster, the centroid of each cluster is recalculated as the mean of all points within that cluster.  
5. **Repeat:** Steps 3 and 4 are repeated iteratively. In each iteration, points may be reassigned to a different cluster, and the centroids are updated. This process continues until the cluster assignments no longer change, meaning the algorithm has converged to a stable solution.5

Because the initial random placement of centroids can affect the final result, it is standard practice to run the algorithm multiple times with different random starting points and select the best solution (the one with the lowest total intra-cluster variation). This is controlled by the nstart argument in R's kmeans() function.5

#### **Implementation with kmeans()**

We can perform k-means clustering in R using the kmeans() function from the stats package. Let's use the scaled USArrests data again.

R

\# Prepare the data (scaling is important for distance-based algorithms)  
df\_scaled \<- scale(USArrests)

\# Set seed for reproducibility  
set.seed(123)

\# Perform k-means clustering with k=4 and 25 initial configurations  
km\_result \<- kmeans(df\_scaled, centers \= 4, nstart \= 25)

\# View the results  
print(km\_result)

The km\_result object contains information such as the cluster assignment for each observation (km\_result$cluster), the final cluster centroids (km\_result$centers), and the within-cluster sum of squares for each cluster.

#### **Determining the Optimal Number of Clusters (k)**

The choice of k is the most challenging aspect of k-means clustering. There is no single definitive method, but several heuristics can guide the decision.30 The

factoextra package provides the fviz\_nbclust() function, which makes it easy to apply these methods.30

1. **Elbow Method:** This method plots the total within-cluster sum of squares (WSS) for a range of k values. The optimal k is located at the "elbow" of the plot, where the rate of decrease in WSS slows down significantly.30  
2. **Silhouette Method:** This method measures how well each observation fits within its cluster compared to other clusters. The average silhouette width is calculated for different values of k, and the k that maximizes this value is considered optimal.30  
3. **Gap Statistic:** This is a more statistically rigorous method that compares the observed WSS for a given k to the expected WSS under a null reference distribution (i.e., data with no inherent clustering). The optimal k is the one that maximizes the "gap" between the observed and expected WSS.30

R

\# Use factoextra to determine optimal k  
library(factoextra)

\# Elbow method  
fviz\_nbclust(df\_scaled, kmeans, method \= "wss")

\# Silhouette method  
fviz\_nbclust(df\_scaled, kmeans, method \= "silhouette")

\# Gap statistic method  
fviz\_nbclust(df\_scaled, kmeans, method \= "gap\_stat", nboot \= 50)

It is important to recognize that these methods are statistical guides, not infallible rules. They may even suggest different optimal values for k.30 The final decision should be a synthesis of these statistical measures and the substantive interpretability of the resulting clusters. It is often wise to examine the solutions for the top 2-3 suggested values of

k and choose the one that provides the most meaningful and actionable segmentation for the specific research problem.

### **8.4.2 Hierarchical Clustering**

Hierarchical clustering is an alternative to k-means that does not require the number of clusters to be specified beforehand. Instead, it builds a tree-like hierarchy of clusters, called a dendrogram, which can be visualized to decide on the final number of clusters.6

#### **The Hierarchical Clustering Algorithm**

There are two main types of hierarchical clustering 6:

1. **Agglomerative (Bottom-Up):** This is the more common approach. It starts by treating each observation as its own cluster. Then, in each step, it merges the two most similar clusters until all observations are part of a single, large cluster. This is the method implemented by R's hclust() function.6  
2. **Divisive (Top-Down):** This method works in the opposite direction. It starts with all observations in one cluster and, at each step, splits the most heterogeneous cluster into two until each observation is in its own cluster. This is implemented by the diana() function in the cluster package.6

#### **Linkage Methods: Measuring Cluster Dissimilarity**

The critical decision in hierarchical clustering is how to measure the dissimilarity between two *clusters* (not just two points). This is determined by the **linkage method**.34 The most common linkage methods are:

* **Complete Linkage (Farthest Neighbor):** The distance between two clusters is the distance between their two farthest points. This method tends to produce compact, roughly spherical clusters.34  
* **Single Linkage (Nearest Neighbor):** The distance is defined by the two closest points in the different clusters. This method can handle non-spherical shapes but is sensitive to outliers and can result in long, stringy clusters.34  
* **Average Linkage:** The distance is the average of all pairwise distances between the points in the two clusters. It's a compromise between single and complete linkage.35  
* **Ward's Minimum Variance Method (ward.D2):** This is a very popular and often effective method. At each step, it merges the pair of clusters that results in the minimum increase in the total within-cluster variance. It tends to create well-balanced, equally sized clusters.34

#### **Implementation with hclust()**

Performing agglomerative hierarchical clustering in R is a two-step process 6:

1. **Compute the Distance Matrix:** Use the dist() function to calculate the pairwise dissimilarities between all observations.  
2. **Perform Clustering:** Feed the distance matrix into the hclust() function and specify the linkage method.

R

\# 1\. Compute distance matrix  
d \<- dist(df\_scaled, method \= "euclidean")

\# 2\. Perform hierarchical clustering using Ward's method  
hc\_result \<- hclust(d, method \= "ward.D2")

#### **The Dendrogram**

The primary output of hierarchical clustering is the dendrogram, which can be plotted using the base plot() function or more advanced packages like dendextend.6 The y-axis represents the "height" or dissimilarity at which clusters are merged.

R

\# Plot the dendrogram  
plot(hc\_result, cex \= 0.6, hang \= \-1, main \= "Dendrogram of USArrests")

To obtain the final cluster assignments, one must "cut" the dendrogram at a certain height or, more commonly, specify the desired number of clusters (k). The cutree() function is used for this purpose.35

R

\# Cut the tree to get 4 clusters  
clusters \<- cutree(hc\_result, k \= 4)

\# View the cluster assignments for the first few states  
head(clusters)

\# Draw the dendrogram with rectangles around the 4 clusters  
rect.hclust(hc\_result, k \= 4, border \= 2:5)

The following table summarizes the key practical differences between k-means and hierarchical clustering to aid in selecting the appropriate method.

**Table 8.3: Comparison of Clustering Methods**

| Feature | K-Means Clustering | Hierarchical Clustering |
| :---- | :---- | :---- |
| **Cluster Number Specification** | Must be pre-specified (k).5 | Not required upfront; determined by cutting the dendrogram.6 |
| **Cluster Shape** | Tends to produce spherical, equally sized clusters.29 | Can handle more complex and non-spherical shapes, depending on the linkage method.35 |
| **Sensitivity to Outliers** | Highly sensitive, as centroids are based on the mean.32 | Less sensitive, especially with methods like Ward's or complete linkage.34 |
| **Output** | A single partition of the data into k clusters. | A full hierarchy of clusters visualized as a dendrogram, allowing for multiple possible partitions.6 |
| **Computational Complexity** | Relatively efficient, especially for large datasets. | Computationally intensive, particularly for large datasets, due to the need to compute a full distance matrix. |
| **Primary Use Case** | Fast and efficient segmentation of large datasets when the number of clusters is roughly known. | Exploring the hierarchical structure of data, visualizing relationships, and when the number of clusters is unknown. |

## **8.5 Case Study: A Comparative Analysis of the iris Dataset**

To solidify the concepts from this chapter, we will conduct a case study using the famous iris dataset. This dataset is a classic in the field of machine learning because it contains well-defined groups, making it ideal for testing and comparing unsupervised methods.38

### **8.5.1 The Research Problem and Dataset**

The iris dataset contains 150 observations of iris flowers from three different species: *setosa*, *versicolor*, and *virginica*. For each flower, four measurements were taken: Sepal.Length, Sepal.Width, Petal.Length, and Petal.Width.40

**The Goal:** Our objective is to use only the four measurement variables to see if we can "discover" the three species using the unsupervised techniques learned in this chapter. The Species column will be held out and used only at the very end as our "ground truth" to validate the performance of our models. This simulates a real-world scenario where we have data but no pre-existing labels.

### **8.5.2 Step 1: Exploratory Visualization with PCA**

In a real-world analysis without known labels, a good first step is to use PCA to reduce the dimensionality and visually inspect the data for any inherent structure. If distinct clusters exist, they should separate in the space of the first few principal components.

R

\# Load the iris data  
data(iris)

\# Separate the numeric measurements from the species label  
iris\_data \<- iris\[, 1:4\]  
iris\_species \<- iris$Species

\# Perform PCA on the scaled measurement data  
iris\_pca \<- prcomp(iris\_data, center \= TRUE, scale. \= TRUE)

\# Visualize the PCA results, coloring the points by their true species  
\# In a real scenario, we would not have this color information  
fviz\_pca\_ind(iris\_pca,  
             geom.ind \= "point", \# show points only  
             col.ind \= iris\_species, \# color by group  
             palette \= c("\#00AFBB", "\#E7B800", "\#FC4E07"),  
             addEllipses \= TRUE, \# Concentration ellipses  
             legend.title \= "Species")

The resulting PCA plot would clearly show that the *setosa* species forms a very distinct cluster, well-separated from the other two. The *versicolor* and *virginica* species are also largely separated but show some overlap. This initial visualization strongly suggests that there are indeed three groups in the data and gives us confidence to proceed with clustering.

### **8.5.3 Step 2: Group Assignment with K-Means and Hierarchical Clustering**

Based on the PCA and our knowledge of the data, we will now attempt to formally assign the observations to three clusters using both k-means and hierarchical clustering.

#### **K-Means Clustering**

We will set k=3 and run the kmeans algorithm.

R

\# Scale the data for clustering  
iris\_scaled \<- scale(iris\_data)

\# Set seed for reproducibility  
set.seed(123)

\# Perform k-means clustering with k=3  
km\_iris \<- kmeans(iris\_scaled, centers \= 3, nstart \= 25)

\# Add the cluster assignments to the original data  
iris$kmeans\_cluster \<- as.factor(km\_iris$cluster)

#### **Hierarchical Clustering**

We will use Ward's method, a robust choice, and cut the resulting dendrogram into three clusters.

R

\# Compute distance matrix  
dist\_iris \<- dist(iris\_scaled, method \= "euclidean")

\# Perform hierarchical clustering  
hc\_iris \<- hclust(dist\_iris, method \= "ward.D2")

\# Cut the dendrogram to get 3 clusters  
hc\_clusters \<- cutree(hc\_iris, k \= 3)

\# Add the cluster assignments to the original data  
iris$hc\_cluster \<- as.factor(hc\_clusters)

### **8.5.4 Step 3: Validation and Interpretation**

Now for the crucial final step: we will compare the cluster assignments from our unsupervised models against the true Species labels using a confusion matrix, which we can create with the table() function.

R

\# Confusion matrix for K-Means  
kmeans\_table \<- table(iris$Species, iris$kmeans\_cluster)  
print("K-Means Clustering Results:")  
print(kmeans\_table)

\# Confusion matrix for Hierarchical Clustering  
hc\_table \<- table(iris$Species, iris$hc\_cluster)  
print("Hierarchical Clustering Results:")  
print(hc\_table)

The output tables will show how many observations from each true species were assigned to each cluster. We would expect to see that:

* All 50 *setosa* flowers are correctly placed in their own cluster by both methods.  
* There will be some misclassifications between *versicolor* and *virginica*, reflecting the overlap we saw in the PCA plot. K-means might misclassify around 15-16 flowers, while hierarchical clustering might perform slightly better or worse depending on the linkage method.

#### **The Synergy of Unsupervised Methods**

This case study demonstrates more than just the application of individual algorithms; it reveals a powerful analytical strategy. In a real-world project where the "ground truth" is unknown, one cannot rely on a confusion matrix for validation. Confidence in the results must be built from a convergence of evidence.

The process would be:

1. **Hypothesize with PCA:** Begin by using PCA to visualize the data. Does it appear to have structure? The PCA plot for the iris data strongly suggests three groups.  
2. **Guide with Optimization:** Use heuristic methods like the Elbow, Silhouette, and Gap Statistic to get a statistical recommendation for the optimal number of clusters. For the iris data, these methods would robustly point towards k=3.  
3. **Confirm with Multiple Algorithms:** Apply several different clustering algorithms, such as k-means and hierarchical clustering.  
4. **Synthesize and Interpret:** If PCA visually suggests three groups, the optimization methods all point to k=3, and both k-means and hierarchical clustering produce similar, interpretable three-cluster solutions, one can be far more confident in the conclusion that there are indeed three meaningful segments in the data.

This synergistic approach—using PCA for initial exploration, optimization methods for guidance, and multiple clustering algorithms for confirmation—allows the analyst to build a compelling, evidence-based narrative about the hidden structure within their data, transforming an exploratory analysis into a robust and defensible finding.

## **8.6 Chapter Summary and Further Reading**

This chapter has provided a comprehensive introduction to four essential multivariate statistical methods in R. We have journeyed from the theoretical foundations of these techniques to their practical implementation and interpretation, emphasizing the critical decisions an analyst must make along the way.

We began with **dimensionality reduction**, contrasting two powerful techniques:

* **Principal Component Analysis (PCA)** is a data transformation tool used to summarize a large set of correlated variables into a smaller set of uncorrelated components that capture maximum variance. We stressed the absolute necessity of scaling data before performing PCA.  
* **Factor Analysis (FA)** is a statistical modeling technique used to uncover unobserved latent factors that are hypothesized to cause the correlations among observed variables. We highlighted the importance of choosing the number of factors and the counter-intuitive nature of its goodness-of-fit p-value.

Next, we explored **clustering**, or unsupervised classification:

* **K-Means Clustering** is an efficient partitioning algorithm that groups data into a pre-specified number (k) of clusters. We demonstrated that the primary challenge is determining the optimal k, exploring the Elbow, Silhouette, and Gap Statistic methods as valuable guides.  
* **Hierarchical Clustering** builds a complete, tree-like hierarchy of clusters (a dendrogram), which offers a rich visualization of the data's structure without requiring an upfront decision on the number of clusters. The choice of linkage method was shown to be a critical parameter.

Finally, our case study on the iris dataset illustrated how these methods are not used in isolation but can be combined synergistically. Using PCA for initial visualization, optimization methods to guide cluster number selection, and multiple clustering algorithms to confirm findings creates a robust workflow for uncovering and validating hidden patterns in complex data.

Mastery of these multivariate methods is a significant step in becoming a proficient data scientist or researcher. They provide the tools to move beyond simple descriptions and to model the complex, high-dimensional reality that most modern datasets represent.

### **Further Reading**

For readers who wish to delve deeper into the theory and application of these methods, the following resources are highly recommended:

* **Books:**  
  * *An Introduction to Statistical Learning: with Applications in R* by Gareth James, Daniela Witten, Trevor Hastie, and Robert Tibshirani. Chapters on unsupervised learning provide excellent, accessible coverage of PCA and clustering.  
  * *Applied Multivariate Statistical Analysis* by Richard A. Johnson and Dean W. Wichern. A classic, comprehensive textbook on the mathematical theory behind these methods.  
  * *Modern Psychometrics with R* by Patrick Mair. An outstanding resource for a deep dive into Factor Analysis and its applications in the social sciences.  
* **R Packages and Vignettes:**  
  * **factoextra:** Explore the package's documentation and vignettes for advanced visualization of PCA and clustering results.  
  * **psych:** This package offers extensive tools for factor analysis, including alternative estimation and rotation methods.  
  * **cluster:** The foundational package for many clustering algorithms in R, including pam (k-medoids), agnes, and diana.  
  * **dendextend:** A powerful package for enhanced visualization and manipulation of dendrograms from hierarchical clustering.

#### **Works cited**

1. Factor Analysis Introduction with the Principal Component Method ..., accessed on July 30, 2025, [https://www.r-bloggers.com/2017/02/factor-analysis-introduction-with-the-principal-component-method-and-r/](https://www.r-bloggers.com/2017/02/factor-analysis-introduction-with-the-principal-component-method-and-r/)  
2. Principal Components Analysis · UC Business Analytics R ..., accessed on July 30, 2025, [https://uc-r.github.io/pca](https://uc-r.github.io/pca)  
3. Factor Analysis | R Programming for Psychometrics \- Bookdown, accessed on July 30, 2025, [https://bookdown.org/sz\_psyc490/r4psychometics/factor-analysis.html](https://bookdown.org/sz_psyc490/r4psychometics/factor-analysis.html)  
4. K-Means Clustering in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/k-means-clustering-in-r-programming/](https://www.geeksforgeeks.org/r-language/k-means-clustering-in-r-programming/)  
5. K-means Cluster Analysis \- UC Business Analytics R Programming Guide ·, accessed on July 30, 2025, [https://uc-r.github.io/kmeans\_clustering](https://uc-r.github.io/kmeans_clustering)  
6. Hierarchical Cluster Analysis · UC Business Analytics R ..., accessed on July 30, 2025, [https://uc-r.github.io/hc\_clustering](https://uc-r.github.io/hc_clustering)  
7. prcomp in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/prcomp-in-r/](https://www.geeksforgeeks.org/r-language/prcomp-in-r/)  
8. Principal Component Analysis (PCA) in R Tutorial | DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/pca-analysis-r](https://www.datacamp.com/tutorial/pca-analysis-r)  
9. prcomp function \- Principal Components Analysis \- RDocumentation, accessed on July 30, 2025, [https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/prcomp](https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/prcomp)  
10. Mique-Jesus/Principal\_Component\_Analysis.R: Step-by ... \- GitHub, accessed on July 30, 2025, [https://github.com/Mique-Jesus/Principal\_Component\_Analysis.R](https://github.com/Mique-Jesus/Principal_Component_Analysis.R)  
11. USArrests function \- RDocumentation, accessed on July 30, 2025, [https://www.rdocumentation.org/packages/datasets/versions/3.6.2/topics/USArrests](https://www.rdocumentation.org/packages/datasets/versions/3.6.2/topics/USArrests)  
12. How to Use R prcomp Results for Prediction? \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/how-to-use-r-prcomp-results-for-prediction/](https://www.geeksforgeeks.org/machine-learning/how-to-use-r-prcomp-results-for-prediction/)  
13. Visualize Principal Component Analysis — fviz\_pca • factoextra \- R Packages, accessed on July 30, 2025, [https://rpkgs.datanovia.com/factoextra/reference/fviz\_pca.html](https://rpkgs.datanovia.com/factoextra/reference/fviz_pca.html)  
14. factoextra: Extract and Visualize the Results of Multivariate Data Analyses, accessed on July 30, 2025, [https://cran.r-project.org/web/packages/factoextra/factoextra.pdf](https://cran.r-project.org/web/packages/factoextra/factoextra.pdf)  
15. Factor Analysis and Principal Component Analysis: A Simple Explanation \- Displayr, accessed on July 30, 2025, [https://www.displayr.com/factor-analysis-and-principal-component-analysis-a-simple-explanation/](https://www.displayr.com/factor-analysis-and-principal-component-analysis-a-simple-explanation/)  
16. pca \- What are the differences between Factor Analysis and ..., accessed on July 30, 2025, [https://stats.stackexchange.com/questions/1576/what-are-the-differences-between-factor-analysis-and-principal-component-analysi](https://stats.stackexchange.com/questions/1576/what-are-the-differences-between-factor-analysis-and-principal-component-analysi)  
17. factor analysis vs principal components analysis (pca) \- is one more common/useful than the other? : r/AskStatistics \- Reddit, accessed on July 30, 2025, [https://www.reddit.com/r/AskStatistics/comments/m49958/factor\_analysis\_vs\_principal\_components\_analysis/](https://www.reddit.com/r/AskStatistics/comments/m49958/factor_analysis_vs_principal_components_analysis/)  
18. A Comparison of Principle Component Analysis and Factor Analysis Strategies for Uncovering Pleiotropic Factors \- PMC, accessed on July 30, 2025, [https://pmc.ncbi.nlm.nih.gov/articles/PMC3042259/](https://pmc.ncbi.nlm.nih.gov/articles/PMC3042259/)  
19. Intro \- Basic Exploratory Factor Analysis | QuantDev Methodology, accessed on July 30, 2025, [https://quantdev.ssri.psu.edu/tutorials/intro-basic-exploratory-factor-analysis](https://quantdev.ssri.psu.edu/tutorials/intro-basic-exploratory-factor-analysis)  
20. Factor Analysis and Applications in R, accessed on July 30, 2025, [https://www.karlin.mff.cuni.cz/\~maciak/NMST539/cvicenie2018\_8.html](https://www.karlin.mff.cuni.cz/~maciak/NMST539/cvicenie2018_8.html)  
21. A simple example of Factor Analysis in R • SOGA-R • Department of ..., accessed on July 30, 2025, [https://www.geo.fu-berlin.de/en/v/soga-r/Advances-statistics/Multivariate-approaches/Factor-Analysis/A-Simple-Example-of-Factor-Analysis-in-R/index.html](https://www.geo.fu-berlin.de/en/v/soga-r/Advances-statistics/Multivariate-approaches/Factor-Analysis/A-Simple-Example-of-Factor-Analysis-in-R/index.html)  
22. Getting Started with Exploratory Factor Analysis | UVA Library, accessed on July 30, 2025, [https://library.virginia.edu/data/articles/getting-started-with-factor-analysis](https://library.virginia.edu/data/articles/getting-started-with-factor-analysis)  
23. Workshop 4: Factor Analysis, accessed on July 30, 2025, [https://maths.dur.ac.uk/stats/MDS-DEVUL/Workshop4\_FA.html](https://maths.dur.ac.uk/stats/MDS-DEVUL/Workshop4_FA.html)  
24. factanal function \- Factor Analysis \- RDocumentation, accessed on July 30, 2025, [https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/factanal](https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/factanal)  
25. Principal Component Analysis (PCA) vs. Exploratory Factor Analysis \- when/why? : r/statistics \- Reddit, accessed on July 30, 2025, [https://www.reddit.com/r/statistics/comments/26px43/principal\_component\_analysis\_pca\_vs\_exploratory/](https://www.reddit.com/r/statistics/comments/26px43/principal_component_analysis_pca_vs_exploratory/)  
26. Exploratory factor analysis \-- Advanced Statistics using R, accessed on July 30, 2025, [https://advstats.psychstat.org/book/factor/efa.php](https://advstats.psychstat.org/book/factor/efa.php)  
27. Factor Interpretation in Factor Analysis : r/AskStatistics \- Reddit, accessed on July 30, 2025, [https://www.reddit.com/r/AskStatistics/comments/tvmmco/factor\_interpretation\_in\_factor\_analysis/](https://www.reddit.com/r/AskStatistics/comments/tvmmco/factor_interpretation_in_factor_analysis/)  
28. What is the meaning of the R factanal output? \- Cross Validated \- Stack Exchange, accessed on July 30, 2025, [https://stats.stackexchange.com/questions/121271/what-is-the-meaning-of-the-r-factanal-output](https://stats.stackexchange.com/questions/121271/what-is-the-meaning-of-the-r-factanal-output)  
29. K-Means Clustering in R with Step by Step Code Examples ..., accessed on July 30, 2025, [https://www.datacamp.com/tutorial/k-means-clustering-r](https://www.datacamp.com/tutorial/k-means-clustering-r)  
30. Determining The Optimal Number Of Clusters: 3 Must Know ..., accessed on July 30, 2025, [https://www.datanovia.com/en/lessons/determining-the-optimal-number-of-clusters-3-must-know-methods/](https://www.datanovia.com/en/lessons/determining-the-optimal-number-of-clusters-3-must-know-methods/)  
31. Elbow Method in R: Find Optimal Clusters for K-Means, accessed on July 30, 2025, [https://www.rstudiodatalab.com/2023/08/elbow-method-R-optimal-number-clusters.html](https://www.rstudiodatalab.com/2023/08/elbow-method-R-optimal-number-clusters.html)  
32. K-Means: Getting the Optimal Number of Clusters \- Analytics Vidhya, accessed on July 30, 2025, [https://www.analyticsvidhya.com/blog/2021/05/k-mean-getting-the-optimal-number-of-clusters/](https://www.analyticsvidhya.com/blog/2021/05/k-mean-getting-the-optimal-number-of-clusters/)  
33. Visualize Silhouette Information from Clustering — fviz\_silhouette ..., accessed on July 30, 2025, [https://rpkgs.datanovia.com/factoextra/reference/fviz\_silhouette.html](https://rpkgs.datanovia.com/factoextra/reference/fviz_silhouette.html)  
34. Unsupervised Learning in R: Hierarchical Clustering | by Fatih Emre ..., accessed on July 30, 2025, [https://medium.com/@ozturkfemre/unsupervised-learning-in-r-hierarchical-clustering-6e27260a11ff](https://medium.com/@ozturkfemre/unsupervised-learning-in-r-hierarchical-clustering-6e27260a11ff)  
35. Hierarchical Clustering in R \- R-bloggers, accessed on July 30, 2025, [https://www.r-bloggers.com/2016/01/hierarchical-clustering-in-r-2/](https://www.r-bloggers.com/2016/01/hierarchical-clustering-in-r-2/)  
36. hclust function \- Hierarchical Clustering \- RDocumentation, accessed on July 30, 2025, [https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/hclust](https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/hclust)  
37. Dendrogram | the R Graph Gallery, accessed on July 30, 2025, [https://r-graph-gallery.com/dendrogram.html](https://r-graph-gallery.com/dendrogram.html)  
38. Iris dataset in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/iris-dataset-in-r/](https://www.geeksforgeeks.org/r-language/iris-dataset-in-r/)  
39. A Complete Guide to the Iris Dataset in R \- Statology, accessed on July 30, 2025, [https://www.statology.org/iris-dataset-r/](https://www.statology.org/iris-dataset-r/)  
40. Iris Data \- R, accessed on July 30, 2025, [https://search.r-project.org/CRAN/refmans/MVTests/html/iris.html](https://search.r-project.org/CRAN/refmans/MVTests/html/iris.html)  
41. iris Edgar Anderson's Iris Data \- RDocumentation, accessed on July 30, 2025, [https://www.rdocumentation.org/packages/datasets/versions/3.6.2/topics/iris](https://www.rdocumentation.org/packages/datasets/versions/3.6.2/topics/iris)  
42. Edgar Anderson's Iris Data \- R, accessed on July 30, 2025, [https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/iris.html](https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/iris.html)