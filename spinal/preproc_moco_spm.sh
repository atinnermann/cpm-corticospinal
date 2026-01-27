#!/bin/bash


#abort on error
set -e

#add path of toolbox
PATH=~/spinalcordtoolbox/bin:$PATH

#project dir
basedir=/mnt/c/Users/tinnermann/Documents/data/cpm/mri/

#tmp dir
export TMPDIR=${basedir}tmp

listofSubs=($(seq 1 1 49))

exclude=(3 7 14 19 28 35 36 41 )

for i in "${exclude[@]}"; do
    temp+=$( echo ${listofSubs[@]} | sed 's/\<'$i'\>//g' )
    listofSubs=()
    listofSubs+=${temp[@]}
    temp=()
done

echo ${listofSubs[@]}


for subject in ${listofSubs[@]}; do

subdir=${basedir}sub`printf %02d ${subject}`

echo "Sub${subject}"

rundir1=${subdir}/run1/spinal/
epiname1=sub`printf %02d ${subject}`_fmri_spinal_run1

for run in {1..4}; do

rundir=${subdir}/run${run}/spinal/
epiname=sub`printf %02d ${subject}`_fmri_spinal_run${run}

echo "Run${run}"

cd ${rundir} || exit

#Average all fMRI time series (to be able to do the next step)
sct_maths -i ${epiname}.nii -mean t -o ${epiname}_mean.nii

# Get cord centerline
sct_get_centerline -i ${epiname}_mean.nii -c t2s

# Create mask around the cord to help motion correction and for faster processing
sct_create_mask -i ${epiname}_mean.nii -p centerline,${epiname}_mean_centerline.nii.gz -size 65mm -f cylinder -o ${epiname}_mask_65mm.nii
sct_create_mask -i ${epiname}_mean.nii -p centerline,${epiname}_mean_centerline.nii.gz -size 40mm -f cylinder -o ${epiname}_mask_40mm.nii

#coregister run means to first run
if (( ${run} > 1 ));then		
	if (( ${subject} == 49 && ${run} == 4)) || (( ${subject} == 7 && ${run} == 4)); then #
		sct_register_multimodal -i ${epiname}_moco_mean.nii -d ${rundir1}${epiname1}_moco_mean.nii -param step=1,type=im,algo=rigid,metric=MeanSquares -x spline || pbl=( "${pbl[@]}" "Sub${subject}" "Run$run") 
	elif (( ${subject} == 7 && ${run} == 3)); then
		sct_register_multimodal -i ${epiname}_moco_mean.nii -d ${rundir1}${epiname1}_moco_mean.nii -m ${rundir1}${epiname1}_mask_65mm.nii -param step=1,type=im,algo=rigid,metric=MeanSquares -x spline || pbl=( "${pbl[@]}" "Sub${subject}" "Run$run") 
	else
		sct_register_multimodal -i ${epiname}_moco_mean.nii -d ${rundir1}${epiname1}_moco_mean.nii -m ${rundir1}${epiname1}_mask_65mm.nii -param step=1,type=im,algo=rigid,metric=MI -x spline || pbl=( "${pbl[@]}" "Sub${subject}" "Run$run") 
	fi
fi

#concatenate session means
if (( ${run} == 1 ));then
	cp ${epiname}_moco_mean.nii concat_run_means.nii
	cp ${epiname}_moco_mean.nii ${epiname}_moco_mean_2run1.nii
else
	sct_image -i ${rundir1}concat_run_means.nii ${epiname}_moco_mean_reg.nii -concat t -o ${rundir1}concat_run_means.nii
	mv ${epiname}_moco_mean_reg.nii ${epiname}_moco_mean_2run1.nii
	rm ${epiname1}_moco_mean_reg.nii	
fi

done

cd ${rundir1} || exit

meanepi=sub`printf %02d ${subject}`_fmri_spinal_mean_first

#calculate mean of all session means
sct_maths -i concat_run_means.nii -mean t -o ${meanepi}.nii 

#delete concat mean image
rm concat_run_means.nii

#### do coregistration again to mean image
for run in {1..4}; do

rundir=${subdir}/run${run}/spinal/
epiname=sub`printf %02d ${subject}`_fmri_spinal_run${run}

echo "Run${run}"

cd ${rundir} || exit

#coregister run means to mean epi
sct_register_multimodal -i ${epiname}_moco_mean_2run1.nii -d ${rundir1}${meanepi}.nii -m ${rundir1}${epiname1}_mask_40mm.nii -param step=1,type=im,algo=rigid,metric=MI -x spline || pbl=( "${pbl[@]}" "Sub${subject}" "Run$run") 

mv ${epiname}_moco_mean_2run1_reg.nii ${epiname}_moco_mean_2mean.nii
	
#concatenate session means
if (( ${run} == 1 ));then
	cp ${epiname}_moco_mean_2mean.nii concat_run_means_clean.nii
else
	sct_concat_transfo -d ${rundir1}${meanepi}.nii -w warp_${epiname}_moco_mean2${epiname1}_moco_mean.nii.gz warp_${epiname}_moco_mean_2run12${meanepi}.nii.gz -o warp_mean_run${run}2mean.nii.gz
	sct_apply_transfo -i ${epiname}_moco_mean.nii -d ${rundir1}${meanepi}.nii -w warp_mean_run${run}2mean.nii.gz -o ${epiname}_moco_mean_2mean_clean.nii
	sct_image -i ${rundir1}concat_run_means_clean.nii ${epiname}_moco_mean_2mean_clean.nii -concat t -o ${rundir1}concat_run_means_clean.nii
fi

done

cd ${rundir1} || exit

newmean=sub`printf %02d ${subject}`_fmri_spinal_mean

#calculate mean of all session means
sct_maths -i concat_run_means_clean.nii -mean t -o ${newmean}.nii 

#delete concat mean image
rm concat_run_means_clean.nii


done