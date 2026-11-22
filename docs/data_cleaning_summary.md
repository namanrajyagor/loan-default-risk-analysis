# Data Cleaning Summary

## Row Funnel
| Step | Rows |
|---|---|
| Raw dataset (all loans, 2007–2018) | 2,260,701 |
| Kept only completed loans (Fully Paid / Charged Off) | 1,348,059 |
| Dropped rows missing credit history or income | 1,348,029 (−30) |
| Dropped loans with zero annual income | 1,347,668 (−361) |
| Kept only individual applications (removed joint) | **1,322,229** (−25,439) |

## Columns
- Loaded only 36 of the 151 columns to save memory (8 GB RAM laptop), reading the file in chunks of 250,000 rows
- Final clean dataset: **49 columns** (36 original + 13 engineered features)

## Data Type Fixes
- `term`: "36 months" → 36
- `emp_length`: "10+ years" → 10, "< 1 year" → 0 (stored as `emp_years`)
- `issue_d`, `earliest_cr_line`, `last_pymnt_d`: text → dates
- `is_default`: 1 if Charged Off, 0 if Fully Paid

## Missing Values
| Column | Treatment |
|---|---|
| emp_length | Labelled "Unknown" + `emp_length_missing` flag (missing may signal risk) |
| mort_acc | Median (1.0) |
| revol_util | Median (52.2) |
| dti | Median (17.61) |
| pub_rec_bankruptcies | 0 (most common value) |
| last_pymnt_d | Left as is (reference only) |

## Outliers (capped at 99th percentile, rows kept)
| Column | Issue | Fix |
|---|---|---|
| annual_inc | Max $10.99M | Capped at $251,000 (13,471 values) |
| dti | Values of −1 and 999 | Negatives → median; capped at 38.47 (13,446 values) |
| revol_bal | Max $2.9M | Capped at $95,378 (13,477 values) |
| revol_util | Max 892% | Capped at 100% (4,712 values) |

## Engineered Features
- `issue_year`, `issue_month`: for trend and vintage analysis
- `credit_history_years`: years between first credit line and loan issue
- `fico_avg`: average of FICO low and high
- `loan_to_income`, `payment_to_income`: affordability ratios
- `income_band`, `dti_band`, `fico_band`: groups for analysis
- `net_profit`: total payments − funded amount − collection fees
- `return_pct`: net profit ÷ funded amount

## Early Insights
- Fully paid loans return **+15.77%** on average; defaulted loans return **−46.61%**
- One default wipes out the profit of about 3 good loans → segments with a default rate above **~25%** likely lose money
- Default rate falls steadily with FICO: **26.22%** (<670) → **9.38%** (740+)

## Data Leakage Note
Outcome columns (`total_pymnt`, `total_rec_prncp`, `total_rec_int`, `recoveries`, `collection_recovery_fee`, `last_pymnt_d`, `net_profit`, `return_pct`) are used **only for profit analysis**, never as model inputs, because they are only known after the loan ends.