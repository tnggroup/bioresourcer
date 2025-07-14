#DROP TABLE t_consented_alias;
CREATE TEMPORARY TABLE t_consented_alias
(PRIMARY KEY t_pk (rn))
SELECT
ROW_NUMBER() OVER w AS rn,
jt.alias_matched STUDY_ID,
p.nhs_number NHS_NUMBER,
p.last_name SURNAME,
p.first_name FORENAME,
'' MIDDLENAMES,
p.address_line_1 ADDRESS_1,
p.address_line_2 ADDRESS_2,
p.address_city ADDRESS_3,
p.address_county ADDRESS_4,
'' ADDRESS_5,
p.address_post_code POSTCODE,
p.phone PHONE_NUMBER,
p.email,
p.date_of_birth DATE_OF_BIRTH,
p.date_of_death DATE_OF_DEATH,
p.gender_biological sex,
CASE  p.gender_identity
   			WHEN 'male' THEN 'male'
            WHEN 'female' THEN 'female'
            WHEN 'other' THEN 'other'
            ELSE p.gender_biological
END gender,
IF(ps2.consented_at IS NULL,
	cfr.created_at,
	ps2.consented_at) CONSENT_ACCEPTED, #fall-back on cfr.created_at in case of no ps2.consented_at
IF(ps2.consented_at IS NULL,1,0) CONSENT_ACCEPTED_is_null,
cf.version CONSENT_FORM_VERSION,
p.created_at CREATE_DATE,
-- destruction_request (value 1: request to destroy data, value 0: we are allowed to keep their data)
-- withdraw_samples (value 1: request to destroy samples, value 0: we are allowed to keep their sample)
w.llc_opt_out_outcome UKLLC_STATUS,
/* CASE w.can_access_medical_records
		WHEN '1' THEN '1'
		ELSE '0'
END withdrawn,
*/
-- '1'  National_Opt_Out,
CASE WHEN w.withdrew_at IS NULL
	THEN 0
	ELSE 1
END withdrawn,
w.withdrew_at,
w.reason withdrew_reason,
w.instigated_by withdrawn_by,
CASE WHEN w.sample_destruction_requested_at IS NULL
	THEN 0
	ELSE 1
END destruction_request,
is2.label information_sheet,
#not included in the PID export
p.id participant_id,
s.name study_name,
s.id study_id_num,
cf.id consent_form_id,
cfr.id consent_form_response_id,
cfr.created_at consent_form_response_created_at
FROM
mhbior.participants p
LEFT JOIN mhbior.withdrawals w
			ON p.id = w.participant_id
LEFT JOIN mhbior.participant_study ps
   		    ON ps.participant_id = p.id
LEFT JOIN mhbior.studies s
			ON  s.id = ps.study_id
LEFT JOIN mhbior.consent_form_responses cfr
			ON cfr.participant_id  = p.id
LEFT JOIN mhbior.participant_study ps2
            ON ( ps2.consent_form_response_id = cfr.id AND ps2.participant_id = p.id AND ps2.study_id = s.id)
LEFT JOIN mhbior.consent_forms cf
            ON ( cf.id = cfr.consent_form_id AND cf.study_id = s.id)
LEFT JOIN mhbior.information_sheets is2
			ON ps.information_sheet_id = is2.id
CROSS JOIN JSON_TABLE( p.aliases, '$[*]' COLUMNS( alias_matched VARCHAR(255) PATH '$'  ) ) AS jt
WHERE ( p.first_name NOT LIKE 'test%' OR p.last_name NOT LIKE 'test%')
AND jt.alias_matched IS NOT NULL
AND p.account_type = 'Active'
WINDOW w AS (ORDER BY jt.alias_matched,s.name,cf.id,cfr.id);

#152,331
#rn,STUDY_ID,CONSENT_ACCEPTED,consent_form_response_created_at
#SELECT * FROM t_consented_alias;
