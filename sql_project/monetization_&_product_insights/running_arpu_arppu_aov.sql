with rev as (
   SELECT date,
       sum(revenue) OVER (ORDER BY date) as total_revenue
    FROM   (SELECT creation_time::date as date,
               sum(price) as revenue
            FROM   (SELECT creation_time,
                       unnest(product_ids) as product_id
                    FROM   orders
                    WHERE  order_id not in (SELECT order_id
                                             FROM   user_actions
                                            WHERE  action = 'cancel_order')) t1
            LEFT JOIN products using (product_id)
            GROUP BY date) t2
),

users_count as (

SELECT start_date as date,
       (sum(new_users) OVER (ORDER BY start_date))::int as user_count
FROM   (SELECT start_date,
                      count(user_id) as new_users
               FROM   (SELECT user_id,
                              min(time::date) as start_date
                       FROM   user_actions
                       GROUP BY user_id) sd
               GROUP BY start_date) nu
),

paying_us as (

    SELECT start_date as date,
       (sum(new_paying_users) OVER (ORDER BY start_date))::int as paying_user
FROM   (SELECT start_date,
                      count(user_id) as new_paying_users
               FROM   (SELECT user_id,
                              min(time::date) as start_date
                       FROM   user_actions
                       where order_id not in (select order_id from user_actions where action = 'cancel_order')
                       GROUP BY user_id) ds
               GROUP BY start_date) pu
),
orders_count as(
    select
        date,
        sum(order_count) OVER(ORDER BY date) as count_order
    from (select
            creation_time::date as date,
            count(distinct order_id) as order_count
        from orders
        where order_id not in (select order_id from user_actions where action = 'cancel_order')
        group by date) as t5
)

select 
    date,
    round(total_revenue::decimal / uc.user_count, 2) as running_arpu,
    round(total_revenue::decimal / pu.paying_user, 2) as running_arppu,
    round(total_revenue::decimal / oc.count_order, 2) as running_aov
from rev
left join users_count uc using(date)
left join paying_us pu using(date)
left join orders_count oc using(date)
order by date;