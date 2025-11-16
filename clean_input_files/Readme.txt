NOTE: There is a change in schema

1. We have impc_parameter_orig_id for IMPC_analysis table and we decided to drop parameter_name and parameter_id. The assumption was that a unique set of parameter_name and parameter_id represents an impc_parameter_orig_id in Parameters table and this true for many rows but not for all. There are multiple unique impc_parameter_orig_ids which represent the same set of parameter_name and parameter_id. For example, in parameters table rows 918 and 262 both have "Blood Vessel Morphology" as parameter name and "IMPC_GEP_013_001" as parameter_id. So, exactly the same rows, just a different impc_parameter_orig_id. If we find  impc_parameter_orig_id in parameters table for the  parameter_name and parameter_id in analysis table, we will have multiple impc_parameter_orig_id to choose from. One way is choose the first instance. Because we have this issue to resolve, I have not changed the structure of analysis table yet. But if we align on how to handle this, I can update the structure.

2. I have not created the IMPC_gene table as there is no other mapping between mgi_accession_id and gene_symbol available other than in the analysis table which is the experimental data and should not be used to determine the relation between the two fields. We can drop this table and keep gene_symbol in analysis table as it was earlier.

3. Kept column name omim_id instead of omim_ids in IMPC_disease table

4. IMPC_parameter_group and IMPC_parameter_group_member tables need to be created in DB, others are available as CSV files as part of data cleaning.