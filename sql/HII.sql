WITH subject_amount AS(
       SELECT trader,
              SUM(ethAmount) AS trader_volume
       FROM friendtech_base.FriendtechSharesV1_evt_Trade
       GROUP BY trader
),
total_amount AS (
       SELECT SUM(ethAmount) AS total_volume
       FROM friendtech_base.FriendtechSharesV1_evt_Trade
)
SELECT SUM(POWER(CAST(sa.trader_volume AS double)/CAST(ta.total_volume AS double),2)) AS herfindahl_index
FROM subject_amount sa, total_amount ta
