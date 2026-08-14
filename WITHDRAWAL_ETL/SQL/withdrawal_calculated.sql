TRUNCATE TABLE withdrawal_calculated;

INSERT INTO withdrawal_calculated(
   exported_date,

    -- Transaction
    serial_number,
    account,
    account_id,
    
    -- Status / Processing
    status,
    processing_by,
    processed_by,
    locked_by,
    unlocked_by,
    locked_state,
    
    -- Withdrawal Details
    amount,
    type,
    label,
    site_product,
    exception_prompt,
    exception_prompt_check,
    
    -- Timeline
    created_time,
    unlocked_date,
    processing_time,
    process_time,
    risk_completion_time,
    
    -- Notes
    remark,

    -- calc
    duration,
    duration_seconds,
    processing_type,
    duration_bracket,
    last_label
)

WITH duration_calc AS (

SELECT
    *,

    CASE
        WHEN status = 'Cancel in background'
             AND process_time IS NOT NULL THEN

            CASE
                WHEN locked_state = 'Unlocked'
                     AND unlocked_date IS NOT NULL
                THEN process_time - unlocked_date
                ELSE process_time - created_time
            END

        WHEN processing_time IS NOT NULL THEN

            CASE
                WHEN locked_state = 'Unlocked'
                     AND unlocked_date IS NOT NULL
                THEN processing_time - unlocked_date
                ELSE processing_time - created_time
            END

        ELSE NULL
    END AS duration

FROM withdrawal_clean

),

seconds_calc AS (

SELECT
    *,
    EXTRACT(EPOCH FROM duration)::INTEGER AS duration_seconds

FROM duration_calc

)

SELECT

   exported_date,

		-- Transaction
		serial_number,
		account,
		account_id,
		
		-- Status / Processing
		status,
		processing_by,
		processed_by,
		locked_by,
		unlocked_by,
		locked_state,
		
		-- Withdrawal Details
		amount,
		type,
		label,
		site_product,
		exception_prompt,
		exception_prompt_check,
		
		-- Timeline
		created_time,
		unlocked_date,
		processing_time,
		process_time,
		risk_completion_time,
		
		-- Notes
		remark,
		
		-- Calculated
		duration,
		duration_seconds,

    /* Processing Type */
    CASE
        WHEN LOWER(COALESCE(processing_by,'')) = 'system'
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

	TRIM(
    split_part(
	        label,
	        ',',
	        array_length(string_to_array(label, ','), 1)
	    )
	) AS last_label

FROM seconds_calc;