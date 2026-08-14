TRUNCATE TABLE ekyc_breakdown_daily;

INSERT INTO ekyc_breakdown_daily (
    exported_date,
    breakdown_type,
    category,
    breakdown_value,
    breakdown_order,
    total
)

/* ==========================================
   VIP LEVEL
========================================== */
SELECT
    exported_date,
    'VIP' AS breakdown_type,
    status AS category,
    COALESCE(vip_level, 'Unknown') AS breakdown_value,

    CASE
        WHEN vip_level IS NULL THEN 0
        WHEN vip_level = 'V1' THEN 1
        WHEN vip_level = 'V2' THEN 2
        WHEN vip_level = 'V3' THEN 3
        WHEN vip_level = 'V4' THEN 4
        WHEN vip_level = 'V5' THEN 5
        WHEN vip_level = 'V6' THEN 6
        WHEN vip_level = 'V7' THEN 7
        WHEN vip_level = 'V8' THEN 8
        WHEN vip_level = 'V9' THEN 9
        WHEN vip_level = 'V10' THEN 10
        ELSE 999
    END AS breakdown_order,

    COUNT(*) AS total

FROM ekyc_calculated

GROUP BY
    exported_date,
    status,
    vip_level


UNION ALL

/* ==========================================
   PROCESSING DURATION
========================================== */

SELECT
    exported_date,
    'Duration' AS breakdown_type,
    processing_type AS category,
    duration_bracket AS breakdown_value,

    CASE duration_bracket
        WHEN '< 3 min' THEN 1
        WHEN '3-7 min' THEN 2
        WHEN '7-10 min' THEN 3
        WHEN '10-20 min' THEN 4
        WHEN '20 min+' THEN 5
        ELSE 999
    END AS breakdown_order,

    COUNT(*) AS total

FROM ekyc_calculated

WHERE duration_bracket IS NOT NULL

GROUP BY
    exported_date,
    processing_type,
    duration_bracket


UNION ALL

/* ==========================================
   REJECTION REASON
========================================== */
SELECT
    exported_date,
    'Reject Reason' AS breakdown_type,
    processing_type AS category,
    rejection_reason AS breakdown_value,
	0 AS breakdown_order,
    COUNT(*) AS total

FROM ekyc_calculated

WHERE
    status IN ('Auto Reject', 'Manual Reject')
    AND rejection_reason IS NOT NULL

GROUP BY
    exported_date,
    processing_type,
    rejection_reason

UNION ALL

/* ==========================================
   ID TYPE
========================================== */

SELECT
    exported_date,
    'ID Type' AS breakdown_type,
    status AS category,
    COALESCE(id_type, 'Unknown') AS breakdown_value,
    0 AS breakdown_order,
    COUNT(*) AS total

FROM ekyc_calculated

GROUP BY
    exported_date,
    status,
    id_type

UNION ALL

/* ==========================================
   AGENT PERFORMANCE
========================================== */

SELECT
    exported_date,
    'Agent' AS breakdown_type,
    status AS category,
    processed_by AS breakdown_value,
    NULL AS breakdown_order,
    COUNT(*) AS total

FROM ekyc_calculated

WHERE
    processed_by IS NOT NULL
    AND processed_by <> 'system'
    AND status IN ('Approval','Manual Reject')

GROUP BY
    exported_date,
    status,
    processed_by

UNION ALL

/* ==========================================
   AGENT PROCESSING TIME
========================================== */

SELECT
    exported_date,
    'Agent2' AS breakdown_type,
    processed_by AS category,
    duration_bracket AS breakdown_value,

 	CASE duration_bracket
        WHEN '< 3 min' THEN 1
        WHEN '3-7 min' THEN 2
        WHEN '7-10 min' THEN 3
        WHEN '10-20 min' THEN 4
        WHEN '20 min+' THEN 5
        ELSE 999
    END AS breakdown_order,

	
    COUNT(*) AS total

FROM ekyc_calculated

WHERE processing_type = 'Manual'
  AND processed_by IS NOT NULL
  AND duration_bracket IS NOT NULL

GROUP BY
    exported_date,
    processed_by,
    duration_bracket

ORDER BY
    exported_date,
    breakdown_type,
    category,
    breakdown_value;