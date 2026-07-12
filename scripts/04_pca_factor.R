# Experiment 04: principal component analysis and factor analysis.
#
# PCA of the USArrests correlation matrix and a varimax-rotated
# maximum-likelihood factor analysis of six mtcars variables. Writes
# results/pca_biplot.png.
#
# Usage:
#   Rscript scripts/04_pca_factor.R

file_arg <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE)[1])
root <- tryCatch(dirname(dirname(normalizePath(file_arg))), error = function(e) getwd())
if (!dir.exists(file.path(root, "R"))) root <- getwd()
source(file.path(root, "R", "utils.R"))
source(file.path(root, "R", "pca_factor.R"))

# Draw the variance-explained bar chart with a cumulative overlay.
plot_scree <- function(var_explained, main = "Variance explained") {
  bp <- barplot(100 * var_explained, names.arg = paste0("PC", seq_along(var_explained)),
                col = "steelblue", border = "white", ylim = c(0, 112),
                ylab = "% of variance", main = main)
  lines(bp, 100 * cumsum(var_explained), type = "b", pch = 19, col = "grey30")
  text(bp, pmin(100 * cumsum(var_explained) + 6, 108),
       sprintf("%.0f%%", 100 * cumsum(var_explained)), col = "grey30")
}

# Run PCA and factor analysis, print a summary, save the figure, and return
# the markdown lines for RESULTS.md.
report_pca_factor <- function(datasets, out_dir) {
  dm <- run_dimensionality(datasets)

  png(file.path(out_dir, "pca_biplot.png"), width = 1250, height = 620)
  op <- par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1), cex = 1.0)
  biplot(stats::prcomp(datasets$arrests, scale. = TRUE),
         main = "PCA biplot of USArrests", col = c("grey45", "steelblue"),
         cex = c(0.7, 1.0))
  plot_scree(dm$pca$var_explained, main = "USArrests variance explained")
  par(op)
  dev.off()

  cat("PCA of USArrests, variance explained:\n")
  print(round(dm$pca$var_explained, 4))
  cat(sprintf("First two components explain %.1f%% of variance\n",
              100 * dm$pca$cumulative[2]))
  cat("Factor analysis loadings (mtcars, 2 factors):\n")
  print(round(dm$factor$loadings, 3))

  pca_tbl <- data.frame(
    component = paste0("PC", seq_along(dm$pca$var_explained)),
    proportion = dm$pca$var_explained,
    cumulative = dm$pca$cumulative
  )
  load_tbl <- data.frame(
    variable = rownames(dm$factor$loadings),
    factor1 = dm$factor$loadings[, 1],
    factor2 = dm$factor$loadings[, 2],
    uniqueness = unname(dm$factor$uniquenesses[rownames(dm$factor$loadings)])
  )
  c("## PCA and factor analysis", "",
    "PCA of USArrests (scaled), variance explained:", "", md_table(pca_tbl), "",
    sprintf("The first two components carry %.1f%% of the total variance.",
            100 * dm$pca$cumulative[2]),
    "", "Varimax-rotated ML factor analysis of six mtcars variables:", "",
    md_table(load_tbl, digits = 3), "",
    "Figure: `results/pca_biplot.png`.", "")
}

if (sys.nframe() == 0L) {
  datasets <- load_datasets(file.path(root, "data"))
  out_dir <- ensure_dir(file.path(root, "results"))
  section("Dimensionality reduction")
  invisible(report_pca_factor(datasets, out_dir))
}
