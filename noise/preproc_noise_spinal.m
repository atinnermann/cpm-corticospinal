function preproc_noise_spinal

addpath('..\global');
addpath('..\utils');

subIDs = [1:49 ]; %1:49 

exclude = [3 7 14 19 28 35 36 41 25];

subIDs = subIDs(~ismember(subIDs,exclude));

outlier  = 0;
csf      = 1;
wm       = 0 ;


if outlier == 1
    create_outlier_tsda_spinal(subIDs);
end

if csf == 1
     create_spinal_csf_reg_var(subIDs);
end

if wm == 1
    create_spinal_wm_reg(subIDs);
end