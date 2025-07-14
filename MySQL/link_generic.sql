/*THIS WILL NOT EXECUTE IN YOUR DB GUI - IS SUPPOSED TO BE RUN FROM A SCRIPT THAT CAN REPLACE ? PARAMETERS*/

#DROP TABLE t_link;
CREATE TEMPORARY TABLE t_link
(PRIMARY KEY t_link_pk (STUDY_ID,barcode))
SELECT
ca.STUDY_ID,
SURNAME,
FORENAME,
DATE_OF_BIRTH,
email,
POSTCODE,
study_name,
s.barcode,
s.date_kit_received,
s.date_kit_sent,
s.nhs_provided,
s.kit_unusable,
s.destruction_certificate,
s.type,
s.royal_mail_tracking_id,
s.sample_import_id
FROM
(
	SELECT 
	t_consented_alias.*,
	ROW_NUMBER() OVER(PARTITION BY STUDY_ID ORDER BY CONSENT_ACCEPTED_is_null,CONSENT_ACCEPTED,consent_form_response_created_at,participant_id,rn) rnr 
	FROM
	t_consented_alias, #shared temporary table
	(SELECT ? sidnumsetting) sidnumsetting_table
	WHERE
	(
		sidnumsetting = 1 #GLAD
	  	AND study_id_num  = 1
	  	AND STUDY_ID REGEXP '^GLAD[0-9]{6}$'
	  	AND CONSENT_ACCEPTED < '2024-10-16' #Flag when CONSENT_ACCEPTED is null somehow?
	)
	OR
	(
		sidnumsetting = 2 #EDGI
	  	AND study_id_num  = 2
	  	AND STUDY_ID REGEXP '^EDGI[0-9]{6}$'
	)
	
	#CONSENT_ACCEPTED is now falling back on the cfr created date
	#we should use the earliest consent date in case there are multiple for the same study
	
) ca
LEFT JOIN mhbior.samples s ON ca.participant_id = s.participant_id
WHERE
rnr=1
AND s.barcode IS NOT NULL
ORDER BY ca.STUDY_ID;
#SELECT * FROM t_link;