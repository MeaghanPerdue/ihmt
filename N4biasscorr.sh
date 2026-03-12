#!/bin/bash
# Run rigid registration and ANTS N4 bias correction on ihMT raw data
# This should be done before ihmt_proc additional preprocessing and map calculation
# Calculates bias field from MT reference volume, then applies to remaining volumes
# software requirements: ANTS, FSL
# by Meaghan Perdue, March 2026
# Work-in-progress, adjustments to parameters may be needed
## will need to generalize to remove subject-specific paths (replace sub-10007/ses-05 with ${1}/${2} to match current code convention)

# set up paths and directories
export input=/Volumes/G-DRIVE/preschool_bids
export output=/Volumes/G-DRIVE/preschool_bids/derivatives/ihmt_proc_test


mkdir -p $output/sub-10007/ses-05/tmp

# split 4D image into volumes for co-registration
fslsplit $input/sub-10007/ses-05/anat/sub-10007_ses-05_ihMT.nii.gz $output/sub-10007/ses-05/tmp/ihmtsplit -t


# consider creating a mask for registration and bias field correction

# Rigid registration to first volume
## Set reference as first volume
reference="$output/sub-10007/ses-05/tmp/ihmtsplit0000.nii.gz"
num_volumes=14

## Loop over each volume (This part created by ChatGPT mini 4.1, need to review parameters and optimize)
for i in $(seq -w 0 $((num_volumes - 1))); do
    moving="$output/sub-10007/ses-05/tmp/ihmtsplit00${i}.nii.gz"
    outputprefix="${output}/sub-10007/ses-05/tmp/reg_vol${i}"

    if [ "$moving" == "$reference" ]; then
        # Copy reference as is
        cp "$moving" "${output}/sub-10007/ses-05/tmp/reg_vol${i}.nii.gz"
        continue
    fi

    antsRegistration \
        --dimensionality 3 \
        --float 1 \
        --output [$outputprefix,${outputprefix}.nii.gz] \
        --interpolation Linear \
        --use-histogram-matching 0 \
        --initial-moving-transform [$reference,$moving,1] \
        --transform Rigid[0.1] \
        --metric MI[$reference,$moving,1,32,Regular,0.25] \
        --convergence 100x50x30x10 \
        --shrink-factors 8x4x2x1 \
        --smoothing-sigmas 3x2x1x0vox \
        --verbose
done

echo "Rigid co-registration complete."


# N4 bias field correction, reference volume
# from documentation: " Compute the bias field on a representative 3D volume and apply it by dividing each component or measurement by the bias field."
# consider whether options for -b (bspline-fitting) and -c (convergence) should be changed from defaults; run without -s (shrink factor)?
N4BiasFieldCorrection -d 3 -v 1 -s 4 \
  -i ${output}/sub-10007/ses-05/tmp/reg_vol00.nii.gz -o [ $output/sub-10007/ses-05/tmp/reg_vol00_N4corr.nii.gz, $output/sub-10007/ses-05/tmp/reg_vol00_BiasField.nii.gz ]

ref_N4biascorr="$output/sub-10007/ses-05/tmp/reg_vol00_N4corr.nii.gz"

# apply bias field to each volume
for i in $(seq -w 0 $((num_volumes - 1))); do
    regvol="$output/sub-10007/ses-05/tmp/reg_vol${i}.nii.gz"
    outputprefix="${output}/sub-10007/ses-05/tmp/reg_vol_N4corr${i}"

    if [ "$regvol" == "$ref_N4biascorr" ]; then
        # Copy reference as is
        cp "$regvol" "${output}/sub-10007/ses-05/tmp/reg_vol_N4corr${i}.nii.gz"
        continue
    fi

    fslmaths $regvol -div $output/sub-10007/ses-05/tmp/reg_vol00_BiasField.nii.gz  $output/sub-10007/ses-05/tmp/reg_vol_N4corr${i}.nii.gz
done

#merge N4 bias corrected volumes into 4D image
fslmerge -t $output/sub-10007/ses-05/sub-10007_ses-05_ihMT_biascorrected.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr00.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr01.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr02.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr03.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr04.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr05.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr06.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr07.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr08.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr09.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr10.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr11.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr12.nii.gz \
    $output/sub-10007/ses-05/tmp/reg_vol_N4corr13.nii.gz 

echo "ihMT volumes bias-corrected and merged! sub-10007_ses-05_ihMT_biascorrected.nii.gz is ready for input to ihmt_proc"

# cleanup tmp folder
# rm -R $output/sub-10007/ses-05/tmp