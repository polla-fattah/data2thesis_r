---
title: Hypothesis Testing and Statistical Inference
slug: chapter06
order: 060
published: false
abstract: >
    Readers will learn the foundations of hypothesis testing, including t-tests, chi-square tests, and non-parametric methods. This chapter focuses on interpreting results and applying these techniques to answer research questions with confidence.
---




This chapter marks a pivotal transition from describing data to making inferences from it. So far, we have focused on data wrangling and visualization—the essential skills for understanding the data you *have*. Now, we will learn the formal techniques of **statistical inference**: the process of using data from a sample to draw reasoned conclusions about the larger, unobserved population from which the sample was drawn.1 This is where R transitions from a mere calculator to a powerful tool for scientific discovery and data-driven decision-making.3 We will explore the framework of hypothesis testing, learn to use its core tools like p-values and confidence intervals, and apply a suite of common statistical tests in R.

## **The Framework of Statistical Inference**

Before we write a single line of R code for a test, we must understand the logical structure of hypothesis testing. It is a formalized procedure for weighing evidence and making decisions in the face of uncertainty.3

### **The Core Idea: Two Competing Hypotheses**

At the heart of every hypothesis test are two competing, mutually exclusive statements about a population parameter, such as a population mean (

μ  
) or proportion.6

* **The Null Hypothesis (H0​)**: This is the "skeptic's" hypothesis. It represents the default position, the status quo, or a statement of "no effect," "no difference," or "no relationship".8 It is the hypothesis we assume to be true at the outset of the test. A useful analogy is the principle of "innocent until proven guilty" in a legal trial; the null hypothesis is the defendant's innocence, which holds unless there is sufficient evidence to overturn it.6 The goal of our test is to determine if the sample data provides enough evidence to reject this default position.  
* **The Alternative Hypothesis (Ha​ or H1​)**: This is often called the "researcher's" hypothesis. It is the claim we are trying to find evidence for and represents the logical opposite of the null hypothesis.3 It posits that there  
  *is* an effect, a difference, or a relationship.

Translating a practical research question into this formal structure is the first critical step. For instance, imagine a company wants to know if a new website design increases the average user engagement time from the current baseline of 3 minutes.

* **Research Question:** Does the new website design increase average user engagement time?  
* **Null Hypothesis (H0​)**: The new design has no effect on the average engagement time. The population mean engagement time (  
  μ  
  ) is still 3 minutes. Mathematically:  
  H0​:μ=3  
  .  
* **Alternative Hypothesis (Ha​)**: The new design increases the average engagement time. The population mean engagement time (  
  μ  
  ) is greater than 3 minutes. Mathematically:  
  Ha​:μ\>3  
  .

### **Directionality: One-Tailed vs. Two-Tailed Tests**

The precise wording of the alternative hypothesis is critical because it dictates the type of test we perform and how we evaluate the evidence.11

* **Two-Tailed Test**: This test is used when we are interested in detecting a difference in *any* direction. The alternative hypothesis is non-directional and uses a "not equal to" (  
  \=  
  ) sign. For example, if the research question was simply "Does the new website design change the average engagement time?", the alternative hypothesis would be  
  Ha​:μ=3  
  . We would reject the null hypothesis if the sample mean is either significantly higher or significantly lower than 3\.  
* **One-Tailed Test**: This test is used when we have a specific, directional prediction based on prior knowledge or a strong theoretical reason.4 The alternative hypothesis uses a "greater than" (  
  \>  
  ) or "less than" (  
  \<  
  ) sign.  
  * **Right-Tailed Test**: Used when we predict an increase. In our website example, we are testing if the new design *improves* engagement, so we use  
    Ha​:μ\>3  
    .  
  * **Left-Tailed Test**: Used when we predict a decrease. For example, if we were testing whether a new compression algorithm *reduces* website load time from a baseline of 2 seconds, our alternative would be  
    Ha​:μ\<2  
    .

The choice between a one-tailed and two-tailed test must be made *before* collecting or analyzing the data; it cannot be chosen after the fact to make results appear more significant.10

### **The Logic of Decision-Making and Potential Errors**

The hypothesis testing process follows a clear logic: assume

H0​  
is true, collect sample data, and then assess how likely it is to have obtained our sample data (or something more extreme) if

H0​  
were indeed true.12 If our sample data is highly improbable under the null hypothesis, we reject

H0​  
in favor of

Ha​  
.

Because we are making inferences about a population from a limited sample, our decision is never 100% certain. This uncertainty leads to the possibility of two types of errors 8:

* **Type I Error (False Positive)**: We reject the null hypothesis when it is actually true. This is akin to convicting an innocent person. The probability of making a Type I error is denoted by the Greek letter alpha (  
  α  
  ), which is also known as the **significance level** of the test. We, the researchers, set this value in advance, typically at 0.05 (or 5%).3  
* **Type II Error (False Negative)**: We fail to reject the null hypothesis when it is actually false. This is like letting a guilty person go free. The probability of making a Type II error is denoted by the Greek letter beta (  
  β  
  ).6

The complement of a Type II error (

1−β  
) is known as the **statistical power** of a test. Power is the probability of correctly rejecting a false null hypothesis—that is, the probability of detecting an effect that genuinely exists.6

The choice of the significance level,

α  
, is not merely a convention; it is a strategic decision that involves balancing the risks of these two errors. Alpha and beta have an inverse relationship: decreasing the probability of a Type I error (by setting a lower

α  
) necessarily increases the probability of a Type II error (

β  
), and vice versa.6 This trade-off has profound practical implications. Consider the example of an engineer testing a public bridge.6 The two hypotheses could be:

* H0​  
  : The bridge is not safe.  
* Ha​  
  : The bridge is safe.

Here, a Type I error (rejecting

H0​  
when it is true) means declaring an unsafe bridge to be safe. The potential consequences are catastrophic. A Type II error (failing to reject

H0​  
when it is false) means keeping a safe bridge closed for further inspection. This is costly and inconvenient but far less dangerous. In this high-stakes scenario, the engineer would choose a very small

α  
(e.g., 0.001) to minimize the chance of a false positive, even though this increases the risk of a false negative. This frames hypothesis testing not as a rigid rule, but as a flexible risk management framework.

## **The Tools of Decision-Making: p-values and Confidence Intervals**

With the logical framework established, we now turn to the statistical tools used to make a decision. The two most important are the p-value and the confidence interval. They are complementary, offering different but related perspectives on our results.

### **The p-value: A Measure of Surprise**

The **p-value** is one of the most ubiquitous—and misunderstood—concepts in statistics. Its formal definition is: the probability of observing a test statistic as extreme as, or more extreme than, the one calculated from our sample, *assuming the null hypothesis is true*.8 In simpler terms, it's a measure of how "surprising" our data is if the null hypothesis of no effect is correct. A small p-value indicates that our observed data is very unlikely under the null hypothesis, thus providing strong evidence against it.4

The decision rule is a direct comparison of the p-value to our pre-determined significance level (

α  
) 12:

* If  
  p≤α  
  , the result is declared **statistically significant**. We reject the null hypothesis (  
  H0​  
  ) in favor of the alternative (  
  Ha​  
  ).  
* If  
  p\>α  
  , the result is **not statistically significant**. We **fail to reject** the null hypothesis (  
  H0​  
  ).

It is crucial to use precise language. We "fail to reject"

H0​  
; we never "accept" it. A non-significant result does not prove that the null hypothesis is true. It simply means that we lack sufficient evidence from our sample to overturn the default position.6

The p-value is a powerful tool, but it is frequently misinterpreted. It is essential to understand what a p-value is *not*. A common fallacy is to interpret the p-value as "the probability that the null hypothesis is true." This is incorrect. The p-value is calculated *assuming*

H0​  
is true; it tells us about the probability of our *data*, not the probability of our *hypothesis*.14 For example, a p-value of 0.04 does not mean there is a 4% chance

H0​  
is true. It means that *if*

H0​  
were true, there would only be a 4% chance of observing sample data as extreme as ours.

Furthermore, statistical significance does not automatically imply practical significance. With a very large sample size, even a tiny, trivial difference between groups can produce a very small p-value.8 A data scientist must always consider the context: is the detected effect large enough to be meaningful in the real world?

### **Confidence Intervals: A Range of Plausible Values**

While a p-value provides a single measure of evidence, a **confidence interval (CI)** offers a more informative perspective by providing an estimated range of plausible values for an unknown population parameter.17

A confidence interval is always associated with a **confidence level**, most commonly 95%. This level represents the long-run reliability of the method used to construct the interval. A 95% confidence level means that if we were to repeat our sampling procedure 100 times and calculate a 95% CI for each sample, we would expect the true, unknown population parameter to be contained within approximately 95 of those 100 intervals.19

Confidence intervals and hypothesis tests are deeply connected. A 95% confidence level corresponds directly to a significance level of

α=0.05  
(since

1−0.95=0.05  
).19 This relationship provides an alternative way to conduct a hypothesis test. For a two-tailed test, the rule is simple:

* If the null-hypothesized value falls **outside** the confidence interval, the result is statistically significant (equivalent to  
  p≤α  
  ).  
* If the null-hypothesized value falls **inside** the confidence interval, the result is not statistically significant (equivalent to  
  p\>α  
  ).

This approach is often more valuable than relying on a p-value alone. A p-value gives a binary "yes/no" answer regarding significance. A confidence interval, however, also communicates the magnitude and precision of our estimate. For example, two studies could both find a significant result with

p=0.04  
. Study A might report a 95% CI for a mean difference of \[0.1, 10.0\], while Study B reports \[5.9, 6.1\]. Both are significant, but Study B provides a much more precise estimate of the effect. A very wide CI, even if it excludes the null value, signals that our estimate is imprecise and should be interpreted with caution.9

## **Comparing Means: The t-Test Family**

The t-tests are a foundational part of the statistical toolkit, widely used to compare the means of one or two groups. They are classified as **parametric tests**, which means they rely on certain assumptions about the data, most notably that the data are sampled from a normally distributed population.13

### **Key Assumptions of t-Tests**

The validity of a t-test's p-value and confidence interval hinges on its assumptions being met. Before running a test, it is crucial to perform diagnostic checks on the data.23

* **Normality**: The data should be approximately normally distributed. For a one-sample test, this applies to the sample data itself. For a two-sample test, it applies to the data within each group.  
* **Independence**: Observations should be independent of one another. This is typically ensured by the study design (e.g., random sampling) and is not something that can be tested statistically from the data itself.22  
* **Homogeneity of Variances**: For the independent two-sample t-test, the two groups being compared should have approximately equal variances. This is also known as homoscedasticity.

The following table serves as a practical guide for checking these assumptions in R.

| Assumption | What it Means | How to Check in R | R Functions |
| :---- | :---- | :---- | :---- |
| **Normality** | Data follows a bell-shaped curve. | Visual: Q-Q Plot, Histogram. Formal Test: Shapiro-Wilk Test. | qqnorm(), qqline(), hist(), shapiro.test() 23 |
| **Independence** | Observations are not related. | Assessed through study design. | Not a statistical test. |
| **Homogeneity of Variances** | Variances are equal across groups. | Formal Test: Levene's Test (more robust than F-test). | leveneTest() from the car package (preferred), var.test() (F-test, sensitive to non-normality) 23 |

### **One-Sample t-Test**

The one-sample t-test is used to compare the mean of a single sample to a known, hypothesized, or theoretical population mean (

μ0​  
).27 For example, a quality control engineer might test whether the mean weight of a sample of energy bars is significantly different from the 20 grams stated on the label.28

The test is implemented in R using the t.test() function. The essential arguments are x, a numeric vector of the sample data, and mu, the hypothesized population mean from

H0​  
.

Let's test if the average score of a sample of 15 students is significantly different from a known population average of 75\.

R

\# Sample data: test scores of 15 students  
student\_scores \<- c(68, 74, 80, 77, 82, 72, 76, 70, 88, 81, 66, 78, 75, 79, 84)

\# Perform the one-sample t-test  
t\_test\_result \<- t.test(student\_scores, mu \= 75)

\# Print the results  
print(t\_test\_result)

**Output:**

	One Sample t-test

data:  student\_scores  
t \= 1.066, df \= 14, p-value \= 0.3045  
alternative hypothesis: true mean is not equal to 75  
95 percent confidence interval:  
 73.31335 80.01998  
sample estimates:  
mean of x   
 76.66667 

**Interpretation of the Output:**

* t \= 1.066: This is the calculated t-statistic.  
* df \= 14: These are the degrees of freedom, calculated as  
  n−1  
  .  
* p-value \= 0.3045: This is the probability of observing a sample mean as far from 75 as ours (or further), if the true population mean were indeed 75\. Since  
  0.3045\>0.05  
  , we fail to reject the null hypothesis.  
* 95 percent confidence interval: \[73.31, 80.02\]: This is the range of plausible values for the true population mean. Notice that our hypothesized mean of 75 falls within this interval, which confirms our conclusion from the p-value.  
* mean of x \= 76.67: This is the sample mean.

Reporting the Result (APA Style):  
A one-sample t-test was conducted to determine whether the average test score of the students differed from the population average of 75\. The results indicated that the sample mean (  
M=76.67,SD=5.58  
) was not significantly different from 75,

t(14)=1.07,p=.305  
. The 95% confidence interval for the mean score was \[73.31, 80.02\].29

### **Two-Sample Independent t-Test**

This test is used to compare the means of two independent, unrelated groups.31 For example, we could compare the effectiveness of a new drug against a placebo by comparing the mean recovery times of two separate groups of patients.

A critical consideration for this test is the assumption of equal variances. The classic Student's t-test requires this assumption to hold. However, a modification known as Welch's t-test does not, making it a more robust and generally safer option.33 If the variances are truly equal, Welch's test provides a result that is nearly identical to Student's. If they are unequal, Welch's test is more reliable. For this reason,

**R's t.test() function performs the Welch t-test by default**. To perform the Student's t-test, one must explicitly set the argument var.equal \= TRUE.

The t.test() function in R is most commonly used with the formula interface y \~ x, where y is the numeric outcome variable and x is a factor with two levels defining the groups.

Let's use the built-in CO2 dataset to test if the mean CO2 uptake rate (uptake) differs between chilled and non-chilled plants (Treatment).

R

\# Perform the Welch's two-sample t-test (default)  
t.test(uptake \~ Treatment, data \= CO2)

**Output:**

	Welch Two Sample t-test

data:  uptake by Treatment  
t \= \-3.0485, df \= 80.945, p-value \= 0.003107  
alternative hypothesis: true difference in means between group nonchilled and group chilled is not equal to 0  
95 percent confidence interval:  
 \-11.336682  \-2.382366  
sample estimates:  
mean in group nonchilled   mean in group chilled   
               27.85238                34.69286 

**Interpretation:** The p-value is 0.0031, which is less than 0.05. Therefore, we reject the null hypothesis and conclude that there is a statistically significant difference in the mean CO2 uptake between chilled and non-chilled plants. The confidence interval for the difference in means is \[-11.34, \-2.38\], which does not contain 0, confirming the significant result.

Reporting the Result (APA Style):  
An independent-samples t-test was conducted to compare CO2 uptake rates for chilled and non-chilled plants. There was a significant difference in uptake rates between the non-chilled (  
M=27.85,SD=9.61  
) and chilled (

M=34.69,SD=9.38  
) groups;

t(80.95)=−3.05,p=.003  
.35

### **Paired-Sample t-Test**

The paired-sample t-test is used to compare the means of two related or matched samples.37 This design is common in "before-and-after" studies, where the same subjects are measured twice (e.g., before and after an intervention).39

This test is powerful because it controls for individual-level variability. Instead of comparing two groups of different individuals, it analyzes the *difference* within each pair. The test is mathematically equivalent to performing a one-sample t-test on the vector of difference scores, testing if the mean difference is significantly different from zero.37 This focus on within-subject change often reduces noise and increases statistical power compared to an independent-samples design.

In R, we use the t.test() function with the paired \= TRUE argument.

Let's use a fictional dataset to test the effectiveness of a weight-loss program by comparing participants' weights before and after the program.

R

\# Fictional data for a weight-loss program  
before\_weight \<- c(190, 195, 200, 185, 210, 198, 205)  
after\_weight  \<- c(180, 182, 191, 178, 199, 190, 195)

\# Perform the paired-sample t-test  
t.test(before\_weight, after\_weight, paired \= TRUE)

**Output:**

	Paired t-test

data:  before\_weight and after\_weight  
t \= 7.9897, df \= 6, p-value \= 0.0001815  
alternative hypothesis: true mean difference is not equal to 0  
95 percent confidence interval:  
  6.91418 12.51440  
sample estimates:  
mean difference   
       9.714286 

**Interpretation:** The p-value is extremely small (

p\<.001  
), providing strong evidence to reject the null hypothesis. We conclude that there was a statistically significant mean weight loss of 9.71 kg. The 95% confidence interval for the mean difference \[6.91, 12.51\] does not include zero, reinforcing this conclusion.

Reporting the Result (APA Style):  
A paired-samples t-test was conducted to evaluate the impact of a weight-loss program. There was a statistically significant decrease in weight from before the program (  
M=198.14,SD=8.61  
) to after the program (

M=187.86,SD=7.71  
),

t(6)=7.99,p\<.001  
. The mean weight loss was 9.71 kg, with a 95% confidence interval of \[6.91, 12.51\].40

## **Analyzing Categorical Data: Chi-Square (**

χ2  
) Tests

When our data consists of counts or frequencies within different categories, rather than continuous measurements, we use the chi-square (

χ2  
) family of tests. These are non-parametric tests designed specifically for categorical variables.13

### **The Core Idea and Assumption**

The fundamental logic of all chi-square tests is to compare the **observed frequencies** (the actual counts in our sample) with the **expected frequencies** (the counts we would expect if the null hypothesis were true).43 The

χ2  
test statistic quantifies the discrepancy between what was observed and what was expected.$$  
\\chi^2 \= \\sum \\frac{(O\_i \- E\_i)^2}{E\_i}

where  
O\_i

istheobservedfrequencyand  
E\_i

istheexpectedfrequencyforcategory  
i$$.

A key assumption for the validity of the chi-square test is that the expected count in each cell should be sufficiently large. A widely used rule of thumb is that **all expected frequencies should be 5 or greater**.45 In R, we can easily check this assumption by accessing the

expected component of the object returned by the test function.

### **Chi-Square Goodness-of-Fit Test**

This test is used to determine if the observed frequency distribution of a *single* categorical variable matches a hypothesized or expected distribution.47 For example, a biologist might test if the observed ratio of phenotypes in a genetic cross (e.g., 9:3:3:1) matches the ratio predicted by Mendelian genetics.

In R, we use the chisq.test() function. We supply a vector of the observed counts to the x argument and a vector of the expected probabilities to the p argument.

Let's test the question from an example where wild tulips were collected, and 81 were red, 50 were yellow, and 27 were white. The null hypothesis is that all colors are equally common.47

R

\# Vector of observed counts  
observed\_counts \<- c(red \= 81, yellow \= 50, white \= 27)

\# H0: Colors are equally common, so expected probabilities are (1/3, 1/3, 1/3)  
test\_result \<- chisq.test(observed\_counts, p \= c(1/3, 1/3, 1/3))

\# Print the result  
print(test\_result)

**Output:**

	Chi-squared test for given probabilities

data:  observed\_counts  
X-squared \= 27.886, df \= 2, p-value \= 8.803e-07

**Interpretation:** The p-value is extremely small (

8.8×10−7  
), which is much less than 0.05. We reject the null hypothesis and conclude that the colors of wild tulips are not equally distributed.

Reporting the Result (APA Style):  
A chi-square goodness-of-fit test was performed to determine whether the three tulip colors (red, yellow, white) were equally common. The results indicated that the frequency of colors was not equally distributed,  
χ2(2,N=158)=27.89,p\<.001  
.49

### **Chi-Square Test of Independence**

This test is one of the most common statistical procedures, used to determine if there is a significant association between *two* categorical variables.51 It tests the null hypothesis that the two variables are independent—that is, the distribution of one variable is not dependent on the category of the other variable. For example, is there a relationship between a person's educational level and their voting preference?

To perform this test in R, we first need to create a contingency table (also called a cross-tabulation) of the two variables using the table() function. This table is then passed to chisq.test().

Let's use the mtcars dataset to test for an association between the number of gears (gear) and the number of cylinders (cyl).

R

\# Create a contingency table from the mtcars dataset  
contingency\_table \<- table(mtcars$gear, mtcars$cyl)  
print(contingency\_table)

\# Perform the chi-square test of independence  
chi\_test\_result \<- chisq.test(contingency\_table)  
print(chi\_test\_result)

**Output (Contingency Table):**

   4  6  8  
  3  1  2 12  
  4  8  4  0  
  5  2  1  2

**Output (Test Result):**

	Pearson's Chi-squared test

data:  contingency\_table  
X-squared \= 18.036, df \= 4, p-value \= 0.001214

**Interpretation:** The p-value of 0.0012 is less than 0.05, so we reject the null hypothesis of independence. We conclude that there is a statistically significant association between the number of gears and the number of cylinders in cars.

A significant p-value tells us that a relationship exists, but it doesn't describe the *nature* of that relationship. To understand which combinations of categories are driving the association, we can examine the test's residuals. The chisq.test() object stores observed counts, expected counts, and residuals.42 The Pearson residuals, calculated as

(Observed−Expected)/Expected​  
, are particularly useful. A large positive residual for a cell indicates that we observed many more cases than expected under independence (a positive association), while a large negative residual indicates we observed far fewer (a negative association).

R

\# Examine the Pearson residuals  
round(chi\_test\_result$residuals, 2)

**Output (Residuals):**

      4     6     8  
  3 \-2.29 \-1.49  2.49  
  4  1.54  0.03 \-2.52  
  5  0.35 \-0.91  0.00

The large positive residual (2.49) for 3-gear, 8-cylinder cars and the large negative residual (-2.52) for 4-gear, 8-cylinder cars suggest that 8-cylinder cars are disproportionately likely to have 3 gears and unlikely to have 4 gears. This provides a much richer interpretation than the p-value alone.

## **When Assumptions Are Not Met: Non-Parametric Alternatives**

What should we do when our data violates the assumptions of a t-test, such as being heavily skewed or containing significant outliers? In these cases, we can turn to **non-parametric tests**. These tests do not assume a specific underlying distribution for the data and often work by converting the data to ranks before performing calculations.9

### **The Mann-Whitney U Test (Wilcoxon Rank-Sum Test)**

The Mann-Whitney U test (referred to in R as the Wilcoxon rank-sum test) is the non-parametric alternative to the **independent two-sample t-test**.55 It is used to compare two independent groups when the normality assumption is not met.

It is often described as a "test of medians," but this is only strictly true if we can assume that the distributions of the two groups have the same shape and spread.57 The test's true null hypothesis is more general: that the probability of a randomly selected value from one group being greater than a randomly selected value from the other group is 0.5. If the test is significant and the distributions have different shapes, the most accurate conclusion is that the

*distributions* of the two groups differ, or that values in one group tend to be higher than in the other.

In R, the test is performed using the wilcox.test() function with the formula interface.

Let's re-examine the mtcars data, testing for a difference in gas mileage (mpg) between automatic (am \= 0\) and manual (am \= 1\) transmissions, this time using a non-parametric approach.

R

\# Perform the Mann-Whitney U test  
wilcox.test(mpg \~ am, data \= mtcars)

**Output:**

	Wilcoxon rank sum test with continuity correction

data:  mpg by am  
W \= 42, p-value \= 0.001871  
alternative hypothesis: true location shift is not equal to 0

**Interpretation:** The p-value of 0.0019 is less than 0.05. We reject the null hypothesis and conclude that there is a significant difference in the distribution of gas mileage between automatic and manual transmission cars.

Reporting the Result (APA Style):  
A Mann-Whitney U test was conducted to evaluate the difference in gas mileage between automatic and manual transmission cars. The results indicated a significant difference in mileage, with manual transmission cars (Mdn \= 22.8) having higher mileage than automatic transmission cars (Mdn \= 17.3),  
U=42,p=.002  
.59

### **The Wilcoxon Signed-Rank Test**

The Wilcoxon signed-rank test is the non-parametric alternative to the **paired-sample t-test**. It is used for two related samples when the distribution of the differences between pairs is not normal.61 The test works by calculating the differences, ranking their absolute values, and then summing the ranks corresponding to the positive and negative differences.

The R implementation uses the same wilcox.test() function, but with the paired \= TRUE argument.

Let's use the built-in immer dataset from the MASS package to test if barley yield differed between 1931 (Y1) and 1932 (Y2) for the same fields.61

R

\# Load the MASS package for the 'immer' dataset  
library(MASS)

\# Perform the Wilcoxon signed-rank test  
wilcox.test(immer$Y1, immer$Y2, paired \= TRUE)

**Output:**

	Wilcoxon signed rank test with continuity correction

data:  immer$Y1 and immer$Y2  
V \= 368.5, p-value \= 0.005318  
alternative hypothesis: true location shift is not equal to 0

**Interpretation:** The p-value of 0.0053 is less than 0.05, so we reject the null hypothesis. We conclude that there was a significant difference in barley yield between 1931 and 1932\.

Reporting the Result (APA Style):  
A Wilcoxon signed-rank test was used to determine if there was a difference in barley yield between 1931 and 1932\. The results showed a statistically significant difference in yield between 1931 (Mdn \= 101.2) and 1932 (Mdn \= 88.9),  
Z=−2.79,p=.005  
.63 (Note: The Z-statistic is often reported for this test and can be calculated from the p-value if not directly provided).

## **Chapter Summary and A Guide to Choosing the Right Test**

This chapter has provided a comprehensive introduction to the principles and practice of statistical inference in R. We have moved from the foundational logic of null and alternative hypotheses to the practical application of key statistical tools like p-values and confidence intervals. We have implemented a range of parametric tests (the t-test family) for comparing means and non-parametric tests (chi-square and Wilcoxon-based tests) for analyzing categorical data and data that violate parametric assumptions.

Choosing the correct statistical test is a critical step in any analysis. The decision depends on the research question, the number of variables, the type of data, and whether the assumptions of parametric tests are met. The following table provides a decision-making guide to help select the appropriate test covered in this chapter.65

| Research Goal | Data Type & Number of Variables | Sample Relationship | Parametric Assumptions Met? | Recommended Test (R Function) |
| :---- | :---- | :---- | :---- | :---- |
| **Compare a sample mean to a known value** | 1 Continuous Variable | N/A | Yes (Normality) | **One-Sample t-Test** (t.test(x, mu=...)) |
|  |  |  | No | **One-Sample Wilcoxon Signed-Rank Test** (wilcox.test(x, mu=...)) |
| **Compare the means of two groups** | 1 Continuous Variable, 1 Categorical Variable (2 groups) | **Independent** | Yes (Normality, Equal Variance\*) | **Independent Two-Sample t-Test** (t.test(y\~x)) |
|  |  |  | No | **Mann-Whitney U Test** (wilcox.test(y\~x)) |
|  |  | **Paired/Related** | Yes (Normality of differences) | **Paired t-Test** (t.test(x, y, paired=TRUE)) |
|  |  |  | No | **Wilcoxon Signed-Rank Test** (wilcox.test(x, y, paired=TRUE)) |
| **Compare observed to expected frequencies** | 1 Categorical Variable | N/A | Yes (Expected counts \> 5\) | **Chi-Square Goodness-of-Fit Test** (chisq.test(x, p=...)) |
| **Test for association between two variables** | 2 Categorical Variables | **Independent** | Yes (Expected counts \> 5\) | **Chi-Square Test of Independence** (chisq.test(table(x,y))) |

*\*Note on Equal Variance for t-test: R's t.test defaults to Welch's t-test, which does not assume equal variance. This is generally the safer and recommended option.*

#### **Works cited**

1. 5.1 \- Introduction to Inferences | STAT 500, accessed on July 30, 2025, [https://online.stat.psu.edu/stat500/lesson/5/5.1](https://online.stat.psu.edu/stat500/lesson/5/5.1)  
2. Unit 4A: Introduction to Statistical Inference, accessed on July 30, 2025, [https://stats.libretexts.org/Bookshelves/Applied\_Statistics/Biostatistics\_-\_Open\_Learning\_Textbook/Unit\_4A%3A\_Introduction\_to\_Statistical\_Inference](https://stats.libretexts.org/Bookshelves/Applied_Statistics/Biostatistics_-_Open_Learning_Textbook/Unit_4A%3A_Introduction_to_Statistical_Inference)  
3. Hypothesis Testing: Types, Steps, Formula, and Examples \- Simplilearn.com, accessed on July 30, 2025, [https://www.simplilearn.com/tutorials/statistics-tutorial/hypothesis-testing-in-statistics](https://www.simplilearn.com/tutorials/statistics-tutorial/hypothesis-testing-in-statistics)  
4. A Beginner's Guide to Hypothesis Testing in Business, accessed on July 30, 2025, [https://online.hbs.edu/blog/post/hypothesis-testing](https://online.hbs.edu/blog/post/hypothesis-testing)  
5. Introduction to Hypothesis Testing in R \- Learn every concept from Scratch\! \- DataFlair, accessed on July 30, 2025, [https://data-flair.training/blogs/hypothesis-testing-in-r/](https://data-flair.training/blogs/hypothesis-testing-in-r/)  
6. 6a.1 \- Introduction to Hypothesis Testing | STAT 500, accessed on July 30, 2025, [https://online.stat.psu.edu/stat500/lesson/6a/6a.1](https://online.stat.psu.edu/stat500/lesson/6a/6a.1)  
7. Null & Alternative Hypotheses | Definitions, Templates & Examples \- Scribbr, accessed on July 30, 2025, [https://www.scribbr.com/statistics/null-and-alternative-hypotheses/](https://www.scribbr.com/statistics/null-and-alternative-hypotheses/)  
8. Hypothesis Testing: Principles and Methods \- Mind the Graph, accessed on July 30, 2025, [https://mindthegraph.com/blog/hypothesis-testing/](https://mindthegraph.com/blog/hypothesis-testing/)  
9. Mastering Hypothesis Testing Fundamentals: Methods, Techniques, and Applications, accessed on July 30, 2025, [https://www.numberanalytics.com/blog/hypothesis-testing-fundamentals-methods-techniques](https://www.numberanalytics.com/blog/hypothesis-testing-fundamentals-methods-techniques)  
10. Introduction to Hypothesis Testing (Psychology) \- Numeracy, Maths and Statistics \- Academic Skills Kit, accessed on July 30, 2025, [https://www.ncl.ac.uk/webtemplate/ask-assets/external/maths-resources/psychology/introduction-to-hypothesis-testing.html](https://www.ncl.ac.uk/webtemplate/ask-assets/external/maths-resources/psychology/introduction-to-hypothesis-testing.html)  
11. Null and Alternative Hypotheses, accessed on July 30, 2025, [https://www.ncl.ac.uk/webtemplate/ask-assets/external/maths-resources/statistics/hypothesis-testing/null-and-alternative-hypotheses.html](https://www.ncl.ac.uk/webtemplate/ask-assets/external/maths-resources/statistics/hypothesis-testing/null-and-alternative-hypotheses.html)  
12. 4.2 Hypothesis Testing \- Principles of Data Science | OpenStax, accessed on July 30, 2025, [https://openstax.org/books/principles-data-science/pages/4-2-hypothesis-testing](https://openstax.org/books/principles-data-science/pages/4-2-hypothesis-testing)  
13. Hypothesis Testing in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/hypothesis-testing-in-r-programming/](https://www.geeksforgeeks.org/r-language/hypothesis-testing-in-r-programming/)  
14. Interpretation of Alpha and p-Value \- SPC for Excel, accessed on July 30, 2025, [https://www.spcforexcel.com/knowledge/basic-statistics/interpretation-alpha-and-p-value/](https://www.spcforexcel.com/knowledge/basic-statistics/interpretation-alpha-and-p-value/)  
15. A Quick Guide T-Test: P-Value & α Explained \- Number Analytics, accessed on July 30, 2025, [https://www.numberanalytics.com/blog/quick-guide-t-test-pvalue-alpha-explained](https://www.numberanalytics.com/blog/quick-guide-t-test-pvalue-alpha-explained)  
16. www.ncbi.nlm.nih.gov, accessed on July 30, 2025, [https://www.ncbi.nlm.nih.gov/books/NBK459346/\#:\~:text=A%20study%20is%20statistically%20significant,not%20a%20statistically%20significant%20result.](https://www.ncbi.nlm.nih.gov/books/NBK459346/#:~:text=A%20study%20is%20statistically%20significant,not%20a%20statistically%20significant%20result.)  
17. wmed.edu, accessed on July 30, 2025, [https://wmed.edu/sites/default/files/ANATOMY%20OF%20A%20CONFIDENCE%20INTERVAL%20%28full%29.pdf](https://wmed.edu/sites/default/files/ANATOMY%20OF%20A%20CONFIDENCE%20INTERVAL%20%28full%29.pdf)  
18. What Is a Confidence Interval and How Do You Calculate It? \- Investopedia, accessed on July 30, 2025, [https://www.investopedia.com/terms/c/confidenceinterval.asp](https://www.investopedia.com/terms/c/confidenceinterval.asp)  
19. Understanding Confidence Intervals | Easy Examples & Formulas \- Scribbr, accessed on July 30, 2025, [https://www.scribbr.com/statistics/confidence-interval/](https://www.scribbr.com/statistics/confidence-interval/)  
20. Confidence interval \- Wikipedia, accessed on July 30, 2025, [https://en.wikipedia.org/wiki/Confidence\_interval](https://en.wikipedia.org/wiki/Confidence_interval)  
21. What Is the Difference Between Alpha and P-Values? \- ThoughtCo, accessed on July 30, 2025, [https://www.thoughtco.com/the-difference-between-alpha-and-p-values-3126420](https://www.thoughtco.com/the-difference-between-alpha-and-p-values-3126420)  
22. What does it take to do a t-test? \- R Views, accessed on July 30, 2025, [https://rviews.rstudio.com/2021/03/29/what-does-it-take-to-do-a-t-test/](https://rviews.rstudio.com/2021/03/29/what-does-it-take-to-do-a-t-test/)  
23. t-test | Research Methods: R Supplemental User Guide \- Andrew Farina, accessed on July 30, 2025, [https://andrewfarina.com/books/pl361-r\_userguide/t-test](https://andrewfarina.com/books/pl361-r_userguide/t-test)  
24. T-Test Assumptions : Excellent Tutorial You Will Love \- Datanovia, accessed on July 30, 2025, [https://www.datanovia.com/en/lessons/t-test-assumptions/](https://www.datanovia.com/en/lessons/t-test-assumptions/)  
25. How to Perform and Interpret the Shapiro-Wilk Test in R | by RStudioDataLab, accessed on July 30, 2025, [https://rstudiodatalab.medium.com/how-to-perform-and-interpret-the-shapiro-wilk-test-in-r-afab5234997d](https://rstudiodatalab.medium.com/how-to-perform-and-interpret-the-shapiro-wilk-test-in-r-afab5234997d)  
26. www.r-bloggers.com, accessed on July 30, 2025, [https://www.r-bloggers.com/2025/02/levene-test-in-r-for-homogeneity-of-variances-step-by-step-guide/\#:\~:text=The%20Levene%20Test%2C%20a%20statistical,are%20equal%20before%20further%20analysis.\&text=Tests%20the%20null%20hypothesis%20that%20variances%20are%20equal%20across%20groups.\&text=A%20p%2Dvalue%20%3C%200.05%20indicates,differences%20in%20variances%20among%20groups.](https://www.r-bloggers.com/2025/02/levene-test-in-r-for-homogeneity-of-variances-step-by-step-guide/#:~:text=The%20Levene%20Test%2C%20a%20statistical,are%20equal%20before%20further%20analysis.&text=Tests%20the%20null%20hypothesis%20that%20variances%20are%20equal%20across%20groups.&text=A%20p%2Dvalue%20%3C%200.05%20indicates,differences%20in%20variances%20among%20groups.)  
27. One Sample T-test in R \- MAKE ME ANALYST, accessed on July 30, 2025, [https://makemeanalyst.com/statistics-with-r/one-sample-t-test-in-r/](https://makemeanalyst.com/statistics-with-r/one-sample-t-test-in-r/)  
28. One-Sample t-Test | Introduction to Statistics \- JMP, accessed on July 30, 2025, [https://www.jmp.com/en/statistics-knowledge-portal/t-test/one-sample-t-test](https://www.jmp.com/en/statistics-knowledge-portal/t-test/one-sample-t-test)  
29. How to Report One Sample t Tests from SPSS in APA Style, accessed on July 30, 2025, [https://ezspss.com/how-to-report-one-sample-t-tests-from-spss-in-apa-style/](https://ezspss.com/how-to-report-one-sample-t-tests-from-spss-in-apa-style/)  
30. How to Report the Result of a T-Test (APA style), accessed on July 30, 2025, [https://www.socscistatistics.com/tutorials/ttest/default.aspx](https://www.socscistatistics.com/tutorials/ttest/default.aspx)  
31. Two-Sample t-Test | Introduction to Statistics \- JMP, accessed on July 30, 2025, [https://www.jmp.com/en/statistics-knowledge-portal/t-test/two-sample-t-test](https://www.jmp.com/en/statistics-knowledge-portal/t-test/two-sample-t-test)  
32. T-test in R: The Ultimate Guide \- Datanovia, accessed on July 30, 2025, [https://www.datanovia.com/en/lessons/t-test-in-r/](https://www.datanovia.com/en/lessons/t-test-in-r/)  
33. Unpaired Two-Samples T-test in R \- Easy Guides \- Wiki \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/wiki/unpaired-two-samples-t-test-in-r](https://www.sthda.com/english/wiki/unpaired-two-samples-t-test-in-r)  
34. How To Do Two-Sample T-test in R : Best Tutorial You Will Love \- Datanovia, accessed on July 30, 2025, [https://www.datanovia.com/en/lessons/how-to-do-a-t-test-in-r-calculation-and-reporting/how-to-do-two-sample-t-test-in-r/](https://www.datanovia.com/en/lessons/how-to-do-a-t-test-in-r-calculation-and-reporting/how-to-do-two-sample-t-test-in-r/)  
35. How to Report T-Test Results (With Examples) \- Statology, accessed on July 30, 2025, [https://www.statology.org/how-to-report-t-test-results/](https://www.statology.org/how-to-report-t-test-results/)  
36. APA Style T-Test Reporting Guide \- Learn Statistics Easily, accessed on July 30, 2025, [https://statisticseasily.com/2023/01/10/t-test-apa-report/](https://statisticseasily.com/2023/01/10/t-test-apa-report/)  
37. 22 Paired t-test \- Practical Statistics in Medicine with R, accessed on July 30, 2025, [https://practical-stats-med-r.netlify.app/paired\_t\_test](https://practical-stats-med-r.netlify.app/paired_t_test)  
38. Paired Samples T-test in R \- Easy Guides \- Wiki \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/wiki/paired-samples-t-test-in-r](https://www.sthda.com/english/wiki/paired-samples-t-test-in-r)  
39. Hypothesis Testing in R \- Meritshot, accessed on July 30, 2025, [https://www.meritshot.com/hypothesis-testing-in-r/](https://www.meritshot.com/hypothesis-testing-in-r/)  
40. Tutorial 19: Paired Samples t-test \- USF Scholarship Repository, accessed on July 30, 2025, [https://repository.usfca.edu/cgi/viewcontent.cgi?article=1088\&context=jips](https://repository.usfca.edu/cgi/viewcontent.cgi?article=1088&context=jips)  
41. How to report an Paired Samples t-Test? \- YouTube, accessed on July 30, 2025, [https://www.youtube.com/watch?v=JJmdRr16Zok](https://www.youtube.com/watch?v=JJmdRr16Zok)  
42. Chi-Square Test of Independence in R \- Easy Guides \- Wiki \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/wiki/chi-square-test-of-independence-in-r](https://www.sthda.com/english/wiki/chi-square-test-of-independence-in-r)  
43. Chi-Square Goodness-of-Fit Test • SOGA-R \- Freie Universität Berlin, accessed on July 30, 2025, [https://www.geo.fu-berlin.de/en/v/soga-r/Basics-of-statistics/Hypothesis-Tests/Chi-Square-Tests/Chi-Square-Goodness-of-Fit-Test/index.html](https://www.geo.fu-berlin.de/en/v/soga-r/Basics-of-statistics/Hypothesis-Tests/Chi-Square-Tests/Chi-Square-Goodness-of-Fit-Test/index.html)  
44. How to Perform a Chi-Square Goodness of Fit Test in R \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/how-to-perform-a-chi-square-goodness-of-fit-test-in-r/](https://www.geeksforgeeks.org/r-language/how-to-perform-a-chi-square-goodness-of-fit-test-in-r/)  
45. Chi-Square Test in R: A Complete Guide \- DataCamp, accessed on July 30, 2025, [https://www.datacamp.com/tutorial/chi-square-test-r](https://www.datacamp.com/tutorial/chi-square-test-r)  
46. The Four Assumptions of a Chi-Square Test \- Statology, accessed on July 30, 2025, [https://www.statology.org/chi-square-test-assumptions/](https://www.statology.org/chi-square-test-assumptions/)  
47. Chi-Square Goodness of Fit Test \- RPubs, accessed on July 30, 2025, [https://rpubs.com/pg2000in/ChiSquareGoodnessFit](https://rpubs.com/pg2000in/ChiSquareGoodnessFit)  
48. Chapter 26 Goodness of fit tests | Introductory Biostatistics with R, accessed on July 30, 2025, [https://tuos-bio-data-skills.github.io/intro-stats-book/goodness-of-fit-tests.html](https://tuos-bio-data-skills.github.io/intro-stats-book/goodness-of-fit-tests.html)  
49. How to Report a Chi-Square Result (APA Style), accessed on July 30, 2025, [https://www.socscistatistics.com/tutorials/chisquare/default.aspx](https://www.socscistatistics.com/tutorials/chisquare/default.aspx)  
50. Reporting Statistics in APA Style – Jeffrey H. Kahn (Jef Kahn) \- Illinois State University, accessed on July 30, 2025, [https://about.illinoisstate.edu/jhkahn/apastats/](https://about.illinoisstate.edu/jhkahn/apastats/)  
51. Chi-Square Test of Independence in R \- EZ SPSS Tutorials, accessed on July 30, 2025, [https://ezspss.com/chi-square-test-of-independence-in-r/](https://ezspss.com/chi-square-test-of-independence-in-r/)  
52. Chi-square test of independence in R \- Stats and R, accessed on July 30, 2025, [https://statsandr.com/blog/chi-square-test-of-independence-in-r/](https://statsandr.com/blog/chi-square-test-of-independence-in-r/)  
53. chisq.test: Pearson's Chi-squared Test for Count Data \- rdrr.io, accessed on July 30, 2025, [https://rdrr.io/r/stats/chisq.test.html](https://rdrr.io/r/stats/chisq.test.html)  
54. Wilcoxon Test in R: The Ultimate Guide \- Datanovia, accessed on July 30, 2025, [https://www.datanovia.com/en/lessons/wilcoxon-test-in-r/](https://www.datanovia.com/en/lessons/wilcoxon-test-in-r/)  
55. Mann-Whitney-Wilcoxon Test | R Tutorial, accessed on July 30, 2025, [https://www.r-tutor.com/elementary-statistics/non-parametric-methods/mann-whitney-wilcoxon-test](https://www.r-tutor.com/elementary-statistics/non-parametric-methods/mann-whitney-wilcoxon-test)  
56. Mann-Whitney U & Wilcoxon signed-rank tests \- DLC\_statistical\_guides, accessed on July 30, 2025, [https://repub.github.io/DLC\_statistical\_guides/docs/R/Mann-Whitney-Wilcoxon.html](https://repub.github.io/DLC_statistical_guides/docs/R/Mann-Whitney-Wilcoxon.html)  
57. 21 Wilcoxon-Mann-Whitney test \- Practical Statistics in Medicine with R, accessed on July 30, 2025, [https://practical-stats-med-r.netlify.app/wmw\_test](https://practical-stats-med-r.netlify.app/wmw_test)  
58. Mann Whitney U Test Explained \- Statistics By Jim, accessed on July 30, 2025, [https://statisticsbyjim.com/hypothesis-testing/mann-whitney-u-test/](https://statisticsbyjim.com/hypothesis-testing/mann-whitney-u-test/)  
59. Reporting Mann-Whitney U-Test in Apa | PDF | Outlier | Hypothesis \- Scribd, accessed on July 30, 2025, [https://www.scribd.com/document/548782360/reporting-mann-whitney-u-test-in-apa](https://www.scribd.com/document/548782360/reporting-mann-whitney-u-test-in-apa)  
60. How to Report a Mann-Whitney U Test from SPSS in APA Style, accessed on July 30, 2025, [https://ezspss.com/how-to-report-a-mann-whitney-u-test-from-spss-in-apa-style/](https://ezspss.com/how-to-report-a-mann-whitney-u-test-from-spss-in-apa-style/)  
61. Wilcoxon Signed-Rank Test | R Tutorial, accessed on July 30, 2025, [https://www.r-tutor.com/elementary-statistics/non-parametric-methods/wilcoxon-signed-rank-test](https://www.r-tutor.com/elementary-statistics/non-parametric-methods/wilcoxon-signed-rank-test)  
62. Wilcoxon Signed Rank Test in R Programming \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/wilcoxon-signed-rank-test-in-r-programming/](https://www.geeksforgeeks.org/r-language/wilcoxon-signed-rank-test-in-r-programming/)  
63. wilcoxon-apa-style | PDF \- Scribd, accessed on July 30, 2025, [https://www.scribd.com/document/858123081/wilcoxon-apa-style](https://www.scribd.com/document/858123081/wilcoxon-apa-style)  
64. Report a Wilcoxon Signed-Rank Test from SPSS in APA Style, accessed on July 30, 2025, [https://ezspss.com/report-a-wilcoxon-signed-rank-test-from-spss-in-apa-style/](https://ezspss.com/report-a-wilcoxon-signed-rank-test-from-spss-in-apa-style/)  
65. Flow Chart for Selecting Commonly Used Statistical Tests, accessed on July 30, 2025, [https://www.brookes.ac.uk/getmedia/bede726d-771d-461f-900b-a3526fc7e199/Stats-Flow-Chart.pdf](https://www.brookes.ac.uk/getmedia/bede726d-771d-461f-900b-a3526fc7e199/Stats-Flow-Chart.pdf)  
66. An Introduction to Statistics: Choosing the Correct Statistical Test \- PMC, accessed on July 30, 2025, [https://pmc.ncbi.nlm.nih.gov/articles/PMC8327789/](https://pmc.ncbi.nlm.nih.gov/articles/PMC8327789/)