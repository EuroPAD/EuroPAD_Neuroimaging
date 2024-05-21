#!/bin/bash
code_dir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/MIND/Schaefer2018_LocalGlobal_Parcellations_FreeSurfer5.3_fsaverage 
freesurfer_dir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/FreeSurfer_crossectional
module load FreeSurfer

if [ ! -d ${freesurfer_dir}/fsaverage ]; then
  cp -r ${FREESURFER_HOME}/subjects/fsaverage $freesurfer_dir
else
  echo "fsaverage folder already exists"
fi 

export SUBJECTS_DIR=${freesurfer_dir}

# loop over subjects/sessions
for subjectname in `ls -d ${freesurfer_dir}/sub-*` ; do
i="`basename $subjectname`"

if [ -f ${freesurfer_dir}/${i}/label/lh.Schaefer2018_400Parcels_7Networks_order.annot -a -f ${freesurfer_dir}/${i}/label/rh.Schaefer2018_400Parcels_7Networks_order.annot ]; then
  echo "${i} already OK"
else
  mri_surf2surf --hemi lh \
    --srcsubject fsaverage \
    --trgsubject ${i} \
    --sval-annot ${code_dir}/label/lh.Schaefer2018_400Parcels_7Networks_order.annot \
    --tval ${SUBJECTS_DIR}/${i}/label/lh.Schaefer2018_400Parcels_7Networks_order.annot
    
  mri_surf2surf --hemi rh \
    --srcsubject fsaverage \
    --trgsubject ${i} \
    --sval-annot ${code_dir}/label/rh.Schaefer2018_400Parcels_7Networks_order.annot \
    --tval ${SUBJECTS_DIR}/${i}/label/rh.Schaefer2018_400Parcels_7Networks_order.annot
    
  mv ${SUBJECTS_DIR}/${i}/surf/lh.pial.T1 ${SUBJECTS_DIR}/${i}/surf/lh.pial
  mv ${SUBJECTS_DIR}/${i}/surf/rh.pial.T1 ${SUBJECTS_DIR}/${i}/surf/rh.pial

  mris_anatomical_stats \
    -f ${SUBJECTS_DIR}/${i}/stats/lh.Schaefer2018_400Parcels_7Networks_order.stats \
    -b -a ${SUBJECTS_DIR}/${i}/label/lh.Schaefer2018_400Parcels_7Networks_order.annot \
    ${i} lh
    
  mris_anatomical_stats \
    -f ${SUBJECTS_DIR}/${i}/stats/rh.Schaefer2018_400Parcels_7Networks_order.stats \
    -b -a ${SUBJECTS_DIR}/${i}/label/rh.Schaefer2018_400Parcels_7Networks_order.annot \
    ${i} rh

  mv ${SUBJECTS_DIR}/${i}/surf/lh.pial ${SUBJECTS_DIR}/${i}/surf/lh.pial.T1
  mv ${SUBJECTS_DIR}/${i}/surf/rh.pial ${SUBJECTS_DIR}/${i}/surf/rh.pial.T1
fi
done

