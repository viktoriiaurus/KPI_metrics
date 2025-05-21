SELECT
  count(DISTINCT courier_id) as active_couriers,
  time :: date as date
from
  courier_actions
group by
  date;