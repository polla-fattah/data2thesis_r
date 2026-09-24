# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 15: Time Series Forecasting
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Replace every ______ with your own code.
# Try each exercise yourself before you look at solutions.R.

library(dplyr)
library(ggplot2)
library(tsibble)
library(fable)
library(feasts)

counselling_visits <- read.csv("counselling_visits.csv")

visits <- counselling_visits |>
  mutate(week_start = as.Date(week_start),
         week = yearweek(week_start)) |>
  as_tsibble(index = week)

visits_train <- visits |> filter(week_start < as.Date("2024-09-01"))
visits_test  <- visits |> filter(week_start >= as.Date("2024-09-01"))


# Exercise 1: Benchmarks for a series with a trend
# Add a steady increase of one visit a day to the clinic series, and forecast
# 7 days ahead with MEAN, NAIVE, and SNAIVE. Which forecasts make sense now?
clinic <- tsibble(
  day    = 1:14,
  visits = c(12, 10, 9, 11, 7, 3, 2,   14, 11, 10, 12, 8, 4, 2) + ______,
  index  = day
)


# Exercise 2: The seasonally adjusted series
visits_stl <- visits |>
  model(STL(visits ~ season(period = 52), robust = TRUE)) |>
  components()
# Plot season_adjust against week. What does it show?


# Exercise 3: Fourier models with K = 2, 6, and 12
fourier_fit <- visits_train |>
  model(
    k2  = ARIMA(log(visits) ~ fourier(period = 52, K = 2) + PDQ(0, 0, 0)),
    k6  = ARIMA(log(visits) ~ fourier(period = 52, K = ______) + PDQ(0, 0, 0)),
    k12 = ARIMA(log(visits) ~ fourier(period = 52, K = 12) + PDQ(0, 0, 0))
  )
# Forecast 52 weeks and compare accuracy() on the test year.


# Exercise 4: A different test year
# Train on the first three academic years (before September 2023) and test on
# the fourth. Compare SNAIVE and the STL and ETS model.


# Exercise 5: Visits before the first exams of 2025/26
# Fit the STL and ETS model on all the data, simulate 1000 futures, and add up
# weeks 12 to 15 of the new academic year (the four weeks before the exams).
final_fit <- visits |>
  model(stl_ets = decomposition_model(
    STL(log(visits) ~ season(period = 52), robust = TRUE),
    ETS(season_adjust ~ season("N"))
  ))


# Exercise 6: Explain a prediction interval
# Write a short paragraph for the counselling service explaining what the 95%
# prediction interval for next year's total visits means.
