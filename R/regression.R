# Regression: multiple linear regression and logistic regression.
#
# Both models are fit with base R (stats::lm and stats::glm). The fitted
# model objects are returned alongside the headline numbers so callers can
# draw diagnostic plots without refitting.

# Multiple linear regression of mpg on weight, horsepower, and quarter-mile
# time (mtcars).
#
# Returns: list with the fitted lm object, coefficients, residual standard
# error, R-squared, and adjusted R-squared.
linear_regression <- function(data) {
  fit <- stats::lm(mpg ~ wt + hp + qsec, data = data)
  s <- summary(fit)
  list(
    fit = fit,
    coefficients = stats::coef(fit),
    sigma = s$sigma,
    r_squared = s$r.squared,
    adj_r_squared = s$adj.r.squared
  )
}

# Logistic regression predicting transmission type (am) from weight and
# horsepower, fit by maximum likelihood with a binomial GLM.
#
# Returns: list with the fitted glm object, coefficients, in-sample
# classification accuracy at a 0.5 threshold, and the null and residual
# deviances.
logistic_regression <- function(data) {
  fit <- stats::glm(am ~ wt + hp, data = data, family = stats::binomial())
  prob <- stats::predict(fit, type = "response")
  pred <- as.integer(prob > 0.5)
  list(
    fit = fit,
    coefficients = stats::coef(fit),
    accuracy = mean(pred == data$am),
    null_deviance = fit$null.deviance,
    residual_deviance = fit$deviance
  )
}

# Run both regression analyses on mtcars and return the collected results.
run_regression <- function(datasets) {
  mtcars <- datasets$mtcars
  list(
    linear = linear_regression(mtcars),
    logistic = logistic_regression(mtcars)
  )
}
