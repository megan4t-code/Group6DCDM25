#!/bin/bash -l
#SBATCH --job-name=impc_pipeline
#SBATCH --output=/scratch/grp/msc_appbio/DCDM/Group6/impc_data_analysis/logs/%x_%j.out
#SBATCH --error=/scratch/grp/msc_appbio/DCDM/Group6/impc_data_analysis/logs/%x_%j.err
#SBATCH --time=04:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=2
#SBATCH -p msc_tutorial

# Paths
IMG=/scratch/users/k25118204/containers/rocker_verse.sif
PROJECT_DIR=/scratch/grp/msc_appbio/DCDM/Group6/impc_data_analysis
SCRIPTS_DIR=$PROJECT_DIR/scripts

  singularity exec --cleanenv \
    --bind $PROJECT_DIR:$PROJECT_DIR \
    --pwd $PROJECT_DIR \
    $IMG bash "$PROJECT_DIR/jobs/pipeline.sh"
