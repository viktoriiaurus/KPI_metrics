SELECT
  date_trunc('week', time) as week,
  count(DISTINCT user_id) as WAU
FROM
  user_actions
group by
  week;