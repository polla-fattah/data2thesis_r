---
title: ANOVA and Regression
slug: chapter07
order: 065
published: false
abstract: >
    Building on the two-group comparisons of the previous chapter, this chapter introduces ANOVA for comparing many groups, followed by linear and logistic regression for modelling relationships between variables. Readers will learn to fit, interpret, and check these models, culminating in a case study predicting survival on the Titanic.
---



## **Introduction: Beyond Basic Comparisons**

In the preceding chapters, we established the foundational principles of statistical inference, culminating in Chapter 6 with hypothesis tests for comparing two groups, such as the t-test. These methods are powerful for answering binary questions: Does a new drug perform better than a placebo? Is there a difference in mean test scores between two teaching methods? However, research questions are often more complex and involve comparisons across multiple groups or seek to understand the relationships between several variables simultaneously. For instance, a researcher might need to ask, "How does the mean crop yield differ across *three* different fertilizer types?" A simple t-test is insufficient here, as performing multiple pairwise comparisons (Fertilizer A vs. B, B vs. C, A vs. C) dramatically increases the probability of making a Type I error—falsely concluding a difference exists when it does not.1

To address these more sophisticated questions, we must move to a more powerful and flexible set of tools. This chapter introduces three cornerstone techniques of modern statistical analysis: Analysis of Variance (ANOVA), Linear Regression, and Logistic Regression. While often taught as distinct methods, they are deeply connected under a unifying statistical framework known as the **General Linear Model (GLM)**. This framework posits that an outcome variable can be modeled as a linear combination of predictor variables plus an error term. The t-test, ANOVA, and linear regression are all special cases of this model. Logistic regression, in turn, is a key example of a *generalized* linear model, which extends the GLM framework to handle outcomes that are not continuous, such as binary (yes/no) data.2 By understanding this common theoretical backbone, you will see that you are not learning a disparate collection of tests, but rather different applications of a single, elegant statistical idea. This chapter will guide you through the theory, practical R implementation, and nuanced interpretation of these essential techniques, empowering you to move from simple group comparisons to robust predictive modeling.

## **Analysis of Variance (ANOVA): Comparing Means Across Multiple Groups**

Analysis of Variance, or ANOVA, is a statistical method used to test for significant differences between the means of three or more independent groups.3 It extends the two-sample t-test to scenarios with multiple categories, allowing researchers to analyze the effect of a single categorical independent variable (or "factor") on a continuous dependent variable without inflating the Type I error rate.4

### **The Core Idea of ANOVA: Partitioning Variance**

The name "Analysis of Variance" can seem counterintuitive, as the primary goal of the test is to make an inference about population *means*. The method achieves this, however, by systematically analyzing, or partitioning, the total variability in a dataset.6 The core principle of ANOVA is to determine whether the differences observed between the sample means are large enough to be considered statistically significant, relative to the natural variation observed within each group.6

Imagine we have data on crop yields for three different fertilizer treatments. The total variation in crop yield across all samples can be broken down into two components 7:

1. **Between-Group Variance (SSbetween​):** This component measures the variation *between* the mean yields of the different fertilizer groups. It represents the "signal" in our data—the systematic effect of the fertilizer type. A large between-group variance suggests that the fertilizers have different effects on the mean yield.6  
2. **Within-Group Variance (SSwithin​):** This component measures the variation of individual crop yields *within* each fertilizer group. It represents the random, unexplained variation, or "noise," in the data—the natural variability that occurs even when all plants receive the same treatment. This is also known as the residual variance.4

ANOVA calculates a test statistic, the **F-statistic**, which is fundamentally a ratio of the signal to the noise. It is calculated by dividing the Mean Square Between groups (MSbetween​) by the Mean Square Within groups (MSwithin​).6 The Mean Square is simply the Sum of Squares (

SS) divided by its corresponding degrees of freedom.

F=Variance within groupsVariance between groups​=MSwithin​MSbetween​​  
A large F-statistic (F\>1) indicates that the variation between the groups is greater than the random variation within the groups. This suggests that the observed differences in the sample means are unlikely to be due to chance alone, leading us to reject the null hypothesis that all group means are equal.4

### **One-Way ANOVA in Practice**

A one-way ANOVA (also known as a one-factor ANOVA) is used when we have one categorical independent variable and one continuous dependent variable.5

#### **Hypotheses**

The statistical hypotheses for a one-way ANOVA are 4:

* Null Hypothesis (H0​): The population means of all groups are equal.  
  H0​:μ1​=μ2​=⋯=μk​  
* Alternative Hypothesis (H1​): At least one population mean is different from the others.  
  H1​:At least one μi​ is different.

It is crucial to note that a significant ANOVA test tells us that *at least one* group is different, but it does not specify *which* groups differ from each other. To answer that question, we must perform post-hoc tests, which will be discussed later.1

#### **R Implementation**

We will use the built-in R dataset PlantGrowth, which contains the dried weight of plants under a control condition and two different treatment conditions (trt1, trt2).4

First, let's load and inspect the data. It is good practice to ensure the grouping variable is a factor and that its levels are ordered logically if necessary.

R

\# Load the dataset  
data("PlantGrowth")

\# Inspect the structure  
str(PlantGrowth)

\# Ensure 'group' is a factor with a specific order  
PlantGrowth$group \<- ordered(PlantGrowth$group, levels \= c("ctrl", "trt1", "trt2"))

\# Get summary statistics by group using dplyr  
library(dplyr)  
PlantGrowth %\>%  
  group\_by(group) %\>%  
  summarise(  
    count \= n(),  
    mean \= mean(weight, na.rm \= TRUE),  
    sd \= sd(weight, na.rm \= TRUE)  
  )

Next, we visualize the data using a boxplot to get an initial sense of the differences between the groups.

R

\# Visualize with a boxplot  
library(ggplot2)  
ggplot(PlantGrowth, aes(x \= group, y \= weight, fill \= group)) \+  
  geom\_boxplot() \+  
  labs(title \= "Plant Weight by Treatment Group",  
       x \= "Treatment Group",  
       y \= "Dried Weight") \+  
  theme\_minimal()

Now, we perform the one-way ANOVA using the aov() function, which stands for "analysis of variance."

R

\# Perform one-way ANOVA  
res.aov \<- aov(weight \~ group, data \= PlantGrowth)

\# View the summary of the ANOVA table  
summary(res.aov)

#### **Interpreting the ANOVA Table**

The summary() function produces the ANOVA table, which is the core output of the analysis.4

|  | Df | Sum Sq | Mean Sq | F value | Pr(\>F) |
| :---- | :---- | :---- | :---- | :---- | :---- |
| group | 2 | 3.766 | 1.8832 | 4.846 | 0.0159 \* |
| Residuals | 27 | 10.492 | 0.3886 |  |  |
| \--- |  |  |  |  |  |
| Signif. codes: 0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1 |  |  |  |  |  |

**Table 7.1: One-Way ANOVA Summary for PlantGrowth Data**

Let's break down each column of this table:

* **Df (Degrees of Freedom):** For group, this is the number of groups minus 1 (k−1=3−1=2). For Residuals, it is the total number of observations minus the number of groups (N−k=30−3=27).  
* **Sum Sq (Sum of Squares):** This shows the partitioned variance. group corresponds to SSbetween​ (3.766), and Residuals corresponds to SSwithin​ (10.492).  
* **Mean Sq (Mean Square):** This is the Sum of Squares divided by the Degrees of Freedom (SS/Df). It represents the average variation for each component. MSbetween​=3.766/2=1.8832 and MSwithin​=10.492/27=0.3886.  
* **F value:** This is the F-statistic, calculated as MSbetween​/MSwithin​ (1.8832/0.3886=4.846).  
* **Pr(\>F):** This is the p-value associated with the F-statistic. It tells us the probability of observing an F-statistic as large as 4.846 (or larger) if the null hypothesis were true. Here, the p-value is 0.0159.

Since our p-value (0.0159) is less than the conventional significance level of 0.05, we reject the null hypothesis. We conclude that there is a statistically significant difference in the mean dried weight of plants among the three treatment groups.9

### **Checking ANOVA Assumptions**

The validity of the p-value from an ANOVA test depends on three key assumptions about the data.10 These assumptions relate to the model's residuals (

ϵik​), which are the differences between the observed data points and their respective group means.

1. **Independence of Observations:** This assumption means that the observations in each group are independent of one another. This is primarily a matter of study design and data collection methodology; it cannot be easily tested with diagnostic plots. For example, repeated measurements on the same plant would violate this assumption.6  
2. **Normality of Residuals:** The residuals for each group should be approximately normally distributed. ANOVA is considered robust to minor violations of this assumption, especially with larger sample sizes.10 We can check this by examining a Q-Q (Quantile-Quantile) plot of the residuals and by performing a formal statistical test like the Shapiro-Wilk test.  
3. **Homogeneity of Variances (Homoscedasticity):** The variance of the residuals should be equal across all groups. This means the spread of data within each group should be roughly the same.11 This can be checked visually with a Residuals vs. Fitted plot and formally with Levene's test.

Let's check these assumptions for our PlantGrowth model in R.

R

\# 1\. Check Normality of Residuals  
\# Q-Q plot  
plot(res.aov, 2)

\# Shapiro-Wilk test on residuals  
aov\_residuals \<- residuals(object \= res.aov)  
shapiro.test(x \= aov\_residuals)

\# 2\. Check Homogeneity of Variances  
\# Residuals vs. Fitted plot  
plot(res.aov, 1)

\# Levene's test  
library(car)  
leveneTest(weight \~ group, data \= PlantGrowth)

For our model, the Q-Q plot shows points falling closely along the diagonal line, and the Shapiro-Wilk test yields a non-significant p-value (p\>0.05), supporting the normality assumption.5 The Residuals vs. Fitted plot shows a random scatter of points around the zero line with no discernible pattern, and Levene's test is non-significant (

p\>0.05), supporting the assumption of homogeneity of variances.5 If the homogeneity assumption were violated, a Welch one-way test (

oneway.test()) would be a suitable alternative as it does not assume equal variances.5

### **Post-Hoc Analysis: Identifying Specific Differences**

Our significant ANOVA result (p=0.0159) tells us that the group means are not all equal, but it doesn't tell us which specific groups are different from one another. Is trt1 different from control? Is trt2 different from trt1? To answer these questions, we need to perform post-hoc ("after this") tests for multiple pairwise comparisons.1

The most common and appropriate post-hoc test following a one-way ANOVA is **Tukey's Honestly Significant Difference (HSD) test**. This test compares all possible pairs of means while controlling the overall Type I error rate for the entire set of comparisons.15

We can perform Tukey's HSD test in R using the TukeyHSD() function on our fitted aov object.

R

\# Perform Tukey's HSD test  
tukey.results \<- TukeyHSD(res.aov)

\# View the results  
print(tukey.results)

The output provides a table of pairwise comparisons:

  Tukey multiple comparisons of means  
    95% family-wise confidence level

Fit: aov(formula \= weight \~ group, data \= PlantGrowth)

$group  
            diff        lwr       upr     p adj  
trt1-ctrl \-0.371 \-1.0622161 0.3202161 0.3908711  
trt2-ctrl  0.494 \-0.1972161 1.1852161 0.1979960  
trt2-trt1  0.865  0.1737839 1.5562161 0.0120064

* **Interpretation:** The key column is p adj, which gives the p-value for each pairwise comparison, adjusted for multiple testing.  
  * The comparison between trt1 and ctrl is not significant (p=0.391).  
  * The comparison between trt2 and ctrl is not significant (p=0.198).  
  * The comparison between trt2 and trt1 **is significant** (p=0.012).

Our final conclusion is that only the second treatment (trt2) produced a significantly different mean plant weight compared to the first treatment (trt1).

For publication-quality reports, it is highly effective to visualize these post-hoc results directly on the plot. Packages like ggpubr and rstatix provide convenient functions for this.6

### **Two-Way ANOVA: Analyzing Multiple Factors**

Research is often more complex than examining a single factor. A **two-way ANOVA** allows us to simultaneously evaluate the effect of two independent categorical variables (factors) on a continuous dependent variable.17 This approach is more efficient than running separate one-way ANOVAs and, more importantly, it allows us to test for an

**interaction effect** between the two factors.7

An interaction effect occurs when the effect of one factor on the dependent variable depends on the level of the second factor. For example, a new drug might be effective for one gender but not the other. Analyzing only the main effect of the drug or the main effect of gender would miss this crucial nuance.

#### **R Implementation and Interpretation**

We will use the ToothGrowth dataset, which examines the effect of vitamin C on tooth length in guinea pigs. The two factors are:

* supp: The delivery method (Orange Juice 'OJ' or Ascorbic Acid 'VC').  
* dose: The dose of vitamin C (0.5, 1, or 2 mg/day).

First, we prepare the data, ensuring dose is treated as a factor.

R

\# Load the data  
data("ToothGrowth")

\# Convert dose to a factor  
ToothGrowth$dose \<- as.factor(ToothGrowth$dose)  
str(ToothGrowth)

To visualize a potential interaction, we can use an interaction plot, which displays the mean of the response variable for each combination of factor levels.

R

\# Interaction plot  
interaction.plot(x.factor \= ToothGrowth$dose,  
                 trace.factor \= ToothGrowth$supp,  
                 response \= ToothGrowth$len,  
                 fun \= mean,  
                 type \= "b",  
                 xlab \= "Dose (mg/day)",  
                 ylab \= "Tooth Length",  
                 col \= c("blue", "red"),  
                 pch \= c(19, 17),  
                 main \= "Interaction Plot of Dose and Supplement Type")  
legend("topleft", legend \= c("Orange Juice", "Ascorbic Acid"),  
       col \= c("blue", "red"), lty \= 1, pch \= c(19, 17))

Non-parallel lines in an interaction plot suggest a possible interaction effect. In our plot, the lines are not parallel; the effect of the supplement type appears to differ across dose levels.

To test this formally, we fit a two-way ANOVA model. The syntax supp \* dose in the aov() formula tells R to include the main effect of supp, the main effect of dose, and the interaction effect between them (supp:dose).17

R

\# Fit the two-way ANOVA model with interaction  
res.aov2 \<- aov(len \~ supp \* dose, data \= ToothGrowth)  
summary(res.aov2)

The interpretation strategy for a two-way ANOVA is hierarchical:

1. **Examine the Interaction Effect First:** Look at the p-value for the interaction term (supp:dose). In our results, this term is significant (p\<0.05).  
2. **Interpret Accordingly:**  
   * **If the interaction is significant:** The main effects of supp and dose should not be interpreted in isolation. The significant interaction tells us that the effect of the supplement type *depends on* the dose level (and vice-versa). The analysis should proceed by examining the *simple main effects*—that is, the effect of one factor at each level of the other factor.6 For example, one could run a one-way ANOVA on  
     supp for each dose level.  
   * **If the interaction is not significant:** You can remove the interaction term and re-run an *additive model* (len \~ supp \+ dose). In that case, you would interpret the main effects directly, as the effect of each factor is consistent across the levels of the other factor.18

Given our significant interaction, we conclude that the way vitamin C is delivered (orange juice vs. ascorbic acid) has a different impact on tooth growth depending on the dosage level.

## **Linear Regression: Modeling Continuous Outcomes**

While ANOVA is excellent for comparing group means, many research questions focus on modeling the relationship between two or more continuous variables. **Linear regression** is a statistical method used to model the relationship between a continuous dependent (or outcome) variable and one or more independent (or predictor) variables.20 The goal is to find the "line of best fit" that describes how the dependent variable changes as the independent variables change.21

### **The Mechanics of Linear Models**

The equation for a simple linear regression model, with one predictor variable, is:

y=β0​+β1​x+ϵ  
where:

* y is the dependent variable.  
* x is the independent variable.  
* β0​ is the **intercept**, representing the predicted value of y when x=0.23  
* β1​ is the **slope**, representing the average change in y for a one-unit increase in x.23  
* ϵ is the **error term** or **residual**, representing the difference between the observed value of y and the value predicted by the model. It captures all the variability in y that is not explained by x.23

The model finds the optimal values for β0​ and β1​ using the method of **Ordinary Least Squares (OLS)**. This method identifies the unique line that minimizes the sum of the squared residuals (RSS)—the sum of the squared vertical distances between each data point and the regression line.21

### **Simple and Multiple Linear Regression in R**

The workhorse function for fitting linear models in R is lm().24 We will use the

marketing dataset from the datarium package, which contains data on sales figures based on advertising budgets for YouTube, Facebook, and newspaper ads.26

#### **Simple Linear Regression**

Let's first model the relationship between sales and a single predictor, youtube advertising budget.

R

\# Load the data  
data("marketing", package \= "datarium")

\# Fit a simple linear regression model  
simple.model \<- lm(sales \~ youtube, data \= marketing)  
summary(simple.model)

The summary() output will provide the estimated coefficients. The coefficient for youtube in this model represents the direct association between YouTube ad spending and sales, without considering any other factors.

#### **Multiple Linear Regression**

Now, let's build a **multiple linear regression** model that includes all three advertising platforms as predictors.26

R

\# Fit a multiple linear regression model  
multiple.model \<- lm(sales \~ youtube \+ facebook \+ newspaper, data \= marketing)  
summary(multiple.model)

A crucial point of understanding is how the interpretation of a coefficient changes between simple and multiple regression. In the multiple model, the coefficient for youtube now represents the expected change in sales for a one-unit increase in youtube budget, *while holding the budgets for facebook and newspaper constant*.24 This ability to "statistically control for" or "adjust for" the effects of other variables is the primary strength of multiple regression. Comparing the

youtube coefficient from simple.model to that in multiple.model will reveal that its value has changed, because the second model has now accounted for the overlapping influence of the other advertising channels.

### **Deep Dive into Model Interpretation: The summary() Output**

The output from summary(lm\_model) is information-dense and provides a complete assessment of the model. Understanding each component is essential for any researcher.27 Let's analyze the output for a refined multiple regression model where we drop the non-significant

newspaper term.

R

\# Refined multiple model  
model.final \<- lm(sales \~ youtube \+ facebook, data \= marketing)  
summary(model.final)

|  |  |
| :---- | :---- |
| **Call:** (1) | lm(formula \= sales \~ youtube \+ facebook, data \= marketing) |
| **Residuals:** (2) | Min: \-9.69, 1Q: \-1.03, Median: 0.22, 3Q: 1.20, Max: 3.42 |
| **Coefficients:** (3) |  |
|  | **Estimate** |
| (Intercept) | 3.50532 |
| youtube | 0.04575 |
| facebook | 0.18799 |
| \--- |  |
| Signif. codes: 0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1 |  |
| **Residual standard error:** (4) | 2.018 on 197 degrees of freedom |
| **Multiple R-squared:** (5) | 0.8972, **Adjusted R-squared:** 0.8962 |
| **F-statistic:** (6) | 859.6 on 2 and 197 DF, p-value: \< 2.2e-16 |

**Table 7.2: Annotated summary(lm()) Output**

1. **Call:** Confirms the formula and data used to build the model.  
2. **Residuals:** A five-number summary of the model's residuals. A median close to zero suggests that the residuals are symmetrically distributed, which is a good sign.28  
3. **Coefficients Table:** This is the core of the output.  
   * **Estimate:** The estimated values for the intercept (β0​) and slopes (β1​, β2​, etc.). Here, the model equation is: sales=3.505+0.046×youtube+0.188×facebook.  
   * **Std. Error:** The standard error of the coefficient estimates. It measures the average amount that the coefficient estimates vary from the actual average value of our response variable, indicating the precision of the estimate.28  
   * **t value:** The test statistic for each coefficient (Estimate / Std. Error). It measures how many standard deviations the coefficient is from zero.27  
   * **Pr(\>|t|):** The p-value for the t-test of each coefficient. A small p-value (\< 0.05) indicates that the predictor is significantly related to the outcome variable.23 Here,  
     youtube and facebook are both highly significant predictors of sales.  
4. **Residual Standard Error (RSE):** The typical deviation of the observed values from the fitted regression line, measured in the units of the outcome variable. Here, our model's predictions are, on average, off by about 2.018 units (i.e., $2,018 in sales).24  
5. **Multiple R-squared and Adjusted R-squared:** The proportion of the variance in the dependent variable that can be predicted from the independent variables. The Adjusted R-squared is preferred in multiple regression because it penalizes the model for including predictors that do not improve the model fit.23 Here, our model explains approximately 89.6% of the variance in sales.  
6. **F-statistic:** A global test of the model's significance. It tests the null hypothesis that all model coefficients (excluding the intercept) are zero. A significant p-value (as seen here, \< 2.2e-16) indicates that the model has predictive power and is statistically significant overall.23

### **Essential Model Diagnostics**

The results of a linear regression are only reliable if the model's underlying assumptions are met.33 R provides a standard set of four diagnostic plots to assess these assumptions, which can be generated by applying the

plot() function to the lm object.36

R

\# Generate diagnostic plots  
par(mfrow \= c(2, 2)) \# Arrange plots in a 2x2 grid  
plot(model.final)  
par(mfrow \= c(1, 1)) \# Reset plotting device

The four key assumptions and their corresponding diagnostic plots are:

1. **Linearity:** The relationship between the predictors and the outcome variable should be linear.  
   * **Check:** The **Residuals vs. Fitted** plot. A horizontal red line with no distinct pattern (like a curve) suggests the linearity assumption holds.  
2. **Independence of Errors:** The residuals should be independent of one another. This is especially important for time-series data where autocorrelation can be an issue. This assumption is mainly addressed through study design.  
3. **Homoscedasticity (Constant Variance):** The variance of the residuals should be constant across all levels of the predictor variables.  
   * **Check:** The **Scale-Location** plot (and also the Residuals vs. Fitted plot). The points should be randomly scattered, and the red line should be roughly horizontal. A funnel shape (fanning out) indicates heteroscedasticity, meaning the prediction error changes for different fitted values.38  
4. **Normality of Residuals:** The residuals should be normally distributed.  
   * **Check:** The **Normal Q-Q** plot. The points should fall approximately along the 45-degree dashed line. Deviations at the tails are common, but severe, systematic deviations suggest a violation.

A fifth plot, **Residuals vs. Leverage**, helps identify influential outliers—data points that have an outsized effect on the regression results. Points that fall outside the dashed Cook's distance lines are potentially influential and warrant further investigation.

## **Logistic Regression: Modeling Binary Outcomes**

Our discussion so far has focused on modeling continuous outcome variables. However, many research questions involve binary or dichotomous outcomes: Did a patient survive (yes/no)? Did a customer churn (yes/no)? Did a student pass an exam (pass/fail)? For these scenarios, linear regression is inappropriate. **Logistic regression** is a powerful technique specifically designed to model the relationship between one or more predictor variables and a binary outcome.39

### **From Linear to Logistic: The Logit Transformation**

Applying a linear regression model directly to a 0/1 outcome variable presents two major problems:

1. The model can predict probabilities less than 0 or greater than 1, which are nonsensical.39  
2. The assumption of homoscedasticity is violated, as the variance of a binary variable depends on its mean.

Logistic regression solves these problems by modeling the *probability* of the outcome through a transformation. The core idea is to convert the bounded probability scale (0 to 1\) to an unbounded scale using the concept of **log-odds**.40

1. **Probability (p):** The likelihood of the event occurring, ranging from 0 to 1\.  
2. **Odds:** The ratio of the probability of the event occurring to the probability of it not occurring. Odds=p/(1−p). Odds range from 0 to ∞.  
3. **Log-Odds (Logit):** The natural logarithm of the odds. Logit(p)=ln(p/(1−p)). The log-odds are unbounded, ranging from −∞ to \+∞.

By modeling the log-odds as a linear combination of the predictors, we can use a linear model framework:

ln(1−pp​)=β0​+β1​x1​+⋯+βk​xk​

To get back to the probability scale, we use the inverse of the logit transformation, which is the sigmoid (or logistic) function:

p=1+e−(β0​+β1​x1​+⋯+βk​xk​)1​

This function produces the characteristic "S"-shaped curve, ensuring that the predicted probability p is always between 0 and 1.44

### **Building and Interpreting a Logistic Model in R**

In R, logistic regression is performed using the glm() (generalized linear model) function, specifying family \= "binomial" to indicate a binary outcome.47

The most critical skill in logistic regression is interpreting the model coefficients. The raw coefficients produced by glm() are on the log-odds scale and are not directly intuitive. To make them interpretable, we must exponentiate them (exp()) to convert them into **Odds Ratios (ORs)**.43

The interpretation of an Odds Ratio is as follows:

* **OR \> 1:** For a one-unit increase in the predictor, the odds of the outcome occurring (being in class '1') are multiplied by the OR. This indicates a positive association.  
* **OR \< 1:** For a one-unit increase in the predictor, the odds of the outcome occurring are multiplied by the OR. This indicates a negative association.  
* **OR \= 1:** The predictor has no effect on the odds of the outcome.

For example, if a predictor has an OR of 1.5, a one-unit increase in that predictor is associated with a 50% increase in the odds of the outcome. If a predictor has an OR of 0.8, a one-unit increase is associated with a 20% decrease in the odds of the outcome.

### **Checking Logistic Regression Assumptions**

While logistic regression is more flexible than linear regression, it still relies on several key assumptions 55:

1. **Binary Outcome:** The dependent variable must be binary.  
2. **Independence of Observations:** The observations must be independent.  
3. **Linearity in the Logit:** There must be a linear relationship between any continuous independent variables and the logit of the outcome variable.  
4. **No Severe Multicollinearity:** The independent variables should not be highly correlated with each other.

The linearity-in-the-logit assumption can be checked by plotting the continuous predictors against their logit values.57 Multicollinearity can be assessed using the Variance Inflation Factor (VIF) from the

car package, with a common rule of thumb being that VIF values above 5 or 10 are problematic.55

### **Evaluating Classification Performance**

After building a model, we need to evaluate how well it classifies new data. This involves making predictions and comparing them to the actual outcomes.

#### **Prediction and the Confusion Matrix**

We can use predict(model, newdata, type \= "response") to get the predicted probabilities for new data. To make a class prediction (0 or 1), we apply a **classification threshold**, typically 0.5. If the predicted probability is ≥0.5, we classify the outcome as 1; otherwise, we classify it as 0\.

The **confusion matrix** is a table that summarizes the performance of a classification model by cross-tabulating the predicted classes against the actual classes.58 It contains four key values:

* **True Positives (TP):** The model correctly predicts the positive class.  
* **True Negatives (TN):** The model correctly predicts the negative class.  
* **False Positives (FP):** The model incorrectly predicts the positive class (a "Type I error").  
* **False Negatives (FN):** The model incorrectly predicts the negative class (a "Type II error").

From these values, we can calculate several important performance metrics:

* **Accuracy:** The proportion of total correct predictions. Accuracy=(TP+TN)/(TP+TN+FP+FN).  
* **Sensitivity (Recall or True Positive Rate):** The proportion of actual positives that were correctly identified. Sensitivity=TP/(TP+FN).  
* **Specificity (True Negative Rate):** The proportion of actual negatives that were correctly identified. Specificity=TN/(TN+FP).

While accuracy is intuitive, it can be a highly misleading metric, especially on **imbalanced datasets**. For example, in a medical test for a rare disease affecting 1% of the population, a model that always predicts "no disease" will have 99% accuracy. However, its sensitivity would be 0%, making it completely useless for its intended purpose of identifying sick patients. For this reason, sensitivity and specificity often provide a more nuanced and meaningful assessment of a model's performance.

#### **The ROC Curve and AUC**

The choice of a 0.5 classification threshold is arbitrary. A model's performance can be evaluated across *all* possible thresholds using a **Receiver Operating Characteristic (ROC) curve**. The ROC curve plots the True Positive Rate (Sensitivity) against the False Positive Rate (1 \- Specificity) at various threshold settings.58

The **Area Under the Curve (AUC)** is a single scalar value that summarizes the ROC curve. It represents the probability that the model will rank a randomly chosen positive instance higher than a randomly chosen negative instance.63

* **AUC \= 1.0:** A perfect classifier.  
* **AUC \= 0.5:** A model with no discriminatory power, equivalent to random guessing.  
* **AUC \< 0.5:** A model that performs worse than random guessing.

The AUC is a widely used metric for comparing classification models because it is independent of the chosen classification threshold.

## **Case Study: Predicting Survival on the Titanic**

To synthesize the concepts of logistic regression and model evaluation, we will conduct a case study using the well-known Titanic dataset. Our objective is to build a model that predicts which factors were most influential in determining a passenger's survival.64

### **The Research Question and Dataset**

We will use a version of the Titanic dataset readily available online to investigate the predictors of survival (Survived), a binary variable where 1 indicates survival and 0 indicates the passenger perished.66 Key predictor variables include

Pclass (passenger class), Sex, Age, SibSp (number of siblings/spouses aboard), and Parch (number of parents/children aboard).

First, we load the data and perform some initial exploratory data analysis (EDA).

R

\# Load the dataset (assuming it's downloaded as titanic.csv)  
titanic\_data \<- read.csv("titanic.csv")

\# Inspect the data  
summary(titanic\_data)  
str(titanic\_data)

EDA reveals that the Age variable has a significant number of missing values, a common challenge in real-world data analysis.68

### **Data Preprocessing and Feature Engineering**

Before building our model, we must handle the missing data and ensure our variables are in the correct format. For simplicity in this case study, we will impute the missing Age values with the median age of all passengers. In a more advanced analysis, more sophisticated imputation methods like multiple imputation would be preferred.69 We also need to convert categorical variables to factors.

R

\# Impute missing Age values with the median  
median\_age \<- median(titanic\_data$Age, na.rm \= TRUE)  
titanic\_data$Age\[is.na(titanic\_data$Age)\] \<- median\_age

\# Convert categorical variables to factors  
titanic\_data$Survived \<- as.factor(titanic\_data$Survived)  
titanic\_data$Pclass \<- as.factor(titanic\_data$Pclass)  
titanic\_data$Sex \<- as.factor(titanic\_data$Sex)

### **Building and Refining the Model**

We will now build a multiple logistic regression model to predict Survived based on Pclass, Sex, Age, and SibSp. To get an unbiased assessment of the model's performance, we first split the data into a training set (70%) and a testing set (30%).

R

\# Set seed for reproducibility  
set.seed(123)

\# Split data into training and testing sets  
sample\_indices \<- sample(1:nrow(titanic\_data), 0.7 \* nrow(titanic\_data))  
train\_data \<- titanic\_data\[sample\_indices, \]  
test\_data \<- titanic\_data\[-sample\_indices, \]

\# Build the logistic regression model on the training data  
titanic.model \<- glm(Survived \~ Pclass \+ Sex \+ Age \+ SibSp,  
                     family \= "binomial",  
                     data \= train\_data)

\# View the model summary  
summary(titanic.model)

To interpret the model, we calculate the odds ratios and their 95% confidence intervals.

| Predictor | Coefficient (Log-Odds) | Odds Ratio (95% CI) |
| :---- | :---- | :---- |
| **(Intercept)** | 3.55 | 34.81 (17.58, 72.45) |
| **Pclass (2nd)** | \-1.13 | 0.32 (0.18, 0.58) |
| **Pclass (3rd)** | \-2.31 | 0.10 (0.05, 0.18) |
| **Sex (male)** | \-2.57 | 0.08 (0.05, 0.13) |
| **Age** | \-0.03 | 0.97 (0.95, 0.99) |
| **SibSp** | \-0.32 | 0.73 (0.59, 0.89) |

**Table 7.3: Logistic Regression Coefficients and Odds Ratios for Titanic Survival**

* **Passenger Class (Pclass):** Compared to 1st class passengers, the odds of survival for 2nd class passengers were 68% lower (OR \= 0.32), and the odds for 3rd class passengers were 90% lower (OR \= 0.10).  
* **Sex:** The odds of survival for males were 92% lower than for females (OR \= 0.08).  
* **Age:** For each additional year of age, the odds of survival decreased by about 3% (OR \= 0.97).  
* **Siblings/Spouses (SibSp):** For each additional sibling or spouse aboard, the odds of survival decreased by 27% (OR \= 0.73).

These results statistically support the historical narrative of "women and children first," and also highlight the strong advantage held by passengers in higher classes.54

### **Rigorous Model Evaluation**

Finally, we evaluate our model's predictive performance on the unseen test data.

R

\# Make predictions on the test data  
predicted\_probs \<- predict(titanic.model, newdata \= test\_data, type \= "response")  
predicted\_class \<- ifelse(predicted\_probs \> 0.5, "1", "0")  
predicted\_class \<- as.factor(predicted\_class)

\# Create the confusion matrix  
library(caret)  
conf\_matrix \<- confusionMatrix(predicted\_class, test\_data$Survived, positive \= "1")  
print(conf\_matrix)

|  | Predicted: Perished (0) | Predicted: Survived (1) |
| :---- | :---- | :---- |
| **Actual: Perished (0)** | 141 (TN) | 22 (FP) |
| **Actual: Survived (1)** | 30 (FN) | 74 (TP) |

**Table 7.4: Confusion Matrix for Titanic Survival Predictions on Test Data**

From this confusion matrix, we derive the key performance metrics:

* **Accuracy:** (141 \+ 74\) / 267 \= 80.5%  
* **Sensitivity (Recall):** 74 / (74 \+ 30\) \= 71.2% (The model correctly identified 71.2% of the actual survivors).  
* **Specificity:** 141 / (141 \+ 22\) \= 86.5% (The model correctly identified 86.5% of those who perished).

To get a threshold-independent measure, we plot the ROC curve and calculate the AUC.

R

\# ROC and AUC  
library(pROC)  
roc\_curve \<- roc(response \= test\_data$Survived, predictor \= predicted\_probs)  
plot(roc\_curve, main \= "ROC Curve for Titanic Survival Model")  
auc(roc\_curve)

The resulting AUC is approximately 0.85, indicating that the model has strong discriminatory power. There is an 85% probability that the model will assign a higher prediction score to a randomly chosen survivor than to a randomly chosen non-survivor. This case study demonstrates the complete workflow of building, interpreting, and rigorously evaluating a logistic regression model in R to answer a substantive research question.

#### **Works cited**

1. What Is ANOVA (Analysis of Variance): Definition, Types, Uses & Assumptions | Editage, accessed on July 30, 2025, [https://www.editage.com/blog/anova-types-uses-assumptions-a-quick-guide-for-biomedical-researchers/](https://www.editage.com/blog/anova-types-uses-assumptions-a-quick-guide-for-biomedical-researchers/)  
2. Binary logistic regression in R \- Stats and R, accessed on July 30, 2025, [https://statsandr.com/blog/binary-logistic-regression-in-r/](https://statsandr.com/blog/binary-logistic-regression-in-r/)  
3. One-Way ANOVA in R: A Step-by-Step Guide \- EZ SPSS Tutorials, accessed on July 30, 2025, [https://ezspss.com/one-way-anova-in-r-a-step-by-step-guide/](https://ezspss.com/one-way-anova-in-r-a-step-by-step-guide/)  
4. One way ANOVA Example in R-Quick Guide \- R-bloggers, accessed on July 30, 2025, [https://www.r-bloggers.com/2022/05/one-way-anova-example-in-r-quick-guide/](https://www.r-bloggers.com/2022/05/one-way-anova-example-in-r-quick-guide/)  
5. One-Way ANOVA Test in R \- Easy Guides \- Wiki \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/wiki/one-way-anova-test-in-r](https://www.sthda.com/english/wiki/one-way-anova-test-in-r)  
6. ANOVA in R: The Ultimate Guide \- Datanovia, accessed on July 30, 2025, [https://www.datanovia.com/en/lessons/anova-in-r/](https://www.datanovia.com/en/lessons/anova-in-r/)  
7. Two-way ANOVA \- Advanced Statistics using R, accessed on July 30, 2025, [https://advstats.psychstat.org/book/anova/twowayanova.php](https://advstats.psychstat.org/book/anova/twowayanova.php)  
8. ANOVA in R | A Complete Step-by-Step Guide with Examples \- Scribbr, accessed on July 30, 2025, [https://www.scribbr.com/statistics/anova-in-r/](https://www.scribbr.com/statistics/anova-in-r/)  
9. One way ANOVA in R, accessed on July 30, 2025, [https://mrinalcs.github.io/one-way-anova-in-r](https://mrinalcs.github.io/one-way-anova-in-r)  
10. 10.2.1 \- ANOVA Assumptions | STAT 500 \- STAT ONLINE, accessed on July 30, 2025, [https://online.stat.psu.edu/stat500/lesson/10/10.2/10.2.1](https://online.stat.psu.edu/stat500/lesson/10/10.2/10.2.1)  
11. 14.7: Assumptions of One-way ANOVA \- Statistics LibreTexts, accessed on July 30, 2025, [https://stats.libretexts.org/Bookshelves/Applied\_Statistics/Learning\_Statistics\_with\_R\_-\_A\_tutorial\_for\_Psychology\_Students\_and\_other\_Beginners\_(Navarro)/14%3A\_Comparing\_Several\_Means\_(One-way\_ANOVA)/14.07%3A\_Assumptions\_of\_One-way\_ANOVA](https://stats.libretexts.org/Bookshelves/Applied_Statistics/Learning_Statistics_with_R_-_A_tutorial_for_Psychology_Students_and_other_Beginners_\(Navarro\)/14%3A_Comparing_Several_Means_\(One-way_ANOVA\)/14.07%3A_Assumptions_of_One-way_ANOVA)  
12. One-way ANOVA in SPSS Statistics \- Step-by-step procedure including testing of assumptions., accessed on July 30, 2025, [https://statistics.laerd.com/spss-tutorials/one-way-anova-using-spss-statistics.php](https://statistics.laerd.com/spss-tutorials/one-way-anova-using-spss-statistics.php)  
13. Module 7 One-Way Assumptions | Readings for MTH207 \- Derek H. Ogle, accessed on July 30, 2025, [http://derekogle.com/Book207/ANOVA1Assumptions.html](http://derekogle.com/Book207/ANOVA1Assumptions.html)  
14. Post-Hoc Analysis with Tukey's Test \- RPubs, accessed on July 30, 2025, [https://rpubs.com/aaronsc32/post-hoc-analysis-tukey](https://rpubs.com/aaronsc32/post-hoc-analysis-tukey)  
15. Chapter 19 Post hoc tests | Quantitative Methods Using R \- Bookdown, accessed on July 30, 2025, [https://bookdown.org/subashparajuli/quant-r/post-hoc-tests.html](https://bookdown.org/subashparajuli/quant-r/post-hoc-tests.html)  
16. Tukey Test and boxplot in R \- The R Graph Gallery, accessed on July 30, 2025, [https://r-graph-gallery.com/84-tukey-test.html](https://r-graph-gallery.com/84-tukey-test.html)  
17. Two-Way ANOVA Example in R-Quick Guide \- R-bloggers, accessed on July 30, 2025, [https://www.r-bloggers.com/2022/05/two-way-anova-example-in-r-quick-guide/](https://www.r-bloggers.com/2022/05/two-way-anova-example-in-r-quick-guide/)  
18. Two-Way ANOVA Test in R \- Easy Guides \- Wiki \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/wiki/two-way-anova-test-in-r](https://www.sthda.com/english/wiki/two-way-anova-test-in-r)  
19. Two-Way ANOVA | Examples & When To Use It \- Scribbr, accessed on July 30, 2025, [https://www.scribbr.com/statistics/two-way-anova/](https://www.scribbr.com/statistics/two-way-anova/)  
20. Linear Regression in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/linear-regression-in-r/](https://www.geeksforgeeks.org/r-language/linear-regression-in-r/)  
21. Simple Linear Regression: Everything You Need to Know \- DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/simple-linear-regression](https://www.datacamp.com/tutorial/simple-linear-regression)  
22. R Linear Regression Tutorial \- Door to master its working\! \- DataFlair, accessed on July 30, 2025, [https://data-flair.training/blogs/r-linear-regression-tutorial/](https://data-flair.training/blogs/r-linear-regression-tutorial/)  
23. Simple Linear Regression in R \- Articles \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/articles/40-regression-analysis/167-simple-linear-regression-in-r/](https://www.sthda.com/english/articles/40-regression-analysis/167-simple-linear-regression-in-r/)  
24. Linear Regression In R Cheatsheet \- Codecademy, accessed on July 30, 2025, [https://www.codecademy.com/learn/learn-linear-regression-in-r/modules/linear-regression-in-r/cheatsheet](https://www.codecademy.com/learn/learn-linear-regression-in-r/modules/linear-regression-in-r/cheatsheet)  
25. How to Do Linear Regression in R \- DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/linear-regression-R](https://www.datacamp.com/tutorial/linear-regression-R)  
26. Multiple Linear Regression in R \- Articles \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/articles/40-regression-analysis/168-multiple-linear-regression-in-r/](https://www.sthda.com/english/articles/40-regression-analysis/168-multiple-linear-regression-in-r/)  
27. Explaining the lm() Summary in R – Learn by Marketing, accessed on July 30, 2025, [https://www.learnbymarketing.com/tutorials/explaining-the-lm-summary-in-r/](https://www.learnbymarketing.com/tutorials/explaining-the-lm-summary-in-r/)  
28. Quick Guide: Interpreting Simple Linear Model Output in R \- Felipe Rego, accessed on July 30, 2025, [https://feliperego.github.io/blog/2015/10/23/Interpreting-Model-Output-In-R](https://feliperego.github.io/blog/2015/10/23/Interpreting-Model-Output-In-R)  
29. Linear Regression in R: Annotated Output \- Get started with Arcus Education, accessed on July 30, 2025, [https://education.arcus.chop.edu/annotated-output-lm/](https://education.arcus.chop.edu/annotated-output-lm/)  
30. Understanding Linear Regression Output in R | Towards Data Science, accessed on July 30, 2025, [https://towardsdatascience.com/understanding-linear-regression-output-in-r-7a9cbda948b3/](https://towardsdatascience.com/understanding-linear-regression-output-in-r-7a9cbda948b3/)  
31. What does this linear regression summary tells me? : r/RStudio \- Reddit, accessed on July 30, 2025, [https://www.reddit.com/r/RStudio/comments/fbr3rm/what\_does\_this\_linear\_regression\_summary\_tells\_me/](https://www.reddit.com/r/RStudio/comments/fbr3rm/what_does_this_linear_regression_summary_tells_me/)  
32. Interpreting the summary() of a lm() linear model in R \- Cross Validated \- Stack Exchange, accessed on July 30, 2025, [https://stats.stackexchange.com/questions/642224/interpreting-the-summary-of-a-lm-linear-model-in-r](https://stats.stackexchange.com/questions/642224/interpreting-the-summary-of-a-lm-linear-model-in-r)  
33. Assumptions of Regression Analysis \- Numeracy, Maths and Statistics \- Academic Skills Kit, accessed on July 30, 2025, [https://www.ncl.ac.uk/webtemplate/ask-assets/external/maths-resources/statistics/regression-and-correlation/assumptions-of-regression-analysis.html](https://www.ncl.ac.uk/webtemplate/ask-assets/external/maths-resources/statistics/regression-and-correlation/assumptions-of-regression-analysis.html)  
34. Linear Regression Assumptions \- Why is it important \- Towards Data Science, accessed on July 30, 2025, [https://towardsdatascience.com/linear-regression-assumptions-why-is-it-important-af28438a44a1/](https://towardsdatascience.com/linear-regression-assumptions-why-is-it-important-af28438a44a1/)  
35. Understanding Linear Regression Assumptions: A Crucial Foundation for Analysis \- Medium, accessed on July 30, 2025, [https://medium.com/@data-overload/understanding-linear-regression-assumptions-a-crucial-foundation-for-analysis-9220a18fb836](https://medium.com/@data-overload/understanding-linear-regression-assumptions-a-crucial-foundation-for-analysis-9220a18fb836)  
36. Diagnostic Plots \- R-project.org, accessed on July 30, 2025, [https://cran.r-project.org/web/packages/rmcorr/vignettes/model\_diag.html](https://cran.r-project.org/web/packages/rmcorr/vignettes/model_diag.html)  
37. 10 Assumptions of Linear Regression \- Full List with Examples and ..., accessed on July 30, 2025, [http://r-statistics.co/Assumptions-of-Linear-Regression.html](http://r-statistics.co/Assumptions-of-Linear-Regression.html)  
38. Regression Model Assumptions | Introduction to Statistics \- JMP, accessed on July 30, 2025, [https://www.jmp.com/en/statistics-knowledge-portal/what-is-regression/simple-linear-regression-assumptions](https://www.jmp.com/en/statistics-knowledge-portal/what-is-regression/simple-linear-regression-assumptions)  
39. Logistic Regression \- UC Business Analytics R Programming Guide ·, accessed on July 30, 2025, [https://uc-r.github.io/logistic\_regression](https://uc-r.github.io/logistic_regression)  
40. 5 Binomial Logistic Regression for Binary Outcomes | Handbook of ..., accessed on July 30, 2025, [https://peopleanalytics-regression-book.org/bin-log-reg.html](https://peopleanalytics-regression-book.org/bin-log-reg.html)  
41. Logistic Regression Coefficients Interpretation \- RPubs, accessed on July 30, 2025, [https://rpubs.com/omaymas/182726](https://rpubs.com/omaymas/182726)  
42. FAQ: How do I interpret odds ratios in logistic regression? \- OARC Stats \- UCLA, accessed on July 30, 2025, [https://stats.oarc.ucla.edu/other/mult-pkg/faq/general/faq-how-do-i-interpret-odds-ratios-in-logistic-regression/](https://stats.oarc.ucla.edu/other/mult-pkg/faq/general/faq-how-do-i-interpret-odds-ratios-in-logistic-regression/)  
43. Odds Ratio in Logistic Regression: Interpreting Relationships \- Datatab, accessed on July 30, 2025, [https://datatab.net/tutorial/odds-ratio-logistic-regression](https://datatab.net/tutorial/odds-ratio-logistic-regression)  
44. Logistic Regression in R Tutorial \- DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/logistic-regression-R](https://www.datacamp.com/tutorial/logistic-regression-R)  
45. Logistic Regression and Evaluation Metrics, accessed on July 30, 2025, [https://nthu-datalab.github.io/ml/labs/06\_Logistic-Regression\_Metrics/06\_Logistic-Regression\_Metrics.html](https://nthu-datalab.github.io/ml/labs/06_Logistic-Regression_Metrics/06_Logistic-Regression_Metrics.html)  
46. Logistic Regression in Machine Learning \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/machine-learning/understanding-logistic-regression/](https://www.geeksforgeeks.org/machine-learning/understanding-logistic-regression/)  
47. Logistic Regression in R \- An Example • SOGA-R \- Freie Universität Berlin, accessed on July 30, 2025, [https://www.geo.fu-berlin.de/en/v/soga-r/Basics-of-statistics/Logistic-Regression/Logistic-Regression-in-R---An-Example/index.html](https://www.geo.fu-berlin.de/en/v/soga-r/Basics-of-statistics/Logistic-Regression/Logistic-Regression-in-R---An-Example/index.html)  
48. Binary Logistic Regression With R in 60 Seconds \- YouTube, accessed on July 30, 2025, [https://www.youtube.com/watch?v=ZVLdhISc\_TE](https://www.youtube.com/watch?v=ZVLdhISc_TE)  
49. Logistic regression via glm — details\_logistic\_reg\_glm \- parsnip \- tidymodels, accessed on July 30, 2025, [https://parsnip.tidymodels.org/reference/details\_logistic\_reg\_glm.html](https://parsnip.tidymodels.org/reference/details_logistic_reg_glm.html)  
50. Chapter 10 Glm function for regression | Introduction \- Bookdown, accessed on July 30, 2025, [https://bookdown.org/introrbook/intro2r/glm-function-for-regression.html](https://bookdown.org/introrbook/intro2r/glm-function-for-regression.html)  
51. How to Interpret Logistic Regression Coefficients \- Displayr, accessed on July 30, 2025, [https://www.displayr.com/how-to-interpret-logistic-regression-coefficients/](https://www.displayr.com/how-to-interpret-logistic-regression-coefficients/)  
52. Can someone tell me in simple terms how to interpret my coefficients from a logistic regression model? : r/statistics \- Reddit, accessed on July 30, 2025, [https://www.reddit.com/r/statistics/comments/3cmjf9/can\_someone\_tell\_me\_in\_simple\_terms\_how\_to/](https://www.reddit.com/r/statistics/comments/3cmjf9/can_someone_tell_me_in_simple_terms_how_to/)  
53. R: Calculate and interpret odds ratio in logistic regression \- Stack Overflow, accessed on July 30, 2025, [https://stackoverflow.com/questions/41384075/r-calculate-and-interpret-odds-ratio-in-logistic-regression](https://stackoverflow.com/questions/41384075/r-calculate-and-interpret-odds-ratio-in-logistic-regression)  
54. Estimating a logistic regression model in R, accessed on July 30, 2025, [https://einsteinmed.edu/uploadedfiles/centers/ictr/new/estimating-a-logistic-regression-model-using-r.pdf?version=1.2](https://einsteinmed.edu/uploadedfiles/centers/ictr/new/estimating-a-logistic-regression-model-using-r.pdf?version=1.2)  
55. Logistic Regression Assumptions and Diagnostics in R \- Articles ..., accessed on July 30, 2025, [https://www.sthda.com/english/articles/36-classification-methods-essentials/148-logistic-regression-assumptions-and-diagnostics-in-r/](https://www.sthda.com/english/articles/36-classification-methods-essentials/148-logistic-regression-assumptions-and-diagnostics-in-r/)  
56. Assumptions of Logistic Regression \- Statistics Solutions, accessed on July 30, 2025, [https://www.statisticssolutions.com/free-resources/directory-of-statistical-analyses/assumptions-of-logistic-regression/](https://www.statisticssolutions.com/free-resources/directory-of-statistical-analyses/assumptions-of-logistic-regression/)  
57. Logistic Regression Assumptions \- RPubs, accessed on July 30, 2025, [https://rpubs.com/guptadeepak/logit-assumptions](https://rpubs.com/guptadeepak/logit-assumptions)  
58. Auc-ROC\_Curve\_Confusion\_Matrix\_Explained in Detail \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/code/vithal2311/auc-roc-curve-confusion-matrix-explained-in-detail](https://www.kaggle.com/code/vithal2311/auc-roc-curve-confusion-matrix-explained-in-detail)  
59. Understanding the Confusion Matrix and ROC Curve in R – CJL & Lab, accessed on July 30, 2025, [https://changjunlee.com/blogs/posts/4\_confusion\_mat\_and\_roc](https://changjunlee.com/blogs/posts/4_confusion_mat_and_roc)  
60. Evaluating Classification Models: Understanding the Confusion Matrix and ROC Curves, accessed on July 30, 2025, [https://statisticallyrelevant.com/confusion-matrix-and-roc-curves/](https://statisticallyrelevant.com/confusion-matrix-and-roc-curves/)  
61. Practical Guide to Logistic Regression Analysis in R Tutorials & Notes | Machine Learning, accessed on July 30, 2025, [https://www.hackerearth.com/practice/machine-learning/machine-learning-algorithms/logistic-regression-analysis-r/tutorial/](https://www.hackerearth.com/practice/machine-learning/machine-learning-algorithms/logistic-regression-analysis-r/tutorial/)  
62. Classification: ROC and AUC | Machine Learning \- Google for Developers, accessed on July 30, 2025, [https://developers.google.com/machine-learning/crash-course/classification/roc-and-auc](https://developers.google.com/machine-learning/crash-course/classification/roc-and-auc)  
63. \[P\] Interactive Explanation to ROC AUC Score : r/MachineLearning \- Reddit, accessed on July 30, 2025, [https://www.reddit.com/r/MachineLearning/comments/1iem7bq/p\_interactive\_explanation\_to\_roc\_auc\_score/](https://www.reddit.com/r/MachineLearning/comments/1iem7bq/p_interactive_explanation_to_roc_auc_score/)  
64. Titanic \- Machine Learning from Disaster | Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/competitions/titanic](https://www.kaggle.com/competitions/titanic)  
65. Titanic Dataset \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/datasets/yasserh/titanic-dataset](https://www.kaggle.com/datasets/yasserh/titanic-dataset)  
66. titanic.csv \- calmcode \- learn code calmly, accessed on July 30, 2025, [https://calmcode.io/datasets/titanic](https://calmcode.io/datasets/titanic)  
67. Survival on the Titanic \- logistic regression \- RegressIt, accessed on July 30, 2025, [https://regressit.com/titanic-example.html](https://regressit.com/titanic-example.html)  
68. 2 Case Study: The Titanic – R Workflow \- hbiostat, accessed on July 30, 2025, [https://hbiostat.org/rflow/case](https://hbiostat.org/rflow/case)  
69. 12 Logistic Model Case Study: Survival of Titanic Passengers ..., accessed on July 30, 2025, [https://hbiostat.org/rmsc/titanic](https://hbiostat.org/rmsc/titanic)  
70. Titanic \- Logistic Regression in R \- Kaggle, accessed on July 30, 2025, [https://www.kaggle.com/code/jeremyd/titanic-logistic-regression-in-r](https://www.kaggle.com/code/jeremyd/titanic-logistic-regression-in-r)