params <-
list(data_dir = "../output/merged_data/", metadata_dir = "../metadata/", 
    output_dir = "../output/")

source("validators.R")
library(stringr)
library(dplyr)
library(tidyr)


##Read Metadata
output_path <- params$output_dir
metadata_path <- params$metadata_dir

IMPC_parameters_orig <- read.csv(
  paste0(metadata_path, "IMPC_parameter_description.txt"),
  col.names = c("impc_parameter_orig_id", "parameter_name", "description", "parameter_code"),
  stringsAsFactors = FALSE
) %>% mutate(across(where(is.character), trimws)) %>%   # remove leading/trailing white spaces
  mutate(across(where(is.character), ~ na_if(., ""))) %>% # set blanks to NA so DB can treat NAs as null
  mutate(across(where(is.character), ~ na_if(., "NA")))   # setting all "NA" strings to true NAs

IMPC_procedures_orig <- read.csv(
  paste0(metadata_path, "IMPC_procedure.txt"),
  col.names = c("procedure_name", "description", "is_mandatory", "impc_parameter_orig_id"),
  stringsAsFactors = FALSE
) %>% mutate(across(where(is.character), trimws)) %>%
  mutate(across(where(is.character), ~ na_if(., ""))) %>%
  mutate(across(where(is.character), ~ na_if(., "NA")))

IMPC_disease_orig <- read.csv(
  paste0(metadata_path, "Disease_information.txt"),
  sep = "\t",
  col.names = c("disease_id", "disease_name", "omim_id", "mgi_accession_id"),
  stringsAsFactors = FALSE
) %>% mutate(across(where(is.character), trimws)) %>%
  mutate(across(where(is.character), ~ na_if(., ""))) %>%
  mutate(across(where(is.character), ~ na_if(., "NA")))

#Reading clean data
IMPC_analysis_orig <- read.csv(
  paste0(output_path, "validated_analysis_data.csv"), 
  col.names = c("analysis_id", "mgi_accession_id", "gene_symbol", "mouse_life_stage", "mouse_strain", "parameter_id",	"parameter_name", "pvalue"),
  stringsAsFactors = FALSE
) %>% mutate(across(where(is.character), trimws)) %>%
  mutate(across(where(is.character), ~ na_if(., ""))) %>%
  mutate(across(where(is.character), ~ na_if(., "NA")))


#Writing formatted data frames with primary key duplicates removed to CSVs
#parameters
result <- remove_duplicates(IMPC_parameters_orig, "impc_parameter_orig_id")
IMPC_parameters_with_unique_orig_id <- result$data
write.csv(IMPC_parameters_with_unique_orig_id, "../output/IMPC_parameters.csv", row.names = FALSE, na = "\\N")

#procedure
write.csv(IMPC_procedures_orig, "../output/IMPC_procedure.csv", row.names = FALSE, na = "\\N")

#disease
result <- remove_duplicates(IMPC_disease_orig, "disease_id")
IMPC_unique_disease <- result$data
write.csv(IMPC_unique_disease, "../output/IMPC_disease.csv", row.names = FALSE, na = "\\N")

#analysis
write.csv(IMPC_analysis_orig, "../output/IMPC_analysis.csv", row.names = FALSE, na = "\\N")


#Split joined omim ids to separate rows and create normalized disease omim relation and write the data to CSV to load in DB
IMPC_human_gene_disease <- IMPC_unique_disease %>%
  select(disease_id, omim_id) %>%
  filter(!is.na(omim_id) & omim_id != "") %>%
  # Split omim id values like these:"OMIM:247640|OMIM:613065" into rows
  separate_rows(omim_id, sep = "\\|") %>%
  mutate(
    omim_ids = trimws(omim_id)
  ) %>%
  select(disease_id, omim_ids) %>%
  distinct()

write.csv(IMPC_human_gene_disease, "../output/IMPC_human_gene_disease.csv", row.names = FALSE, na = "\\N")

