# Hypothesis testing: normality, two-sample comparison, and independence.

# Shapiro-Wilk normality test on a numeric vector.
# Returns a list with the statistic and p-value.
normality_test <- function(x) {
  res <- shapiro.test(x)
  list(statistic = unname(res$statistic), p_value = res$p.value)
}

# Welch two-sample t-test comparing a numeric response across two groups.
# `data` is a data frame; `response` and `group` are column names.
two_sample_ttest <- function(data, response, group) {
  formula <- stats::as.formula(paste(response, "~", group))
  res <- stats::t.test(formula, data = data)
  list(
    statistic = unname(res$statistic),
    df = unname(res$parameter),
    p_value = res$p.value,
    mean_diff = unname(res$estimate[1] - res$estimate[2])
  )
}

# Chi-square test of independence between two categorical variables.
independence_test <- function(x, y) {
  tbl <- table(x, y)
  res <- suppressWarnings(stats::chisq.test(tbl))
  list(statistic = unname(res$statistic), df = unname(res$parameter), p_value = res$p.value)
}

# Run the hypothesis-testing analyses and return the collected results.
run_hypothesis_tests <- function(datasets) {
  tooth <- datasets$tooth
  mtcars <- datasets$mtcars
  list(
    normality_len = normality_test(tooth$len),
    supp_ttest = two_sample_ttest(tooth, "len", "supp"),
    gear_vs_cyl = independence_test(mtcars$gear, mtcars$cyl)
  )
}
