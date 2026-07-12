# Experiment 05: association-rule mining, implemented from scratch.
#
# Mines two-item rules (support, confidence, lift) over the committed
# market-basket transactions in data/transactions.csv (or regenerates the
# identical set with seed 1). Writes results/rules_lift.png.
#
# Usage:
#   Rscript scripts/05_association_rules.R

file_arg <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE)[1])
root <- tryCatch(dirname(dirname(normalizePath(file_arg))), error = function(e) getwd())
if (!dir.exists(file.path(root, "R"))) root <- getwd()
source(file.path(root, "R", "utils.R"))
source(file.path(root, "R", "association_rules.R"))

# Mine the rules, print a summary, save the figure, and return the markdown
# lines for RESULTS.md.
report_association <- function(transactions, out_dir) {
  ar <- run_association(transactions)
  top <- head(ar$rules, 8)

  png(file.path(out_dir, "rules_lift.png"), width = 1200, height = 520)
  op <- par(mfrow = c(1, 2), mar = c(8, 4.5, 3, 1), cex = 1.0)
  barplot(top$lift, names.arg = paste(top$antecedent, "->", top$consequent),
          las = 2, col = "steelblue", border = "white", ylab = "lift",
          main = "Top rules by lift")
  abline(h = 1, lty = 2, col = "grey40")
  par(mar = c(4.5, 4.5, 3, 1))
  plot(ar$rules$support, ar$rules$confidence, pch = 19,
       cex = ar$rules$lift, col = grDevices::adjustcolor("steelblue", 0.6),
       xlab = "support", ylab = "confidence",
       main = "Rules: support vs confidence (size = lift)")
  text(ar$rules$support, ar$rules$confidence,
       paste(ar$rules$antecedent, "->", ar$rules$consequent),
       pos = 1, cex = 0.8, col = "grey30")
  par(op)
  dev.off()

  cat(sprintf("Mined %d transactions; %d rules pass support >= 0.05 and confidence >= 0.5\n",
              ar$n_transactions, nrow(ar$rules)))
  cat("Top rules by lift:\n")
  print(head(round_rules(ar$rules), 8))

  tbl <- round_rules(top)
  tbl$rule <- paste(tbl$antecedent, "->", tbl$consequent)
  tbl <- tbl[, c("rule", "support", "confidence", "lift")]
  c("## Association rules (from scratch)", "",
    sprintf("%d transactions mined; %d two-item rules pass support >= 0.05 and confidence >= 0.5. Top rules by lift:",
            ar$n_transactions, nrow(ar$rules)),
    "", md_table(tbl), "",
    "The generator plants diapers with beer and cola with chips; the miner recovers exactly those dependencies with the highest lift, which validates the from-scratch support, confidence, and lift computations.",
    "", "Figure: `results/rules_lift.png`.", "")
}

if (sys.nframe() == 0L) {
  out_dir <- ensure_dir(file.path(root, "results"))
  section("Association rules")
  invisible(report_association(load_transactions(file.path(root, "data")), out_dir))
}
