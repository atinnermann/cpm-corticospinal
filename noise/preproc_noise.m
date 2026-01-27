function preproc_noise

addpath('..\global');
addpath('..\utils');

subIDs      = [1:49 ];  %1:49
exclude     = [3 7 14 19 28 35 36 41 ];
subIDs      = subIDs(~ismember(subIDs,exclude));


motion   = 0;
outlier  = 0;
wmcsf    = 1;

if motion == 1
    create_motion_reg(subIDs);
end

if outlier == 1
    create_outlier_reg(subIDs);
end

if wmcsf == 1
    segID = []; %1: wm; 2: csf
    create_wm_csf_reg(subIDs,segID);  
end
