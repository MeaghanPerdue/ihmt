# IHMT re-processing with ihmt_proc including motion correction, denoising, etc.
Meaghan Perdue 18 July 2025

## Software Requirements
ihmt_proc: <https://github.com/lsoustelle/ihmt_proc> \
ihMT_MoCo (license agreement required): <https://crmbm.univ-amu.fr/ihmt-moco/> \
ANTS \
FSL 

**Preschool IHMT Volumes Acquisition Order: (starts at 1 for inputs)**
1: Reference ihMTR/MTR \
2: Reference qihMT/qMT (omit from proc_ihmt) \
3: positive saturation \
4: dual saturation \
5: negative saturation \
6: dual saturation \
7: positive saturation \
8: dual saturation \
9: negative saturation \
10: dual saturation \
11: positive saturation \
12: dual saturation \
13: negative saturation \
14: dual saturation

## Run preprocessing
```sh run_proc_ihmt.sh sub-NNNNN ses-NN```
will output preprocessed ihMT with all maps calculated
Output with _ihMT.nii suffix is just the unprocessed input file with 13 volumes