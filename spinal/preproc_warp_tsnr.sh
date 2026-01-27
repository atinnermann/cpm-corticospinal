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

listofSubs=($(seq 1 1 49))


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


templ=mean_t2_template_crop 


for run in {1..4}; do

rundir=${subdir}/run${run}/spinal/

echo "Run${run}"

# fmri runs
# ===========================================================================================
cd ${rundir} || exit

epiname=sub`printf %02d ${subject}`_fmri_spinal_run${run}

#apply warp fields to all epis
if (( ${run} == 1 ));then
	sct_apply_transfo -i ${epiname}_moco_tsnr.nii -d ${basedir}${templ}.nii -w warpfield_mean2temp.nii.gz -o ${epiname}_2temp.nii	
else
	#concatenate warp fields
	sct_apply_transfo -i ${epiname}_moco_tsnr.nii -d ${basedir}${templ}.nii -w warpfield_run${run}.nii.gz -o ${epiname}_2temp.nii
fi

done

done

