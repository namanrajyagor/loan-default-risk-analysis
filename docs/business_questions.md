# Loan Default Risk & Portfolio Analysis — Business Questions

## Project Objective
Act as a data analyst at a consumer lending company. Leadership wants to understand
why borrowers default, which segments carry the most risk, whether loans are priced
correctly for that risk, and what changes to the approval policy would reduce losses
while protecting business volume.

## Stakeholders
- **Chief Risk Officer** — wants to reduce credit losses
- **Head of Lending / Business** — wants to protect loan volume and revenue
- **Pricing Team** — wants interest rates that match risk

## Dataset
- Source: Lending Club accepted loans, 2007–2018 (Kaggle)
- Scope: individual applications only (joint applications use combined income and DTI stored in separate fields, so they were excluded for consistency)
- **Default definition:** a loan is a default if its status is "Charged Off" (including "Does not meet the credit policy. Status: Charged Off")
- Currency: US Dollars ($)

## Business Questions

### A. Portfolio Overview
1. How many loans have we issued, how much money have we lent, and what is our overall default rate?
2. How has the default rate changed across loan issue years (vintage analysis)?

### B. Risk Drivers
3. How does the default rate vary by loan grade and sub-grade?
4. Which loan purposes (debt consolidation, credit card, small business, etc.) default the most?
5. How do borrower characteristics affect default: income band, debt-to-income (DTI) band, employment length and home ownership?
6. Do 60-month loans default more than 36-month loans?
7. Which US states have the highest and lowest default rates?

### C. Pricing & Profitability
8. For each grade, is the interest rate high enough to cover the losses from defaults? Which grades are mispriced?
9. Which customer segments make money and which lose money for the company?

### D. Prediction & Policy
10. Can we predict, at the time of application, which loans are likely to default? What are the main drivers of risk?
11. If we reject applications above a certain risk score, how many defaults do we avoid, how much business do we lose, and which cut-off maximises profit?

## Success Metrics
- Clear, data-backed answers to all 11 questions
- A risk model evaluated on future loans (time-based validation), not a random split
- A recommended approval cut-off with its expected impact on defaults, volume and profit
- A dashboard and an Excel what-if calculator that business users can use without coding

## Deliverables
| Deliverable | Tool |
|---|---|
| Cleaned dataset | Python (pandas) |
| Loan database | PostgreSQL |
| Analysis queries | SQL |
| Interactive dashboard | Power BI |
| Default risk model + explanations | Python (scikit-learn, XGBoost, SHAP) |
| What-if approval calculator | Excel |
| Findings & recommendations summary | Markdown / PDF |