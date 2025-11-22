1. Execute data_merge.qmd to merge and reshape all csv data files

Input: raw csv data files
Output: merged_data.csv


2. Execute validators.R

No input/output


3. Execute data_cleaning.qmd

Input: IMPC_SOP.csv
       merged_data.csv

Output: validated_analysis_data.csv
        issue_log.csv

4. Execute process_metadata.qmd

Input: IMPC_parameter_description.txt
       IMPC_procedure.txt
       Disease_information.txt
       validated_analysis_data.csv

Output: IMPC_parameters.csv
        IMPC_procedure.csv
        IMPC_disease.csv
        IMPC_analysis.csv
        IMPC_human_gene_disease.csv

5. Execute parameter_grouping.qmd

Input: IMPC_parameters.csv

Output: parameter_groupings.csv
