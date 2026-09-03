DELETE FROM ekyc_duration_daily
WHERE exported_date IN (
    SELECT DISTINCT exported_date
    FROM staging_ekyc
    WHERE exported_date IS NOT NULL
);

INSERT INTO ekyc_duration_daily (
    exported_date,
    manual_reviewed,
    system_reviewed,
    cs_correction,
    total_reviewed,
    invalid_duration,
    less_3min,
    min_3_to_7,
    min_7_to_10,
    min_10_to_20,
    greater_than_20,
    total_pass,
    total_pass_manual,
    total_pass_system,
    total_fail,
    total_fail_manual,
    total_fail_system,

-- pass
    system_approval_pass,
    manual_approval_pass,
    auto_reject_pass,
    manual_reject_pass,
-- fail
    system_approval_fail,
    manual_approval_fail,
    auto_reject_fail,
    manual_reject_fail,

    avg_duration_seconds,
    avg_manual_seconds,
    avg_system_seconds,
    avg_cs_correction_seconds,
    avg_not_cs_correction_seconds
)

SELECT
    exported_date,

	COUNT(*) FILTER (
	    WHERE processing_type = 'Manual'
	) AS manual_reviewed,

	COUNT(*) FILTER (
	    WHERE processing_type = 'System'
	) AS system_reviewed,

    COUNT(*) FILTER (
	    WHERE cs_start_time IS NOT NULL
	      AND cs_completion_time IS NOT NULL
	) AS cs_correction,

    -- Total Reviewed (only records with valid duration)
    COUNT(duration_seconds) AS total_reviewed,

    -- Records that should have an SLA but have no valid duration
    COUNT(*) FILTER (
        WHERE status NOT IN ('Invalid', 'Improve Information')
          AND duration_seconds IS NULL
    ) AS invalid_duration,

    -- SLA Brackets
    COUNT(*) FILTER (
        WHERE duration_bracket = '< 3 min'
    ) AS less_3min,

    COUNT(*) FILTER (
        WHERE duration_bracket = '3-7 min'
    ) AS min_3_to_7,

    COUNT(*) FILTER (
        WHERE duration_bracket = '7-10 min'
    ) AS min_7_to_10,

    COUNT(*) FILTER (
        WHERE duration_bracket = '10-20 min'
    ) AS min_10_to_20,

    COUNT(*) FILTER (
        WHERE duration_bracket = '20 min+'
    ) AS greater_than_20,

    -- SLA Pass
    COUNT(*) FILTER (
        WHERE duration_seconds < 180
    ) AS total_pass,

    COUNT(*) FILTER (
        WHERE duration_seconds < 180
          AND LOWER(processed_by) <> 'system'
    ) AS total_pass_manual,

    COUNT(*) FILTER (
        WHERE duration_seconds < 180
          AND LOWER(processed_by) = 'system'
    ) AS total_pass_system,

    -- SLA Fail
    COUNT(*) FILTER (
        WHERE duration_seconds >= 180
    ) AS total_fail,

    COUNT(*) FILTER (
        WHERE duration_seconds >= 180
          AND LOWER(processed_by) <> 'system'
    ) AS total_fail_manual,

	COUNT(*) FILTER (
        WHERE duration_seconds >= 180
          AND LOWER(processed_by) = 'system'
    ) AS total_fail_system,

    -- PASS
	
	COUNT(*) FILTER (
	    WHERE duration_seconds < 180
	      AND LOWER(processed_by) = 'system'
	      AND status = 'Approval'
	) AS system_approval_pass,
	
	COUNT(*) FILTER (
	    WHERE duration_seconds < 180
	      AND LOWER(processed_by) <> 'system'
	      AND status = 'Approval'
	) AS manual_approval_pass,
	
	COUNT(*) FILTER (
	    WHERE duration_seconds < 180
	      AND status = 'Auto Reject'
	) AS auto_reject_pass,
	
	COUNT(*) FILTER (
	    WHERE duration_seconds < 180
	      AND status = 'Manual Reject'
	) AS manual_reject_pass,
	
	
	-- FAIL
	
	COUNT(*) FILTER (
	    WHERE duration_seconds >= 180
	      AND LOWER(processed_by) = 'system'
	      AND status = 'Approval'
	) AS system_approval_fail,
	
	COUNT(*) FILTER (
	    WHERE duration_seconds >= 180
	      AND LOWER(processed_by) <> 'system'
	      AND status = 'Approval'
	) AS manual_approval_fail,
	
	COUNT(*) FILTER (
	    WHERE duration_seconds >= 180
	      AND status = 'Auto Reject'
	) AS auto_reject_fail,
	
	COUNT(*) FILTER (
	    WHERE duration_seconds >= 180
	      AND status = 'Manual Reject'
	) AS manual_reject_fail,

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
	        WHERE cs_start_time IS NOT NULL
	          AND cs_completion_time IS NOT NULL
			  AND processing_type = 'Manual'
	    ),
	    2
	) AS avg_cs_correction_seconds,

	ROUND(
	    AVG(duration_seconds) FILTER (
	        WHERE cs_start_time IS NULL
	          AND cs_completion_time IS NULL
			  AND processing_type = 'Manual'
	    ),
	    2
	) AS avg_not_cs_correction_seconds	

FROM ekyc_calculated

WHERE exported_date IN (
    SELECT DISTINCT exported_date
    FROM staging_ekyc
    WHERE exported_date IS NOT NULL
)

GROUP BY exported_date

ORDER BY exported_date;