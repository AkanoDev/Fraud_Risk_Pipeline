DELETE FROM ekyc_calculated
    WHERE bill_no IN (
        SELECT DISTINCT bill_no
        FROM staging_ekyc
    WHERE bill_no IS NOT NULL
);

INSERT INTO ekyc_calculated (
    exported_date,
	bill_no,
	account,
	account_id,
    status,
    rejection_reason,
    manual_reason,
    processed_by,
    vip_level,
    provider_type,
    nationality,
    id_type,
    channel,
	info_time,
	cs_start_time,
	cs_completion_time,
	risk_completion_time,
    duration,
    duration_seconds,
    processing_type,
    approval_type,
    duration_bracket
)

WITH duration_calc AS (
    SELECT
        *,
        CASE

            -- No Info Time and status is not Invalid / Improve Information
            WHEN info_time IS NULL
                 AND status NOT IN ('Invalid', 'Improve Information')
            THEN
                risk_completion_time - created_date

            -- System process
            WHEN processed_by = 'system' THEN
                risk_completion_time - info_time

            -- Waiting for processor
            WHEN processed_by IS NULL
                 OR processed_by IN ('None', 'nan', '')
            THEN
                cs_pre_review_time - info_time

            -- Risk completed → waiting for CS completion
            WHEN cs_pre_review_time IS NOT NULL
                 AND cs_completion_time IS NULL
            THEN
                risk_completion_time - cs_pre_review_time

            -- CS completed
            WHEN cs_completion_time IS NOT NULL
            THEN
                risk_completion_time - cs_completion_time

            -- Default
            ELSE
                risk_completion_time - info_time

        END AS duration

    FROM ekyc_clean
    
    WHERE bill_no IN (
        SELECT DISTINCT bill_no
        FROM staging_ekyc
        WHERE bill_no IS NOT NULL
    )
),

seconds_calc AS (
    SELECT
        *,
        EXTRACT(EPOCH FROM duration)::INTEGER AS duration_seconds
    FROM duration_calc
)

SELECT
    exported_date,
	bill_no,
	account,
	account_id,
    status,
	rejection_reason,
	manual_reason,
    processed_by,
    vip_level,
    provider_type,
    nationality,
    id_type,
    channel,

	info_time,
	cs_start_time,
	cs_completion_time,
	risk_completion_time,

    duration,
    duration_seconds,

    CASE
        WHEN status IN ('Invalid', 'Improve Information') THEN NULL
        WHEN LOWER(COALESCE(processed_by, '')) = 'system' THEN 'System'
        ELSE 'Manual'
    END AS processing_type,

    CASE
        WHEN status <> 'Approval' THEN NULL
        WHEN LOWER(COALESCE(processed_by, '')) = 'system' THEN 'System Approval'
        ELSE 'Manual Approval'
    END AS approval_type,

    CASE
        WHEN status IN ('Invalid', 'Improve Information') THEN NULL
        WHEN duration_seconds < 180 THEN '< 3 min'
        WHEN duration_seconds < 420 THEN '3-7 min'
        WHEN duration_seconds < 600 THEN '7-10 min'
        WHEN duration_seconds < 1200 THEN '10-20 min'
        ELSE '20 min+'
    END AS duration_bracket

FROM seconds_calc;