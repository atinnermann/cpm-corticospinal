function preproc_physio

addpath('../utils');
addpath('../global');
addpath(genpath(fullfile(userpath,'CEDMATLAB')));

subIDs      = [6 ];  %1:49
exclude     = [3 14 19 28 35 36 41 ];
subIDs      = subIDs(~ismember(subIDs,exclude));


sbp_convert_physio_smr(subIDs);
sbp_clean_physio(subIDs);
sbp_create_physio_reg(subIDs);
sbp_check_bpm(subIDs);
