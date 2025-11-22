#!/bin/bash -l
#SBATCH --job-name=data_merge
#SBATCH --output=/scratch/users/k25118204/DCDM_CW/logs/%x_%j.out
#SBATCH --error=/scratch/users/k25118204/DCDM_CW/logs/%x_%j.err
#SBATCH --time=04:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=2
#SBATCH -p msc_tutorial


# Paths
IMG=/scratch/users/k25118204/containers/rocker_verse.sif
PROJECT_DIR=/scratch/users/k25118204/DCDM_CW
QMD=$PROJECT_DIR/scripts/data_merge.qmd
OUTDIR=$PROJECT_DIR/output
DATADIR=$PROJECT_DIR/data


# Run Quarto inside the container
singularity exec --bind $PROJECT_DIR:$PROJECT_DIR --pwd $PROJECT_DIR \
  $IMG quarto render $QMD --execute \
  -P data_dir=/scratch/users/k25118204/DCDM_CW/data \
  -P output_dir=/scratch/users/k25118204/DCDM_CW/output \
  --output-dir $OUTDIR
