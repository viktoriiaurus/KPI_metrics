SELECT
    date,
    new_users,
    new_couriers,
    total_users,
    total_couriers,
    new_users_change,
    new_couriers_change,
    round((total_users - lag(total_users) over(order by date))*100 / lag(total_users) over(order by date)::DECIMAL, 2) as total_users_growth,
    round((total_couriers - lag(total_couriers) over(order by date))*100 / lag(total_couriers) over(order by date)::DECIMAL, 2) as total_couriers_growth
FROM    (SELECT
        date,
        new_users,
        new_couriers,
        sum(new_users) OVER(order by date)::integer as total_users,
        sum(new_couriers) OVER(order BY date)::integer as total_couriers,
        round((new_users - lag(new_users) over(order by date))*100 / lag(new_users) over(order by date)::DECIMAL, 2) as new_users_change,
        round((new_couriers - lag(new_couriers) over(order by date))*100 / lag(new_couriers) over(order by date)::DECIMAL, 2) as new_couriers_change
    from    (SELECT
            user_activities.first_active_date AS date,
            COUNT(DISTINCT user_activities.user_id) AS new_users,
            COUNT(DISTINCT courier_activities.courier_id) AS new_couriers
        FROM (
            SELECT
                user_id,
                MIN(time::date) AS first_active_date
            FROM user_actions
            GROUP BY user_id
        ) AS user_activities
        LEFT JOIN (
            SELECT
                courier_id,
                MIN(time::date) AS first_active_date
            FROM courier_actions
            GROUP BY courier_id
        ) AS courier_activities
        ON user_activities.first_active_date = courier_activities.first_active_date
        GROUP BY user_activities.first_active_date
        ORDER BY user_activities.first_active_date) t1
    ) t2;
