INSERT INTO IMPC_procedure_parameter (procedure_id, impc_parameter_orig_id)
SELECT
p.procedure_id,
r.impc_parameter_orig_id
FROM IMPC_procedure_raw r
JOIN IMPC_procedure p
ON r.procedure_name = p.procedure_name
WHERE r.impc_parameter_orig_id IS NOT NULL;
