#!/bin/bash
# Run process_ihmt.sh on a single subject
# Uses pipeline from <https://github.com/lsoustelle/ihmt_proc?tab=readme-ov-file>
# Dependencies: ANTS, FSL, MRTRIX
# Make sure ANTS path is set in bash profile
# edited lines 87 and 88 in 'process_ihMT.sh' to remove '-n' flag (older BASH version of the command?)
# does denoising, unringing, motion correction, computes maps
# set denoising kernel extent (multiplied) to =< total number of raw volumes (n=12)
# run as sh run_proc_ihmt.sh subject session


export input=/Volumes/G-DRIVE/preschool_bids
export output=/Volumes/G-DRIVE/preschool_bids/derivatives/ihmt_proc2

#gunzip ${input}/${1}/${2}/${1}_${2}_ihMT.nii.gz

sh ihmt_proc/process_ihmt.sh -i ${input}/${1}/${2}/anat/${1}_${2}_ihMT.nii.gz -o ${output}/${1}/${2}/${1}_${2}_ \
    -c ihMT,ihMTR,MTRs,MTRd,ihMTRinv,MTRsinv,MTRdinv \
    -n 4 \
    -d 1 \
    -e 4,4,4 \
    -u 1 \
    -m 1 \
    -R 1 \
    -S 3,5,7,9,11,13 \
    -D 4,6,8,10,12,14 \
    -w 0

