# Lightweight base-R test suite using stopifnot.
#
# Run with:
#   Rscript tests/test_basics.R
# Exits with a non-zero status on the first failed assertion, which is what the
# continuous integration workflow checks.

root <- getwd()
source(file.path(root, "R", "utils.R"))
source(file.path(root, "R", "hypothesis_tests.R"))
source(file.path(root, "R", "anova.R"))
source(file.path(root, "R", "regression.R"))
source(file.path(root, "R", "pca_factor.R"))
source(file.path(root, "R", "association_rules.R"))

datasets <- load_datasets()
n_pass <- 0
check <- function(cond, msg) {
  if (!isTRUE(cond)) stop(paste("FAIL:", msg), call. = FALSE)
  cat("ok -", msg, "\n")
  n_pass <<- n_pass + 1
}

# Datasets load with expected shapes.
check(nrow(datasets$mtcars) == 32, "mtcars has 32 rows")
check(ncol(datasets$arrests) == 4, "USArrests has 4 columns")

# Committed sample CSVs (when present) round-trip to the built-ins exactly.
data_dir <- file.path(root, "data")
if (file.exists(file.path(data_dir, "mtcars.csv"))) {
  from_csv <- load_datasets(data_dir)
  check(isTRUE(all.equal(from_csv$mtcars, datasets$mtcars, tolerance = 1e-9)),
        "mtcars.csv matches the built-in dataset")
  check(isTRUE(all.equal(from_csv$arrests, datasets$arrests, tolerance = 1e-9)),
        "usarrests.csv matches the built-in dataset")
  check(isTRUE(all.equal(from_csv$tooth$len, datasets$tooth$len)) &&
          identical(as.character(from_csv$tooth$supp),
                    as.character(datasets$tooth$supp)),
        "tooth_growth.csv matches the built-in dataset")
  csv_rules <- run_association(load_transactions(data_dir))$rules
  gen_rules <- run_association()$rules
  check(isTRUE(all.equal(csv_rules, gen_rules, check.attributes = FALSE)),
        "transactions.csv yields the same rules as the seed-1 generator")
}

# Hypothesis tests return finite p-values in [0, 1].
ht <- run_hypothesis_tests(datasets)
check(ht$supp_ttest$p_value >= 0 && ht$supp_ttest$p_value <= 1, "t-test p-value in range")
check(is.finite(ht$gear_vs_cyl$statistic), "chi-square statistic is finite")

# ANOVA: the dose effect on tooth length is strongly significant.
av <- run_anova(datasets)
check(av$dose_effect$p_value < 0.05, "dose effect is significant")

# Regression: a sensible R-squared and a valid accuracy.
rg <- run_regression(datasets)
check(rg$linear$r_squared > 0.7 && rg$linear$r_squared <= 1, "linear R2 is high and valid")
check(rg$logistic$accuracy >= 0 && rg$logistic$accuracy <= 1, "logistic accuracy in range")

# PCA: variance-explained sums to one; first PC dominates for USArrests.
dm <- run_dimensionality(datasets)
check(abs(sum(dm$pca$var_explained) - 1) < 1e-8, "PCA variance sums to 1")
check(dm$pca$var_explained[1] > 0.5, "first PC explains most variance")

# Association rules: known dependencies surface with lift above 1.
ar <- run_association()
check(nrow(ar$rules) > 0, "association rules were found")
check(all(ar$rules$confidence >= 0.5), "all rules meet the confidence threshold")
check(any(ar$rules$antecedent == "diapers" & ar$rules$consequent == "beer"),
      "the planted diapers -> beer rule is recovered")

cat(sprintf("\nAll %d checks passed.\n", n_pass))
