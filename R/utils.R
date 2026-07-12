# Shared helpers for the statistical methods project.
#
# Every analysis in this repository runs on datasets that ship with base R, so
# the results are fully reproducible with no download and no external packages.

# Return a named list of the public built-in datasets used across the analyses.
load_datasets <- function() {
  list(
    mtcars = datasets::mtcars,
    tooth = datasets::ToothGrowth,
    iris = datasets::iris,
    arrests = datasets::USArrests
  )
}

# Print a labelled section header, used by the runner for readable output.
section <- function(title) {
  cat("\n", strrep("=", 70), "\n", title, "\n", strrep("=", 70), "\n", sep = "")
}

# Ensure an output directory exists and return its path.
ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
  path
}
