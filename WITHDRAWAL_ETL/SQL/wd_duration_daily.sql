TRUNCATE TABLE wd_duration_daily;

INSERT INTO wd_duration_daily (
    exported_date,
    manual_reviewed,
    system_reviewed,
    branch_reviewed,
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
    total_pass_manual,
    total_pass_system,
    total_pass_branch,
    total_fail,
    total_fail_manual,
    total_fail_system,
    avg_duration_seconds,
    avg_manual_seconds,
    avg_system_seconds,
    avg_branch_seconds
)

SELECT 
	exported_date,

	COUNT(*) FILTER (
		WHERE processing_type = 'Manual'
		  AND status NOT IN ('Pending', 'Pending2')
	) AS manual_reviewed,

	COUNT(*) FILTER (
	    WHERE processing_type = 'System'
	) AS system_reviewed,

	COUNT(*) FILTER (
	    WHERE type = 'Branch'
		  AND status NOT IN ('Pending', 'Pending2')
	) AS branch_reviewed,

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
        WHERE status NOT IN ('Pending', 'Pending2')
          AND duration_seconds IS NOT NULL
    ) AS total_reviewed,

	  -- SLA Pass
    COUNT(*) FILTER (
        WHERE duration_seconds < 180
    ) AS total_pass,

    COUNT(*) FILTER (
        WHERE duration_seconds < 180
          AND processing_type <> 'System'
    ) AS total_pass_manual,

	COUNT(*) FILTER (
        WHERE duration_seconds < 180
          AND processing_type = 'System'
    ) AS total_pass_system,

	COUNT(*) FILTER (
        WHERE duration_seconds < 180
          AND type = 'Branch'
    ) AS total_pass_branch,

    -- SLA Fail
    COUNT(*) FILTER (
        WHERE duration_seconds >= 180
    ) AS total_fail,

    COUNT(*) FILTER (
        WHERE duration_seconds >= 180
          AND processing_type <> 'System'
    ) AS total_fail_manual,

	COUNT(*) FILTER (
        WHERE duration_seconds >= 180
          AND processing_type = 'System'
    ) AS total_fail_system,

	-- Average Duration (seconds)
    ROUND(
        AVG(duration_seconds),
        2
    ) AS avg_duration_seconds,

    ROUND(
        AVG(duration_seconds) FILTER (
            WHERE processing_type = 'Manual'
        ),
        2
    ) AS avg_manual_seconds,

    ROUND(
        AVG(duration_seconds) FILTER (
            WHERE processing_type = 'System'
        ),
        2
    ) AS avg_system_seconds,
    	
    ROUND(
        AVG(duration_seconds) FILTER (
            WHERE type = 'Branch'
        ),
        2
    ) AS avg_branch_seconds

FROM withdrawal_calculated
GROUP BY exported_date
ORDER BY exported_date;