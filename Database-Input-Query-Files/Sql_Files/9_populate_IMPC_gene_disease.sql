-- 9. Populate IMPC_gene_disease (gene-disease link)
-- =========================================================

INSERT INTO IMPC_gene_disease (mgi_accession_id, disease_id)
SELECT DISTINCT
mgi_accession_id,
disease_id
FROM IMPC_disease_raw
WHERE mgi_accession_id IS NOT NULL
AND disease_id IS NOT NULL;
