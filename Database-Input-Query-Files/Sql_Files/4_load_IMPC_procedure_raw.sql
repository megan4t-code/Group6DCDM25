USE impc_db;
DROP TABLE IF EXISTS IMPC_procedure_raw;


-- 4. STAGING: IMPC_procedure_raw
--    File: IMPC_procedure.csv
--    Columns: procedure_name, description, is_mandatory, impc_parameter_orig_id
-- =========================================================

CREATE TABLE IMPC_procedure_raw (
procedure_name         VARCHAR(255),
description            TEXT,
is_mandatory           VARCHAR(10),
impc_parameter_orig_id INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE 'IMPC_procedure.csv'
INTO TABLE IMPC_procedure_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(procedure_name, description, is_mandatory, impc_parameter_orig_id);
