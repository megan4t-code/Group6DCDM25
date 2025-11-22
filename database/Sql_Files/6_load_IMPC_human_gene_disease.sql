-- 6.
-- Loading directly to IMPC_human_gene_disease table
-- The csv file is generated through R script as part of data cleaning
-- csv contains disease_id and omim_ids mapping
-- omim_id format in disease metadata is fixed using R script 
-- (example bad data- omim ids with pipe separation in a cell: OMIM:100300|OMIM:614219|OMIM:615297)

LOAD DATA LOCAL INFILE 'IMPC_human_gene_disease.csv'
INTO TABLE IMPC_human_gene_disease
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(disease_id, omim_ids);
