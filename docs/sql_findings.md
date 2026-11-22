# SQL Analysis — Key Findings

## Methodology Notes
- **Data:** 1,322,229 completed individual loans (2007–2018) in PostgreSQL
- **Return** = total net profit ÷ total amount funded (money-weighted, over the full loan life, not annualised)
- **Mature loans:** 36-month loans issued ≤ 2015 and 60-month loans issued ≤ 2013. Used for pricing and profitability, because loans issued later had not finished by the data cut-off (maturity bias: only early defaults and early payoffs are included for those years)
- **Robustness check:** pricing re-tested on 36-month loans only, to remove the effect of mixing loan terms

## Q1. Portfolio Overview
| KPI | Value |
|---|---|
| Total loans | 1,322,229 |
| Total funded | $18.92 billion |
| Average loan | $14,311 |
| Average interest rate | 13.21% |
| Defaults | 262,973 (19.89%) |
| Total net profit | $542.9 million |
| Portfolio return | 2.87% |

**Insight:** Borrowers pay 13.21% interest on average, but defaults leave only a 2.87% lifetime return. Larger loans perform worse (money-weighted return 2.87% vs simple average 3.36%).

## Q2. Trends by Issue Year
- Volume grew from 574 loans (2007) to 375,144 loans / $5.49B (2015)
- 2007–2008: high defaults (27.00%, 20.73%) — financial crisis
- **2009–2013 were the best years:** default 13.69%–16.20%, returns 7.75%–13.99%
- 2014–2015: quality declined as volume grew (default 18.45% → 20.18%, return 9.08% → 3.41%)
- **2016–2018 look unprofitable (−2.07% to −10.93%) because of maturity bias**, not necessarily worse lending

## Q3. Grade and Sub-grade
- Default rate rises steadily: **A 5.99% → G 49.53%** (sub-grades A1 3.22% → G5 52.60%)
- Grades A–C = 75% of all loans
- Interest rises ~5× from A1 to G5, but default rises ~16×

## Q4. Loan Purpose (all loans)
- Debt consolidation (57.89% of loans) and credit card (22.02%) are both profitable (2.91%, 4.36%)
- Small business is the riskiest purpose: 29.67% default, −2.61% return
- Vacation and major purchase default less than debt consolidation but still lose money → default rate alone does not determine profit

## Q5. Borrower Characteristics (all loans)
- **DTI is the strongest borrower factor:** 14.81% (0–10) → 29.30% (30+); DTI 30+ returns −1.69%
- Income: 23.42% default (<$40K) → 14.60% ($150K+)
- Employment length barely matters (18.75%–20.56%), **but "Unknown" employment defaults at 26.64%** (−1.50% return)
- Renters (40% of loans) earn only 0.31%; mortgage holders earn 4.80%

## Q6. Loan Term
| | 36-month | 60-month |
|---|---|---|
| Default rate (mature) | 12.63% | 25.22% |
| Lifetime return (mature) | 10.38% | 18.50% |

60-month loans default about 2× more. Their higher lifetime return comes from 5 years of interest; on a rough per-year basis returns are similar, with more risk and longer capital lock-up.

## Q7. States (min. 1,000 loans)
- Riskiest: Mississippi 25.88%, Nebraska 25.13% (both negative returns on all loans)
- Safest: DC 13.23%, Vermont 13.92%
- **Biggest business impact: New York (108,723 loans, 21.91%) and Florida (94,094 loans, 21.43%)** — large volume, above-average risk, thin returns (1.64%, 1.25%)

## Q8. Pricing Check by Grade (mature loans)
- With both terms mixed, all grades look healthy and returns seem to rise from A to G — **this was a term-mix effect**
- **36-month loans only (fair comparison):**

| Grade | Default | Break-even | Safety margin | Return |
|---|---|---|---|---|
| A | 5.22% | 20.67% | 15.44 pts | 7.22% |
| B | 10.99% | 28.41% | 17.42 pts | **8.87%** |
| C | 17.88% | 33.01% | 15.12 pts | 8.43% |
| D | 24.06% | 36.71% | 12.65 pts | 7.76% |
| E | 29.77% | 38.88% | 9.10 pts | 5.98% |
| F | 35.77% | 42.28% | 6.51 pts | 4.70% |
| G | 38.55% | 42.33% | **3.78 pts** | **2.82%** |

**Insight:** B and C are the sweet spot. **F and G are under-priced for their risk** — G takes 7× the default risk of A for less than half the return.

## Q9. Weakest Segments (term × grade × DTI, mature loans)
- No segment with 500+ loans is loss-making on mature data → earlier losses were mostly driven by immature 2016–2018 loans
- Weakest: F + DTI 30+ (0.76%), F + DTI 20–30 (2.99%), E + DTI 30+ (3.11%), E + DTI 20–30 (3.57%)
- **Within grade F, return falls from 8.16% (DTI 0–10) to 0.76% (DTI 30+)** → grades do not fully price in debt burden

## Early Recommendations (to be tested in Phases 6–7)
1. Raise rates or tighten approval for grades F and G
2. Add a DTI-based rate add-on or approval limit for grades E–G with DTI above 20
3. Require extra verification when employment information is missing
4. Monitor New York and Florida closely (large volume, above-average risk)
5. Re-evaluate 2016–2018 loans once they mature