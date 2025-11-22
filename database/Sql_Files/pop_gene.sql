-- 5. Populate IMPC_gene (canonical gene symbol per MGI ID)
-- =========================================================

-- IMPC_gene: one row per gene, choose a canonical symbol
INSERT INTO IMPC_gene (mgi_accession_id, gene_symbol)
SELECT 
    d.mgi_accession_id,
    MIN(a.gene_symbol) AS gene_symbol   -- NULL if no match or only NULLs
FROM (
    -- unique mgi_accession_id from disease data
    SELECT DISTINCT mgi_accession_id
    FROM IMPC_disease_raw
    WHERE mgi_accession_id IS NOT NULL
) AS d
LEFT JOIN IMPC_analysis_raw a
  ON d.mgi_accession_id = a.mgi_accession_id
GROUP BY d.mgi_accession_id;
