-- =========================================================
-- 8. Populate IMPC_disease (distinct diseases)
--    IMPC_disease(disease_id, disease_name, omim_ids)
-- =========================================================

INSERT INTO IMPC_disease (disease_id, disease_name, omim_ids)
SELECT DISTINCT
disease_id,
disease_name,
omim_id
FROM IMPC_disease_raw
WHERE disease_id IS NOT NULL;
