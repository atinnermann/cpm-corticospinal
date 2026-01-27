#!/bin/bash


#abort on error
set -e

#add path of toolbox
PATH=~/sct_6.4/bin:$PATH

#project dir
basedir=/mnt/c/Users/tinnermann/Documents/data/cpm/mri/

#tmp dir
export TMPDIR=${basedir}tmp

#template dir
tpldir=${basedir}PAM50

#array that lists all subs and runs in which registration problems occured
pbl=("problems")

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

for subject in ${listofSubs[@]}; do

subdir=${basedir}sub`printf %02d ${subject}`

echo "Sub${subject}"

rundir1=${subdir}/run1/spinal/
# fmri
# ===========================================================================================


cd ${rundir1} || exit

meanepi=sub`printf %02d ${subject}`_fmri_spinal_mean_2temp_clean

#segment spinal cord
sct_deepseg -i ${meanepi}.nii -task seg_sc_epi -o ${meanepi}_episeg.nii -qc ${basedir}/qc_sct/seg_mean 

#segment gray matter
sct_deepseg_gm -i ${meanepi}.nii
sct_maths -i ${meanepi}_gmseg.nii -dilate 2 -o ${meanepi}_gmseg_d2.nii


done


echo ${pbl[@]}
