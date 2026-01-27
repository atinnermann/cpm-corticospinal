#!/bin/bash
#

# Abort on error
set -e

#add path of toolbox
PATH=~/spinalcordtoolbox/bin:$PATH

#project dir
basedir=/mnt/c/Users/tinnermann/Documents/data/cpm/mri/

#tmp dir
export TMPDIR=${basedir}tmp

#template dir
tpldir=${basedir}templates/templates_spinal/

#array that lists all subs and runs in which registration problems occured
pbl=("problems")

listofSubs=($(seq 2 2 49))

#subjects to exclude from analysis
exclude=(3 7 14 19 28 35 36 41 25 )

for i in "${exclude[@]}"; do
    temp+=$( echo ${listofSubs[@]} | sed 's/\<'$i'\>//g' )
    listofSubs=()
    listofSubs+=${temp[@]}
    temp=()
done


for subject in ${listofSubs[@]}; do

subdir=${basedir}sub`printf %02d ${subject}`

echo "Sub${subject}"

anatdir=${subdir}/run1/spinal/

# fmri mean_of_mean
# ===========================================================================================
cd ${anatdir} || exit

meanepi=sub`printf %02d ${subject}`_fmri_spinal_mean
anatname=sub`printf %02d ${subject}`_t2_crop1
templ=mean_t2_template_crop 

#concatenate warp fields
sct_concat_transfo -d ${basedir}${templ}.nii -w ${anatdir}warp_${meanepi}2${anatname}.nii.gz ${anatdir}warp_${meanepi}_2t22${templ}.nii.gz -o warpfield_mean2temp.nii.gz

#apply warp fields to mean of mean 
sct_apply_transfo -i ${meanepi}.nii -d ${basedir}${templ}.nii -w warpfield_mean2temp.nii.gz -o ${meanepi}_2temp_clean.nii

for run in {1..4}; do

rundir=${subdir}/run${run}/spinal/

echo "Run${run}"

# fmri runs
# ===========================================================================================
cd ${rundir} || exit

epiname=sub`printf %02d ${subject}`_fmri_spinal_run${run}
epiname1=sub`printf %02d ${subject}`_fmri_spinal_run1

#apply warp fields to all epis
if (( ${run} == 1 ));then
	sct_apply_transfo -i ${epiname}_moco.nii -d ${basedir}${templ}.nii -w warpfield_mean2temp.nii.gz -o ${epiname}_2temp.nii	
	sct_apply_transfo -i ${epiname}_moco_tsnr.nii -d ${basedir}${templ}.nii -w warpfield_mean2temp.nii.gz -o ${epiname}_tsnr_2temp.nii
else
	#concatenate warp fields
	sct_concat_transfo -d ${basedir}${templ}.nii -w warp_${epiname}_moco_mean2${epiname1}_moco_mean.nii.gz warp_${epiname}_moco_mean_2run12${meanepi}_first.nii.gz ${anatdir}warp_${meanepi}2${anatname}.nii.gz ${anatdir}warp_${meanepi}_2t22${templ}.nii.gz -o warpfield_run${run}.nii.gz
	sct_apply_transfo -i ${epiname}_moco.nii -d ${basedir}${templ}.nii -w warpfield_run${run}.nii.gz -o ${epiname}_2temp.nii
	sct_apply_transfo -i ${epiname}_moco_tsnr.nii -d ${basedir}${templ}.nii -w warpfield_run${run}.nii.gz -o ${epiname}_tsnr_2temp.nii
fi

done

done

