INSERT INTO withdrawal_clean
SELECT *
FROM staging_withdrawal
ON CONFLICT (serial_number, exported_date)
DO NOTHING;