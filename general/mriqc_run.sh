#!/bin/bash
#SBATCH --job-name=mriqc
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --cpus-per-task=4
#SBATCH --partition=fat_rome
#SBATCH --time 12:00:00
#SBATCH --mem=256G
module load 2022
module load Python/3.10.4-GCCcore-11.3.0

mkdir -p /projects/0/prjs0840/MRIQCcommands/tmpdir_$1 
TMPDIR=/projects/0/prjs0840/MRIQCcommands/tmpdir_$1
BIDSDIR=/projects/0/prjs0840/rawdata/
echo "Number of tasks: $SLURM_NTASKS..."
# Create shell_file_$i in $TMPDIR with the command to run
python /projects/0/prjs0840/mriqc/mriqc_prepare_inputs.py $1 $SLURM_NTASKS $BIDSDIR $TMPDIR
for i in `seq 1 $SLURM_NTASKS`; do
(
chmod +x $TMPDIR/shell_file_$i
$TMPDIR/shell_file_$i
) &
done

wait


