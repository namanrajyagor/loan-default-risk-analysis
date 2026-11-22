-- ============================================================
-- 00_setup_table.sql
-- Primary key, indexes and a quick check of the loaded data
-- ============================================================

-- 1. Primary key: each loan id must be unique
ALTER TABLE loans ADD PRIMARY KEY (id);

-- 2. Indexes on columns we will often filter by
CREATE INDEX idx_loans_issue_d    ON loans (issue_d);
CREATE INDEX idx_loans_grade      ON loans (grade);
CREATE INDEX idx_loans_addr_state ON loans (addr_state);
CREATE INDEX idx_loans_purpose    ON loans (purpose);

-- 3. Update table statistics so PostgreSQL plans queries well
ANALYZE loans;

-- 4. Quick check of the loaded data
SELECT
    COUNT(*)                                AS total_loans,
    ROUND(AVG(is_default) * 100, 2)         AS default_rate_pct,
    ROUND(SUM(funded_amnt)::numeric / 1e9, 2) AS total_funded_billion_usd,
    MIN(issue_d)::date                      AS first_loan,
    MAX(issue_d)::date                      AS last_loan
FROM loans;