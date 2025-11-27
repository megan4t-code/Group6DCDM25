Unzip data.zip inside data directory.
Keep only .csv files in data directory.

Script uses data from data and metadata directories.

All outputs (including intermediate outputs which serve as input to next script in the pipeline) are collected in output directory.

The output of data_merge script is stored in output/merged_data directory and is utilised from this location as an input to other scripts.

All scripts us relative paths like '../output' and no absolute paths and therefore, no path changes are required whether the project is run in local machine or on HPC as everything is within the project directory.

The output/merged_data directory also contains a merged_data_TEST_FILE.csv which was created to test the validations.