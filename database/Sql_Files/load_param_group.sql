DROP TABLE IF EXISTS IMPC_parameter_group_raw;

CREATE TABLE IMPC_parameter_group_raw(
group_name     VARCHAR(100),
parameter_name VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE 'parameter_groups.csv'
INTO TABLE IMPC_parameter_group_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(group_name, parameter_name);

INSERT IGNORE INTO IMPC_parameter_group (group_name)
SELECT DISTINCT group_name
FROM IMPC_parameter_group_raw;
