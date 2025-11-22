-- 12. Populate IMPC_analysis (normalized experimental data)
--     Need to map (parameter_id, parameter_name) from IMPC_analysis_raw
--     to impc_parameter_orig_id in IMPC_parameter.
--
--     IMPC_parameter can have duplicate (parameter_code, parameter_name)
--     - multiple unique impc_parameter_orig_id.
--     - we pick MIN(impc_parameter_orig_id) per combination as the "first match".
-- =========================================================

INSERT INTO IMPC_analysis (
analysis_id,
mgi_accession_id,
impc_parameter_orig_id,
mouse_life_stage,
mouse_strain,
p_value
)
SELECT
a.analysis_id,
a.mgi_accession_id,
mp.impc_parameter_orig_id,
a.mouse_life_stage,
a.mouse_strain,
a.pvalue
FROM IMPC_analysis_raw a
LEFT JOIN (
SELECT
MIN(impc_parameter_orig_id) AS impc_parameter_orig_id,
parameter_code,
parameter_name
FROM IMPC_parameter
GROUP BY parameter_code, parameter_name
) mp
ON a.parameter_id = mp.parameter_code
AND a.parameter_name = mp.parameter_name;

-- Notes:
-- - If no match is found in IMPC_parameter, impc_parameter_orig_id will be NULL.
--   This is allowed and correctly reflects unmapped parameters.
