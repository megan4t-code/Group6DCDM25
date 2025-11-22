LOAD DATA LOCAL INFILE 'IMPC_human_gene_disease.csv'
INTO TABLE IMPC_human_gene_disease
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(disease_id, omim_ids);
