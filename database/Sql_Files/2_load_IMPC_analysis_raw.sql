USE impc_db;

-- =========================================================
-- 2.  Drop staging table if it exists
-- =========================================================
DROP TABLE IF EXISTS IMPC_analysis_raw;

-- 2. STAGING: IMPC_analysis_raw
--    File: IMPC_analysis.csv
--    Columns:
--      analysis_id, mgi_accession_id, gene_symbol,
--      mouse_life_stage, mouse_strain,
--      parameter_id, parameter_name, pvalue
-- =========================================================

CREATE TABLE IMPC_analysis_raw (
analysis_id      VARCHAR(20),
mgi_accession_id VARCHAR(20),
gene_symbol      VARCHAR(50),
mouse_life_stage VARCHAR(50),
mouse_strain     VARCHAR(50),
parameter_id     VARCHAR(50),    -- this corresponds to parameter_code (IMPC_...)
parameter_name   VARCHAR(255),
pvalue           DOUBLE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE 'IMPC_analysis.csv'
INTO TABLE IMPC_analysis_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(analysis_id, mgi_accession_id, gene_symbol,
mouse_life_stage, mouse_strain,
parameter_id, parameter_name, pvalue);
