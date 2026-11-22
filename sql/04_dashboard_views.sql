-- ============================================================
-- 04_dashboard_views.sql
-- View used by the Power BI dashboard (only the columns it needs)
-- ============================================================

CREATE OR REPLACE VIEW vw_loans_dashboard AS
SELECT
    id,
    issue_d,
    issue_year,
    term,
    grade,
    sub_grade,
    purpose,
    addr_state,
    home_ownership,
    emp_length,
    income_band,
    dti_band,
    fico_band,
    int_rate,
    funded_amnt,
    annual_inc,
    dti,
    fico_avg,
    is_default,
    net_profit,
    total_pymnt,
    -- 1 = loan had enough time to finish before the data cut-off
    CASE
        WHEN (term = 36 AND issue_year <= 2015)
          OR (term = 60 AND issue_year <= 2013) THEN 1
        ELSE 0
    END AS is_mature,
    -- Sort-order columns so Power BI shows bands in the right order
    CASE income_band
        WHEN '<40K'      THEN 1
        WHEN '40K-60K'   THEN 2
        WHEN '60K-80K'   THEN 3
        WHEN '80K-100K'  THEN 4
        WHEN '100K-150K' THEN 5
        WHEN '150K+'     THEN 6
    END AS income_band_order,
    CASE fico_band
        WHEN '<670'    THEN 1
        WHEN '670-689' THEN 2
        WHEN '690-709' THEN 3
        WHEN '710-739' THEN 4
        WHEN '740+'    THEN 5
    END AS fico_band_order,
    COALESCE(emp_years, 11)::int AS emp_length_order   -- "Unknown" goes last
FROM loans;