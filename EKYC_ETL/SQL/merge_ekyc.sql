INSERT INTO ekyc_clean
SELECT *
FROM staging_ekyc

ON CONFLICT (bill_no, exported_date)

DO UPDATE SET
    bill_no = EXCLUDED.bill_no,
    account = EXCLUDED.account,
    account_id = EXCLUDED.account_id,
    vip_level = EXCLUDED.vip_level,
    created_date = EXCLUDED.created_date,
    created_by = EXCLUDED.created_by,
    info_time = EXCLUDED.info_time,
    status = EXCLUDED.status,
    full_name = EXCLUDED.full_name,
    processed_by = EXCLUDED.processed_by,
    rejection_reason = EXCLUDED.rejection_reason,
    remark = EXCLUDED.remark,
    product = EXCLUDED.product,
    bloodline = EXCLUDED.bloodline,
    channel = EXCLUDED.channel,
    manual_reason = EXCLUDED.manual_reason,
    id_type = EXCLUDED.id_type,
    id_no = EXCLUDED.id_no,
    is_same_user = EXCLUDED.is_same_user,
    matched_user = EXCLUDED.matched_user,
    nationality = EXCLUDED.nationality,
    transaction_id = EXCLUDED.transaction_id,
    risk_start_time = EXCLUDED.risk_start_time,
    cs_start_time = EXCLUDED.cs_start_time,
    cs_completion_time = EXCLUDED.cs_completion_time,
    risk_completion_time = EXCLUDED.risk_completion_time,
    result_date = EXCLUDED.result_date,
    result = EXCLUDED.result,
    update_date = EXCLUDED.update_date,
    update_by = EXCLUDED.update_by,
    cs_pre_review_by = EXCLUDED.cs_pre_review_by,
    cs_pre_review_time = EXCLUDED.cs_pre_review_time,
    provider_type = EXCLUDED.provider_type,
    ekyc_version = EXCLUDED.ekyc_version;