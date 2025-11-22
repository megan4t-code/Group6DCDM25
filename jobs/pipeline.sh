#!/bin/bash -l
#SBATCH --job-name=impc_pipeline
#SBATCH --output=/scratch/grp/msc_appbio/DCDM/Group6/impc_data_analysis/logs/%x_%j.out
#SBATCH --error=/scratch/grp/msc_appbio/DCDM/Group6/impc_data_analysis/logs/%x_%j.err
#SBATCH --time=04:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=2
#SBATCH -p msc_tutorial

# Fail fast: exit on error, undefined variable, or pipeline failure
set -euo pipefail

########################
# Detect project root
########################
# This script lives in: PROJECT_DIR/jobs/run_pipeline.sh
# So PROJECT_DIR is one level up from the directory of this script.

PROJECT_DIR="/scratch/grp/msc_appbio/DCDM/Group6/impc_data_analysis/scripts"

R_MERGE_FILE="data_merge.R"
R_CLEANING_FILE="data_cleaning.R"
R_PROCESS_METADATA_FILE="process_metadata.R"
R_PARAMETER_GROUPING_FILE="parameter_grouping.R"

# Move to project root so that relative paths in .R work as written
cd "$PROJECT_DIR"

# Load modules for R / Quarto if running in HPC:
if command -v module &> /dev/null; then
    module load r/4.3.0-gcc-13.2.0-withx-rmath-standalone-python-3.11.6
else
    echo "No module system detected — assuming local environment."
fi

########################
# 1. Merge raw CSVs -> merged_data.csv
########################
if [ -f "$R_MERGE_FILE" ]; then
  echo "=== [1/4] Rendering $R_MERGE_FILE ==="
  # No -P overrides: use the relative paths defined inside the .R
  Rscript "$R_MERGE_FILE"
  echo "=== data_merge complete ==="
else
  echo "ERROR: $R_MERGE_FILE not found."
  exit 1
fi

########################
# 2. Data cleaning -> validated_analysis_data.csv, issue_log.csv
########################
if [ -f "$R_CLEANING_FILE" ]; then
  echo "=== [2/4] Rendering $R_CLEANING_FILE ==="
  Rscript "$R_CLEANING_FILE"
  echo "=== data_cleaning complete ==="
else
  echo "ERROR: $R_CLEANING_FILE not found."
  exit 1
fi

########################
# 3. Process metadata -> IMPC_*.csv(metadata) + IMPC_analysis.csv
########################
if [ -f "$R_PROCESS_METADATA_FILE" ]; then
  echo "=== [3/4] Rendering $R_PROCESS_METADATA_FILE ==="
  Rscript "$R_PROCESS_METADATA_FILE"
  echo "=== process_metadata complete ==="
else
  echo "ERROR: $R_PROCESS_METADATA_FILE not found."
  exit 1
fi

########################
# 4. Group parameters -> parameter_groupings.csv
########################
if [ -f "$R_PARAMETER_GROUPING_FILE" ]; then
  echo "=== [4/4] Rendering $R_PARAMETER_GROUPING_FILE ==="
  Rscript "$R_PARAMETER_GROUPING_FILE"
  echo "=== parameter_grouping complete ==="
else
  echo "ERROR: $R_PARAMETER_GROUPING_FILE not found."
  exit 1
fi

echo "=== All pipeline steps completed successfully. ==="
