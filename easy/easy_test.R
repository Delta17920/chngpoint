library(changepoint)
library(EnvCpt)
library(ggplot2)

set.seed(42)

# Create time series with changing AR structure
# Segment 1 (1-200):   AR(1) with phi = 0.8
# Segment 2 (201-400): AR(1) with phi = -0.6
# Segment 3 (401-600): AR(2) with phi1 = 0.5, phi2 = 0.3
n1 <- 200; n2 <- 200; n3 <- 200
n  <- n1 + n2 + n3

seg1 <- arima.sim(list(ar = 0.8),          n = n1, sd = 1)
seg2 <- arima.sim(list(ar = -0.6),         n = n2, sd = 1)
seg3 <- arima.sim(list(ar = c(0.5, 0.3)), n = n3, sd = 1)

data <- as.numeric(c(seg1, seg2, seg3))

cat("Time series length:", n, "\n")
cat("True changepoints at: 200, 400\n\n")

# ── AR1 changepoint detection (NOT using envcpt) ──────────────────────────────
# Format: cbind(response, intercept, lag1)
cat("Running AR1 changepoint detection...\n")
ar1_data <- cbind(data[-1], rep(1, n - 1), data[-n])

ar1cpt <- EnvCpt:::cpt.reg(
  ar1_data,
  method    = "PELT",
  minseglen = 3
)
cat("AR1 changepoints detected at:", changepoint::cpts(ar1cpt), "\n\n")

# ── AR2 changepoint detection (NOT using envcpt) ──────────────────────────────
# Format: cbind(response, intercept, lag1, lag2)
cat("Running AR2 changepoint detection...\n")
ar2_data <- cbind(
  data[-c(1:2)],
  rep(1, n - 2),
  data[2:(n - 1)],
  data[1:(n - 2)]
)

ar2cpt <- EnvCpt:::cpt.reg(
  ar2_data,
  method    = "PELT",
  minseglen = 4
)
cat("AR2 changepoints detected at:", changepoint::cpts(ar2cpt), "\n\n")

# ── Plot ──────────────────────────────────────────────────────────────────────
df <- data.frame(time = 1:n, value = data)

ar1_cpts <- changepoint::cpts(ar1cpt)
ar2_cpts <- changepoint::cpts(ar2cpt) + 1  # offset by 1 due to lag

cpt_lines <- rbind(
  data.frame(xintercept = ar1_cpts,   model = "AR1 detected"),
  data.frame(xintercept = ar2_cpts,   model = "AR2 detected")
)

ggplot(df, aes(x = time, y = value)) +
  geom_line(color = "steelblue", linewidth = 0.6) +
  geom_vline(data = cpt_lines,
             aes(xintercept = xintercept, color = model, linetype = model),
             linewidth = 1) +
  geom_vline(xintercept = c(200, 400),
             color = "black", linetype = "dotted", linewidth = 0.8) +
  scale_color_manual(values = c(
    "AR1 detected" = "#E63946",
    "AR2 detected" = "#2A9D8F"
  )) +
  scale_linetype_manual(values = c(
    "AR1 detected" = "dashed",
    "AR2 detected" = "dashed"
  )) +
  annotate("text", x = 100, y = max(data) * 0.95,
           label = "AR(1)\nphi=0.8",     size = 3.5, color = "grey30") +
  annotate("text", x = 300, y = max(data) * 0.95,
           label = "AR(1)\nphi=-0.6",   size = 3.5, color = "grey30") +
  annotate("text", x = 500, y = max(data) * 0.95,
           label = "AR(2)\nphi=0.5,0.3", size = 3.5, color = "grey30") +
  labs(
    title    = "Easy Test: AR1 and AR2 Changepoint Detection (EnvCpt non-exported functions)",
    subtitle = "Black dotted = true changepoints | Red dashed = AR1 detected | Teal dashed = AR2 detected",
    x        = "Time",
    y        = "Value",
    color    = "Model",
    linetype = "Model"
  ) +
  theme_bw(base_size = 13) +
  theme(legend.position = "bottom")