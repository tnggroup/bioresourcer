/* GLAD reminder email (registration 1)
 * Date: 27/02/2024
 * Author: Mika Malouf
 */
 

USE mhbior;
 
SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 ps.id as 'Participant id',
 ps2.consented_at,
 ps.first_name as forename,
 last_name as surname, 
 ps.email,
 ps.phone as mobile,
 ps2.export_eligibility_state,
 ps.registered_at

FROM participants ps, samples s, participant_study ps2, studies ss
WHERE ps.id = s.participant_id 
AND ps2.participant_id = ps.id
AND ss.id = ps2.study_id
AND account_type = 'Active'
AND ps.withdrew_at IS NULL
AND ss.name = 'GLAD'
AND ps.email IS NOT NULL
AND date_kit_sent IS NULL
AND ps2.consented_at IS NULL
AND ps.registered_at IS NOT NULL;