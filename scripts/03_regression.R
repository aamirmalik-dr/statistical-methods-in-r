# Experiment 03: regression.
#
# Multiple linear regression of mpg on wt, hp, and qsec, plus a logistic
# regression of transmission type on wt and hp. Writes
# results/regression_diagnostics.png.
#
# Usage:
#   Rscript scripts/03_regression.R

file_arg <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE)[1])
root <- tryCatch(dirname(dirname(normalizePath(file_arg))), error = function(e) getwd())
if (!dir.exists(file.path(root, "R"))) root <- getwd()
source(file.path(root, "R", "utils.R"))
source(file.path(root, "R", "regression.R"))

# Run both regressions, print a summary, save the diagnostics figure, and
# return the markdown lines for RESULTS.md.
report_regression <- function(datasets, out_dir) {
  rg <- run_regression(datasets)
  mt <- datasets$mtcars

  png(file.path(out_dir, "regression_diagnostics.png"), width = 1100, height = 1000)
  op <- par(mfrow = c(2, 2), mar = c(4.5, 4.5, 3, 1), cex = 1.1)
  plot(rg$linear$fit, which = 1, pch = 19, col = "grey40")
  plot(rg$linear$fit, which = 2, pch = 19, col = "grey40")
  plot(rg$linear$fit, which = 3, pch = 19, col = "grey40")
  # Logistic fit: predicted P(manual) against weight at the median horsepower.
  wt_grid <- seq(min(mt$wt), max(mt$wt), length.out = 200)
  prob <- stats::predict(
    rg$logistic$fit,
    newdata = data.frame(wt = wt_grid, hp = stats::median(mt$hp)),
    type = "response"
  )
  plot(mt$wt, mt$am, pch = 19, col = ifelse(mt$am == 1, "steelblue", "grey40"),
       xlab = "weight (1000 lb)", ylab = "P(manual transmission)",
       main = "Logistic fit at median hp")
  lines(wt_grid, prob, lwd = 2, col = "steelblue")
  abline(h = 0.5, lty = 2, col = "grey60")
  par(op)
  dev.off()

  cat(sprintf("Linear mpg ~ wt + hp + qsec: R2=%.4f, adj R2=%.4f, sigma=%.3f\n",
              rg$linear$r_squared, rg$linear$adj_r_squared, rg$linear$sigma))
  cat("Coefficients:\n")
  print(round(rg$linear$coefficients, 4))
  cat(sprintf("Logistic am ~ wt + hp: in-sample accuracy=%.4f, deviance %.2f -> %.2f\n",
              rg$logistic$accuracy, rg$logistic$null_deviance,
              rg$logistic$residual_deviance))

  coefs <- data.frame(
    term = names(rg$linear$coefficients),
    estimate = unname(rg$linear$coefficients)
  )
  c("## Regression", "",
    sprintf("Linear `mpg ~ wt + hp + qsec`: R^2 = %.3f, adjusted R^2 = %.3f, residual SE = %.3f.",
            rg$linear$r_squared, rg$linear$adj_r_squared, rg$linear$sigma),
    "", md_table(coefs), "",
    sprintf("Logistic `am ~ wt + hp`: in-sample accuracy %.4f at a 0.5 threshold, deviance %.2f (null) to %.2f (residual).",
            rg$logistic$accuracy, rg$logistic$null_deviance,
            rg$logistic$residual_deviance),
    "", "Figure: `results/regression_diagnostics.png`.", "")
}

if (sys.nframe() == 0L) {
  datasets <- load_datasets(file.path(root, "data"))
  out_dir <- ensure_dir(file.path(root, "results"))
  section("Regression")
  invisible(report_regression(datasets, out_dir))
}
