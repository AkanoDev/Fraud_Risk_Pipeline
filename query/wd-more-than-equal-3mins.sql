SELECT *
FROM withdrawal_calculated
    WHERE duration_seconds >= 180
    AND exported_date BETWEEN '2026-09-01' AND '2026-09-07';