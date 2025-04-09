
for subses  in `ls -d ../../../../derivatives/fmriprep/Graph_Properties_0.5/sub-0*/ses*`; do outputnum=`ls $subses | wc -l`; echo $outputnum; if [[ $outputnum -lt 7 ]]; then  rm -rf $subses ; fi  ; done
