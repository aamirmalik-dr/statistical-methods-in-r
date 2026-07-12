# Regression: multiple linear regression and logistic regression.

# Multiple linear regression of mpg on several predictors (mtcars).
# Returns coefficients, R-squared, and adjusted R-squared.
linear_regression <- function(data) {
  fit <- stats::lm(mpg ~ wt + hp + qsec, data = data)
  s <- summary(fit)
  list(
    coefficients = stats::coef(fit),
    r_squared = s$r.squared,
    adj_r_squared = s$adj.r.squared
  )
}

# Logistic regression predicting transmission type (am) from weight and hp.
# Returns coefficients and in-sample classification accuracy.
logistic_regression <- function(data) {
  fit <- stats::glm(am ~ wt + hp, data = data, family = stats::binomial())
  prob <- stats::predict(fit, type = "response")
  pred <- as.integer(prob > 0.5)
  list(
    coefficients = stats::coef(fit),
    accuracy = mean(pred == data$am)
  )
}

run_regression <- function(datasets) {
  mtcars <- datasets$mtcars
  list(
    linear = linear_regression(mtcars),
    logistic = logistic_regression(mtcars)
  )
}
