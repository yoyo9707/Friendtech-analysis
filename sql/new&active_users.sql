WITH active AS (
  SELECT date_trunc('month', evt_block_time) AS date,
         COUNT(DISTINCT trader) AS active_users
  FROM friendtech_base.FriendtechSharesV1_evt_Trade
  GROUP BY 1
),
first_active AS (
  SELECT trader,
         MIN(evt_block_time) AS first_time
  FROM friendtech_base.FriendtechSharesV1_evt_Trade
  GROUP BY trader
),
new_users AS (
  SELECT date_trunc('month', first_time) AS date,
         COUNT(*) AS new_users
  FROM first_active
  GROUP BY 1
),
all_dates AS (
  SELECT date FROM active
  UNION
  SELECT date FROM new_users
),
joined AS (
  SELECT d.date,
         COALESCE(a.active_users,0) AS active_users,
         COALESCE(n.new_users,0)  AS new_users
  FROM all_dates d
  LEFT JOIN active     a ON a.date = d.date
  LEFT JOIN new_users  n ON n.date = d.date
)
SELECT date,
       active_users,
       new_users,
       AVG(active_users) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS active_users_7d,
       AVG(new_users) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS new_users_7d,
       SUM(new_users) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_new_users
FROM joined
ORDER BY date
