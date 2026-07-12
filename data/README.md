# Data

All committed CSVs in this directory are license clean and tiny, and the
whole analysis runs on them with no network access.

| File | Rows | Source |
|------|-----:|--------|
| `mtcars.csv` | 32 | exact copy of base R `datasets::mtcars` (1974 Motor Trend road tests) |
| `tooth_growth.csv` | 60 | exact copy of base R `datasets::ToothGrowth` (guinea pig odontoblast lengths) |
| `usarrests.csv` | 50 | exact copy of base R `datasets::USArrests` (1973 US state arrest rates) |
| `transactions.csv` | 400 baskets | synthetic market-basket set, generated deterministically with `set.seed(1)` |

`scripts/make_sample_data.R` regenerates every file byte for byte, so the
CSVs are fully auditable. `load_datasets()` in `R/utils.R` reads these CSVs
when present and falls back to the built-in copies otherwise; both paths
produce identical results, and the test suite asserts the CSVs match the
built-ins.

There is no external dataset to fetch. `scripts/download_data.R` exists only
to document that.

To run the same analyses on your own data, point the functions in `R/` at
your data frame; they take a data frame and column names.
