USE impc_db;
DROP TABLE IF EXISTS IMPC_disease_raw;

-- 3. STAGING: IMPC_disease_raw
--    File: IMPC_disease.csv
--    Columns: disease_id, disease_name, omim_id, mgi_accession_id
-- =========================================================

CREATE TABLE IMPC_disease_raw (
disease_id       VARCHAR(50),
disease_name     VARCHAR(255),
omim_id          VARCHAR(100),
mgi_accession_id VARCHAR(20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE 'IMPC_disease.csv'
INTO TABLE IMPC_disease_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(disease_id, disease_name, omim_id, mgi_accession_id);
