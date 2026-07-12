# Dimensionality reduction: principal component analysis and factor analysis.

# PCA on a numeric data frame (scaled).
# Returns the standard deviations, proportion of variance explained, and loadings.
run_pca <- function(data) {
  pca <- stats::prcomp(data, scale. = TRUE)
  var_explained <- pca$sdev^2 / sum(pca$sdev^2)
  list(
    sdev = pca$sdev,
    var_explained = var_explained,
    cumulative = cumsum(var_explained),
    loadings = pca$rotation
  )
}

# Maximum-likelihood factor analysis with a varimax rotation.
# Returns the loadings and the proportion of variance each factor explains.
run_factor_analysis <- function(data, n_factors = 2) {
  fa <- stats::factanal(data, factors = n_factors, rotation = "varimax")
  list(
    loadings = unclass(fa$loadings),
    uniquenesses = fa$uniquenesses,
    p_value = fa$PVAL
  )
}

run_dimensionality <- function(datasets) {
  arrests <- datasets$arrests
  list(
    pca = run_pca(arrests),
    factor = run_factor_analysis(datasets$mtcars[, c("mpg", "disp", "hp", "drat", "wt", "qsec")])
  )
}
