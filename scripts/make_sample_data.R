# Export the committed sample data under data/.
#
# The CSVs are exact copies of datasets that ship with base R (mtcars,
# ToothGrowth, USArrests) plus the deterministic market-basket transactions
# from R/association_rules.R (seed 1). They are committed so the whole
# analysis runs offline from files on disk; regenerating them with this
# script reproduces them byte for byte.
#
# Usage:
#   Rscript scripts/make_sample_data.R

file_arg <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE)[1])
root <- tryCatch(dirname(dirname(normalizePath(file_arg))), error = function(e) getwd())
if (!dir.exists(file.path(root, "R"))) root <- getwd()
source(file.path(root, "R", "utils.R"))
source(file.path(root, "R", "association_rules.R"))

data_dir <- ensure_dir(file.path(root, "data"))

# Row names are meaningful for mtcars (car models) and USArrests (states),
# so they are written as the first CSV column and read back with row.names = 1.
utils::write.csv(datasets::mtcars, file.path(data_dir, "mtcars.csv"))
utils::write.csv(datasets::USArrests, file.path(data_dir, "usarrests.csv"))
utils::write.csv(datasets::ToothGrowth, file.path(data_dir, "tooth_growth.csv"),
                 row.names = FALSE)

# Empty baskets are legitimate transactions (they enter the support
# denominator), so they are written as a single row with an empty item that
# load_transactions() strips back out.
transactions <- make_transactions()
items <- lapply(transactions, function(t) if (length(t) > 0) t else "")
long <- data.frame(
  transaction_id = rep(seq_along(items), lengths(items)),
  item = unlist(items)
)
utils::write.csv(long, file.path(data_dir, "transactions.csv"), row.names = FALSE)

cat("Wrote", length(list.files(data_dir, pattern = "[.]csv$")),
    "CSV files to", data_dir, "\n")
