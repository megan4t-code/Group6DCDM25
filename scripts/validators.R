#This script has validation functions which will be used for data cleaning

library(dplyr)
library(stringr)


#Function to collect bad data
record_issue <- function(invalid_logical, col_name, orig_col_values, problem){
  if(!any(invalid_logical)){
    return(NULL)
  }
  data.frame(
    row = which(invalid_logical),
    field = col_name,
    value = orig_col_values[invalid_logical],
    issue_type = problem,
    stringsAsFactors = FALSE
  )
}

#Validation functions
validate_datatype <- function(data, col, sop_data_type){
   col_data <- data[[col]]
   #'switch' adds NA if type can't be changed, and invalid values become NA
   type_changed <- switch(sop_data_type,
                          numeric = suppressWarnings(as.numeric(col_data)),
                          integer = suppressWarnings(as.numeric(col_data)),
                          float = suppressWarnings(as.numeric(col_data)),
                          #No warnings for char as any value can be changed to string
                          character = as.character(col_data),
                          string = as.character(col_data),
                          stop("Unexpected data type")
                          )
    #Invalid is a flag for what is wrong. It is a logical vector with:
    #TRUE for what failed and FALSE for what passed
    invalid <- !is.na(col_data) & is.na(type_changed)
    #Update the col values which are changed and keep NAs which already existed
    data[[col]] <- type_changed
    
    #call record issue function to add invalid values to the log
    issues <- record_issue(
      invalid_logical = invalid,
      col_name = col,
      orig_col_values = col_data, 
      problem = "Data type"
    )
    
    #naming data and issues and adding them to the return list (if not named(reassigned), 
    #the next function in pipeline will have to to call it by index [1] for data, [2] for issues
    list(
      data = data,
      issues = issues
    )
}


validate_string_length <- function(data, col, sop_min, sop_max){
  col_data <- data[[col]]
  
  invalid <- ((!is.na(col_data)) & (nchar(col_data) < sop_min | nchar(col_data) > sop_max))
  
  #explicitly replace invalid values by NA
  data[[col]][invalid] <- NA  #READ ON IT
  
  issues <- record_issue(
    invalid_logical = invalid,
    col_name = col,
    orig_col_values = col_data, 
    problem = "Incorrect length"
  )
  
  list(
    data = data,
    issues = issues
  )
}



validate_alphanumeric <- function(data, col){
  col_data <- data[[col]]
  
  invalid <- !is.na(col_data) & !grepl("^[A-Za-z0-9]+$", col_data)
  
  data[[col]][invalid] <- NA
  
  issues <- record_issue(
    invalid_logical = invalid,
    col_name = col,
    orig_col_values = col_data, 
    problem = "Not alphanumeric"
  )
  
  list(
      data = data,
      issues = issues
    )
}


validate_pattern <- function(data, col, pattern, ignore_case = TRUE) {
  col_data <- data[[col]]
  
  # matches has TRUE where value matches the pattern
  matches <- grepl(pattern, col_data, ignore.case = ignore_case)
  
  # non-NA values that do NOT match
  invalid <- !is.na(col_data) & !matches
  
  data[[col]][invalid] <- NA
  
  issues <- record_issue(
    invalid_logical = invalid,
    col_name = col,
    orig_col_values = col_data,
    problem = "Pattern mismatch"
  )
  
  list(
    data   = data,
    issues = issues
  )
}


remove_duplicates <- function(data, col){
  col_data <- data[[col]]
  
  invalid <- !is.na(col_data) & duplicated(col_data)
  #drop = FALSE is important to handle the case when there is only 1 row or 1 column
  #If drop = FALSE is not used, R will turn the single row or single column into a vector dissolving the data frame dimensions
  #drop = FALSE prevents this and keep the data frame structure even if there is one row or one column only
  unique_rows <- data[!invalid, , drop = FALSE]
  
  issues <- record_issue(
    invalid_logical = invalid,
    col_name = col,
    orig_col_values = col_data,
    problem = "Duplicate value"
  )
  
  list(
      data = unique_rows,
      issues = issues
    )
}


validate_range <- function(data, col, sop_min, sop_max){
  
  #Remove below line as data type will already be validated in the pipeline before this function
  col_data <- as.numeric(data[[col]])
  
  #Uncomment below
  #col_data <- data[[col]]
  
  invalid <- !is.na(col_data) & (col_data < sop_min | col_data > sop_max)
  
  data[[col]][invalid] <- NA
  
  #Should not round-off pvalue as they may round up to 0 or 1
  #data[[col]] <- round(data[[col]], 2)
  
  issues <- record_issue(
    invalid_logical = invalid,
    col_name = col,
    orig_col_values = col_data,
    problem = "Out of range"
  )
  
  list(
    data = data,
    issues = issues
  )
}


validate_enum <- function(data, col, enum_list){
  col_data <- data[[col]]
  
  #Normalize both col_data and enum_list to uppercase and get a vector of integers where,
  #each integer refers to a value in col_data, ex, enum_list has('Early', 'Late', 'Adult'), 
  #for values in col_data,EARLY-1, Early-1, early-1, eaRly-1, lAte-2, adulT-3
  match_index <- match(toupper(col_data), toupper(enum_list))
  
  #is.na(match_index) checks if there is no match_index for a value which means the value is not in enum_list
  invalid <- !is.na(col_data) & is.na(match_index)
  
  #invalid is a combination as above(ex. enum_list <- c("Early", "Late")
  #value:"OLD" match_index:NA , so, !invalid represents those combinations where value & match_index both are not NA
  #(ex. value:"EARLY", match_index:1) and where both are NA(missing)
  #valid_plus_missing <- !invalid
  #Now we need to handle the scenario where both are NA(missing value and therefore match_index NA)
  #(value:NA, match_index:NA), we don't want to match the case with enum_list for these values so we exclude them
  #!invalid will pick sets like (value:"EARLY", match_index:1) and (value:NA, match_index:NA),
  #!is.na(match_index) will exclude sets like (value:NA, match_index:NA)
  #valid is a logical vector
  valid <- !invalid & !is.na(match_index)
  
  col_clean <- col_data
  #col_clean[valid] - extracts values from col_clean for which valid logical vector is TRUE,
  #match_index[valid] - extract values from match_index for which valid is TRUE 
  #col_clean = c("EARLY", "early", "Late", "OLD", NA); match_index = c(1, 1, 2, NA, NA); valid = c(T, T, T, F, F)
  #match_index[valid]  = c(1, 1, 2)
  #enum_list[match_index[valid]] - enum_list[c(1, 1, 2)] = Early, Early, Late
  col_clean[valid] <- enum_list[match_index[valid]]
  
  col_clean[invalid] <- NA
  
  data[[col]] <- col_clean
  
  issues <- record_issue(
    invalid_logical = invalid,
    col_name = col,
    orig_col_values = col_data,
    problem = "Not allowed"
  )
  
  list(
    data = data,
    issues = issues
  )
}
