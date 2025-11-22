--15.

INSERT INTO IMPC_gene (mgi_accession_id, gene_symbol)
SELECT DISTINCT mgi_accession_id, gene_symbol
FROM IMPC_analysis_raw
WHERE mgi_accession_id NOT IN (
    SELECT mgi_accession_id FROM IMPC_gene
);
