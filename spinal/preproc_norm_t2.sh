#!/bin/bash
#

# Abort on error
set -e

#add path of toolbox
PATH=~/spinalcordtoolbox/bin:$PATH

#project dir
basedir=/mnt/d/projects/cpm/mri/

#tmp dir
export TMPDIR=${basedir}tmp


listofSubs=($(seq 1 1 49)

#subjects to exclude from analysis
exclude=(3 7 14 19 28 35 36 41 25 )

for i in "${exclude[@]}"; do
    temp+=$( echo ${listofSubs[@]} | sed 's/\<'$i'\>//g' )
    listofSubs=()
    listofSubs+=${temp[@]}
    temp=()
done

echo ${listofSubs[@]}

seg3d=(40 ) 
manLabel=(37 ) 
except1=(37 )
except2=(45 43 )

for subject in ${listofSubs[@]}; do

echo "Sub${subject}"

subdir=${basedir}sub`printf %02d ${subject}`

targetdir=${subdir}/anat2/


# t1
# ===========================================================================================
 cd "$targetdir" || exit

filename=sub`printf %02d ${subject}`_t2

#segment spinal cord
if [[ " ${seg3d[*]} " == *" ${subject} "*  ]]; then
	 sct_deepseg_sc -i ${filename}.nii -c t2 -centerline svm -kernel 3d -qc ${basedir}qc_sct/seg_t2
else
	sct_deepseg_sc -i ${filename}.nii -c t2 -centerline svm -qc ${basedir}qc_sct/seg_t2
fi

#find spinal vertebrae
if [[ " ${manLabel[*]} " == *" ${subject} "*  ]]; then
	if ! test -f label_c5c6.nii; then
		#if labeling of vertebrae fails, manual help is required
		sct_label_utils -i ${filename}.nii -create-viewer 6 -o label_c5c6.nii -msg "Click at the posterior tip of #C5/C6 inter-vertebral disc" 
	fi	
	sct_label_vertebrae -i ${filename}.nii -s ${filename}_seg.nii -c t2 -initlabel label_c5c6.nii -qc ${basedir}/qc_sct/label
else
	sct_label_vertebrae -i ${filename}.nii -s ${filename}_seg.nii -c t2  -qc ${basedir}/qc_sct/label
fi


#label two vertebrae for registration
sct_label_utils -i ${filename}_seg_labeled.nii -vert-body 3,7 -o ${filename}_labels_vert.nii
 
#normalize T2 to PAM50
if [[ " ${except1[*]} " == *" ${subject} "*  ]]; then 
	sct_label_utils -i ${filename}_seg_labeled.nii -vert-body 4,5,6 -o ${filename}_labels_vert.nii
	sct_register_to_template -i ${filename}.nii -s ${filename}_seg.nii -l ${filename}_labels_vert.nii -c t2 #-param step=1,type=seg,algo=slicereg,metric=MeanSquares:step=2,type=seg,algo=affine,metric=MeanSquares:step=3,type=im,algo=syn,metric=MeanSquares	
elif [[ " ${except2[*]} " == *" ${subject} "*  ]]; then 
	sct_label_utils -i ${filename}_seg_labeled.nii -vert-body 4,5,6 -o ${filename}_labels_vert.nii
	sct_register_to_template -i ${filename}.nii -s ${filename}_seg.nii -l ${filename}_labels_vert.nii 
else
	sct_register_to_template -i ${filename}.nii -s ${filename}_seg.nii -l ${filename}_labels_vert.nii -param step=1,type=seg,algo=centermass,metric=MeanSquares:step=2,type=seg,algo=rigid,metric=MeanSquares:step=3,type=im,algo=syn,metric=MeanSquares
fi

#rename file
mv anat2template.nii ${filename}_2temp.nii

#crop normalized T2
sct_crop_image -i ${filename}_2temp.nii -zmin 730 -zmax 880 -o ${filename}_2temp_crop1.nii

sct_apply_transfo -i ${filename}_2temp_crop1.nii -d ${filename}.nii -w warp_template2anat.nii.gz -o ${filename}_crop1.nii
sct_apply_transfo -i ${filename}_seg.nii -d ${filename}_2temp.nii -w warp_anat2template.nii.gz -o ${filename}_seg_2temp.nii
sct_crop_image -i ${filename}_seg_2temp.nii -zmin 730 -zmax 880 -o ${filename}_seg_2temp_crop1.nii
sct_apply_transfo -i ${filename}_seg_2temp_crop1.nii -d ${filename}_seg.nii -w warp_template2anat.nii.gz -o ${filename}_seg_crop1.nii

#tidy up
rm warp_curve2straight.nii.gz
rm warp_straight2curve.nii.gz

done
