SELECT
  subject,
  CAST(SUM(CASE WHEN isBuy THEN shareAmount ELSE -shareAmount END) AS double) AS net_share_change,
  CAST(SUM(CASE WHEN isBuy THEN ethAmount ELSE -ethAmount END) AS double) AS net_eth_change
FROM friendtech_base.FriendtechSharesV1_evt_Trade
GROUP BY 1
ORDER BY net_eth_change DESC
LIMIT 10