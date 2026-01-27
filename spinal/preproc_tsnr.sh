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


for run in {1..4}; do

rundir=${subdir}/run${run}/spinal/
epiname=sub`printf %02d ${subject}`_fmri_spinal_run${run}

echo "Run${run}"

cd ${rundir} || exit

#Compute tSNR per realigned run
sct_fmri_compute_tsnr -i ${epiname}_moco.nii -o ${epiname}_moco_tsnr.nii

done
done