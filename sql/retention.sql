WITH first_login AS (
    SELECT
        trader,
        DATE_TRUNC('month', MIN(evt_block_date)) AS cohort_month
    FROM friendtech_base.FriendtechSharesV1_evt_Trade
    GROUP BY trader
),
activity AS (
    SELECT
        trader,
        DATE_TRUNC('month', evt_block_date) AS active_month
    FROM friendtech_base.FriendtechSharesV1_evt_Trade
    GROUP BY trader, DATE_TRUNC('month', evt_block_date)
),
joined AS (
    SELECT
        f.trader,
        f.cohort_month,
        a.active_month,
        DATE_DIFF('month', f.cohort_month, a.active_month) AS months_since_first
    FROM first_login f
    JOIN activity a ON f.trader = a.trader
    WHERE DATE_DIFF('month', f.cohort_month, a.active_month) >= 0
),
cohort_counts AS (
    SELECT
        cohort_month,
        months_since_first,
        COUNT(DISTINCT trader) AS user_count
    FROM joined
    GROUP BY cohort_month, months_since_first
),
cohort_size AS (
    SELECT
        cohort_month,
        user_count AS cohort_size
    FROM cohort_counts
    WHERE months_since_first = 0
)
SELECT
    format_datetime(c.cohort_month, 'yyyy-MM') AS cohort_month,
    lpad(CAST(c.months_since_first AS varchar), 2, '0') AS months_since_first,
    ROUND(100.0 * c.user_count / s.cohort_size, 1) AS retention_pct,
    c.user_count,
    s.cohort_size
FROM cohort_counts c
JOIN cohort_size s ON c.cohort_month = s.cohort_month
ORDER BY c.cohort_month, months_since_first
