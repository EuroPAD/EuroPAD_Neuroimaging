#!/bin/bash
#SBATCH --job-name=graph
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4000              # max memory per node
# Request 36 hours run time
#SBATCH -t 36:0:0
#SBATCH --nice=100			# be nice
#SBATCH --partition=luna-long  # rng-short is default, but use rng-long if time exceeds 7h

filelist=$1
python3 extract_graphs.py $1
