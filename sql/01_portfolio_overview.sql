-- ============================================================
-- 01_portfolio_overview.sql
-- Business Questions 1–2: Portfolio KPIs and trends over time
-- ============================================================

-- Q1. Overall portfolio KPIs
SELECT
    COUNT(*)                                                    AS total_loans,
    ROUND(SUM(funded_amnt)::numeric)                            AS total_funded_usd,
    ROUND(AVG(funded_amnt)::numeric)                            AS avg_loan_usd,
    ROUND(AVG(int_rate)::numeric, 2)                            AS avg_interest_rate_pct,
    SUM(is_default)                                             AS total_defaults,
    ROUND(AVG(is_default) * 100, 2)                             AS default_rate_pct,
    ROUND(SUM(net_profit)::numeric)                             AS total_net_profit_usd,
    ROUND((SUM(net_profit) / SUM(funded_amnt) * 100)::numeric, 2) AS portfolio_return_pct
FROM loans;


-- Q2. Trends by loan issue year (vintage analysis)
--     LAG() compares each year's default rate with the previous year
SELECT
    issue_year,
    COUNT(*)                                                      AS loans,
    ROUND((SUM(funded_amnt) / 1e6)::numeric, 1)                   AS funded_million_usd,
    ROUND(AVG(int_rate)::numeric, 2)                              AS avg_interest_rate_pct,
    ROUND(AVG(is_default) * 100, 2)                               AS default_rate_pct,
    ROUND(AVG(is_default) * 100
          - LAG(AVG(is_default) * 100) OVER (ORDER BY issue_year), 2) AS default_rate_change_pts,
    ROUND((SUM(net_profit) / SUM(funded_amnt) * 100)::numeric, 2) AS return_pct
FROM loans
GROUP BY issue_year
ORDER BY issue_year;