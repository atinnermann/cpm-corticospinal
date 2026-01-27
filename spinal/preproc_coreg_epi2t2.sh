#!/bin/bash
#

#abort on error
set -e

#add path of toolbox
PATH=~/spinalcordtoolbox/bin:$PATH

#project dir
basedir=/mnt/d/projects/cpm/mri/

#tmp dir
export TMPDIR=${basedir}tmp

listofSubs=($(seq 1 1 49))

#subjects to exclude from analysis
exclude=(3 7 14 19 28 35 36 41 25)

for i in "${exclude[@]}"; do
    temp+=$( echo ${listofSubs[@]} | sed 's/\<'$i'\>//g' )
    listofSubs=()
    listofSubs+=${temp[@]}
    temp=()
done

echo ${listofSubs[@]}

except1=(1 )  
except4=(23 ) 
except6=(5 9 33 44 49 )
except9=(15 18 32)

for subject in ${listofSubs[@]}; do

subdir=${basedir}sub`printf %02d ${subject}`

echo "Sub${subject}"


rundir1=${subdir}/run1/spinal/
anatdir=${subdir}/anat2/

# fmri
# ===========================================================================================
cd ${rundir1} || exit

anatname=sub`printf %02d ${subject}`_t2
epiname=sub`printf %02d ${subject}`_fmri_spinal_mean
segname=sub`printf %02d ${subject}`_fmri_spinal_mean_episeg


#register mean of mean to t2   
if [[ " ${except1[*]} " == *" ${subject} "*  ]]; then 
	sct_register_multimodal -i ${anatdir}${anatname}_crop1.nii -d ${epiname}.nii -iseg ${anatdir}${anatname}_seg_crop1.nii -dseg ${segname}.nii -param step=1,type=seg,algo=affine,metric=MeanSquares -x spline || pbl=( "${pbl[@]}" "Sub${subject}" )
elif [[ " ${except4[*]} " == *" ${subject} "*  ]]; then
	sct_register_multimodal -i ${anatdir}${anatname}_crop1.nii -d ${epiname}.nii -iseg ${anatdir}${anatname}_seg_crop1.nii -dseg ${segname}.nii -param step=1,type=seg,algo=translation,metric=MeanSquares,smooth=2 -x spline || pbl=( "${pbl[@]}" "Sub${subject}" )	
elif [[ " ${except6[*]} " == *" ${subject} "*  ]]; then
	sct_register_multimodal -i ${anatdir}${anatname}_crop1.nii -d ${epiname}.nii -iseg ${anatdir}${anatname}_seg_crop1.nii -dseg ${segname}.nii -param step=1,type=seg,algo=rigid,metric=MeanSquares,gradStep=0.3,smooth=3 -x spline || pbl=( "${pbl[@]}" "Sub${subject}" )
elif [[ " ${except9[*]} " == *" ${subject} "*  ]]; then
	sct_register_multimodal -i ${anatdir}${anatname}_crop1.nii -d ${epiname}.nii -iseg ${anatdir}${anatname}_seg_crop1.nii -dseg ${segname}.nii -param step=1,type=seg,algo=rigid,metric=MeanSquares,init=centermass,smooth=3 -x spline || pbl=( "${pbl[@]}" "Sub${subject}" )
else
	sct_register_multimodal -i ${anatdir}${anatname}_crop1.nii -d ${epiname}.nii -iseg ${anatdir}${anatname}_seg_crop1.nii -dseg ${segname}.nii -param step=1,type=seg,algo=rigid,metric=MeanSquares -x spline || pbl=( "${pbl[@]}" "Sub${subject}" )	
fi

#tidy up
mv ${epiname}_reg.nii ${epiname}_2t2.nii
rm ${anatname}_crop1_reg.nii


done

echo ${pbl[@]}
