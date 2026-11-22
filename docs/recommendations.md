# Findings & Recommendations

**To:** Chief Risk Officer, Head of Lending, Pricing Team
**Scope:** 1,322,229 completed individual loans (2007–2018); policy tested on 445,357 mature test loans (2014–2015)

## Executive Summary
1. **The portfolio is profitable but margins are thin:** borrowers pay 13.21% interest on average, but defaults leave a 2.87% lifetime return overall.
2. **Riskier loans are under-priced:** on mature 36-month loans, return peaks in grades B–C (8.4–8.9%) and falls to 2.8% in grade G, whose safety margin over break-even is only 3.8 points.
3. **A model-based approval rule adds value:** declining the riskiest 10% of applicants avoids 21% of defaults for a 9% loss in volume, and adds **$15.6M of economic profit** at a 6% cost of capital.
4. **The model beats Lending Club's own grade:** at the same 10% decline rate, it avoids ~930 more defaults and adds **$10.1M more** economic profit than declining by sub-grade.

## Key Findings

### Risk
- Default rate rises steadily with grade: **A 5.99% → G 49.53%**
- Strongest borrower risk factors: **DTI** (14.8% → 29.3% default), **missing employment** (26.6%), **renters** (23.1%), **low income** (23.4% below $40K)
- 60-month loans default about **2× more** than 36-month loans (mature data: 25.2% vs 12.6%)
- Riskiest states: Mississippi (25.9%) and Nebraska (25.1%); the biggest business impact comes from **New York and Florida** (large volume, above-average risk)

### Pricing (mature 36-month loans)
| Grade | Default | Break-even | Safety margin | Return |
|---|---|---|---|---|
| B | 10.99% | 28.41% | 17.42 pts | **8.87%** |
| G | 38.55% | 42.33% | **3.78 pts** | **2.82%** |

- Within grade F, return falls from **8.2% (DTI 0–10) to 0.8% (DTI 30+)** → grades do not fully price in debt burden

### Model
- XGBoost: **AUC 0.6834 / Gini 0.3668**, vs 0.6712 / 0.3425 for the sub-grade
- The riskiest 10% of applicants default **9.2× more** than the safest 10% (30.4% vs 3.3%)
- Top risk drivers (SHAP): sub-grade, income, FICO, loan-to-income, recent credit inquiries, DTI, missing employment

## Approval Policy Simulation (test loans, 2014–2015)

| Decline riskiest | Defaults avoided | Volume lost | Default rate | Return | Economic profit (6% hurdle) |
|---|---|---|---|---|---|
| 0% (approve all) | 0% | 0% | 14.46% | 7.24% | $70.4M |
| 5% | 11.4% | 4.6% | 13.49% | 7.49% | $80.5M |
| **10%** | **21.0%** | **9.1%** | **12.69%** | **7.67%** | **$86.0M** |
| 15% | 29.4% | 13.6% | 12.00% | 7.79% | $87.5M |
| 20% | 37.2% | 18.0% | 11.35% | 7.88% | $87.2M |

**Best cut-off depends on the cost of capital:**
| Cost of capital (lifetime) | Best cut-off | Gain vs approve-all |
|---|---|---|
| 0% | Approve all | — |
| 3% | Decline riskiest 5% | +$2.3M |
| 6% | Decline riskiest 15% | +$17.1M |

**Model vs Lending Club grade (same decline rate, 6% hurdle):**
| Decline riskiest | Extra defaults avoided by model | Extra economic profit from model |
|---|---|---|
| 5% | +0.8 pts | +$5.9M |
| 10% | +1.5 pts (~930 loans) | +$10.1M |
| 15% | +1.7 pts | +$12.7M |
| 20% | +1.9 pts | +$14.8M |

## Recommendations
1. **Adopt model-based screening and decline the riskiest 10% of applicants.** It is a robust choice: it breaks even when capital is cheap (3% hurdle), adds $15.6M when capital costs 6%, and sits on the flat, near-optimal part of the profit curve (10–20%).
2. **Use the model, not the grade alone, to choose who to decline.** At every cut-off the model avoids more defaults and earns more.
3. **Re-price grades F and G** (higher rates) or cap their volume. Their return is far below grades B–C for 3–4× the default risk.
4. **Add a DTI-based rate add-on or approval limit** for grades E–G with DTI above 20.
5. **Require extra verification when employment information is missing.**
6. **Monitor New York and Florida closely** (large volume, above-average risk) and apply stricter rules to small-business loans.
7. **Review the cut-off when funding costs change** using the Excel calculator: if the cost of capital rises, move towards declining 15–20%.
8. **Re-evaluate 2016–2018 loans once they mature, and retrain the model regularly.**

## Tools for Decision-Makers
- **Power BI dashboard** (`dashboard/loan_risk_dashboard.pbix`): portfolio, risk drivers, pricing and geography
- **Excel calculator** (`excel/loan_policy_calculator.xlsx`): choose a decline % and cost of capital to see approvals, defaults avoided, profit, economic profit and a verdict, plus a full scenario table

## Assumptions & Limitations
- Cost of capital is applied as a simple lifetime % of the amount lent (a simplification; a full model would charge it on the outstanding balance over time)
- The policy was tested on 2014–2015 loans, which are all 36-month in the mature test set
- Outcomes for declined applicants are never observed (reject inference is out of scope); results assume past approved loans are representative
- Returns are lifetime, not annualised