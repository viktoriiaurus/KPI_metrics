SELECT
  time :: date as date,
  count(distinct user_id) as dau 
from
  user_actions
group by
  date;