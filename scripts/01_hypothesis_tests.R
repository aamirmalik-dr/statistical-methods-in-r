# Experiment 01: hypothesis tests.
#
# Shapiro-Wilk normality, a Welch two-sample t-test, and a chi-square test of
# independence, all on committed sample data (or the identical base-R
# built-ins). Writes results/hypothesis_tests.png.
#
# Usage:
#   Rscript scripts/01_hypothesis_tests.R

file_arg <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE)[1])
root <- tryCatch(dirname(dirname(normalizePath(file_arg))), error = function(e) getwd())
if (!dir.exists(file.path(root, "R"))) root <- getwd()
source(file.path(root, "R", "utils.R"))
source(file.path(root, "R", "hypothesis_tests.R"))

# Run the hypothesis-test suite, print a summary, save the figure, and
# return the markdown lines for RESULTS.md.
report_hypothesis_tests <- function(datasets, out_dir) {
  ht <- run_hypothesis_tests(datasets)
  len <- datasets$tooth$len

  png(file.path(out_dir, "hypothesis_tests.png"), width = 1200, height = 420)
  op <- par(mfrow = c(1, 3), mar = c(4.5, 4.5, 3, 1), cex = 1.1)
  hist(len, breaks = 12, freq = FALSE, col = "grey85", border = "white",
       main = "Tooth length distribution", xlab = "len")
  curve(dnorm(x, mean(len), sd(len)), add = TRUE, lwd = 2, col = "steelblue")
  qqnorm(len, main = "Normal Q-Q plot of len", pch = 19, col = "grey40")
  qqline(len, lwd = 2, col = "steelblue")
  boxplot(len ~ supp, data = datasets$tooth, col = c("grey80", "steelblue"),
          main = "len by delivery method", xlab = "supp", ylab = "len")
  par(op)
  dev.off()

  cat(sprintf("Shapiro-Wilk on ToothGrowth len: W=%.4f, p=%.4f\n",
              ht$normality_len$statistic, ht$normality_len$p_value))
  cat(sprintf("Welch t-test len ~ supp: t=%.4f, df=%.2f, p=%.4f, mean diff=%.3f\n",
              ht$supp_ttest$statistic, ht$supp_ttest$df, ht$supp_ttest$p_value,
              ht$supp_ttest$mean_diff))
  cat(sprintf("Chi-square gear vs cyl: X2=%.4f, df=%d, p=%.4f\n",
              ht$gear_vs_cyl$statistic, ht$gear_vs_cyl$df, ht$gear_vs_cyl$p_value))

  tbl <- data.frame(
    test = c("Shapiro-Wilk normality (ToothGrowth len)",
             "Welch two-sample t-test (len ~ supp)",
             "Chi-square independence (gear vs cyl)"),
    statistic = c(ht$normality_len$statistic, ht$supp_ttest$statistic,
                  ht$gear_vs_cyl$statistic),
    df = c(NA, ht$supp_ttest$df, ht$gear_vs_cyl$df),
    p_value = c(ht$normality_len$p_value, ht$supp_ttest$p_value,
                ht$gear_vs_cyl$p_value)
  )
  c("## Hypothesis tests", "", md_table(tbl), "",
    sprintf("Mean difference in tooth length, OJ minus VC: %.3f.",
            ht$supp_ttest$mean_diff),
    "", "Figure: `results/hypothesis_tests.png`.", "")
}

if (sys.nframe() == 0L) {
  datasets <- load_datasets(file.path(root, "data"))
  out_dir <- ensure_dir(file.path(root, "results"))
  section("Hypothesis tests")
  invisible(report_hypothesis_tests(datasets, out_dir))
}
