/*GLAD reminder email (registration 1) v2
  Date: 22/05/2025
  Author: Laura Meldrum */
 
SELECT 
jt.alias_matched AS Aliases,
p.id AS 'Participant id', 
p.first_name AS forename,
p.last_name AS surname, 
p.email AS 'Email address',
p.phone AS 'Phone number',
p.registered_at, 
cfr.created_at AS consented

FROM participants p
CROSS JOIN JSON_TABLE(p.aliases, '$[*]' COLUMNS(alias_matched VARCHAR(255) PATH '$')) AS jt
JOIN participant_study ps ON ps.participant_id = p.id
LEFT JOIN consent_form_responses cfr ON cfr.participant_id = p.id 
LEFT JOIN consent_forms cf ON cf.id = cfr.consent_form_id AND cf.study_id = ps.study_id
LEFT JOIN communications c ON c.participant_id = p.id AND c.study_id = ps.study_id
LEFT JOIN withdrawals w on w.participant_id = p.id AND w.study_id = ps.study_id

WHERE p.account_type = 'Active'
AND jt.alias_matched REGEXP '^GLAD[0-9]{6}$'
AND (p.first_name NOT LIKE 'test%' OR p.last_name NOT LIKE 'test%')
AND cfr.created_at IS NULL #has NOT consented
AND c.sent_at IS NULL #has NOT already received a reminder 
AND w.withdrew_at IS NULL #has NOT withdrawn 
AND ps.study_id = 1 #GLAD

ORDER BY Aliases
;

/*
Issues - LM 22/05/2025
are participants who have already consented still in this report?
are all withdrawn participants removed from this report?
does this remove all people who have already had a registration reminder? no it does not (obscured-1699250890-654882ca8c720@example.co.uk)
EDGI participants are in this list
why are there some consent dates in the consented_at column that do not match MHBIOR?

Testing: go through the usual registration reminders process and check if there are participants who are being removed in the merging steps*/