#!/bin/bash
#SBATCH --job-name=MIND_jobs
#SBATCH --output=logs/MIND_%A_%a.out
#SBATCH --error=logs/MIND_%A_%a.err
#SBATCH --array=4001-5451%50   # Run 50 jobs at a time; BATCH 2: 2001-4000%50 ; BATCH 3: 4001-5451%50 
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --time=0-00:30:00
#SBATCH --partition=luna-short

# Load Anaconda module
module load Anaconda3/2024.02-1

# Activate Conda environment
source activate mind_env

# Define atlas
atlas="Schaefer2018_200Parcels_7Networks_order"  # <-- replace this with your atlas variable

# Define paths
code_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/T1w/MIND/
MIND_list=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/MIND-freesurfer-v7.1.1/MIND_list.txt

MIND_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/MIND-freesurfer-v7.1.1/${atlas}/ 

mkdir -p $MIND_dir
mkdir -p logs

# Get the subject/session for this SLURM task ID
subject_path=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${MIND_list}")

# Ensure the subject_path is valid
if [ -z "$subject_path" ]; then
    echo "Error: Could not find subject for SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

subject=$(basename "$subject_path")
output_file="${MIND_dir}/${subject}_MIND-${atlas}.csv"

# Check if output already exists
if [ -f "$output_file" ]; then
    echo "Skipping ${subject}: Output file already exists (${output_file})"
    exit 0
fi

# Check if .annot files exist
if [[ ! -f "${subject_path}/label/lh.${atlas}.annot" || ! -f "${subject_path}/label/rh.${atlas}.annot" ]]; then
    echo "[SKIP] Atlas annotations for ${atlas} not found for ${subject}."
    exit 1
fi

echo "Computing MIND network for ${subject}..."
python3 "${code_dir}/MIND-networks.py" "$subject_path" -o "${MIND_dir}" --atlas "${atlas}"

# Verify if output was successfully created
if [ -f "$output_file" ]; then
    echo "Successfully processed ${subject}!"
else
    echo "Warning: ${subject} computation did not generate expected output!"
fi