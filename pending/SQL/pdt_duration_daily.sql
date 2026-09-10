DELETE FROM pdt_duration_daily
WHERE exported_date IN (
    SELECT DISTINCT exported_date
    FROM staging_pending
    WHERE exported_date IS NOT NULL
);

INSERT INTO pdt_duration_daily (
    exported_date,
    less_1min,
    min_1_to_2,
    min_2_to_3,
    min_3_to_5,
    min_5_to_7,
    min_7_to_10,
    min_10_to_20,
    greater_than_20,
    total_reviewed,
    total_pass,
    total_fail,
    avg_duration_seconds
)

SELECT 
	exported_date,

-- SLA Brackets
    COUNT(*) FILTER (
        WHERE duration_bracket = '< 1 min'
    ) AS less_1min,

    COUNT(*) FILTER (
        WHERE duration_bracket = '1-2 min'
    ) AS min_1_to_2,

    COUNT(*) FILTER (
        WHERE duration_bracket = '2-3 min'
    ) AS min_2_to_3,

    COUNT(*) FILTER (
        WHERE duration_bracket = '3-5 min'
    ) AS min_3_to_5,

    COUNT(*) FILTER (
        WHERE duration_bracket = '5-7 min'
    ) AS min_5_to_7,

    COUNT(*) FILTER (
        WHERE duration_bracket = '7-10 min'
    ) AS min_7_to_10,

    COUNT(*) FILTER (
        WHERE duration_bracket = '10-20 min'
    ) AS min_10_to_20,

    COUNT(*) FILTER (
        WHERE duration_bracket = '20 min+'
    ) AS greater_than_20,
	
    COUNT(*) FILTER (
        WHERE LOWER(processing_status) = 'processed'
    ) AS total_reviewed,

	  -- SLA Pass
    COUNT(*) FILTER (
        WHERE duration_seconds < 300
    ) AS total_pass,

    -- SLA Fail
    COUNT(*) FILTER (
        WHERE duration_seconds >= 300
    ) AS total_fail,

	-- Average Duration (seconds)
    ROUND(
        AVG(duration_seconds),
        2
    ) AS avg_duration_seconds

FROM pending_calculated
GROUP BY exported_date
ORDER BY exported_date;