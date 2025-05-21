SELECT
  date_trunc('month', time) as month,
  count(DISTINCT user_id) as MAU
FROM
  user_actions
group by
  month;