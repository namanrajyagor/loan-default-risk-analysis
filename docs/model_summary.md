# Default Risk Model — Summary

## Objective
Predict, at the time of application, the probability that a loan will default, and explain what drives that risk.

## Data and Split
- **Mature loans only** (36-month issued ≤ 2015, 60-month issued ≤ 2013), so every loan has a final outcome: 676,034 loans
- **Time-based split** (past predicts future, not a random split):

| Set | Period | Loans | Default rate |
|---|---|---|---|
| Train | 2007–2013 | 230,677 | 15.65% |
| Test | 2014–2015 | 445,357 | 14.46% |

- The test set is larger because lending volume grew sharply in 2014–2015
- The test set contains only 36-month loans, because 60-month loans from those years had not finished by the data cut-off

## Features (26, all known at application time)
- **Loan:** loan amount, term, interest rate, installment, sub-grade
- **Borrower:** annual income, DTI, employment years (+ missing flag), home ownership, verification status, state, purpose
- **Credit history:** FICO, open/total accounts, revolving balance and utilisation, public records, bankruptcies, delinquencies, recent inquiries, mortgage accounts, credit history length
- **Engineered:** loan-to-income, payment-to-income

**No data leakage:** payment and outcome columns (total payments, recoveries, last payment date, profit) were excluded from the model.

## Models and Results (test set, 2014–2015)
| Model | AUC | Gini |
|---|---|---|
| Sub-grade alone (Lending Club baseline) | 0.6712 | 0.3425 |
| Logistic Regression | 0.6764 | 0.3528 |
| **XGBoost** | **0.6834** | **0.3668** |

- XGBoost improves on Lending Club's own grade by **+0.0121 AUC**. The sub-grade is itself the output of a credit model, so this is added value on top of a professional baseline.
- XGBoost used fixed, conservative settings (no tuning on the test set) and `tree_method="hist"` for memory efficiency.
- Preprocessing for Logistic Regression ran inside a scikit-learn Pipeline (median imputation, scaling, one-hot encoding), fitted on training data only.

## Risk Deciles (XGBoost, test set)
| Decile | Predicted PD | Actual default | Avg interest | Return |
|---|---|---|---|---|
| 1 (safest) | 2.68% | 3.30% | 6.71% | 7.34% |
| 2 | 4.64% | 5.95% | 7.91% | 7.70% |
| 3 | 6.43% | 8.13% | 9.21% | 8.20% |
| 4 | 8.21% | 10.08% | 10.37% | 8.60% |
| 5 | 10.06% | 11.93% | 11.41% | **8.69%** |
| 6 | 12.09% | 14.61% | 12.37% | 8.07% |
| 7 | 14.40% | 16.97% | 13.22% | 7.63% |
| 8 | 17.16% | 19.82% | 14.04% | 6.82% |
| 9 | 20.94% | 23.41% | 15.00% | 5.75% |
| 10 (riskiest) | 28.98% | 30.41% | 16.85% | **3.00%** |

- The riskiest 10% default **9.2× more often** than the safest 10%
- Default rate rises steadily across all 10 deciles, and predicted PD tracks the actual rate closely
- **Return peaks in the middle (decile 5) and falls sharply for the riskiest loans:** decile 10 pays the highest interest but returns only 3.00% → higher rates do not fully compensate for higher risk (confirms the SQL pricing finding)

## Key Risk Drivers (SHAP, 5,000-loan sample)
Top drivers by average impact: sub-grade, annual income, term, interest rate, state, loan-to-income, recent inquiries, DTI, open accounts, purpose, FICO.

| Driver | Effect on default risk |
|---|---|
| Worse sub-grade | ↑ strongly |
| Higher annual income | ↓ |
| Higher FICO | ↓ strongly |
| Higher loan-to-income | ↑ |
| More inquiries in last 6 months | ↑ ("credit-hungry" borrowers) |
| Higher DTI | ↑ |
| Missing employment length | ↑ (matches SQL finding) |
| Certain states and purposes (e.g. small business) | ↑ |

**Notes on interpretation:**
- `term` appears important, but all test loans are 36-month, so it shifts every test loan equally and does not rank them
- For categorical features, SHAP colours are category codes; the spread of values is what matters
- Low revolving balance slightly increases risk — a likely explanation is thin credit history (hypothesis, not proven)

## Outputs
- `data/processed/test_predictions.parquet` — predicted default probability, decile, outcome and profit for each test loan (used in Phase 7)
- `data/processed/risk_deciles.csv`, `model_comparison.csv`, `shap_feature_importance.csv`
- `models/xgb_default_model.json` — trained XGBoost model
- `images/shap_importance.png`, `images/shap_summary.png`

## Limitations
- Test period covers only 36-month loans
- Model performance (AUC 0.68) is typical for consumer credit using application data only
- Lending Club's grade already captures much of the risk, so gains over it are modest