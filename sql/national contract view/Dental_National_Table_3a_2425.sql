-------------------------------------------------------------------------
-- DENTAL National Activity - Table 3a
-------------------------------------------------------------------------

DROP TABLE dental_national_table3a_2425;

CREATE TABLE dental_national_table3a_2425 AS
SELECT treatment_year  as treatment_year,    
       SUM(uoa)        as uoa
FROM OST.DS_CONT_ORTHO_FACT_2425
WHERE 1=1 
GROUP BY treatment_year
ORDER BY treatment_year DESC
; 