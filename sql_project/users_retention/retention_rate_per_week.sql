SELECT 
    DATE(start_month) as start_month,  
    first_activity_week, 
    week_number, 
    retention
FROM
(SELECT week, 
        COUNT(DISTINCT user_id) as active_users,
        ROUND(COUNT(DISTINCT user_id)::decimal / MAX(COUNT(DISTINCT user_id)) OVER(partition by first_activity_week), 2) as retention,
        first_activity_week,
        date_trunc('month', first_activity_week) as start_month,
        date_trunc('month', week) as month,
        round(EXTRACT (epoch FROM AGE(week, first_activity_week)) / (7 * 24 * 60 * 60)) as week_number 
FROM
    (SELECT user_id, 
            week, 
            DATE_TRUNC('week', first_activity_day)::date as first_activity_week
    FROM
        (SELECT user_id, 
                DATE_TRUNC('week', time) as week,
                MIN(time::date) OVER(partition by user_id) as first_activity_day
        FROM user_actions) t1
        ) t2
    GROUP BY week, first_activity_week
    ) t3
ORDER BY first_activity_week, week_number;