# Experiment 02: analysis of variance.
#
# One-way ANOVA of tooth length on dose, and a two-way ANOVA with a
# supp x dose interaction. Writes results/anova_effects.png.
#
# Usage:
#   Rscript scripts/02_anova.R

file_arg <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE)[1])
root <- tryCatch(dirname(dirname(normalizePath(file_arg))), error = function(e) getwd())
if (!dir.exists(file.path(root, "R"))) root <- getwd()
source(file.path(root, "R", "utils.R"))
source(file.path(root, "R", "anova.R"))

# Run the ANOVA suite, print a summary, save the figure, and return the
# markdown lines for RESULTS.md.
report_anova <- function(datasets, out_dir) {
  av <- run_anova(datasets)
  tooth <- datasets$tooth

  png(file.path(out_dir, "anova_effects.png"), width = 1100, height = 480)
  op <- par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1), cex = 1.1)
  boxplot(len ~ dose, data = tooth, col = c("grey85", "grey65", "steelblue"),
          main = "Tooth length by dose", xlab = "dose (mg/day)", ylab = "len")
  interaction.plot(factor(tooth$dose), tooth$supp, tooth$len,
                   col = c("steelblue", "grey30"), lwd = 2, lty = 1,
                   xlab = "dose (mg/day)", ylab = "mean len",
                   trace.label = "supp", main = "supp x dose interaction")
  par(op)
  dev.off()

  cat(sprintf("One-way ANOVA len ~ dose: F=%.4f, p=%.3g\n",
              av$dose_effect$f_value, av$dose_effect$p_value))
  cat("Two-way ANOVA len ~ supp * dose:\n")
  print(av$supp_dose)

  two_way <- av$supp_dose[!is.na(av$supp_dose$p_value), ]
  two_way$p_value <- format(signif(two_way$p_value, 3), trim = TRUE)
  c("## Analysis of variance", "",
    sprintf("One-way ANOVA of `len ~ dose`: F = %.2f, p = %.3g.",
            av$dose_effect$f_value, av$dose_effect$p_value),
    "", "Two-way ANOVA of `len ~ supp * dose`:", "", md_table(two_way), "",
    "Figure: `results/anova_effects.png`.", "")
}

if (sys.nframe() == 0L) {
  datasets <- load_datasets(file.path(root, "data"))
  out_dir <- ensure_dir(file.path(root, "results"))
  section("Analysis of variance")
  invisible(report_anova(datasets, out_dir))
}
