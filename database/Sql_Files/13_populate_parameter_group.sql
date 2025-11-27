--13.

INSERT IGNORE INTO IMPC_parameter_group (group_name)
SELECT DISTINCT group_name
FROM IMPC_parameter_group_raw;
