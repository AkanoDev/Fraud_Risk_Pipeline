DELETE FROM pending_calculated
    WHERE serial_number IN (
        SELECT DISTINCT serial_number
        FROM staging_pending
    WHERE serial_number IS NOT NULL
);

INSERT INTO pending_calculated(
    exported_date,
    serial_number,
    account,
    account_id,
    user_level,
    amount,
    first_withdrawal,
    old_label,
    label,
    site_product,
    withdraw_time,
    type,
    exception_prompt,
    rule_no,
    ip_address,
    user_source,
    remark,
    created_date,
    processed_by,
    processing_time,
    hit_the_rule,
    processing_status,
    duration,
    duration_seconds,
    processing_type,
    duration_bracket,
    is_adjusted,
    old_last_label,
    new_last_label
)

WITH duration_calc AS (

SELECT
    *,
    processing_time - created_date AS duration

FROM pending_clean

    WHERE serial_number IN (
        SELECT DISTINCT serial_number
        FROM staging_pending
        WHERE serial_number IS NOT NULL
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
	serial_number,
	account,
	account_id,
	user_level,
	amount,
	first_withdrawal,
	old_label,
	label,
	site_product,
	withdraw_time,
	type,
	exception_prompt,
	rule_no,
	ip_address,
	user_source,
	remark,
	created_date,
	processed_by,
	processing_time,
	hit_the_rule,
	processing_status,
	duration,
	duration_seconds,

    /* Processing Type */
    CASE
        WHEN LOWER(COALESCE(processed_by,'')) = 'system'
        THEN 'System'
        ELSE 'Manual'
    END AS processing_type,

    /* Duration Bracket */
    CASE
        WHEN duration_seconds IS NULL THEN NULL
        WHEN duration_seconds < 60 THEN '< 1 min'
        WHEN duration_seconds < 120 THEN '1-2 min'
        WHEN duration_seconds < 180 THEN '2-3 min'
        WHEN duration_seconds < 300 THEN '3-5 min'
        WHEN duration_seconds < 420 THEN '5-7 min'
        WHEN duration_seconds < 600 THEN '7-10 min'
        WHEN duration_seconds < 1200 THEN '10-20 min'
        ELSE '20 min+'
    END AS duration_bracket,

	CASE
	    WHEN COALESCE(old_label, '') <> COALESCE(label, '')
	    THEN 1
	    ELSE 0
	END AS is_adjusted,

	TRIM(
    split_part(
	        old_label,
	        ',',
	        array_length(string_to_array(old_label, ','), 1)
	    )
	) AS old_last_label,

	TRIM(
    split_part(
	        label,
	        ',',
	        array_length(string_to_array(label, ','), 1)
	    )
	) AS new_last_label

FROM seconds_calc;