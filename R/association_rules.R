# Association-rule mining implemented in base R.
#
# Computes support, confidence, and lift for two-item rules over a small
# market-basket transaction set. The transactions are generated deterministically
# so the results are reproducible without any external package.

# Generate a deterministic list of transactions (each a character vector of items).
make_transactions <- function(n = 400, seed = 1) {
  set.seed(seed)
  items <- c("bread", "milk", "eggs", "butter", "beer", "diapers", "cola", "chips")
  transactions <- vector("list", n)
  for (i in seq_len(n)) {
    basket <- character(0)
    if (runif(1) < 0.6) basket <- c(basket, "bread")
    if ("bread" %in% basket && runif(1) < 0.7) basket <- c(basket, "butter")
    if (runif(1) < 0.5) basket <- c(basket, "milk")
    if ("milk" %in% basket && runif(1) < 0.6) basket <- c(basket, "eggs")
    if (runif(1) < 0.3) basket <- c(basket, "diapers")
    if ("diapers" %in% basket && runif(1) < 0.8) basket <- c(basket, "beer")
    if (runif(1) < 0.4) basket <- c(basket, "cola")
    if ("cola" %in% basket && runif(1) < 0.7) basket <- c(basket, "chips")
    transactions[[i]] <- unique(basket)
  }
  transactions
}

# Compute two-item association rules above support and confidence thresholds.
# Returns a data frame ordered by lift (descending).
association_rules <- function(transactions, min_support = 0.05, min_confidence = 0.5) {
  n <- length(transactions)
  items <- sort(unique(unlist(transactions)))
  support1 <- sapply(items, function(it) mean(sapply(transactions, function(t) it %in% t)))
  names(support1) <- items

  rules <- data.frame(
    antecedent = character(0), consequent = character(0),
    support = numeric(0), confidence = numeric(0), lift = numeric(0),
    stringsAsFactors = FALSE
  )
  for (a in items) {
    for (b in items) {
      if (a == b) next
      both <- mean(sapply(transactions, function(t) a %in% t && b %in% t))
      if (both < min_support || support1[a] == 0) next
      conf <- both / support1[a]
      if (conf < min_confidence) next
      lift <- conf / support1[b]
      rules <- rbind(rules, data.frame(
        antecedent = a, consequent = b,
        support = both, confidence = conf, lift = lift,
        stringsAsFactors = FALSE
      ))
    }
  }
  rules[order(-rules$lift), ]
}

# Round the numeric columns of a rules data frame for display.
round_rules <- function(rules, digits = 4) {
  rules$support <- round(rules$support, digits)
  rules$confidence <- round(rules$confidence, digits)
  rules$lift <- round(rules$lift, digits)
  rules
}

run_association <- function() {
  transactions <- make_transactions()
  list(
    n_transactions = length(transactions),
    rules = association_rules(transactions)
  )
}
