TRUNCATE TABLE ekyc_hourly_submission;

INSERT INTO ekyc_hourly_submission (
    exported_date,
    day_num,
    day_name,
    hour_of_day,
    total_submissions
)

SELECT
    exported_date,
    EXTRACT(ISODOW FROM exported_date) AS day_num,
    TO_CHAR(exported_date, 'Dy') AS day_name,
    EXTRACT(HOUR FROM update_date) AS hour_of_day,
    COUNT(*) AS total_submissions

FROM ekyc_clean

WHERE status NOT IN ('Invalid', 'Improve Information')

GROUP BY
    exported_date,
    EXTRACT(ISODOW FROM exported_date),
    TO_CHAR(exported_date, 'Dy'),
    EXTRACT(HOUR FROM update_date)

ORDER BY
    exported_date,
    hour_of_day;