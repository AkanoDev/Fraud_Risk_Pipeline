TRUNCATE TABLE wd_hourly_order;

INSERT INTO wd_hourly_order (
    exported_date,
    day_num,
    day_name,
    hour_of_day,
    total_orders
)

SELECT 
	exported_date,
  	EXTRACT(ISODOW FROM exported_date) AS day_num,
    TO_CHAR(exported_date, 'Dy') AS day_name,
    EXTRACT(HOUR FROM created_time) AS hour_of_day,
    COUNT(*) AS total_orders

FROM withdrawal_clean

GROUP BY
    exported_date,
    EXTRACT(ISODOW FROM exported_date),
    TO_CHAR(exported_date, 'Dy'),
    EXTRACT(HOUR FROM created_time)

ORDER BY
    exported_date,
    hour_of_day;
