# Data note.
#
# Nothing needs downloading. The committed CSVs under data/ are exact copies
# of datasets that ship with base R (mtcars, ToothGrowth, USArrests) plus a
# deterministic seed-1 transaction set; scripts/make_sample_data.R
# regenerates all of them locally. This script is kept so the layout matches
# the other repositories and to document that choice.
cat("No download needed: the committed CSVs under data/ are exported from\n",
    "base-R datasets by scripts/make_sample_data.R. See data/README.md.\n",
    sep = "")
