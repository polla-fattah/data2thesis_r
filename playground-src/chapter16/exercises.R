# FROM DATA TO THESIS: Using R for Non-Technical
# Playground, Chapter 16: Time Series Forecasting
#
# Four parts, as on the playground page:
#   A. Practise the chapter       the book's exercises, with tsibble, fable,
#                                 and feasts
#   B. Go further                 new exercises beyond the book, in base R
#   C. Check your understanding   short questions; answers in solutions.R
#   D. Do it yourself             open tasks with no starter code and no answers
#
# Run a line with Ctrl+Enter (Cmd+Enter on a Mac).
# Try each exercise yourself before you look at solutions.R.

library(dplyr)
library(tsibble)
library(fable)
library(feasts)

counselling_visits <- read.csv("counselling_visits.csv") |>
  mutate(week_start = as.Date(week_start))
visits <- counselling_visits |>
  mutate(week = yearweek(week_start)) |>
  as_tsibble(index = week)

mae_of <- function(actual, forecast) mean(abs(actual - forecast))


# ==============================================================================
# A. PRACTISE THE CHAPTER
# ==============================================================================

# Exercise 1: Benchmarks for a series with a trend
# The clinic series plus one visit a day. Which benchmark is best?
clinic <- tsibble(
  day    = 1:14,
  visits = c(12, 10, 9, 11, 7, 3, 2,   14, 11, 10, 12, 8, 4, 2) + 1:14,
  index  = day
)
clinic |>
  model(mean = MEAN(visits), naive = NAIVE(visits), snaive = SNAIVE(visits ~ lag(______))) |>
  forecast(h = 7) |>
  as_tibble() |>
  select(.model, day, .mean) |>
  tidyr::pivot_wider(names_from = .model, values_from = .mean)


# Exercise 2: The seasonally adjusted series
visits_stl <- visits |>
  model(STL(visits ~ season(period = 52), robust = TRUE)) |>
  components()
autoplot(visits_stl, ______)


# Exercise 3: Fourier models with K = 2 and K = 12
visits_train <- visits |> filter(week_start < as.Date("2024-09-01"))
visits_train |>
  model(
    k2  = ARIMA(log(visits) ~ fourier(period = 52, K = 2) + PDQ(0, 0, 0)),
    k6  = ARIMA(log(visits) ~ fourier(period = 52, K = 6) + PDQ(0, 0, 0)),
    k12 = ARIMA(log(visits) ~ fourier(period = 52, K = ______) + PDQ(0, 0, 0))
  ) |>
  forecast(h = 52) |>
  accuracy(visits) |>
  select(.model, RMSE, MAE)


# Exercise 4: Train on three years, test on the fourth
train_3 <- visits |> filter(week_start < as.Date("______"))
test_4  <- visits |> filter(week_start >= as.Date("2023-09-01"),
                            week_start <  as.Date("2024-09-01"))
train_3 |>
  model(
    mean     = MEAN(visits),
    naive    = NAIVE(visits),
    snaive   = SNAIVE(visits ~ lag(52)),
    stl_ets  = decomposition_model(
                 STL(log(visits) ~ season(period = 52), robust = TRUE),
                 ETS(season_adjust ~ season("N"))
               ),
    fourier  = ARIMA(log(visits) ~ fourier(period = 52, K = 6) + PDQ(0, 0, 0))
  ) |>
  forecast(h = 52) |>
  accuracy(test_4) |>
  select(.model, RMSE, MAE) |>
  arrange(MAE)


# Exercise 5: Visits in the four weeks before the first exam period
final_fit <- visits |>
  model(stl_ets = decomposition_model(
    STL(log(visits) ~ season(period = 52), robust = TRUE),
    ETS(season_adjust ~ season("N"))
  ))
final_fit |> forecast(h = 52) |> as_tibble() |> select(week, .mean) |> print(n = 20)

set.seed(2026)
futures <- final_fit |> ______(h = 52, times = 1000)
four_weeks <- futures |>
  as_tibble() |>
  group_by(.rep) |>
  slice(12:15) |>
  summarise(total = sum(.sim))
quantile(four_weeks$total, c(0.025, 0.5, 0.975))


# Exercise 6: Explaining a prediction interval
# A short paragraph for the counselling service.


# Exercise 7: Twice the noise in the artificial series
par(mfrow = c(2, 1), mar = c(4, 4, 2, 1))
for (noise_sd in c(3, ______)) {
  set.seed(4)
  week <- 1:156
  series <- 30 + 0.05 * week + 12 * sin(2 * pi * week / 52) + rnorm(156, sd = noise_sd)
  plot(week, series, type = "l", main = paste("Noise SD", noise_sd),
       xlab = "Week", ylab = "Series", ylim = c(10, 60))
  print(round(c(noise_sd = noise_sd, series_sd = sd(series)), 2))
}
par(mfrow = c(1, 1))


# ==============================================================================
# B. GO FURTHER (base R, as on the playground page)
# ==============================================================================

counselling <- read.csv("counselling_visits.csv")


# Exercise 8: Build a series and forecast it
set.seed(1)
week <- 1:208
series <- 50 + 0.1 * week + 15 * sin(2 * pi * week / 52) + rnorm(208, sd = 4)
actual <- series[157:208]
last_year <- series[105:156]
c(mean          = mae_of(actual, mean(series[1:156])),
  snaive        = mae_of(actual, last_year),
  snaive_growth = mae_of(actual, last_year + 0.1 * ______))


# Exercise 9: Autocorrelation by hand, against acf()
x <- counselling$visits
n <- length(x)
c(lag_1  = cor(x[-1], x[-n]),
  lag_52 = cor(x[-(1:______)], x[1:(n - 52)]))
acf(x, lag.max = 52, plot = FALSE)$acf[c(2, 53)]


# Exercise 10: Air passengers and growing swings
par(mfrow = c(2, 1), mar = c(4, 4, 2, 1))
plot(AirPassengers, ylab = "Passengers (thousands)")
plot(______(AirPassengers), ylab = "log(passengers)")
par(mfrow = c(1, 1))
swing     <- tapply(AirPassengers, floor(time(AirPassengers)), function(v) max(v) - min(v))
log_swing <- tapply(log(AirPassengers), floor(time(AirPassengers)), function(v) max(v) - min(v))
rbind(swing = swing[c("1949", "1960")], log_swing = round(log_swing[c("1949", "1960")], 2))


# Exercise 11: Carbon dioxide and the missing trend
y <- as.numeric(co2)
train <- 1:(length(y) - 24)
test  <- (length(y) - 23):length(y)
n_train <- length(train)
last_year <- y[n_train - 12 + ((0:23) %% 12) + 1]
growth <- y[n_train] - y[n_train - ______]
with_growth <- last_year + growth * (1 + (0:23) %/% 12)
c(mean          = mae_of(y[test], mean(y[train])),
  snaive        = mae_of(y[test], last_year),
  snaive_growth = mae_of(y[test], with_growth))
growth


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING
# Answer in your own words, then compare with the answers in solutions.R.
# ==============================================================================

# 1. Why are the observations of a time series not independent?
# 2. What is the difference between trend, season, and noise?
# 3. Why must the test period come after the training period?
# 4. What is a prediction interval?
# 5. Why should every forecast be compared with benchmarks?


# ==============================================================================
# D. DO IT YOURSELF
# Open tasks: no starter code, no hints, and no answers. Write your own code
# under each task, as you would for a thesis.
# ==============================================================================

# Task 1: Forecast nottem, UKgas, or ldeaths for two years with benchmarks and
# ETS, evaluate on a held-out period, and report with prediction intervals.
# (as_tsibble() turns a ts object into a tsibble.)



# Task 2: The one-page report for the counselling service on next year's
# demand, with every number from code (generate() for the total).



# Task 3: Three things that could make next year's forecast wrong, and how the
# service would notice each early in the year.
