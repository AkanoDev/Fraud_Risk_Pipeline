INSERT INTO withdrawal_clean
SELECT *
FROM staging_withdrawal

ON CONFLICT (serial_number, exported_date)

DO UPDATE SET
    status = EXCLUDED.status,
    locked_state = EXCLUDED.locked_state,
    locked_by = EXCLUDED.locked_by,
    locked_date = EXCLUDED.locked_date,
    locked_remark = EXCLUDED.locked_remark,
    unlocked_by = EXCLUDED.unlocked_by,
    unlocked_date = EXCLUDED.unlocked_date,
    unlocked_remark = EXCLUDED.unlocked_remark,
    created_time = EXCLUDED.created_time,
    risk_completion_time = EXCLUDED.risk_completion_time,
    exception_prompt = EXCLUDED.exception_prompt,
    type = EXCLUDED.type,
    first_withdrawal = EXCLUDED.first_withdrawal,
    label = EXCLUDED.label,
    account = EXCLUDED.account,
    account_id = EXCLUDED.account_id,
    amount = EXCLUDED.amount,
    site_product = EXCLUDED.site_product,
    created_by = EXCLUDED.created_by,
    open_time = EXCLUDED.open_time,
    audit_by = EXCLUDED.audit_by,
    assignee_time = EXCLUDED.assignee_time,
    processing_time = EXCLUDED.processing_time,
    processing_by = EXCLUDED.processing_by,
    process_time = EXCLUDED.process_time,
    processed_by = EXCLUDED.processed_by,
    risk_check = EXCLUDED.risk_check,
    exception_prompt_check = EXCLUDED.exception_prompt_check,
    ip_address = EXCLUDED.ip_address,
    rejection_reason = EXCLUDED.rejection_reason,
    remark = EXCLUDED.remark;