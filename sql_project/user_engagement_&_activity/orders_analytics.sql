SELECT
    round(cancel_orders::decimal / create_orders, 2) as cancel_rate,
    round(create_orders::decimal / active_users, 2) as orders_per_user,
    cancel_orders,
    create_orders,
    active_users,
    date
from    
(SELECT
  count(order_id) filter(where action = 'cancel_order') as cancel_orders,
  count(order_id) filter(where action = 'create_order') as create_orders,
  count(distinct user_id) as active_users,
  time :: date as date
from
  user_actions
group by
  date) t1;