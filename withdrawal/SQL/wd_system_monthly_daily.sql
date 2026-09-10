DELETE FROM wd_system_monthly_daily
WHERE exported_date IN (
    SELECT DISTINCT exported_date
    FROM staging_withdrawal
    WHERE exported_date IS NOT NULL
);

/* =========================================================
   REBUILD ONLY AFFECTED DATES
========================================================= */

INSERT INTO wd_system_monthly_daily (
    exported_date,
    system_less_1min,
    system_1_to_5min,
    system_5_to_10min,
    system_greater_10min,
    total_system_review,
    total_review,
    system_ratio
)

SELECT
    exported_date,

    /* ==========================================
       SYSTEM PROCESSING DURATION
    ========================================== */

    COUNT(*) FILTER (
        WHERE processing_type = 'System'
          AND duration_seconds < 60
    ) AS system_less_1min,

    COUNT(*) FILTER (
        WHERE processing_type = 'System'
          AND duration_seconds >= 60
          AND duration_seconds < 300
    ) AS system_1_to_5min,

    COUNT(*) FILTER (
        WHERE processing_type = 'System'
          AND duration_seconds >= 300
          AND duration_seconds < 600
    ) AS system_5_to_10min,

    COUNT(*) FILTER (
        WHERE processing_type = 'System'
          AND duration_seconds >= 600
    ) AS system_greater_10min,

    /* ==========================================
       TOTAL SYSTEM REVIEWED
    ========================================== */

    COUNT(*) FILTER (
        WHERE processing_type = 'System'
          AND status NOT IN ('Pending', 'Pending2')
          AND duration_seconds IS NOT NULL
    ) AS total_system_review,

    /* ==========================================
       TOTAL REVIEWED
    ========================================== */

    COUNT(*) FILTER (
        WHERE status NOT IN ('Pending', 'Pending2')
          AND duration_seconds IS NOT NULL
    ) AS total_review,

    /* ==========================================
       SYSTEM RATIO
    ========================================== */

    COALESCE(
        COUNT(*) FILTER (
            WHERE processing_type = 'System'
              AND status NOT IN ('Pending', 'Pending2')
              AND duration_seconds IS NOT NULL
        )::DECIMAL
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE status NOT IN ('Pending', 'Pending2')
                  AND duration_seconds IS NOT NULL
            ),
            0
        ),
        0
    ) AS system_ratio

FROM withdrawal_calculated

WHERE exported_date IN (
    SELECT DISTINCT exported_date
    FROM staging_withdrawal
    WHERE exported_date IS NOT NULL
)

GROUP BY
    exported_date

ORDER BY
    exported_date;