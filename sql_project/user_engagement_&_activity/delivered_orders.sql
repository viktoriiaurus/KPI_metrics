SELECT
  count(order_id) as delivered_orders,
  time :: date as date
from
  courier_actions
where
  action = 'deliver_order'
group by
  date;