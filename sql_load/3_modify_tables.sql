COPY courier_actions
FROM '/Users/viktoria/Desktop/KPI_metrics/files_csv/courier_actions.csv'
DELIMITER ',' CSV HEADER;

COPY couriers
FROM '/Users/viktoria/Desktop/KPI_metrics/files_csv/couriers.csv'
DELIMITER ',' CSV HEADER;

COPY orders
FROM '/Users/viktoria/Desktop/KPI_metrics/files_csv/orders.csv'
DELIMITER ',' CSV HEADER;

COPY products
FROM '/Users/viktoria/Desktop/KPI_metrics/files_csv/products.csv'
DELIMITER ',' CSV HEADER;

COPY user_actions
FROM '/Users/viktoria/Desktop/KPI_metrics/files_csv/user_actions.csv'
DELIMITER ',' CSV HEADER;

COPY users
FROM '/Users/viktoria/Desktop/KPI_metrics/files_csv/users.csv'
DELIMITER ',' CSV HEADER;

