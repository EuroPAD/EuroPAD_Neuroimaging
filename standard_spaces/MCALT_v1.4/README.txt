
The Mayo Clinic Adult Lifespan Template and its associated atlases were 
constructed and made publicly available by the Aging and Dementia Research 
(ADIR) lab at Mayo Clinic to provide a template suitable for the analysis needs 
of aging and Alzheimer’s Disease population studies. Population-matched 
templates are known to allow more accurate quantitative MRI analysis, but most 
MRI standard templates are generated from scans of younger individuals. Unlike 
these, the MCALT is designed for analysis of MRI of adult subjects age 30+. 
MCALT was designed for use with SPM12 and integrates easily into its workflows, 
but is not specific to SPM12 and may be used easily with other segmentation 
software.

This template was constructed from T1-weighted scans of 202 Mayo Clinic 
subjects from the Mayo Clinic Study of Aging (MCSA) and Alzheimer’s Disease 
Research Center (ADRC) including:
* 39 young clinically unimpaired subjects aged 30-49 (10 men + 10 women from 
30-39,10 men + 9 women from 40-49)
* 80 randomly selected MCSA clinically unimpaired subjects aged 51-89 (10 men + 
10 women from each age decade)
* 83 MCSA or ADRC subjects with probable Alzheimer’s Disease dementia aged 
51-92, 61% male

Input images were acquired at Mayo Clinic, Rochester, MN, USA using two 3T GE 
scanners (models 750, Signa Excite) with ADNI-1 MP-RAGE protocols and corrected 
for gradient distortion in 3D and non-uniformity using N3 and SPM5. SPM12b was 
used to segment these preprocessed images with stock priors/settings, and these 
segmentations were validated by image analysts. SPM12b DARTEL groupwise 
registration was used to produce new tissue priors and deformations in the new 
template space. A T1-weighted template was produced by intensity-normalizing 
each scan to equalize the mean intensity value of white matter, using the 
DARTEL warps to transform them to the common space, and voxel-wise averaging 
across subjects. Tissue priors were edited manually to reduce erroneous GM 
prior probability at WM/CSF borders, in the brainstem, and in the neck/face, 
and to create a more-defined fornix region in the WM priors. An in-house 
modified AAL gray matter atlas was transformed to the template using ANTs 
nonlinear registration and manually edited to create accurate boundaries. A 
16-region lobar atlas was also drawn manually.

Please cite the following when using the templates/atlases:
* Christopher G. Schwarz, Jeffrey L. Gunter, Chadwick P. Ward, Prashanthi 
Vemuri, Matthew L. Senjem, Heather J. Wiste, Ronald C. Petersen, David S. 
Knopman, Clifford R. Jack Jr. "The Mayo Clinic Adult Lifespan Template (MCALT): 
Better Quantification across the Lifespan". In Proc: Alzheimer's Association 
International Conference, 2017.

This release also includes matlab source code (/src directory; 
MCALT_spm12_segment.m) to perform SPM12 unified segmentation (tissue-class 
probabilities, bias correction, and normalization to MCALT space) using MCALT 
tissue priors and our modified segmentation method/settings that are optimized 
for older adults age 30+. If Advanced Normalization Tools (ANTS) is installed, 
this function will also transform atlases to the input image space using ANTs 
and calculate per-region GM/tissue volumes and TIV as .csv files. This function 
re-implements the SPM12 T1-weighted processing pipeline used in Dr. Jack's 
Aging and Dementia Research Lab at Mayo Clinic. Output volumes are not exactly 
identical but can be directly compared with those computed in-house.

Regional gray matter volumes measured using this segmentation method have 
larger AUROC values than standard SPM12 pipelines when comparing between 
matched groups of amyloid-positive cognitively-impaired and amyloid-negative 
cognitively-unimpaired subjects. See the source code comments and 
MCALT_Segmentation_Poster.pdf for more information.
If you use the segmentation code, please cite the following:
* Christopher G. Schwarz, Jeffrey L. Gunter, Chadwick P. Ward, Kejal Kantarci, 
Prashanthi Vemuri, Matthew L. Senjem, Ronald C. Petersen, David S. Knopman, 
Clifford R. Jack Jr. "Methods to Improve SPM12 Tissue Segmentations of Older 
Adult Brains". In Proc: Alzheimer's Association International Conference, 2018.

This work was supported by: NIH U01 AG006786, NIH P50 AG016574, NIH R01 
AG034676, NIH R01 AG011378, NIH R01 AG041851, NIH R01 NS097495, NIH R01 
AG040042, GHR Foundation, Elsie and Marvin Dekelboum Family Foundation, 
Alexander Family Alzheimer's Disease Research Professorship of the Mayo Clinic, 
Robert H. and Clarice Smith and Abigail van Buren Alzheimer Disease Research 
Program, Liston Award, Schuler Foundation, Mayo Foundation for Medical 
Education and Research
See https://www.nitrc.org/projects/mcalt/ for more information and continuing 
releases
See LICENSE.txt for license restrictions
Copyright 2017-2020 Mayo Foundation for Medical Education and Research
