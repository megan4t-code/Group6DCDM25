USE impc_db;

-- =========================================================
-- 1. Load IMPC_parameter metadata directly
--    File: IMPC_parameters.csv
--    Columns: impc_parameter_orig_id, parameter_name, description, parameter_code
-- =========================================================

-- IMPC_parameter already exists from schema.sql:
--   IMPC_parameter(
--       impc_parameter_orig_id INT PK,
--       parameter_code         VARCHAR(50),
--       parameter_name         VARCHAR(255),
--       parameter_description  TEXT
--   )

LOAD DATA LOCAL INFILE 'IMPC_parameters.csv'
INTO TABLE IMPC_parameter
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(impc_parameter_orig_id, parameter_name, parameter_description, parameter_code);
