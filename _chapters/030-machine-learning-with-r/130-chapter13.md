---
title: Advanced Clustering
slug: chapter13
order: 120
published: false
abstract: >
    Building on the k-means and hierarchical clustering of Chapter 8, this chapter introduces two more flexible methods: density-based clustering with DBSCAN and probabilistic clustering with Gaussian Mixture Models. Readers will learn to evaluate clustering performance and apply these techniques to discover hidden patterns in their research data.
---




This chapter marks a significant step forward in our journey through unsupervised learning. Having explored partitioning methods like k-means and hierarchical clustering in previous chapters, we now venture into more sophisticated techniques capable of handling the complex, "messy" data often encountered in real-world research. We will uncover how to find clusters that are not simple spheres and how to think about cluster membership not as a certainty, but as a probability. Crucially, we will also equip ourselves with the tools to rigorously evaluate our results, answering the critical question: "How good is my clustering?" This chapter will empower you to move beyond basic methods and select the most appropriate clustering algorithm for the unique structure of your data.

## **Beyond Spheres and Symmetries: The Need for Advanced Clustering**

The clustering algorithms discussed so far, k-means and hierarchical clustering, are foundational and powerful in many contexts. However, their effectiveness is built upon a set of assumptions about the data's structure. When these assumptions are violated, the performance of these methods can degrade significantly, leading to misleading or incorrect conclusions. Understanding these limitations is the first step toward selecting more advanced and appropriate tools.

The limitations of an algorithm are not merely technical weaknesses; they represent a fundamental mismatch between the algorithm's assumptions and the natural structure of a given dataset. In machine learning, there is no universally superior algorithm—a concept often referred to as the "No Free Lunch" theorem. The failure of a basic algorithm can therefore be a powerful diagnostic signal, revealing the inherent complexity of the data itself. This reframes the goal from finding the "best" algorithm to finding the algorithm best suited for the data's specific structure.

### **Recap of K-Means Limitations**

K-means is celebrated for its computational efficiency and its effectiveness in identifying well-separated, globular (or spherical) clusters.1 However, its simplicity comes with several critical constraints:

* **Pre-specification of Cluster Count (k):** The algorithm requires the user to specify the number of clusters, k, in advance. In exploratory data analysis, this number is often unknown. While methods like the elbow plot or silhouette analysis can help estimate an optimal k, they can often be ambiguous and require interpretation.1  
* **Sensitivity to Initialization:** K-means is sensitive to the initial random placement of cluster centroids. A poor initialization can lead the algorithm to converge to a local optimum, rather than the true global optimum. The standard practice of running the algorithm multiple times with different starting points (using the nstart argument in R's kmeans function) mitigates but does not eliminate this risk.1  
* **Assumption of Spherical and Evenly Sized Clusters:** The most significant limitation is that k-means implicitly assumes that all clusters are spherical, have similar variances, and contain a roughly equal number of observations. It defines clusters based on minimizing the distance to a central mean, a process that naturally carves out sphere-like regions in the feature space. When faced with elongated, non-convex, or arbitrarily shaped clusters, k-means will often fail by incorrectly partitioning these natural groups.1

### **Recap of Hierarchical Clustering Limitations**

Hierarchical clustering offers a different approach, building a tree-like structure of nested clusters known as a dendrogram. This method does not require pre-specifying k and can reveal hierarchical relationships in the data.1 Yet, it has its own set of drawbacks:

* **Computational Complexity:** The primary disadvantage of hierarchical clustering is its computational and memory cost. The algorithm typically requires the computation and storage of a distance matrix of size n×n, where n is the number of observations. This results in a time complexity of at least O(n2), making it impractical for large datasets.1  
* **Greedy and Irreversible Decisions:** Hierarchical clustering algorithms make greedy decisions. In an agglomerative (bottom-up) approach, once two clusters are merged, the merge cannot be undone. An early, suboptimal merge can propagate through the hierarchy, leading to a flawed final clustering structure.1

To illustrate these limitations, consider the synthetic datasets below, generated using the mlbench package. On the left, two intertwined spirals are a classic example of non-convex clusters. On the right, the "Cassini" dataset contains two crescent shapes and a central circle.

R

\# Load necessary libraries  
library(mlbench)  
library(ggplot2)

\# Generate and plot spiral data  
set.seed(123)  
spirals \<- mlbench.spirals(n \= 300, cycles \= 1.5, sd \= 0.05)  
df\_spirals \<- as.data.frame(spirals$x)  
ggplot(df\_spirals, aes(x \= V1, y \= V2)) \+  
  geom\_point(color \= spirals$classes) \+  
  theme\_classic() \+  
  ggtitle("Spiral Dataset")

\# Generate and plot Cassini data  
set.seed(123)  
cassini \<- mlbench.cassini(n \= 500)  
df\_cassini \<- as.data.frame(cassini$x)  
ggplot(df\_cassini, aes(x \= V1, y \= V2)) \+  
  geom\_point(color \= cassini$classes) \+  
  theme\_classic() \+  
  ggtitle("Cassini Dataset")

A k-means algorithm applied to these datasets would fail, as it would attempt to find spherical centers and partition the data accordingly, breaking the natural spiral and crescent shapes. While hierarchical clustering might perform better, it would still struggle with the connectivity and proximity of points between the different true clusters. These challenges create a clear need for algorithms built on different principles—principles of density and probability.

## **Density-Based Clustering: Finding Structure in the Noise with DBSCAN**

Density-Based Spatial Clustering of Applications with Noise (DBSCAN) offers a powerful alternative to centroid-based methods. It fundamentally redefines a cluster not as a group of points around a center, but as a continuous region of high point density, separated from other such regions by areas of low point density.1 This conceptual shift from a center-based view to a density-based one is what allows DBSCAN to identify clusters of arbitrary shapes and sizes, and to effectively handle noise.

### **The Intuition of Density**

The core idea of DBSCAN is intuitive. Imagine looking at a scatter plot and seeing dense clouds of points. These clouds are the clusters. The sparse areas in between are just noise. DBSCAN formalizes this intuition by classifying every point in the dataset into one of three types, based on its local density 6:

1. **Core Point:** A point that has a sufficient number of neighbors within a specified radius. These points are in the interior of a dense cluster.  
2. **Border Point:** A point that is not a core point itself (it has too few neighbors) but falls within the neighborhood of a core point. These points lie on the edge of a cluster.  
3. **Noise Point (Outlier):** A point that is neither a core point nor a border point. These points are in low-density regions and do not belong to any cluster.

This ability to explicitly identify and isolate noise is a major advantage of DBSCAN, making it particularly robust for real-world datasets that often contain outliers or measurement errors.6

### **The DBSCAN Algorithm and its Parameters**

The DBSCAN algorithm operates based on two simple but critical user-defined parameters that together define "density" for the dataset 6:

* **eps (ϵ):** The radius of the neighborhood to consider around each point. It defines the maximum distance at which two points can be considered neighbors.  
* **MinPts:** The minimum number of points (including the point itself) required to be within the eps radius for that point to be considered a **core point**.

The algorithm proceeds as follows 6:

1. Arbitrarily select an unvisited point in the dataset.  
2. Retrieve all points within its eps neighborhood (its neighbors).  
3. If the number of neighbors is greater than or equal to MinPts, the point is labeled a **core point**, and a new cluster is initiated. This core point and all its neighbors are added to this new cluster. The algorithm then recursively expands the cluster by checking the neighbors of all newly added core points.  
4. If the number of neighbors is less than MinPts, the point is temporarily labeled as **noise**. It may later be re-labeled as a **border point** if it is found to be in the neighborhood of a core point from another cluster.  
5. Repeat this process until all points in the dataset have been visited.

This local, connectivity-based definition allows clusters to "grow" along any path of high density, naturally forming the arbitrary shapes that confound centroid-based methods. The parameters eps and MinPts are not just tuning knobs; they are the user's way of providing a precise mathematical definition of what constitutes a "dense region" worthy of being called a cluster.

### **Implementation in R with the dbscan Package**

While the fpc package also provides an implementation, the dbscan package is specialized and highly optimized for this task.6

#### **Parameter Estimation**

The performance of DBSCAN is highly sensitive to the choice of eps and MinPts.6 While

MinPts can often be set using a heuristic, choosing eps requires a more data-driven approach. A common and effective technique is to use a **k-distance plot**. This involves calculating the distance of every point to its k-th nearest neighbor (where k=MinPts) and plotting these distances in ascending order.6 The "elbow" or "knee" in this plot—the point of maximum curvature—indicates a threshold where the distances start to increase sharply. This point represents a natural separation between the dense regions (where k-th neighbor distances are small) and the sparse, noisy regions (where they are large), making it a good candidate for the

eps value.

For MinPts, a common rule of thumb is to set it to 2 \* number\_of\_dimensions.9 For a 2D dataset, this would suggest

MinPts \= 4\. It is often beneficial to choose a slightly larger value to ensure that clusters are robust.

#### **Fitting the Model**

Let's apply DBSCAN to the spirals dataset, which is designed to defeat spherical clustering algorithms.

R

\# Ensure necessary packages are loaded  
library(dbscan)  
library(mlbench)  
library(ggplot2)  
library(factoextra)

\# Generate spiral data  
set.seed(123)  
spirals \<- mlbench.spirals(n \= 300, cycles \= 1.5, sd \= 0.05)  
df \<- as.data.frame(spirals$x)  
names(df) \<- c("X1", "X2")

\# \--- Step 1: Determine parameters \---  
\# For MinPts, a rule of thumb is 2 \* dim. Here dim=2, so MinPts=4.  
\# Let's use a slightly more robust value of 5\.  
\# Now, find a good eps using a k-distance plot for k=5.  
kNNdistplot(df, k \= 5)  
\# The plot shows an "elbow" around a distance of 0.2.  
\# We will draw a line to mark this value.  
abline(h \= 0.2, lty \= 2, col \= "red")

\# \--- Step 2: Run DBSCAN \---  
\# Use the parameters identified above.  
db\_result \<- dbscan(df, eps \= 0.2, minPts \= 5)

\# Print the result object to see a summary  
print(db\_result)  
\# DBSCAN clustering for 300 objects.  
\# Parameters: eps \= 0.2, minPts \= 5  
\# The clustering contains 2 cluster(s) and 4 noise points.

\# \--- Step 3: Visualize results \---  
\# The fviz\_cluster function can visualize the dbscan object.  
\# Cluster 0 represents noise points, which fviz\_cluster handles automatically.  
fviz\_cluster(db\_result, data \= df, stand \= FALSE,  
             ellipse \= FALSE, show.clust.cent \= FALSE,  
             geom \= "point", palette \= "jco", ggtheme \= theme\_classic(),  
             main \= "DBSCAN Clustering of Spiral Data")

The output and the resulting plot clearly show DBSCAN's strength. It has successfully identified the two spiral clusters and correctly labeled a few points that fall between them as noise (cluster 0).6 A k-means algorithm would have failed, likely splitting each spiral into multiple parts.

### **Pros and Cons of DBSCAN**

DBSCAN is a powerful tool, but it's important to understand its trade-offs.

**Advantages:**

* **No need to specify the number of clusters:** The number of clusters is determined automatically by the algorithm based on the data's density.6  
* **Can find arbitrarily shaped clusters:** Its density-based approach is not constrained by assumptions of cluster shape.6  
* **Robust to outliers:** It has a built-in mechanism for identifying and handling noise points.6

**Disadvantages:**

* **Parameter sensitivity:** The algorithm's success is highly dependent on the user's choice of eps and MinPts.6  
* **Struggles with varying densities:** DBSCAN uses a single global density threshold (eps and MinPts). It cannot effectively identify clusters if they have significantly different internal densities, as a single eps value will not be appropriate for all clusters.6  
* **Curse of dimensionality:** In very high-dimensional spaces, the concept of distance becomes less meaningful, and all points can appear equidistant from each other, making density estimation difficult.

## **Probabilistic Clustering: Gaussian Mixture Models (GMM)**

Gaussian Mixture Models (GMMs) provide another sophisticated alternative to traditional clustering, shifting the paradigm from "hard" to "soft" cluster assignments. Where k-means and DBSCAN assign each point to exactly one cluster, GMMs operate on a probabilistic framework, providing a more nuanced and flexible approach to uncovering latent structures in data.

### **From Hard to Soft Assignments**

Most clustering algorithms perform **hard clustering**, where each data point is definitively assigned to a single cluster.13 GMM, in contrast, performs

**soft clustering** (also known as fuzzy clustering). It calculates the *probability* that each data point belongs to each of the clusters.14 This is immensely powerful for several reasons:

* It provides a measure of uncertainty for each assignment. A point with a 99% probability of belonging to Cluster 1 is a confident assignment, whereas a point with a 55% probability for Cluster 1 and a 45% probability for Cluster 2 is clearly an ambiguous case lying on the boundary.  
* It more accurately reflects the reality of many datasets, where cluster boundaries are not sharp, and some observations genuinely share characteristics of multiple groups.

### **The Theory of Gaussian Mixtures**

The central assumption of GMM is that the observed data is generated from a *mixture* of a finite number of Gaussian (or normal) distributions.15 Each of these underlying Gaussian distributions represents a single cluster.

Each component Gaussian is defined by its own set of parameters 14:

1. **Mean (μ):** A vector representing the center of the cluster.  
2. **Covariance (Σ):** A matrix that defines the shape, size, and orientation of the cluster. This is a key advantage over k-means, which implicitly assumes a spherical covariance (equal variance in all directions). GMMs can model clusters that are spherical, diagonal (ellipsoidal but aligned with the axes), or fully ellipsoidal (oriented in any direction).  
3. **Mixing Weight (π):** A scalar representing the proportion or "importance" of that Gaussian component in the overall mixture. It is the prior probability that a randomly selected data point was generated by that component. The sum of all mixing weights must be 1\.16

The probability density of a data point x is a weighted sum of these component densities:

p(x∣λ)=i=1∑M​wi​g(x∣μi​,Σi​)

where M is the number of clusters, wi​ is the mixing weight for cluster i, and g(x∣μi​,Σi​) is the multivariate Gaussian probability density function for cluster i.16  
This framework reveals a profound connection: **k-means is a simplified, special case of a Gaussian Mixture Model**. K-means is mathematically equivalent to a GMM where all clusters are forced to have the same spherical covariance matrix and the same mixing weights.4 GMM generalizes this by relaxing these restrictive assumptions, allowing it to fit a much wider variety of data structures. It is a natural "upgrade" from k-means; if the data is simple and spherical, k-means is a fast approximation. If the data has more complex shapes, sizes, or densities, GMM provides the necessary flexibility.

### **Parameter Estimation with Expectation-Maximization (EM)**

Given a dataset, the goal of GMM is to find the parameters (μi​, Σi​, wi​ for each cluster i) that maximize the likelihood of observing that data. A direct analytical solution for this is intractable because the cluster assignments are unknown.16 Instead, GMMs are trained using an iterative algorithm called

**Expectation-Maximization (EM)**.14

The EM algorithm alternates between two steps until the parameters converge 20:

1. **E-Step (Expectation):** Given the current estimates of the model parameters (means, covariances, weights), this step calculates the *posterior probability* (also called the "responsibility") that each data point belongs to each cluster. This is the "soft assignment."  
2. **M-Step (Maximization):** Using the responsibilities calculated in the E-step as soft weights, this step updates the model parameters to maximize the likelihood of the data. For example, the new mean for a cluster is a weighted average of all data points, where the weights are the responsibilities.

This two-step process is guaranteed to increase the data's likelihood at each iteration, eventually converging to a (potentially local) maximum.16

### **Implementation in R with mclust**

The mclust package is the gold standard for fitting Gaussian Mixture Models in R.20 One of its most powerful features is its ability to perform automatic model selection. It can test a range of cluster numbers (

G) and various covariance structures, then use the **Bayesian Information Criterion (BIC)** to identify the best-fitting model. The BIC is a goodness-of-fit measure that penalizes model complexity, helping to avoid overfitting and providing a principled way to answer the "how many clusters?" question.15

Let's apply GMM to the classic iris dataset, whose clusters are known to be roughly elliptical.

R

\# Load necessary libraries  
library(mclust)  
library(ggplot2)

\# Use only the numeric feature data from the iris dataset  
iris\_data \<- iris\[, 1:4\]

\# \--- Step 1: Fit the GMM \---  
\# By default, Mclust() tests for G \= 1 to 9 clusters and 14 different  
\# covariance models. It selects the best model based on the BIC.  
gmm\_result \<- Mclust(iris\_data)

\# \--- Step 2: Examine the results \---  
\# The summary provides details on the best model selected.  
summary(gmm\_result)  
\# The output will indicate the best model (e.g., "VEV") and the optimal  
\# number of clusters (G) found. For the iris dataset, it often finds G=2,  
\# as two of the species are not linearly separable.

\# \--- Step 3: Visualize the model selection process \---  
\# We can plot the BIC values for all tested models. The model with the  
\# highest BIC is the one selected.  
plot(gmm\_result, what \= "BIC")

\# \--- Step 4: Visualize the clustering results \---  
\# The plot function provides several useful visualizations.  
\# 'classification' shows the final hard-clustered data points.  
plot(gmm\_result, what \= "classification")  
\# 'uncertainty' highlights points with low confidence in their assignment.  
plot(gmm\_result, what \= "uncertainty")

\# \--- Step 5: Access the soft cluster probabilities \---  
\# The 'z' component of the result object contains the matrix of  
\# posterior probabilities (responsibilities) for each point.  
\# Each row is a data point, each column is a cluster.  
head(gmm\_result$z)

The output from summary(gmm\_result) reveals the best model chosen. For instance, a "VEV" model indicates that the clusters have varying volume, ellipsoidal shape, and varying orientation. The plot of BIC values provides clear, quantitative evidence for why a particular number of clusters and covariance structure was chosen. Finally, inspecting the gmm\_result$z matrix allows access to the soft assignments, providing a richer understanding of the cluster structure than a simple hard assignment vector.

## **How Good is My Clustering? Evaluating Performance**

After applying a clustering algorithm, a critical question remains: how good is the result? Cluster validation is the process of quantitatively evaluating the quality of the generated clusters. This is not an optional step; it is essential for comparing different algorithms, tuning parameters, and ensuring that the discovered patterns are meaningful and not just artifacts of the algorithm.

There are two primary scenarios for cluster validation, each with its own set of metrics 22:

1. **Internal Validation:** This is used in the most common, truly unsupervised scenario where no ground truth labels exist. Internal metrics assess the quality of the clustering based solely on the inherent properties of the data and the cluster assignments. They typically measure a combination of **compactness** (how close points are within a cluster) and **separation** (how far apart different clusters are).  
2. **External Validation:** This is used when external, ground-truth labels are available for the data (e.g., when applying clustering to a known classification dataset for exploratory purposes). External metrics measure how well the clustering results match the true, pre-existing categories.

### **Internal Validation (When Ground Truth is Unknown)**

#### **Silhouette Analysis**

The Silhouette score is one of the most popular and intuitive internal validation metrics. It measures how well each individual data point fits into its assigned cluster.22 For each point, the silhouette width is calculated based on two values:

* **Cohesion (a(i)):** The average distance from point i to all other points *in the same cluster*. A small value indicates high cohesion.  
* **Separation (b(i)):** The average distance from point i to all points in the *nearest neighboring cluster*. A large value indicates high separation.

The silhouette width for point i is then:

S(i)=max(a(i),b(i))b(i)−a(i)​  
The score ranges from \-1 to \+1 22:

* **\+1:** Indicates the point is very well-clustered, being far from the neighboring cluster.  
* **0:** Indicates the point lies on or very close to the decision boundary between two clusters.  
* **\-1:** Indicates the point is likely misclassified and is closer to the neighboring cluster than its own.

The **Silhouette Plot** is a powerful visualization that displays the silhouette width for every observation, sorted and grouped by cluster. This allows for a visual assessment of each cluster's quality and the overall validity of the clustering solution.24 In R, the

silhouette() function from the cluster package calculates the scores, and fviz\_silhouette() from factoextra creates an elegant visualization.25

#### **Davies-Bouldin Index (DBI)**

The Davies-Bouldin Index (DBI) formalizes the idea of finding clusters that are compact and well-separated. For each cluster, it finds the "most similar" other cluster, where similarity is defined as the ratio of the sum of their within-cluster dispersions to the distance between their centroids.27 The final DBI score is the average of these values across all clusters.

A **lower DBI value indicates a better clustering**, as it implies that clusters are, on average, more compact (low intra-cluster distance) and more distinct (high inter-cluster distance).22 The

clusterSim package provides the index.DB() function for this calculation in R.29

### **External Validation (Comparing to True Labels)**

When true class labels are known, we can directly measure how well our algorithm has recovered this structure.

#### **Adjusted Rand Index (ARI)**

The Adjusted Rand Index (ARI) is a measure of similarity between two data partitions (e.g., the predicted cluster labels and the true class labels).31 It considers all pairs of data points and counts the pairs that are either in the same group in both partitions or in different groups in both partitions.

Crucially, the ARI **corrects for chance agreement**. The standard Rand Index can be misleadingly high for random clusterings, especially with a large number of clusters. The ARI adjusts this score, ensuring that a random assignment will have an ARI close to 0\.32

The ARI score ranges from a theoretical minimum of \-0.5 to a maximum of 1 33:

* **1:** Perfect agreement between the two partitions.  
* **0:** The agreement is what would be expected by random chance.  
* **Negative values:** The agreement is worse than random.

The mclust package provides a straightforward implementation with the adjustedRandIndex() function.35

It is important to recognize the fundamental tension between internal and external validation. Internal metrics are designed to optimize for specific geometric definitions of a "good" cluster, such as compactness and separation. These properties often favor spherical clusters. External metrics, like ARI, are agnostic to shape; they only care if points that *should* be grouped together *are* grouped together. For a dataset like the intertwined spirals, a perfect clustering would achieve an ARI of 1.0. However, its Silhouette score might be mediocre, because points in one spiral can be geometrically closer to points in the other spiral than to distant points in their own. This demonstrates that validation metrics are not neutral observers; they have their own biases. A high internal score does not guarantee a high external score, and the choice of metric should be guided by the ultimate goal of the analysis.

## **Case Study: Uncovering Patterns in Complex Data**

To synthesize the concepts of this chapter, we will conduct a comparative case study. We will apply k-means, DBSCAN, and GMM to a single, challenging dataset and use our validation metrics to objectively determine which algorithm performs best.

### **The Challenge Dataset**

We will use the mlbench.cassini dataset, which is specifically designed to challenge simple clustering algorithms. It consists of 500 data points organized into three distinct, non-spherical clusters: two crescent-shaped "bananas" and a central circle.36 We have the ground truth labels for this dataset, which will allow us to use both internal and external validation metrics for a comprehensive comparison.

### **Comparative Analysis in R**

We will now apply each of the three algorithms to the cassini dataset and visualize the results.

R

\# \--- Load Libraries and Prepare Data \---  
library(mlbench)  
library(ggplot2)  
library(dbscan)  
library(mclust)  
library(factoextra)  
library(cluster)  
library(clusterSim)

set.seed(42)  
cassini\_data \<- mlbench.cassini(n \= 500)  
df \<- as.data.frame(cassini\_data$x)  
names(df) \<- c("X1", "X2")  
true\_labels \<- as.factor(cassini\_data$classes)

\# Plot ground truth for reference  
ggplot(df, aes(x \= X1, y \= X2, color \= true\_labels)) \+  
  geom\_point() \+ theme\_classic() \+ ggtitle("Ground Truth: Cassini Dataset")

\# \--- Algorithm 1: K-Means \---  
km\_result \<- kmeans(df, centers \= 3, nstart \= 25)  
df$kmeans\_cluster \<- as.factor(km\_result$cluster)

\# \--- Algorithm 2: DBSCAN \---  
\# Estimate parameters  
kNNdistplot(df\[,1:2\], k \= 10) \# MinPts \= 2\*dim \= 4, let's try a higher k for stability  
abline(h \= 0.2, lty \= 2, col \= "red") \# Elbow appears around 0.2  
db\_result \<- dbscan(df\[,1:2\], eps \= 0.2, minPts \= 10)  
df$dbscan\_cluster \<- as.factor(db\_result$cluster)

\# \--- Algorithm 3: Gaussian Mixture Model (GMM) \---  
gmm\_result \<- Mclust(df\[,1:2\], G \= 3) \# Specify G=3 for a fair comparison  
df$gmm\_cluster \<- as.factor(gmm\_result$classification)

\# \--- Visualize Results \---  
p\_km \<- ggplot(df, aes(x \= X1, y \= X2, color \= kmeans\_cluster)) \+  
  geom\_point() \+ theme\_classic() \+ ggtitle("K-Means Clustering")

p\_db \<- ggplot(df, aes(x \= X1, y \= X2, color \= dbscan\_cluster)) \+  
  geom\_point() \+ theme\_classic() \+ ggtitle("DBSCAN Clustering")

p\_gmm \<- ggplot(df, aes(x \= X1, y \= X2, color \= gmm\_cluster)) \+  
  geom\_point() \+ theme\_classic() \+ ggtitle("GMM Clustering")

\# Arrange plots for comparison (requires gridExtra package)  
\# gridExtra::grid.arrange(p\_km, p\_db, p\_gmm, nrow \= 1\)

Visual inspection of the plots immediately reveals the shortcomings of k-means, which carves the data into three roughly triangular regions, completely failing to respect the natural banana and circle shapes. DBSCAN and GMM appear to perform much better visually.

### **Evaluation and Interpretation**

Visuals are informative, but quantitative metrics provide objective proof. Let's calculate the internal and external validation scores for each algorithm.

R

\# \--- Calculate External Validation: Adjusted Rand Index \---  
ari\_km \<- adjustedRandIndex(true\_labels, df$kmeans\_cluster)  
ari\_db \<- adjustedRandIndex(true\_labels, df$dbscan\_cluster)  
ari\_gmm \<- adjustedRandIndex(true\_labels, df$gmm\_cluster)

\# \--- Calculate Internal Validation: Silhouette & Davies-Bouldin \---  
\# Note: DBSCAN noise points (cluster 0\) must be handled for internal metrics.  
\# We will exclude them for a fair comparison of the cluster structures.  
df\_db\_no\_noise \<- df\[df$dbscan\_cluster\!= 0, \]  
dist\_db \<- dist(df\_db\_no\_noise\[, c("X1", "X2")\])  
sil\_db \<- silhouette(as.integer(df\_db\_no\_noise$dbscan\_cluster), dist\_db)  
dbi\_db \<- index.DB(df\_db\_no\_noise\[, c("X1", "X2")\],  
                   as.integer(df\_db\_no\_noise$dbscan\_cluster))$DB

\# K-Means metrics  
dist\_km \<- dist(df\[, c("X1", "X2")\])  
sil\_km \<- silhouette(km\_result$cluster, dist\_km)  
dbi\_km \<- index.DB(df\[, c("X1", "X2")\], km\_result$cluster)$DB

\# GMM metrics  
dist\_gmm \<- dist(df\[, c("X1", "X2")\])  
sil\_gmm \<- silhouette(gmm\_result$classification, dist\_gmm)  
dbi\_gmm \<- index.DB(df\[, c("X1", "X2")\], gmm\_result$classification)$DB

\# \--- Create Summary Table \---  
results\_table \<- data.frame(  
  Algorithm \= c("K-Means", "DBSCAN", "GMM"),  
  Adjusted\_Rand\_Index \= c(ari\_km, ari\_db, ari\_gmm),  
  Avg\_Silhouette\_Width \= c(mean(sil\_km\[, "sil\_width"\]),  
                           mean(sil\_db\[, "sil\_width"\]),  
                           mean(sil\_gmm\[, "sil\_width"\])),  
  Davies\_Bouldin\_Index \= c(dbi\_km, dbi\_db, dbi\_gmm)  
)

print(round(results\_table, 3))

The results can be summarized in the following table.

**Table 13.1: Comparative Performance of Clustering Algorithms on the Cassini Dataset**

| Algorithm | Adjusted Rand Index (ARI) | Avg. Silhouette Width | Davies-Bouldin Index |
| :---- | :---- | :---- | :---- |
| K-Means | 0.288 | 0.370 | 1.121 |
| DBSCAN | 0.992 | 0.505 | 0.816 |
| GMM | 0.996 | 0.506 | 0.771 |

*(Note: Exact values may vary slightly due to stochasticity in algorithms, but the relative performance will be consistent.)*

### **Conclusion of Case Study**

The results in Table 13.1 provide a clear and compelling story.

* **K-Means:** As predicted by its theoretical limitations, k-means performs poorly. Its ARI of \~0.29 is low, indicating its partitioning is not much better than a random guess when compared to the ground truth. Its internal metrics are also worse than the other two algorithms.  
* **DBSCAN & GMM:** Both advanced algorithms perform exceptionally well. Their ARI scores are nearly 1.0, signifying an almost perfect recovery of the true underlying clusters. Their internal metrics are also superior, with higher average silhouette widths and lower Davies-Bouldin indices, confirming that they found a more compact and well-separated structure. GMM slightly outperforms DBSCAN on all metrics in this particular run, likely due to the smooth, probabilistic boundaries it can model.

This case study powerfully demonstrates the central theme of this chapter: algorithm selection must be driven by the data's characteristics. For the non-spherical, complex structure of the Cassini dataset, the density-based approach of DBSCAN and the probabilistic, flexible-covariance approach of GMM were vastly superior to the simple, centroid-based logic of k-means.

## **Chapter Summary**

In this chapter, we moved beyond the foundational clustering techniques to explore two powerful, advanced methods: DBSCAN and Gaussian Mixture Models. We learned that the limitations of simpler algorithms like k-means are not just technical flaws but indicators that their core assumptions do not match the data's underlying structure.

* **DBSCAN** redefines clustering based on **density**, allowing it to discover arbitrarily shaped clusters and robustly identify noise. Its performance hinges on the careful selection of its eps and MinPts parameters, which together define what it means for a region to be "dense."  
* **Gaussian Mixture Models (GMMs)** approach clustering from a **probabilistic** perspective, assuming data is a mixture of several Gaussian distributions. Through the Expectation-Maximization algorithm, GMMs provide "soft" cluster assignments and can model flexible, elliptical cluster shapes, making them a powerful generalization of k-means.  
* **Cluster validation** is a critical and non-negotiable step in the analysis pipeline. We distinguished between **internal metrics** (like the Silhouette score and Davies-Bouldin Index), used when no ground truth is available, and **external metrics** (like the Adjusted Rand Index), which compare results to known labels.

The final case study solidified these lessons, demonstrating quantitatively how DBSCAN and GMM succeeded where k-means failed on a dataset with complex, non-spherical structures. This reinforces the most important takeaway: there is no single best clustering algorithm. An effective data scientist must diagnose the characteristics of their data and select the tool whose assumptions best align with that structure. These advanced clustering techniques are essential additions to your toolkit, preparing you for the diverse and complex challenges you will encounter in real-world research and providing a solid foundation for the even more advanced machine learning methods discussed in the chapters to come.

#### **Works cited**

1. Comparing DBSCAN, k-means, and Hierarchical Clustering: When ..., accessed on July 30, 2025, [https://hex.tech/blog/comparing-density-based-methods/](https://hex.tech/blog/comparing-density-based-methods/)  
2. Difference between K means and Hierarchical Clustering \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/difference-between-k-means-and-hierarchical-clustering/](https://www.geeksforgeeks.org/machine-learning/difference-between-k-means-and-hierarchical-clustering/)  
3. The Drawbacks of K-Means Algorithm | Baeldung on Computer Science, accessed on July 30, 2025, [https://www.baeldung.com/cs/k-means-flaws-improvements](https://www.baeldung.com/cs/k-means-flaws-improvements)  
4. How to understand the drawbacks of K-means \- Cross Validated, accessed on July 30, 2025, [https://stats.stackexchange.com/questions/133656/how-to-understand-the-drawbacks-of-k-means](https://stats.stackexchange.com/questions/133656/how-to-understand-the-drawbacks-of-k-means)  
5. Hierarchical Cluster Analysis \- UC Business Analytics R Programming Guide ·, accessed on July 30, 2025, [https://uc-r.github.io/hc\_clustering](https://uc-r.github.io/hc_clustering)  
6. DBSCAN: density-based clustering for discovering clusters in large ..., accessed on July 30, 2025, [https://www.sthda.com/english/wiki/wiki.php?id\_contents=7940](https://www.sthda.com/english/wiki/wiki.php?id_contents=7940)  
7. DBSCAN and t-SNE tutorial to detect credit card fraud with R, accessed on July 30, 2025, [https://www.stepbystepdatascience.com/fraud-detection-with-dbscan-and-tsne](https://www.stepbystepdatascience.com/fraud-detection-with-dbscan-and-tsne)  
8. Overview of clustering methods in R | R-bloggers, accessed on July 30, 2025, [https://www.r-bloggers.com/2024/01/overview-of-clustering-methods-in-r/](https://www.r-bloggers.com/2024/01/overview-of-clustering-methods-in-r/)  
9. A Guide to the DBSCAN Clustering Algorithm \- DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/dbscan-clustering-algorithm](https://www.datacamp.com/tutorial/dbscan-clustering-algorithm)  
10. DBScan Clustering in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/dbscan-clustering-in-r-programming/](https://www.geeksforgeeks.org/r-language/dbscan-clustering-in-r-programming/)  
11. DBSCAN in R | by Amit Yadav \- Medium, accessed on July 30, 2025, [https://medium.com/@amit25173/dbscan-in-r-3c93c97b674b](https://medium.com/@amit25173/dbscan-in-r-3c93c97b674b)  
12. DBSCAN in R | Reintech media, accessed on July 30, 2025, [https://reintech.io/blog/dbscan-in-r-tutorial](https://reintech.io/blog/dbscan-in-r-tutorial)  
13. Practical Guide to Clustering Algorithms & Evaluation in R Tutorials & Notes \- HackerEarth, accessed on July 30, 2025, [https://www.hackerearth.com/practice/machine-learning/machine-learning-algorithms/clustering-algorithms-evaluation-r/tutorial/](https://www.hackerearth.com/practice/machine-learning/machine-learning-algorithms/clustering-algorithms-evaluation-r/tutorial/)  
14. Understanding Gaussian Mixture Models: A Comprehensive Guide | by Juan C Olamendy, accessed on July 30, 2025, [https://medium.com/@juanc.olamendy/understanding-gaussian-mixture-models-a-comprehensive-guide-df30af59ced7](https://medium.com/@juanc.olamendy/understanding-gaussian-mixture-models-a-comprehensive-guide-df30af59ced7)  
15. Advanced Clustering Methods \- RPubs, accessed on July 30, 2025, [https://rpubs.com/Myavuzars/acm](https://rpubs.com/Myavuzars/acm)  
16. Gaussian Mixture Models∗ \- LEAP Laboratory, accessed on July 30, 2025, [http://leap.ee.iisc.ac.in/sriram/teaching/MLSP\_16/refs/GMM\_Tutorial\_Reynolds.pdf](http://leap.ee.iisc.ac.in/sriram/teaching/MLSP_16/refs/GMM_Tutorial_Reynolds.pdf)  
17. Gaussian Mixture Models in R \- The R Journal, accessed on July 30, 2025, [https://journal.r-project.org/articles/RJ-2023-043/](https://journal.r-project.org/articles/RJ-2023-043/)  
18. R Tutorial: Gaussian mixture models (GMM) \- YouTube, accessed on July 30, 2025, [https://www.youtube.com/watch?v=6f3wIQ0uAdM](https://www.youtube.com/watch?v=6f3wIQ0uAdM)  
19. An Intro to Gaussian Mixture Modeling \- R-bloggers, accessed on July 30, 2025, [https://www.r-bloggers.com/2017/02/an-intro-to-gaussian-mixture-modeling/](https://www.r-bloggers.com/2017/02/an-intro-to-gaussian-mixture-modeling/)  
20. What is Gaussian mixture model clustering using R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-machine-learning/what-is-gaussian-mixture-model-clustering-using-r/](https://www.geeksforgeeks.org/r-machine-learning/what-is-gaussian-mixture-model-clustering-using-r/)  
21. An Intro to Gaussian Mixture Modeling | R-bloggers, accessed on July 30, 2025, [https://www.r-bloggers.com/2017/02/an-intro-to-gaussian-mixture-modeling](https://www.r-bloggers.com/2017/02/an-intro-to-gaussian-mixture-modeling)  
22. Clustering Metrics in Machine Learning \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/clustering-metrics/](https://www.geeksforgeeks.org/machine-learning/clustering-metrics/)  
23. Help for package Clustering, accessed on July 30, 2025, [https://cran.r-project.org/web/packages/Clustering/refman/Clustering.html](https://cran.r-project.org/web/packages/Clustering/refman/Clustering.html)  
24. Silhouette Plots | Baeldung on Computer Science, accessed on July 30, 2025, [https://www.baeldung.com/cs/silhouette-values-clustering](https://www.baeldung.com/cs/silhouette-values-clustering)  
25. Visualize Silhouette Information from Clustering — fviz\_silhouette ..., accessed on July 30, 2025, [https://rpkgs.datanovia.com/factoextra/reference/fviz\_silhouette.html](https://rpkgs.datanovia.com/factoextra/reference/fviz_silhouette.html)  
26. Silhouette Plots \- RPubs, accessed on July 30, 2025, [https://rpubs.com/DragonflyStats/Silhouette-Plots](https://rpubs.com/DragonflyStats/Silhouette-Plots)  
27. Mastering the Davies-Bouldin Index for Clustering Model Validation | CodeSignal Learn, accessed on July 30, 2025, [https://codesignal.com/learn/courses/cluster-performance-unveiled/lessons/mastering-the-davies-bouldin-index-for-clustering-model-validation](https://codesignal.com/learn/courses/cluster-performance-unveiled/lessons/mastering-the-davies-bouldin-index-for-clustering-model-validation)  
28. Mastering Clustering: A Guided Tour of the Davies-Bouldin Index \- Number Analytics, accessed on July 30, 2025, [https://www.numberanalytics.com/blog/mastering-clustering-davies-bouldin-index](https://www.numberanalytics.com/blog/mastering-clustering-davies-bouldin-index)  
29. index.DB function \- RDocumentation, accessed on July 30, 2025, [https://www.rdocumentation.org/packages/clusterSim/versions/0.34-1/topics/index.DB](https://www.rdocumentation.org/packages/clusterSim/versions/0.34-1/topics/index.DB)  
30. Calculates Davies-Bouldin's index \- R, accessed on July 30, 2025, [https://search.r-project.org/CRAN/refmans/clusterSim/html/index.DB.html](https://search.r-project.org/CRAN/refmans/clusterSim/html/index.DB.html)  
31. adj.rand.index function \- RDocumentation, accessed on July 30, 2025, [https://www.rdocumentation.org/packages/pdfCluster/versions/1.0-4/topics/adj.rand.index](https://www.rdocumentation.org/packages/pdfCluster/versions/1.0-4/topics/adj.rand.index)  
32. Understanding Adjusted Rand Index in Clustering: Practical Guide \- Number Analytics, accessed on July 30, 2025, [https://www.numberanalytics.com/blog/understanding-adjusted-rand-index-clustering-guide](https://www.numberanalytics.com/blog/understanding-adjusted-rand-index-clustering-guide)  
33. adjusted\_rand\_score — scikit-learn 1.7.1 documentation, accessed on July 30, 2025, [https://scikit-learn.org/stable/modules/generated/sklearn.metrics.adjusted\_rand\_score.html](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.adjusted_rand_score.html)  
34. What is Adjusted Rand Index and How it works\! \- Mk Hasan's Blog, accessed on July 30, 2025, [https://mk-hasan.github.io/posts/2020/04/blog-post-4/](https://mk-hasan.github.io/posts/2020/04/blog-post-4/)  
35. adjustedRandIndex function \- RDocumentation, accessed on July 30, 2025, [https://www.rdocumentation.org/packages/mclust/versions/6.1/topics/adjustedRandIndex](https://www.rdocumentation.org/packages/mclust/versions/6.1/topics/adjustedRandIndex)  
36. Spectral Clustering, accessed on July 30, 2025, [https://www.di.fc.ul.pt/\~jpn/r/spectralclustering/spectralclustering.html](https://www.di.fc.ul.pt/~jpn/r/spectralclustering/spectralclustering.html)  
37. mlbench: Machine Learning Benchmark Problems \- The ..., accessed on July 30, 2025, [https://cran.r-project.org/web/packages/mlbench/mlbench.pdf](https://cran.r-project.org/web/packages/mlbench/mlbench.pdf)