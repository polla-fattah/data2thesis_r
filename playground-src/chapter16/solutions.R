# From Data to Thesis: Research Data Analysis with R
# Playground, Chapter 16: Solutions
#
# One possible solution for each exercise in parts A and B, and model answers
# for part C. Part D has no solutions: the tasks are open, and there are many
# good ways to answer them.

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

# Exercise 1: for a trend without seasonality, naive is best of the three. With
# the clinic's weekly pattern, seasonal naive still wins (MAE 7.0 against 10.7
# and 11.0 on the continued pattern), but misses the trend by 7 visits a day.
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


# Exercise 2: the seasonally adjusted series shows the trend (yearly averages
# about 31, 34, 35, 37, 38) and the awareness-week spike
visits_stl <- visits |>
  model(STL(visits ~ season(period = 52), robust = TRUE)) |>
  components()
autoplot(visits_stl, season_adjust)


# Exercise 3: MAE 10.2 (K = 2), 7.8 (K = 6), 9.2 (K = 12): too few waves cannot
# follow the sharp steps; too many start to fit noise
visits_train <- visits |> filter(week_start < as.Date("2024-09-01"))
visits_train |>
  model(
    k2  = ARIMA(log(visits) ~ fourier(period = 52, K = 2) + PDQ(0, 0, 0)),
    k6  = ARIMA(log(visits) ~ fourier(period = 52, K = 6) + PDQ(0, 0, 0)),
    k12 = ARIMA(log(visits) ~ fourier(period = 52, K = 12) + PDQ(0, 0, 0))
  ) |>
  forecast(h = 52) |>
  accuracy(visits) |>
  select(.model, RMSE, MAE)


# Exercise 4: on year 4, STL and ETS is still best (MAE 5.9), ahead of seasonal
# naive (6.6), Fourier (8.7), mean (14.3), and naive (30.0)
train_3 <- visits |> filter(week_start < as.Date("2023-09-01"))
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


# Exercise 5: the first exam peak starts in week 16 (mid-December 2025); weeks
# 12 to 15: median about 193 visits, 95% interval about 151 to 247 (169 in the
# same weeks of 2024/25)
final_fit <- visits |>
  model(stl_ets = decomposition_model(
    STL(log(visits) ~ season(period = 52), robust = TRUE),
    ETS(season_adjust ~ season("N"))
  ))
final_fit |> forecast(h = 52) |> as_tibble() |> select(week, .mean) |> print(n = 20)

set.seed(2026)
futures <- final_fit |> generate(h = 52, times = 1000)
four_weeks <- futures |>
  as_tibble() |>
  group_by(.rep) |>
  slice(12:15) |>
  summarise(total = sum(.sim))
quantile(four_weeks$total, c(0.025, 0.5, 0.975))


# Exercise 6 (model answer): "The 95% prediction interval is the range within
# which we expect the actual visits to fall in 19 weeks out of 20, if the
# patterns of the past five years continue. Plan for the middle, and expect
# about one week in 20 outside it, most likely above it in busy periods."


# Exercise 7: with twice the noise the series is more jagged; its SD grows only
# from 9.0 to 10.6, but the unforecastable part doubles, and so, roughly, would
# the width of the forecast intervals
par(mfrow = c(2, 1), mar = c(4, 4, 2, 1))
for (noise_sd in c(3, 6)) {
  set.seed(4)
  week <- 1:156
  series <- 30 + 0.05 * week + 12 * sin(2 * pi * week / 52) + rnorm(156, sd = noise_sd)
  plot(week, series, type = "l", main = paste("Noise SD", noise_sd),
       xlab = "Week", ylab = "Series", ylim = c(10, 60))
  print(round(c(noise_sd = noise_sd, series_sd = sd(series)), 2))
}
par(mfrow = c(1, 1))


# ==============================================================================
# B. GO FURTHER
# ==============================================================================

counselling <- read.csv("counselling_visits.csv")


# Exercise 8: mean 13.0, seasonal naive 7.5, seasonal naive with growth 4.5
set.seed(1)
week <- 1:208
series <- 50 + 0.1 * week + 15 * sin(2 * pi * week / 52) + rnorm(208, sd = 4)
actual <- series[157:208]
last_year <- series[105:156]
c(mean          = mae_of(actual, mean(series[1:156])),
  snaive        = mae_of(actual, last_year),
  snaive_growth = mae_of(actual, last_year + 0.1 * 52))


# Exercise 9: lag 1: 0.69 both ways; lag 52: cor() 0.87, acf() 0.68, because
# acf() uses the whole-series mean and divides by the full length
x <- counselling$visits
n <- length(x)
c(lag_1  = cor(x[-1], x[-n]),
  lag_52 = cor(x[-(1:52)], x[1:(n - 52)]))
acf(x, lag.max = 52, plot = FALSE)$acf[c(2, 53)]


# Exercise 10: the swing grows from 44 to 232 thousand passengers; on the log
# scale it is almost constant (0.35 and 0.47)
par(mfrow = c(2, 1), mar = c(4, 4, 2, 1))
plot(AirPassengers, ylab = "Passengers (thousands)")
plot(log(AirPassengers), ylab = "log(passengers)")
par(mfrow = c(1, 1))
swing     <- tapply(AirPassengers, floor(time(AirPassengers)), function(v) max(v) - min(v))
log_swing <- tapply(log(AirPassengers), floor(time(AirPassengers)), function(v) max(v) - min(v))
rbind(swing = swing[c("1949", "1960")], log_swing = round(log_swing[c("1949", "1960")], 2))


# Exercise 11: mean 27.6 ppm, seasonal naive 2.3, with a year's growth (1.7
# ppm) 0.4
y <- as.numeric(co2)
train <- 1:(length(y) - 24)
test  <- (length(y) - 23):length(y)
n_train <- length(train)
last_year <- y[n_train - 12 + ((0:23) %% 12) + 1]
growth <- y[n_train] - y[n_train - 12]
with_growth <- last_year + growth * (1 + (0:23) %/% 12)
c(mean          = mae_of(y[test], mean(y[train])),
  snaive        = mae_of(y[test], last_year),
  snaive_growth = mae_of(y[test], with_growth))
growth


# ==============================================================================
# C. CHECK YOUR UNDERSTANDING: model answers
# ==============================================================================

# 1. Each observation carries over much of what shaped the one before it; the
#    dependence (autocorrelation) makes forecasting possible.
# 2. Trend: long-term direction. Season: a pattern repeating with a fixed
#    period. Noise: what is left, which cannot be forecast.
# 3. A real forecast uses only the past; a random split would let the model
#    fill gaps between known weeks and overstate its accuracy.
# 4. A range expected to contain a single future value with a given
#    probability, if the model holds; wider than a confidence interval.
# 5. An error means nothing alone; benchmarks show whether a model adds
#    anything beyond the simplest methods.


# ==============================================================================
# D. DO IT YOURSELF
# No solutions: these tasks are open. Compare your approach with the methods of
# Chapter 16, and discuss your choices with a fellow student or your supervisor.
# ==============================================================================
