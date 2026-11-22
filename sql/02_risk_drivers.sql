-- ============================================================
-- 02_risk_drivers.sql
-- Business Questions 3–7: What drives loan defaults?
-- ============================================================

-- Q3. Default rate by grade and sub-grade
--     Window functions show grade-level totals next to each sub-grade
SELECT
    grade,
    sub_grade,
    COUNT(*)                                   AS loans,
    ROUND(AVG(int_rate)::numeric, 2)           AS avg_interest_rate_pct,
    ROUND(AVG(is_default) * 100, 2)            AS default_rate_pct,
    ROUND(SUM(SUM(is_default)) OVER (PARTITION BY grade) * 100.0
          / SUM(COUNT(*)) OVER (PARTITION BY grade), 2) AS grade_default_rate_pct,
    ROUND(SUM(COUNT(*)) OVER (PARTITION BY grade) * 100.0
          / SUM(COUNT(*)) OVER (), 2)          AS grade_share_of_loans_pct
FROM loans
GROUP BY grade, sub_grade
ORDER BY sub_grade;


-- Q4. Default rate by loan purpose
--     RANK() orders purposes from riskiest (1) to safest
SELECT
    purpose,
    COUNT(*)                                                      AS loans,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)            AS share_of_loans_pct,
    ROUND(AVG(funded_amnt)::numeric)                              AS avg_loan_usd,
    ROUND(AVG(is_default) * 100, 2)                               AS default_rate_pct,
    ROUND((SUM(net_profit) / SUM(funded_amnt) * 100)::numeric, 2) AS return_pct,
    RANK() OVER (ORDER BY AVG(is_default) DESC)                   AS risk_rank
FROM loans
GROUP BY purpose
ORDER BY risk_rank;


-- Q5. Borrower characteristics: income, DTI, employment length, home ownership
--     A CTE with UNION ALL stacks all four factors into one comparison table
WITH segments AS (
    SELECT 'Income band' AS factor, income_band AS segment, MIN(annual_inc) AS sort_key,
           COUNT(*) AS loans, AVG(is_default) AS default_rate,
           SUM(net_profit) / SUM(funded_amnt) AS return_rate
    FROM loans GROUP BY income_band

    UNION ALL
    SELECT 'DTI band', dti_band, MIN(dti),
           COUNT(*), AVG(is_default), SUM(net_profit) / SUM(funded_amnt)
    FROM loans GROUP BY dti_band

    UNION ALL
    SELECT 'Employment length', emp_length, COALESCE(MIN(emp_years), 99),
           COUNT(*), AVG(is_default), SUM(net_profit) / SUM(funded_amnt)
    FROM loans GROUP BY emp_length

    UNION ALL
    SELECT 'Home ownership', home_ownership, -COUNT(*),
           COUNT(*), AVG(is_default), SUM(net_profit) / SUM(funded_amnt)
    FROM loans GROUP BY home_ownership
)
SELECT
    factor,
    segment,
    loans,
    ROUND(default_rate * 100, 2)            AS default_rate_pct,
    ROUND((return_rate * 100)::numeric, 2)  AS return_pct
FROM segments
ORDER BY factor, sort_key;


-- Q6. 36-month vs 60-month loans
--     FILTER compares all loans vs only mature vintages (issued 2007–2013),
--     because 60-month loans issued after 2013 had not finished by the data cut-off
SELECT
    term                                                          AS term_months,
    COUNT(*)                                                      AS loans_all,
    ROUND(AVG(int_rate)::numeric, 2)                              AS avg_interest_rate_pct,
    ROUND(AVG(is_default) * 100, 2)                               AS default_rate_all_pct,
    ROUND((SUM(net_profit) / SUM(funded_amnt) * 100)::numeric, 2) AS return_all_pct,
    COUNT(*) FILTER (WHERE issue_year <= 2013)                    AS loans_mature,
    ROUND(AVG(is_default) FILTER (WHERE issue_year <= 2013) * 100, 2) AS default_rate_mature_pct,
    ROUND((SUM(net_profit) FILTER (WHERE issue_year <= 2013)
         / SUM(funded_amnt) FILTER (WHERE issue_year <= 2013) * 100)::numeric, 2) AS return_mature_pct
FROM loans
GROUP BY term
ORDER BY term;


-- Q7. Riskiest and safest states (min. 1,000 loans per state)
--     Compares each state with the national average, shows top 10 riskiest and top 10 safest
WITH state_stats AS (
    SELECT
        addr_state,
        COUNT(*)                            AS loans,
        AVG(is_default)                     AS default_rate,
        SUM(net_profit) / SUM(funded_amnt)  AS return_rate
    FROM loans
    GROUP BY addr_state
    HAVING COUNT(*) >= 1000
),
national AS (
    SELECT AVG(is_default) AS avg_default_rate FROM loans
),
ranked AS (
    SELECT
        s.addr_state,
        s.loans,
        s.default_rate,
        s.default_rate - n.avg_default_rate          AS diff_vs_national,
        s.return_rate,
        RANK() OVER (ORDER BY s.default_rate DESC)   AS risk_rank,
        RANK() OVER (ORDER BY s.default_rate ASC)    AS safety_rank
    FROM state_stats s
    CROSS JOIN national n
)
SELECT
    addr_state                               AS state,
    loans,
    ROUND(default_rate * 100, 2)             AS default_rate_pct,
    ROUND(diff_vs_national * 100, 2)         AS vs_national_avg_pts,
    ROUND((return_rate * 100)::numeric, 2)   AS return_pct,
    risk_rank
FROM ranked
WHERE risk_rank <= 10 OR safety_rank <= 10
ORDER BY risk_rank;