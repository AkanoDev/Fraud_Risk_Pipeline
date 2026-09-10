DELETE FROM wd_breakdown_daily
WHERE exported_date IN (
    SELECT DISTINCT exported_date
    FROM staging_withdrawal
    WHERE exported_date IS NOT NULL
);

INSERT INTO wd_breakdown_daily (
    exported_date,
    breakdown_type,
    category,
    breakdown_value,
    breakdown_order,
    total
)

/* ==========================================
   PROCESSING DURATION
========================================== */

SELECT
    exported_date,
    'Duration' AS breakdown_type,
    processing_type AS category,
    duration_bracket AS breakdown_value,

    CASE duration_bracket
        WHEN '< 1 min' THEN 1
        WHEN '1-2 min' THEN 2
        WHEN '2-3 min' THEN 3
        WHEN '3-5 min' THEN 4
        WHEN '5-7 min' THEN 5
        WHEN '7-10 min' THEN 6
        WHEN '10-20 min' THEN 7
        WHEN '20 min+' THEN 8
        ELSE 999
    END AS breakdown_order,

    COUNT(*) AS total

FROM withdrawal_calculated

WHERE duration_bracket IS NOT NULL
  AND exported_date IN (
      SELECT DISTINCT exported_date
      FROM staging_withdrawal
      WHERE exported_date IS NOT NULL
  )

GROUP BY
    exported_date,
    processing_type,
    duration_bracket


UNION ALL

/* ==========================================
   AGENT PERFORMANCE
========================================== */

SELECT
    exported_date,
    'Agent' AS breakdown_type,
    status AS category,

    CASE
        WHEN status = 'Cancel in background'
            THEN processed_by
        ELSE processing_by
    END AS breakdown_value,

    NULL AS breakdown_order,
    COUNT(*) AS total

FROM withdrawal_calculated

WHERE
    exported_date IN (
        SELECT DISTINCT exported_date
        FROM staging_withdrawal
        WHERE exported_date IS NOT NULL
    )

AND(
    processing_by IN (
        'danilo.celedio@', 'laurence.lino@', 'maria.dadia@', 'john.cailo@','jusmien.tugas@',
        'kenneth.reyes@', 'rolly.deogracias@', 'elizondo.adrao@', 'rosemarie.dikitanan@','marilyn.manila@',
        'aldrine.manlangit@', 'julie.cunanan@', 'kimcent.billiones@', 'jonalyn.rivera@', 'micy.soriano@',
        'roma.delacruz@', 'jenny.duan@', 'michael.tadeo@', 'samuel.macariola@', 'paulo.manukay@',
        'trestan.golez@', 'jared.gotgotao@', 'rachel.valle@', 'rhegine.herrera@', 'patrick.penaojas@',
        'alvin.bernardo@', 'ariel.tuplano@', 'erick.alimpolos@', 'jeffrey.bacosmo@', 'jessica.gallardo@',
        'john.tablazon@', 'kimberly.evangelista@', 'mark.bandoy@', 'rex.hemparo@',
        'rosemarie.delespiritusanto@', 'irene.basilio@'
    )

    OR processed_by IN (
        'danilo.celedio@', 'laurence.lino@', 'maria.dadia@', 'john.cailo@','jusmien.tugas@',
        'kenneth.reyes@', 'rolly.deogracias@', 'elizondo.adrao@', 'rosemarie.dikitanan@','marilyn.manila@',
        'aldrine.manlangit@', 'julie.cunanan@', 'kimcent.billiones@', 'jonalyn.rivera@', 'micy.soriano@',
        'roma.delacruz@', 'jenny.duan@', 'michael.tadeo@', 'samuel.macariola@', 'paulo.manukay@',
        'trestan.golez@', 'jared.gotgotao@', 'rachel.valle@', 'rhegine.herrera@', 'patrick.penaojas@',
        'alvin.bernardo@', 'ariel.tuplano@', 'erick.alimpolos@', 'jeffrey.bacosmo@', 'jessica.gallardo@',
        'john.tablazon@', 'kimberly.evangelista@', 'mark.bandoy@', 'rex.hemparo@',
        'rosemarie.delespiritusanto@', 'irene.basilio@'
    )
)

GROUP BY
    exported_date,
    status,
    CASE
        WHEN status = 'Cancel in background'
            THEN processed_by
        ELSE processing_by
    END

UNION ALL

/* ==========================================
   STATUS
========================================== */

SELECT
    exported_date,
    'Status' AS breakdown_type,
    status AS category,
    status AS breakdown_value,
    NULL AS breakdown_order,
    COUNT(*) AS total

FROM withdrawal_calculated

WHERE exported_date IN (
    SELECT DISTINCT exported_date
    FROM staging_withdrawal
    WHERE exported_date IS NOT NULL
)

GROUP BY
    exported_date,
    status

UNION ALL

/* ==========================================
	AGENT PROCESSING TIME
========================================== */

SELECT
    exported_date,
    'Agent2' AS breakdown_type,

    CASE
        WHEN status = 'Cancel in background'
            THEN processed_by
        ELSE processing_by
    END AS category,

    duration_bracket AS breakdown_value,

    CASE duration_bracket
        WHEN '< 1 min' THEN 1
        WHEN '1-2 min' THEN 2
        WHEN '2-3 min' THEN 3
        WHEN '3-5 min' THEN 4
        WHEN '5-7 min' THEN 5
        WHEN '7-10 min' THEN 6
        WHEN '10-20 min' THEN 7
        WHEN '20 min+' THEN 8
        ELSE 999
    END AS breakdown_order,

    COUNT(*) AS total

FROM withdrawal_calculated

WHERE
    exported_date IN (
        SELECT DISTINCT exported_date
        FROM staging_withdrawal
        WHERE exported_date IS NOT NULL
    )

    AND duration_bracket IS NOT NULL

    AND (
        processing_by IN (
            'danilo.celedio@', 'laurence.lino@', 'maria.dadia@', 'john.cailo@',
            'jusmien.tugas@', 'kenneth.reyes@', 'rolly.deogracias@',
            'elizondo.adrao@', 'rosemarie.dikitanan@', 'marilyn.manila@',
            'aldrine.manlangit@', 'julie.cunanan@', 'kimcent.billiones@',
            'jonalyn.rivera@', 'micy.soriano@', 'roma.delacruz@',
            'jenny.duan@', 'michael.tadeo@', 'samuel.macariola@',
            'paulo.manukay@', 'trestan.golez@', 'jared.gotgotao@',
            'rachel.valle@', 'rhegine.herrera@', 'patrick.penaojas@',
            'alvin.bernardo@', 'ariel.tuplano@', 'erick.alimpolos@',
            'jeffrey.bacosmo@', 'jessica.gallardo@', 'john.tablazon@',
            'kimberly.evangelista@', 'mark.bandoy@', 'rex.hemparo@',
            'rosemarie.delespiritusanto@', 'irene.basilio@'
        )

        OR processed_by IN (
            'danilo.celedio@', 'laurence.lino@', 'maria.dadia@', 'john.cailo@',
            'jusmien.tugas@', 'kenneth.reyes@', 'rolly.deogracias@',
            'elizondo.adrao@', 'rosemarie.dikitanan@', 'marilyn.manila@',
            'aldrine.manlangit@', 'julie.cunanan@', 'kimcent.billiones@',
            'jonalyn.rivera@', 'micy.soriano@', 'roma.delacruz@',
            'jenny.duan@', 'michael.tadeo@', 'samuel.macariola@',
            'paulo.manukay@', 'trestan.golez@', 'jared.gotgotao@',
            'rachel.valle@', 'rhegine.herrera@', 'patrick.penaojas@',
            'alvin.bernardo@', 'ariel.tuplano@', 'erick.alimpolos@',
            'jeffrey.bacosmo@', 'jessica.gallardo@', 'john.tablazon@',
            'kimberly.evangelista@', 'mark.bandoy@', 'rex.hemparo@',
            'rosemarie.delespiritusanto@', 'irene.basilio@'
        )
    )

GROUP BY
    exported_date,
    CASE
        WHEN status = 'Cancel in background'
            THEN processed_by
        ELSE processing_by
    END,
    duration_bracket

UNION ALL

/* ==========================================
	PROMPT CHECK
========================================== */

SELECT
    exported_date,
    'Prompt' AS breakdown_type,
    status AS category,
    exception_prompt_check::TEXT AS breakdown_value,
    NULL AS breakdown_order,
    COUNT(*) AS total

FROM withdrawal_calculated

WHERE
    exported_date IN (
        SELECT DISTINCT exported_date
        FROM staging_withdrawal
        WHERE exported_date IS NOT NULL
    )

    AND processing_type <> 'System'
    AND type <> 'Branch'

GROUP BY
    exported_date,
    status,
    exception_prompt_check

ORDER BY
    exported_date,
    breakdown_type,
    category,
    breakdown_value;
