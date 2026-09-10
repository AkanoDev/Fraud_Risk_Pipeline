INSERT INTO pending_clean
SELECT *
FROM staging_pending

ON CONFLICT (serial_number, exported_date)

DO UPDATE SET

    account = EXCLUDED.account,
    account_id = EXCLUDED.account_id,
    user_level = EXCLUDED.user_level,
    amount = EXCLUDED.amount,
    first_withdrawal = EXCLUDED.first_withdrawal,
    old_label = EXCLUDED.old_label,
    label = EXCLUDED.label,
    site_product = EXCLUDED.site_product,
    withdraw_time = EXCLUDED.withdraw_time,
    type = EXCLUDED.type,
    exception_prompt = EXCLUDED.exception_prompt,
    rule_no = EXCLUDED.rule_no,
    ip_address = EXCLUDED.ip_address,
    user_source = EXCLUDED.user_source,
    remark = EXCLUDED.remark,
    created_date = EXCLUDED.created_date,
    processed_by = EXCLUDED.processed_by,
    processing_time = EXCLUDED.processing_time,
    hit_the_rule = EXCLUDED.hit_the_rule,
    processing_status = EXCLUDED.processing_status;