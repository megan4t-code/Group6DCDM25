source("validators.R")
library(dplyr)
library(stringr)

#Setting paths
params <-
  list(data_dir = "../output/merged_data/", 
       metadata_dir = "../metadata/", 
       output_dir = "../output/")


#Read data file to a data frame
data_path <- params$data_dir
merged_data <- read.csv(
  paste0(data_path, "merged_data.csv"),
  stringsAsFactors = FALSE
)
merged_data <- merged_data %>%
  mutate(across(where(is.character), trimws))


#Individual function tests
print(validate_datatype(merged_data, "pvalue", "float"))
print(validate_string_length (merged_data, "gene_symbol", 1, 13))
print(validate_alphanumeric(merged_data, "analysis_id"))
print(remove_duplicates(merged_data, "analysis_id"))
print(validate_range(merged_data, "pvalue", 0, 1))
print(validate_enum(merged_data, "mouse_strain", c("C57BL", "B6J", "C3H", "129SV")))
print(validate_enum(merged_data, "mouse_life_stage", c("E12.5", "E15.5", "E18.5", "E9.5", "Early adult", "Late adult", "Middle aged adult")))
print(upper_case(merged_data, "mouse_strain"))
print(title_case(merged_data, "gene_symbol"))

