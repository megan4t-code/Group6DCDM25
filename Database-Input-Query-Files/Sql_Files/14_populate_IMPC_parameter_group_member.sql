--14.

INSERT INTO IMPC_parameter_group_member (impc_parameter_orig_id, parameter_group_id)
SELECT DISTINCT
p.impc_parameter_orig_id,
g.parameter_group_id
FROM IMPC_parameter_group_raw r
JOIN IMPC_parameter p
ON r.parameter_name = p.parameter_name
JOIN IMPC_parameter_group g
ON r.group_name = g.group_name;
