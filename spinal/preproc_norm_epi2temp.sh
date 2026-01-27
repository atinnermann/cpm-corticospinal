#!/bin/bash
#

#abort on error
set -e

#add path of toolbox
PATH=~/spinalcordtoolbox/bin:$PATH

#project dir
basedir=/mnt/c/Users/tinnermann/Documents/data/cpm/mri/

#tmp dir
export TMPDIR=${basedir}tmp

#template dir
tpldir=${basedir}templates/templates_spinal/

listofSubs=($(seq 1 1 49)) 

#subjects to exclude from analysis
exclude=(3 7 14 19 28 35 36 41 25 )

for i in "${exclude[@]}"; do
    temp+=$( echo ${listofSubs[@]} | sed 's/\<'$i'\>//g' )
    listofSubs=()
    listofSubs+=${temp[@]}
    temp=()
done

echo ${listofSubs[@]}

except1=(5 23 38 )  
except2=(12 26 48  )
except4=(49 )


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

#apply transformation to mean seg
#sct_apply_transfo -i ${segname}.nii -d ${anatdir}${anatname}_crop1.nii -w warp_${epiname}2${anatname}_crop1.nii.gz -o ${segname}_2t2.nii
#sct_apply_transfo -i ${epiname}.nii -d ${anatdir}${anatname}_crop1.nii -w warp_${epiname}2${anatname}_crop1.nii.gz -o ${epiname}_2t2.nii

#norm mean epi to template
if [[ " ${except1[*]} " == *" ${subject} "*  ]]; then 
	sct_register_multimodal -i ${basedir}mean_t2_template_crop.nii -d ${epiname}_2t2.nii -iseg ${basedir}mean_t2_template_seg.nii -dseg ${segname}_2t2.nii  -param step=1,type=im,algo=syn,metric=MI,iter=15,smooth=1:step=2,type=im,algo=syn,metric=CC,iter=15 -initwarp ${anatdir}warp_template2anat.nii.gz -initwarpinv ${anatdir}warp_anat2template.nii.gz -x spline || pbl=( "${pbl[@]}" "Sub${subject}" ) 
elif [[ " ${except2[*]} " == *" ${subject} "*  ]]; then 
	sct_register_multimodal -i ${basedir}mean_t2_template_crop.nii -d ${epiname}_2t2.nii -iseg ${basedir}mean_t2_template_seg.nii -dseg ${segname}_2t2.nii  -param step=1,type=im,algo=syn,metric=MI,iter=15,smooth=1:step=2,type=im,algo=syn,metric=CC,iter=15,smooth=1 -initwarp ${anatdir}warp_template2anat.nii.gz -initwarpinv ${anatdir}warp_anat2template.nii.gz -x spline || pbl=( "${pbl[@]}" "Sub${subject}" ) 
elif [[ " ${except4[*]} " == *" ${subject} "*  ]]; then 
	sct_register_multimodal -i ${basedir}mean_t2_template_crop.nii -d ${epiname}_2t2.nii -iseg ${basedir}mean_t2_template_seg.nii -dseg ${segname}_2t2.nii  -param step=1,type=im,algo=syn,metric=CC,iter=15 -initwarp ${anatdir}warp_template2anat.nii.gz -initwarpinv ${anatdir}warp_anat2template.nii.gz -x spline || pbl=( "${pbl[@]}" "Sub${subject}" ) 
else
	sct_register_multimodal -i ${basedir}mean_t2_template_crop.nii -d ${epiname}_2t2.nii -iseg ${basedir}mean_t2_template_seg.nii -dseg ${segname}_2t2.nii  -param step=1,type=im,algo=syn,metric=MI,iter=15:step=2,type=im,algo=syn,metric=CC,iter=15 -initwarp ${anatdir}warp_template2anat.nii.gz -initwarpinv ${anatdir}warp_anat2template.nii.gz -x spline || pbl=( "${pbl[@]}" "Sub${subject}" ) 
fi

#tidy ups
mv ${epiname}_2t2_reg.nii ${epiname}_2temp.nii
rm mean_t2_template_crop_reg.nii

done

echo ${pbl[@]}

