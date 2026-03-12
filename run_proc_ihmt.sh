#!/bin/bash
# Run process_ihmt.sh on a single subject
# Uses pipeline from <https://github.com/lsoustelle/ihmt_proc?tab=readme-ov-file>
# Dependencies: ANTS, FSL, MRTRIX
# Make sure ANTS path is set in bash profile
# edited lines 87 and 88 in 'process_ihMT.sh' to remove '-n' flag (older BASH version of the command?)
# does denoising, unringing, motion correction, computes maps
# set denoising kernel extent (multiplied) to =< total number of raw volumes (n=12)
# run as sh run_proc_ihmt.sh subject session
# Updates 12 March 2026:
### adjusted to run following ANTS N4 bias correction of raw ihMT data, eventually merge to run workflow in a single script
### to 'scrub' out a bad volume, remove the volume number from -S or -D in the process_ihmt.sh run command

export input=/Volumes/G-DRIVE/preschool_bids
export output=/Volumes/G-DRIVE/preschool_bids/derivatives/ihmt_proc_test


#gunzip ${input}/${1}/${2}/${1}_${2}_ihMT.nii.gz

sh ihmt_proc/process_ihmt.sh -i ${output}/${1}/${2}/${1}_${2}_ihMT_biascorrected.nii.gz -o ${output}/${1}/${2}/${1}_${2}_ \
    -c ihMT,ihMTR,MTRs,MTRd,ihMTRinv,MTRsinv,MTRdinv \
    -n 4 \
    -d 1 \
    -e 4,4,4 \
    -u 1 \
    -m 1 \
    -R 1 \
    -S 3,5,7,9,13 \
    -D 4,6,8,10,12,14 \
    -w 0

# update code to print subject-specific run script for logging so we know when a volume has been scrubbed