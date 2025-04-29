
# FSL based Dual Regression scripts for the EuroPAD cohort

These scripts perform **dual regression** on resting-state fMRI data.

---

## Overview of Workflow
Dual Regression consists of two major stages:

1. **dr_stage1: Subject-specific time courses are estimated from a group of components, for example atlas ROI's or estimated RSN's**
2. **dr_stage2: Subject-specific spatial maps are estimated through a multivariate temporal regression of the subject-specific time courses on the subject-specific rs-fMRI data**
3. **dr_stage3 [optional]: group averages or other statistical tests can be run on the subject-specific spatial maps**

---

**Script:** `dual_regression.sh`  
**Dependencies:** `fsl`

```bash
sbatch dual_regression.sh
```

**Inputs:**
- Subject-level rs-fMRI data, preprocessed with fMRIPrep

**Outputs:**
- Subject-level time courses (dr_stage1) and subject-level spatial maps (dr_stage2), as well as group-level component averages (dr_stage3)

---

**Script:** `dual_regression_masked.sh`  
**Dependencies:** -

```bash
bash dual_regression_masked.sh
```

**Description:**
- can be called with dual_regression.sh by replacing the FSL dual_regression; creates masks for each of the input components, handy for subsequent "dr_stage3" analyses with randomise

## Maintainer
**Leonard Pieperhoff**  
PhD Candidate, Amsterdam UMC
l.pieperhoff@amsterdamumc.nl

Last Updated: 29-04-2025
