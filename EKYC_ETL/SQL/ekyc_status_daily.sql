TRUNCATE TABLE ekyc_status_daily;

INSERT INTO ekyc_status_daily (
    exported_date,
    total_ekyc,
    system_reviewed,
    manual_reviewed,
    total_approval,
    system_approval,
    manual_approval,
    auto_reject,
    manual_reject,
    total_reject,
    invalid,
    improve_information
)

SELECT
    exported_date,

    COUNT(*) AS total_ekyc,

    COUNT(*) FILTER (
        WHERE processed_by = 'system'
    ) AS system_reviewed,

	COUNT(*) FILTER (
	    WHERE processed_by <> 'system'
	      AND (
	          status = 'Approval'
	          OR status = 'Manual Reject'
	      )
	) AS manual_reviewed,

	COUNT(*) FILTER (
        WHERE status = 'Approval' 
    ) AS total_approval,
	
    COUNT(*) FILTER (
        WHERE approval_type = 'System Approval'
    ) AS system_approval,

    COUNT(*) FILTER (
        WHERE approval_type = 'Manual Approval'
    ) AS manual_approval,

    COUNT(*) FILTER (
        WHERE status = 'Auto Reject'
    ) AS auto_reject,

    COUNT(*) FILTER (
        WHERE status = 'Manual Reject'
    ) AS manual_reject,

    COUNT(*) FILTER (
        WHERE status IN ('Auto Reject', 'Manual Reject')
    ) AS total_reject,

    COUNT(*) FILTER (
        WHERE status = 'Invalid'
    ) AS invalid,

    COUNT(*) FILTER (
        WHERE status = 'Improve Information'
    ) AS improve_information


FROM ekyc_calculated

GROUP BY exported_date

ORDER BY exported_date;