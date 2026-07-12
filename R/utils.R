# Shared helpers: dataset loading, output paths, and console formatting.
#
# Every analysis runs on small, license-clean datasets. The canonical copies
# ship with base R (mtcars, ToothGrowth, USArrests) and a deterministic
# market-basket generator. scripts/make_sample_data.R exports them to
# data/*.csv so the repository also carries a committed, network-free
# snapshot. load_datasets() prefers the committed CSVs when they exist and
# falls back to the built-ins, so results are identical either way.

# Load the analysis datasets as a named list of data frames.
#
# Args:
#   data_dir: optional path to a directory of committed CSVs. When NULL, or
#     when a file is missing, the base-R built-in dataset is used instead.
#
# Returns: list with elements mtcars, tooth, arrests.
load_datasets <- function(data_dir = NULL) {
  read_or <- function(file, fallback, row_names = FALSE) {
    path <- if (is.null(data_dir)) "" else file.path(data_dir, file)
    if (nzchar(path) && file.exists(path)) {
      if (row_names) utils::read.csv(path, row.names = 1) else utils::read.csv(path)
    } else {
      fallback
    }
  }
  tooth <- read_or("tooth_growth.csv", datasets::ToothGrowth)
  tooth$supp <- factor(tooth$supp)
  list(
    mtcars = read_or("mtcars.csv", datasets::mtcars, row_names = TRUE),
    tooth = tooth,
    arrests = read_or("usarrests.csv", datasets::USArrests, row_names = TRUE)
  )
}

# Load the market-basket transactions as a list of character vectors.
#
# Reads the committed long-format CSV (columns transaction_id, item) when it
# exists, otherwise regenerates the identical set with make_transactions()
# from R/association_rules.R (seed 1, so both paths give the same rules).
load_transactions <- function(data_dir = NULL) {
  path <- if (is.null(data_dir)) "" else file.path(data_dir, "transactions.csv")
  if (nzchar(path) && file.exists(path)) {
    long <- utils::read.csv(path, stringsAsFactors = FALSE)
    long$item[is.na(long$item)] <- ""
    baskets <- unname(split(long$item, long$transaction_id))
    # An empty item marks a deliberately empty basket; strip the marker but
    # keep the transaction so support denominators stay exact.
    lapply(baskets, function(x) x[nzchar(x)])
  } else {
    make_transactions()
  }
}

# Print a labelled section header, used by the runners for readable output.
section <- function(title) {
  cat("\n", strrep("=", 70), "\n", title, "\n", strrep("=", 70), "\n", sep = "")
}

# Ensure an output directory exists and return its path.
ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
  path
}

# Render a data frame as a small GitHub-flavoured markdown table.
#
# Numeric columns are rounded to `digits`. Returns a character vector of
# lines, one per table row plus the header and separator.
md_table <- function(df, digits = 4) {
  fmt <- function(v) {
    if (is.numeric(v)) format(round(v, digits), trim = TRUE) else as.character(v)
  }
  cols <- lapply(df, fmt)
  header <- paste("|", paste(names(df), collapse = " | "), "|")
  sep <- paste("|", paste(rep("---", ncol(df)), collapse = " | "), "|")
  rows <- apply(as.data.frame(cols, stringsAsFactors = FALSE), 1, function(r) {
    paste("|", paste(r, collapse = " | "), "|")
  })
  c(header, sep, rows)
}
