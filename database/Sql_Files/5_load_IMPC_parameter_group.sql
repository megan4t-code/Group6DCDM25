USE impc_db;
DROP TABLE IF EXISTS IMPC_parameter_group_raw;

-- 5. STAGING: IMPC_parameter_group_raw
--    File: parameter_groupings.csv
--    Columns: group_name, parameter_name
-- =========================================================

CREATE TABLE IMPC_parameter_group_raw(
group_name     VARCHAR(100),
parameter_name VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE 'parameter_groupings.csv'
INTO TABLE IMPC_parameter_group_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(group_name, parameter_name);
