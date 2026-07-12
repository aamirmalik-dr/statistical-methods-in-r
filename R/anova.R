# Analysis of variance: one-way and two-way ANOVA.

# One-way ANOVA of a numeric response across a single factor.
# Returns the F statistic and p-value for the factor.
one_way_anova <- function(data, response, factor) {
  formula <- stats::as.formula(paste(response, "~ factor(", factor, ")"))
  fit <- stats::aov(formula, data = data)
  s <- summary(fit)[[1]]
  list(f_value = s[["F value"]][1], p_value = s[["Pr(>F)"]][1])
}

# Two-way ANOVA with interaction between two factors.
# Returns a data frame of F statistics and p-values per term.
two_way_anova <- function(data, response, factor_a, factor_b) {
  formula <- stats::as.formula(
    paste(response, "~ factor(", factor_a, ") * factor(", factor_b, ")")
  )
  fit <- stats::aov(formula, data = data)
  s <- summary(fit)[[1]]
  terms <- trimws(rownames(s))
  data.frame(
    term = terms,
    f_value = s[["F value"]],
    p_value = s[["Pr(>F)"]],
    row.names = NULL
  )
}

run_anova <- function(datasets) {
  tooth <- datasets$tooth
  list(
    dose_effect = one_way_anova(tooth, "len", "dose"),
    supp_dose = two_way_anova(tooth, "len", "supp", "dose")
  )
}
