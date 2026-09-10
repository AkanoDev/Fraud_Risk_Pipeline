DELETE FROM pdt_rule_daily
WHERE exported_date IN (
    SELECT DISTINCT exported_date
    FROM staging_pending
    WHERE exported_date IS NOT NULL
);

INSERT INTO pdt_rule_daily (
    exported_date,
    rule_no,
    adjusted,
    unadjusted
)

SELECT
    exported_date,
    TRIM(rule) AS rule_no,

    SUM(is_adjusted) AS adjusted,

    COUNT(*) FILTER (
        WHERE is_adjusted = 0
    ) AS unadjusted

FROM pending_calculated

CROSS JOIN LATERAL
    regexp_split_to_table(rule_no, '\s*,\s*') AS rule

WHERE rule_no IS NOT NULL
  AND TRIM(rule) <> ''

GROUP BY
    exported_date,
    TRIM(rule)

ORDER BY
    exported_date,
    TRIM(rule)::INTEGER;