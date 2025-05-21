with rev as (
    SELECT 
        to_char(date, 'Day') as weekday,
        extract(isodow from date) as weekday_number,
        sum(p.price) as revenue
    FROM   (SELECT order_id,
                    creation_time::date as date,
                    unnest(product_ids) as product_id
            FROM   orders
            WHERE  creation_time::date between '2022-08-26' and '2022-09-09' 
                   and order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) pr_id
    LEFT JOIN products as p using(product_id)
    GROUP BY weekday, weekday_number
    ORDER BY weekday_number
), users_count as (
    SELECT to_char(time::date, 'Day') as weekday,
            extract(isodow from time::date) as weekday_number,
            count(distinct user_id) as user_count
        FROM   user_actions
        WHERE  time::date between '2022-08-26' and '2022-09-09'
    GROUP BY weekday, weekday_number
    ORDER BY weekday_number
), paying_us as (
    SELECT to_char(time::date, 'Day') as weekday,
        extract(isodow from time::date) as weekday_number,
        count(distinct user_id) as paying_user
    FROM   user_actions
    WHERE  time::date between '2022-08-26' and '2022-09-09'
                and order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
    GROUP BY weekday, weekday_number
    ORDER BY weekday_number
), orders_count as(
     SELECT 
        to_char(creation_time::date, 'Day') AS weekday,
        extract(isodow FROM creation_time::date) AS weekday_number,
        COUNT(DISTINCT order_id) AS order_count
    FROM orders
    WHERE creation_time::date BETWEEN '2022-08-26' AND '2022-09-09'
            AND order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
    GROUP BY weekday, weekday_number
    ORDER BY weekday_number
)

SELECT r.weekday,
        r.weekday_number,
       round(revenue::decimal / uc.user_count, 2) as arpu,
       round(revenue::decimal / pu.paying_user, 2) as arppu,
       round(revenue::decimal / oc.order_count, 2) as aov
FROM   rev r
    LEFT JOIN users_count uc using(weekday)
    LEFT JOIN paying_us pu using(weekday)
    LEFT JOIN orders_count oc using(weekday)
ORDER BY weekday_number;