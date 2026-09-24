# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 15: Solutions
#
# One possible solution for each exercise. Other answers can be right too.

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
clinic <- tsibble(
  day    = 1:14,
  visits = c(12, 10, 9, 11, 7, 3, 2,   14, 11, 10, 12, 8, 4, 2) + 1:14,
  index  = day
)
clinic |>
  model(mean = MEAN(visits), naive = NAIVE(visits), snaive = SNAIVE(visits ~ lag(7))) |>
  forecast(h = 7) |>
  as_tibble() |>
  select(.model, day, .mean) |>
  tidyr::pivot_wider(names_from = .model, values_from = .mean)
# None of the three benchmarks allows for the trend. The mean (15.7) is below
# the recent values, the naive method (16) ignores the weekly pattern, and the
# seasonal naive method repeats last week without the rise. A series with a trend
# needs a method that models it, such as NAIVE(visits ~ drift()) or ETS.


# Exercise 2: The seasonally adjusted series
visits_stl <- visits |>
  model(STL(visits ~ season(period = 52), robust = TRUE)) |>
  components()
ggplot(visits_stl, aes(x = week, y = season_adjust)) +
  geom_line() +
  labs(x = NULL, y = "Seasonally adjusted visits") +
  theme_minimal()
# Without the seasonal swings, the slow rise in demand is easy to see, and so is
# the awareness week of October 2023, which stands out far above its neighbours.


# Exercise 3: Fourier models with K = 2, 6, and 12
fourier_fit <- visits_train |>
  model(
    k2  = ARIMA(log(visits) ~ fourier(period = 52, K = 2) + PDQ(0, 0, 0)),
    k6  = ARIMA(log(visits) ~ fourier(period = 52, K = 6) + PDQ(0, 0, 0)),
    k12 = ARIMA(log(visits) ~ fourier(period = 52, K = 12) + PDQ(0, 0, 0))
  )
fourier_fit |>
  forecast(h = 52) |>
  accuracy(visits) |>
  select(.model, RMSE, MAE)
# K = 6 is best (MAE about 7.8), but all three are worse than the seasonal naive
# benchmark (7.0). K = 2 is too smooth to follow the exam peaks; K = 12 follows the
# training years too closely, noise included. Smooth waves struggle with the
# sharp steps in this seasonal pattern whatever K is.


# Exercise 4: A different test year
fit3 <- visits |>
  filter(week_start < as.Date("2023-09-01")) |>
  model(
    snaive  = SNAIVE(visits ~ lag(52)),
    stl_ets = decomposition_model(
      STL(log(visits) ~ season(period = 52), robust = TRUE),
      ETS(season_adjust ~ season("N"))
    )
  )
fit3 |>
  forecast(h = 52) |>
  accuracy(visits) |>
  select(.model, RMSE, MAE)
# The STL and ETS model is still better (MAE about 5.9 against 6.6), so the
# conclusion does not depend on the choice of test year.


# Exercise 5: Visits before the first exams of 2025/26
final_fit <- visits |>
  model(stl_ets = decomposition_model(
    STL(log(visits) ~ season(period = 52), robust = TRUE),
    ETS(season_adjust ~ season("N"))
  ))
set.seed(2026)
futures <- final_fit |> generate(h = 52, times = 1000)
pre_exam <- futures |>
  as_tibble() |>
  group_by(.rep) |>
  slice(12:15) |>
  summarise(total = sum(.sim))
quantile(pre_exam$total, c(0.025, 0.5, 0.975)) |> round()
# About 190 visits in those four weeks (95% interval about 150 to 250), roughly
# 50 a week: the service should plan extra staff from about week 12.


# Exercise 6: Explain a prediction interval
# For example: "Our best estimate is about 2,100 visits next year. The 95%
# prediction interval, about 1,950 to 2,290, is the range we expect the actual
# number to fall in, 19 times out of 20, if next year follows the same patterns
# as the last five. It does not allow for changes we cannot foresee, such as a
# new booking system or a crisis."
