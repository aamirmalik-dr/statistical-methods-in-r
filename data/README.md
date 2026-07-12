# Data

Every analysis in this project runs on datasets that ship with base R
(`mtcars`, `ToothGrowth`, `iris`, `USArrests`), plus a deterministically
generated market-basket transaction set for the association-rule mining. Nothing
is downloaded and nothing external is committed, so the results are fully
reproducible with a base R installation and no extra packages.

To run the same analyses on your own data, load a data frame in `scripts/run_all.R`
in place of the built-in datasets; the functions in `R/` take a data frame and
column names.
