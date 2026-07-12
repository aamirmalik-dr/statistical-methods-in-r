# Statistical methods in R

A collection of rigorous statistical analyses in R, covering hypothesis testing,
analysis of variance, regression, dimensionality reduction, and association-rule
mining. Everything is written in base R and runs on datasets that ship with R,
so the whole project is reproducible with a plain R installation and no extra
packages.

## What it does

- **Hypothesis testing** (`R/hypothesis_tests.R`): Shapiro-Wilk normality, a
  Welch two-sample t-test, and a chi-square test of independence.
- **Analysis of variance** (`R/anova.R`): one-way and two-way ANOVA with an
  interaction term.
- **Regression** (`R/regression.R`): multiple linear regression and logistic
  regression with in-sample accuracy.
- **Dimensionality reduction** (`R/pca_factor.R`): principal component analysis
  and a varimax-rotated maximum-likelihood factor analysis.
- **Association-rule mining** (`R/association_rules.R`): support, confidence, and
  lift for two-item rules, implemented from scratch in base R over a generated
  market-basket transaction set.

## What it does not do

- It does not depend on external packages such as `arules`, `psych`, or
  `ggplot2`; the association-rule mining and all plots use base R so the project
  installs and runs anywhere R does.
- The datasets are small and built in, chosen for reproducibility rather than
  scale.

## Requirements

Base R (4.x). No package installation is required.

## Run

```bash
Rscript scripts/run_all.R      # runs every analysis and writes figures to results/
Rscript tests/test_basics.R    # runs the base-R test suite
```

## Results

Produced by `Rscript scripts/run_all.R` in this repository (base R datasets,
deterministic seed for the transactions).

### Hypothesis tests and ANOVA

| Test | Result |
|------|--------|
| Shapiro-Wilk (ToothGrowth len) | W = 0.9674, p = 0.109 (normal) |
| Welch t-test (len ~ supp) | t = 1.915, p = 0.061 |
| Chi-square (gear vs cyl) | X2 = 18.04, df = 4, p = 0.0012 |
| One-way ANOVA (len ~ dose) | F = 67.42, p < 1e-6 |
| Two-way ANOVA (dose term) | F = 92.0, p = 4e-18 |

### Regression

- Linear `mpg ~ wt + hp + qsec`: R^2 = 0.835, adjusted R^2 = 0.817.
- Logistic `am ~ wt + hp`: in-sample accuracy 0.9375.

### Dimensionality reduction

- PCA of USArrests: the first two components explain 86.8 percent of the
  variance (0.620 and 0.247).
- Factor analysis of mtcars recovers a clear two-factor structure (a size/power
  factor and a quarter-mile-time factor).

### Association rules (top by lift)

| Rule | Support | Confidence | Lift |
|------|--------:|-----------:|-----:|
| diapers -> beer | 0.275 | 0.846 | 3.08 |
| cola -> chips   | 0.268 | 0.677 | 2.53 |
| eggs -> milk    | 0.300 | 1.000 | 1.91 |
| butter -> bread | 0.440 | 1.000 | 1.69 |

The mining recovers exactly the dependencies planted in the transaction
generator (diapers with beer, cola with chips, and so on), which is the intended
sanity check that the from-scratch support, confidence, and lift are correct.

Figures (a PCA biplot and a rule-lift bar chart) are written to `results/`.

## Layout

```
R/            utils, hypothesis_tests, anova, regression, pca_factor, association_rules
scripts/      run_all.R, download_data.R (data note)
tests/        test_basics.R (base-R stopifnot suite)
data/         see data/README.md (all data is built in)
```

## License

MIT, see [LICENSE](LICENSE).

## Author

Aamir Malik. [GitHub](https://github.com/aamirmalik-dr) ·
[LinkedIn](https://linkedin.com/in/dr-aamirmalik)
