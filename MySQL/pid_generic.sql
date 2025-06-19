
/*
 * --MySQL top of each group
SELECT group_col, order_col FROM (
  SELECT group_col, order_col
  , ROW_NUMBER() OVER(PARTITION BY group_col ORDER BY order_col) rnr
  FROM some_table
  WHERE <some_condition>
) i
WHERE rnr=1;
*/
#DROP TABLE t_pid;
CREATE TEMPORARY TABLE t_pid
(PRIMARY KEY t_pid_pk (STUDY_ID))
SELECT
STUDY_ID,
NHS_NUMBER,
SURNAME,
FORENAME,
MIDDLENAMES,
ADDRESS_1,
ADDRESS_2,
ADDRESS_3,
ADDRESS_4,
ADDRESS_5,
POSTCODE,
PHONE_NUMBER,
email,
DATE_OF_BIRTH,
DATE_OF_DEATH,
sex,
gender,
CONSENT_ACCEPTED,
CONSENT_FORM_VERSION,
CREATE_DATE, /*remove this, says Laura*/
-- destruction_request (value 1: request to destroy data, value 0: we are allowed to keep their data)
-- withdraw_samples (value 1: request to destroy samples, value 0: we are allowed to keep their sample)
UKLLC_STATUS,
withdrawn,
withdrew_at,
#withdrew_reason,
#withdrawn_by,
destruction_request,
information_sheet
FROM (
	SELECT
	t_consented_alias.*,
	ROW_NUMBER() OVER(PARTITION BY STUDY_ID ORDER BY CONSENT_ACCEPTED_is_null,CONSENT_ACCEPTED,consent_form_response_created_at,participant_id,rn) rnr
	FROM
	t_consented_alias #shared temporary table
	WHERE
	(
	  	? = 1
	  	AND study_id_num  = 1
	  	AND STUDY_ID REGEXP '^GLAD[0-9]{6}$'
	  	AND CONSENT_ACCEPTED < '2024-10-16' #Flag when CONSENT_ACCEPTED is null somehow?
	)
	/*
	OR
	(
	  	? = 2 #EDGI
	  	AND study_id_num  = 2
	  	AND STUDY_ID REGEXP '^EDGI[0-9]{6}$'
	)
*/
	#CONSENT_ACCEPTED is now falling back on the cfr created date
	#we should use the earliest consent date in case there are multiple for the same study
) ca
WHERE rnr=1
ORDER BY STUDY_ID;
