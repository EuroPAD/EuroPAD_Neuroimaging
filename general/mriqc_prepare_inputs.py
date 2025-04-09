import pandas as pd
import sys

def prepare_inputs_freesurfer(batch_number, ntasks, bids_dir, tmp_dir):
	P = pd.read_csv(bids_dir + 'participants.tsv',sep='\t')
	p_list = []
	for i in range(P.shape[0]):
		
		p_list.append(P.loc[i,'participant_id'])

	start = (batch_number - 1)*ntasks
	if start < len(p_list):
		for i in range(ntasks):
			shell_file = open(tmp_dir + "/shell_file_"+str(i+1),'w')
			participant_id = str(p_list[start+i])
			str_to_write = ' mkdir -p /projects/0/prjs0840/mriqc/logs; mkdir -p /scratch-shared/lpieperhoff/amypad_mriqc/logs/' + participant_id + '; singularity run --cleanenv -B /projects/0/prjs0840 -B $HOME -B /scratch-shared/lpieperhoff /projects/0/prjs0840/mriqc-24.0.0.sif /projects/0/prjs0840/rawdata /scratch-shared/lpieperhoff/mriqc participant --participant-label ' + participant_id + ' --nprocs 4 --omp-nthreads 4 --mem-gb 8 --work-dir /scratch-shared/lpieperhoff/mriqc/logs/'+ participant_id + ' --no-sub; rm -rf /scratch-shared/lpieperhoff/mriqc/logs/' + participant_id + '/mriqc_wf/; mv /scratch-shared/lpieperhoff/mriqc/logs/*'+ participant_id + ' /projects/0/prjs0840/mriqc/logs/; mv /scratch-shared/lpieperhoff/mriqc/*'+ participant_id + ' /projects/0/prjs0840/mriqc/; \n'
			x = shell_file.write("#!/bin/bash\n")
			x = shell_file.write(str_to_write)
			shell_file.close()
	return()

if __name__ == "__main__":
	prepare_inputs_freesurfer(int(sys.argv[1]),int(sys.argv[2]),sys.argv[3],sys.argv[4])

