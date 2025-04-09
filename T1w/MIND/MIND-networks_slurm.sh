#!/bin/bash
#SBATCH --job-name=MIND
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-00:30:0
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

i=$1
MIND_dir=$2
freesurfer_dir=$3
code_dir=$4

module load Anaconda3

eval "$(conda shell.bash hook)"
conda activate mario 

python3 ${code_dir}/networks.py ${freesurfer_dir}/${i} -o ${MIND_dir}

echo "network has been computed for ${i}"

