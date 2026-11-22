-- ============================================================
-- 03_pricing_profitability.sql
-- Business Questions 8–9: Is pricing adequate? Who makes / loses money?
-- Uses only MATURE loans to avoid maturity bias:
--   36-month loans issued up to 2015, 60-month loans issued up to 2013
-- ============================================================

-- Q8. Pricing check by grade: actual default rate vs break-even default rate
WITH mature AS (
    SELECT *
    FROM loans
    WHERE (term = 36 AND issue_year <= 2015)
       OR (term = 60 AND issue_year <= 2013)
),
grade_stats AS (
    SELECT
        grade,
        COUNT(*)                                                     AS loans,
        AVG(int_rate)                                                AS avg_rate,
        AVG(is_default)                                              AS default_rate,
        -- default rate weighted by loan amount (matches how profit is measured)
        SUM(funded_amnt) FILTER (WHERE is_default = 1) / SUM(funded_amnt) AS amt_default_rate,
        -- return on good loans and on defaulted loans
        SUM(net_profit) FILTER (WHERE is_default = 0)
            / SUM(funded_amnt) FILTER (WHERE is_default = 0)         AS good_return,
        SUM(net_profit) FILTER (WHERE is_default = 1)
            / SUM(funded_amnt) FILTER (WHERE is_default = 1)         AS bad_return,
        SUM(net_profit) / SUM(funded_amnt)                           AS overall_return,
        SUM(net_profit)                                              AS total_profit
    FROM mature
    GROUP BY grade
),
pricing AS (
    SELECT
        *,
        good_return / (good_return - bad_return)                     AS breakeven_rate
    FROM grade_stats
)
SELECT
    grade,
    loans,
    ROUND(avg_rate::numeric, 2)                                      AS avg_interest_rate_pct,
    ROUND(default_rate * 100, 2)                                     AS default_rate_pct,
    ROUND((amt_default_rate * 100)::numeric, 2)                      AS amt_weighted_default_pct,
    ROUND((breakeven_rate * 100)::numeric, 2)                        AS breakeven_default_pct,
    ROUND(((breakeven_rate - amt_default_rate) * 100)::numeric, 2)   AS safety_margin_pts,
    ROUND((overall_return * 100)::numeric, 2)                        AS return_pct,
    ROUND((total_profit / 1e6)::numeric, 1)                          AS total_profit_million_usd,
    CASE
        WHEN amt_default_rate > breakeven_rate          THEN 'Loss-making'
        WHEN breakeven_rate - amt_default_rate < 0.03   THEN 'Thin margin'
        ELSE 'Healthy'
    END                                                              AS pricing_status
FROM pricing
ORDER BY grade;

-- ============================================================
-- 03_pricing_profitability.sql
-- Business Questions 8–9: Is pricing adequate? Who makes / loses money?
-- Uses only MATURE loans to avoid maturity bias:
--   36-month loans issued up to 2015, 60-month loans issued up to 2013
-- ============================================================

-- Q8b. Robustness check: same pricing check using 36-month loans only (removes term-mix effect)
WITH mature AS (
    SELECT *
    FROM loans
    WHERE term = 36 AND issue_year <= 2015
),
grade_stats AS (
    SELECT
        grade,
        COUNT(*)                                                     AS loans,
        AVG(int_rate)                                                AS avg_rate,
        AVG(is_default)                                              AS default_rate,
        -- default rate weighted by loan amount (matches how profit is measured)
        SUM(funded_amnt) FILTER (WHERE is_default = 1) / SUM(funded_amnt) AS amt_default_rate,
        -- return on good loans and on defaulted loans
        SUM(net_profit) FILTER (WHERE is_default = 0)
            / SUM(funded_amnt) FILTER (WHERE is_default = 0)         AS good_return,
        SUM(net_profit) FILTER (WHERE is_default = 1)
            / SUM(funded_amnt) FILTER (WHERE is_default = 1)         AS bad_return,
        SUM(net_profit) / SUM(funded_amnt)                           AS overall_return,
        SUM(net_profit)                                              AS total_profit
    FROM mature
    GROUP BY grade
),
pricing AS (
    SELECT
        *,
        good_return / (good_return - bad_return)                     AS breakeven_rate
    FROM grade_stats
)
SELECT
    grade,
    loans,
    ROUND(avg_rate::numeric, 2)                                      AS avg_interest_rate_pct,
    ROUND(default_rate * 100, 2)                                     AS default_rate_pct,
    ROUND((amt_default_rate * 100)::numeric, 2)                      AS amt_weighted_default_pct,
    ROUND((breakeven_rate * 100)::numeric, 2)                        AS breakeven_default_pct,
    ROUND(((breakeven_rate - amt_default_rate) * 100)::numeric, 2)   AS safety_margin_pts,
    ROUND((overall_return * 100)::numeric, 2)                        AS return_pct,
    ROUND((total_profit / 1e6)::numeric, 1)                          AS total_profit_million_usd,
    CASE
        WHEN amt_default_rate > breakeven_rate          THEN 'Loss-making'
        WHEN breakeven_rate - amt_default_rate < 0.03   THEN 'Thin margin'
        ELSE 'Healthy'
    END                                                              AS pricing_status
FROM pricing
ORDER BY grade;


-- Q9. Weakest segments: term x grade x DTI band (mature loans, min. 500 loans per segment)
WITH mature AS (
    SELECT *
    FROM loans
    WHERE (term = 36 AND issue_year <= 2015)
       OR (term = 60 AND issue_year <= 2013)
),
segments AS (
    SELECT
        term,
        grade,
        dti_band,
        COUNT(*)                              AS loans,
        AVG(is_default)                       AS default_rate,
        SUM(net_profit) / SUM(funded_amnt)    AS return_rate,
        SUM(net_profit)                       AS total_profit
    FROM mature
    GROUP BY term, grade, dti_band
    HAVING COUNT(*) >= 500
)
SELECT
    term                                       AS term_months,
    grade,
    dti_band,
    loans,
    ROUND(default_rate * 100, 2)               AS default_rate_pct,
    ROUND((return_rate * 100)::numeric, 2)     AS return_pct,
    ROUND((total_profit / 1e6)::numeric, 2)    AS total_profit_million_usd,
    CASE
        WHEN return_rate < 0     THEN 'Loss-making'
        WHEN return_rate < 0.03  THEN 'Thin margin'
        ELSE 'Healthy'
    END                                        AS status,
    RANK() OVER (ORDER BY return_rate)         AS weakest_rank
FROM segments
ORDER BY return_rate
LIMIT 15;