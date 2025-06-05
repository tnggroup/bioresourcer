/* GLAD consented participants who have not yet completed their baseline questionnaire- 
 * Date: 18/06/2024
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) aliases,
 p.id as 'Participant id',
 p.email,
 p.phone as mobile,
 first_name forename,
 last_name surname,
 ps.export_eligibility_state,
 consented_at,
 ps.manual_eligibility_state
 
 FROM participants p, participant_study ps, studies s
 WHERE p.id = ps.participant_id 
 AND s.id = ps.study_id 
 AND ps.export_eligibility_state IS NULL 
 AND ps.manual_eligibility_state IS NULL
 AND ps.consented_at IS NOT NULL
 AND p.withdrew_at IS NULL
 AND s.name = 'GLAD'
 AND account_type = 'Active';