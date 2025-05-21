SELECT 
    date,
    AVG(minutes)::integer AS minutes_to_deliver
FROM (
    SELECT
        date,
        EXTRACT(EPOCH FROM (max_time - min_time)) / 60 AS minutes
    FROM (
        SELECT
            order_id,
            time::date AS date,
            MIN(time) FILTER(WHERE action = 'accept_order') AS min_time,
            MAX(time) FILTER(WHERE action = 'deliver_order') AS max_time
        FROM courier_actions
        WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
        GROUP BY order_id, date
    ) t1
) t2
GROUP BY date
ORDER BY date;
