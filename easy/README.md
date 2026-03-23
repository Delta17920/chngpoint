# Easy Test - AR1 and AR2 Changepoint Detection using EnvCpt

## Objective
Load the `changepoint` and `EnvCpt` packages, create a time series with
changing AR structure, and run the AR1 and AR2 changepoint algorithms using
the non-exported functions in `EnvCpt` (NOT using the `envcpt` function).

## Approach

### Time Series Design
A 600-observation time series with 3 segments and 2 true changepoints:

| Segment | Observations | Model | Parameters |
|---------|-------------|-------|------------|
| 1 | 1 – 200 | AR(1) | φ = 0.8 |
| 2 | 201 – 400 | AR(1) | φ = -0.6 |
| 3 | 401 – 600 | AR(2) | φ₁ = 0.5, φ₂ = 0.3 |

### Non-Exported Functions Used
The wiki explicitly requires NOT using the `envcpt()` function. Instead
we call `EnvCpt:::cpt.reg()` directly with the correct data format:
```r
# AR1 changepoint detection
ar1cpt <- EnvCpt:::cpt.reg(
  cbind(data[-1], rep(1, n - 1), data[-n]),
  method = "PELT", minseglen = 3
)

# AR2 changepoint detection
ar2cpt <- EnvCpt:::cpt.reg(
  cbind(data[-c(1:2)], rep(1, n-2), data[2:(n-1)], data[1:(n-2)]),
  method = "PELT", minseglen = 4
)
```

The data matrix format follows `changepoint::cpt.reg` convention:
- **Column 1:** response variable (lagged series)
- **Column 2:** intercept (column of ones)
- **Column 3+:** lag predictors

## Results

| Model | Detected Changepoints | True Changepoints | Error |
|-------|----------------------|-------------------|-------|
| AR1 | 202, 399 | 200, 400 | ±2, ±1 |
| AR2 | 201, 399 | 200, 400 | ±1, ±1 |

Both algorithms detect the true changepoints with near-perfect accuracy -
within 1-2 observations of the true positions.

## How to Run
```r
install.packages(c("changepoint", "EnvCpt", "ggplot2"))
source("easy/easy_test.R")
```

## Files
| File | Description |
|------|-------------|
| `easy_test.R` | R script |
| `easy_test.png` | Plot of detected changepoints |
| `easy_test_output.png` | Console output screenshot |

## Output Plot
![Changepoint Detection](easy_test.png)

## Console Output
![Console Output](easy_test_output.png)
