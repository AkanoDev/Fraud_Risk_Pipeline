INSERT INTO ekyc_clean
SELECT *
FROM staging_ekyc
ON CONFLICT (bill_no, exported_date)
DO NOTHING;