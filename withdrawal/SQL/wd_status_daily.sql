DELETE FROM wd_status_daily
WHERE exported_date IN (
    SELECT DISTINCT exported_date
    FROM staging_withdrawal
    WHERE exported_date IS NOT NULL
);

INSERT INTO wd_status_daily(
    exported_date,
    total_withdrawal,
    total_pending_wd,
    total_approved_wd,
    total_cancel_wd,
    total_denied_wd,
    total_system_review,
    total_manual_review
)

SELECT
    exported_date,

	COUNT(*) AS total_withdrawal,

	-- WD STATUS
	
	COUNT(*) FILTER (
		WHERE status = 'Pending' OR
			status = 'Pending2'
	) AS total_pending_wd,

	COUNT(*) FILTER (
			WHERE status = 'Approved'
	) AS total_approved_wd,

	COUNT(*) FILTER (
			WHERE status = 'Cancel in background'
	) AS total_cancel_wd,
	
	COUNT(*) FILTER (
			WHERE status = 'Denied'
	) AS total_denied_wd,

	-- REVIEWED BY
	
	COUNT(*) FILTER (
			WHERE processing_by = 'system'
	) AS total_system_review,
	

	COUNT(*) FILTER (
	    WHERE processing_by IN (
			'danilo.celedio@', 'laurence.lino@', 'maria.dadia@', 'john.cailo@','jusmien.tugas@',
			'kenneth.reyes@', 'rolly.deogracias@', 'elizondo.adrao@', 'rosemarie.dikitanan@','marilyn.manila@',
			'aldrine.manlangit@', 'julie.cunanan@', 'kimcent.billiones@', 'jonalyn.rivera@', 'micy.soriano@',
			'roma.delacruz@', 'jenny.duan@', 'michael.tadeo@', 'samuel.macariola@', 'paulo.manukay@',
			'trestan.golez@', 'jared.gotgotao@', 'rachel.valle@', 'rhegine.herrera@', 'patrick.penaojas@',
			'alvin.bernardo@', 'ariel.tuplano@', 'erick.alimpolos@', 'jeffrey.bacosmo@', 'jessica.gallardo@',
			'john.tablazon@', 'kimberly.evangelista@', 'mark.bandoy@', 'rex.hemparo@','rosemarie.delespiritusanto@', 'irene.basilio@'
		)
		OR processed_by IN (
			'danilo.celedio@', 'laurence.lino@', 'maria.dadia@', 'john.cailo@','jusmien.tugas@',
			'kenneth.reyes@', 'rolly.deogracias@', 'elizondo.adrao@', 'rosemarie.dikitanan@','marilyn.manila@',
			'aldrine.manlangit@', 'julie.cunanan@', 'kimcent.billiones@', 'jonalyn.rivera@', 'micy.soriano@',
			'roma.delacruz@', 'jenny.duan@', 'michael.tadeo@', 'samuel.macariola@', 'paulo.manukay@',
			'trestan.golez@', 'jared.gotgotao@', 'rachel.valle@', 'rhegine.herrera@', 'patrick.penaojas@',
			'alvin.bernardo@', 'ariel.tuplano@', 'erick.alimpolos@', 'jeffrey.bacosmo@', 'jessica.gallardo@',
			'john.tablazon@', 'kimberly.evangelista@', 'mark.bandoy@', 'rex.hemparo@','rosemarie.delespiritusanto@', 'irene.basilio@'
		)
	) AS total_manual_review
	
FROM withdrawal_calculated

WHERE exported_date IN (
    SELECT DISTINCT exported_date
    FROM staging_withdrawal
    WHERE exported_date IS NOT NULL
)

GROUP BY exported_date
ORDER BY exported_date; 