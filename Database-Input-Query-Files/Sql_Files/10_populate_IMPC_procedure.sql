-- 10.

INSERT INTO IMPC_procedure (procedure_name, description, is_mandatory)
SELECT
    procedure_name,

    -- Prefer a non-NULL, non-'NA' description
    COALESCE(
        MAX(CASE WHEN description IS NOT NULL AND description <> 'NA' THEN description END),
        NULL
    ) AS description,

    -- Map TRUE/FALSE text to 1/0 at the row level, then aggregate
    MAX(
      CASE 
        WHEN is_mandatory = 'TRUE'  THEN 1
        WHEN is_mandatory = 'FALSE' THEN 0
        ELSE NULL
      END
    ) AS is_mandatory

FROM IMPC_procedure_raw
WHERE procedure_name IS NOT NULL
GROUP BY procedure_name;
