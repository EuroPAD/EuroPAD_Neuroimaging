from pathlib import Path
from niftypet import nimpa
import spm12
import amypet
from amypet import backend_centiloid as centiloid
from amypet import params as Cnt
import matplotlib.pyplot as plt
import numpy as np
import logging
logging.basicConfig(level=logging.INFO)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# INPUT
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ignore_derived = False

# > Uptake ratio (UR) window def
ur_win_def=[5400,6600]

tracer = 'fbb' # 'pib', 'flute', 'fbp'

# > input PET folder
input_fldr = Path('/.../Example_FBB')
outpath = input_fldr.parent/('amypet_output_'+input_fldr.name)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CLASSIFY DICOM INPUT AND CONVERT TO NIfTI
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#------------------------------
# > structural/T1w image
ft1w = amypet.get_t1(input_fldr, Cnt)

if ft1w is None:
    raise ValueError('Could not find the necessary T1w DICOM or NIfTI images')
#------------------------------

#------------------------------
# > processed the PET input data and classify it (e.g., automatically identify UR frames)
indat = amypet.explore_indicom(
    input_fldr,
    Cnt,
    tracer=tracer,
    find_ur=True,
    ur_win_def=ur_win_def,
    outpath=outpath/'DICOMs')

# > convert to NIfTIs
niidat = amypet.convert2nii(indat, use_stored=True)
#------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# REMOVE ARTEFACTS AT THE END OF FOV
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
niidat = amypet.rem_artefacts(niidat, Cnt, artefact='endfov')
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALIGN PET FRAMES FOR STATIC/DYNAMIC IMAGING
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
aligned = amypet.align(
    niidat,
    Cnt,
    reg_tool='spm',
    ur_fwhm=4.5,
    use_stored=True)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CL QUANTIFICATION
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# > optional CSV file output for CL results 
fcsv = niidat['outpath'].parent/'CL'/'results'/(input_fldr.name+'_amypet_suvr_cl.csv')

out_cl = centiloid.run(
    aligned['ur']['fur'],
    ft1w,
    Cnt,
    stage='f',
    voxsz=1,
    bias_corr=True,
    tracer=tracer,
    outpath=outpath/'CL',
    use_stored=True,
    fcsv=fcsv
    )
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SCHAEFER 100 VOIS QUANTIFICATION
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fcsv_schaefer = niidat['outpath'].parent/'SEG'/'amypet_atlas_suvr_cl.csv'
# > get all the regional data with atlas and GM probabilistic mask
vois = amypet.proc_vois(niidat, aligned, out_cl, atlas='schaefer', default_mni = True,
                        outpath=niidat['outpath'].parent/'SEG', fcsv=fcsv_schaefer)
