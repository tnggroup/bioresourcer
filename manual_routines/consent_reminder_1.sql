/*GLAD consent reminder email 1 (GLAD consented not finished survey v2)
  Date: 22/05/2025
  Author: Laura Meldrum */
 
SELECT 
jt.alias_matched AS Aliases,
p.id AS 'Participant id', 
p.first_name AS forename,
p.last_name AS surname, 
p.email AS 'email address',
p.phone AS 'phone number',
cfr.created_at AS consented,
ps.manual_eligibility_state,
ps.export_eligibility_state
#c.type, 
#c.number, 
#c.sent_at
#select jt.alias_matched AS Aliases,p.id,p.first_name,ps.id,cfr.id,cf.id,cremindersone.id

FROM participants p
CROSS JOIN JSON_TABLE(p.aliases, '$[*]' COLUMNS(alias_matched VARCHAR(255) PATH '$')) AS jt
JOIN participant_study ps ON ps.participant_id = p.id
LEFT JOIN consent_form_responses cfr ON cfr.participant_id = p.id 
LEFT JOIN consent_forms cf ON cf.id = cfr.consent_form_id AND cf.study_id = ps.study_id
LEFT JOIN communications cremindersone ON cremindersone.participant_id = p.id AND cremindersone.study_id = ps.study_id AND cremindersone.type = 'Consent Reminder' AND cremindersone.number=1
LEFT JOIN withdrawals w on w.participant_id = p.id AND w.study_id = ps.study_id

WHERE p.account_type = 'Active'
AND ps.study_id = 1 #GLAD
AND jt.alias_matched REGEXP '^GLAD[0-9]{6}$'
AND (p.first_name NOT LIKE 'test%' OR p.last_name NOT LIKE 'test%')
AND cfr.created_at IS NOT NULL #has consented
AND ps.manual_eligibility_state IS NULL 
AND ps.export_eligibility_state IS NULL #is not eligible (this needs to be looked at)
AND cremindersone.id IS NULL #has NOT already received a reminder (this needs to be edited to be has not received the first consent reminder)
AND w.withdrew_at IS NULL #has NOT withdrawn

ORDER BY Aliases
;

#04/06/2025 LM. Issues: eligibility state not correct for participants, for next reminders, how do we select only the ppts who have been sent reminder 1 but not the others 