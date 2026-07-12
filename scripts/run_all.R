# Run every analysis in the project and print a readable summary.
#
# Usage:
#   Rscript scripts/run_all.R

here <- function(...) file.path(dirname(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(FALSE), value = TRUE)[1])))), ...)

# Fall back to the working directory when sourced interactively.
root <- tryCatch(here(), error = function(e) getwd())
if (!dir.exists(file.path(root, "R"))) root <- getwd()

source(file.path(root, "R", "utils.R"))
source(file.path(root, "R", "hypothesis_tests.R"))
source(file.path(root, "R", "anova.R"))
source(file.path(root, "R", "regression.R"))
source(file.path(root, "R", "pca_factor.R"))
source(file.path(root, "R", "association_rules.R"))

datasets <- load_datasets()
out_dir <- ensure_dir(file.path(root, "results"))

section("Hypothesis tests")
ht <- run_hypothesis_tests(datasets)
cat(sprintf("Shapiro-Wilk on ToothGrowth len: W=%.4f, p=%.4f\n",
            ht$normality_len$statistic, ht$normality_len$p_value))
cat(sprintf("Welch t-test len ~ supp: t=%.4f, df=%.2f, p=%.4f, mean diff=%.3f\n",
            ht$supp_ttest$statistic, ht$supp_ttest$df, ht$supp_ttest$p_value,
            ht$supp_ttest$mean_diff))
cat(sprintf("Chi-square gear vs cyl: X2=%.4f, df=%d, p=%.4f\n",
            ht$gear_vs_cyl$statistic, ht$gear_vs_cyl$df, ht$gear_vs_cyl$p_value))

section("Analysis of variance")
av <- run_anova(datasets)
cat(sprintf("One-way ANOVA len ~ dose: F=%.4f, p=%.6f\n",
            av$dose_effect$f_value, av$dose_effect$p_value))
cat("Two-way ANOVA len ~ supp * dose:\n")
print(av$supp_dose)

section("Regression")
rg <- run_regression(datasets)
cat(sprintf("Linear mpg ~ wt + hp + qsec: R2=%.4f, adj R2=%.4f\n",
            rg$linear$r_squared, rg$linear$adj_r_squared))
cat("Coefficients:\n"); print(round(rg$linear$coefficients, 4))
cat(sprintf("Logistic am ~ wt + hp: in-sample accuracy=%.4f\n", rg$logistic$accuracy))

section("Dimensionality reduction")
dm <- run_dimensionality(datasets)
cat("PCA of USArrests, variance explained:\n")
print(round(dm$pca$var_explained, 4))
cat(sprintf("First two components explain %.1f%% of variance\n",
            100 * dm$pca$cumulative[2]))
cat("Factor analysis loadings (mtcars, 2 factors):\n")
print(round(dm$factor$loadings, 3))

section("Association rules")
ar <- run_association()
cat(sprintf("Mined %d transactions; top rules by lift:\n", ar$n_transactions))
print(head(round_rules(ar$rules), 8))

# Figures.
png(file.path(out_dir, "pca_biplot.png"), width = 700, height = 700)
biplot(prcomp(datasets$arrests, scale. = TRUE), main = "PCA of USArrests")
dev.off()

png(file.path(out_dir, "rules_lift.png"), width = 800, height = 500)
top <- head(ar$rules, 8)
barplot(top$lift, names.arg = paste(top$antecedent, "->", top$consequent),
        las = 2, col = "steelblue", ylab = "lift", main = "Top association rules by lift")
dev.off()

cat("\nWrote figures to", out_dir, "\n")
