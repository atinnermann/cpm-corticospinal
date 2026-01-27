function full_diagn_qc

subIDs      = [1:49]; %1:49
exclude     = [3 14 19 28 35 36 41 7 25  ];
subIDs      = subIDs(~ismember(subIDs,exclude));

addpath('..\global');

%!!!!!Be careful here!!!!
%Variables need to be defined below for correct
%first level dir and correct t-map/con number
fLevelDir   = 'first_level_hrf'; %name of first level analysis
tMapNumber  = 15; %t-map/con number of your main effect (e.g. pain, motor)

checkMov    = 0;
dispMov     = 0;
dispCoreg   = 0;
dispNorm    = 1;
dispGM      = 1;
dispfLMask  = 0;
dispCon     = 0;

 %% check movement
 if checkMov == 1
     %diagnostic script to plot movement, find problematic movement and create
     %noise regressors for first-level analyses based on spike movement
     checkMov = 1;  %if 1, dignoses problematic movement
     plotMov = 1;  %if 1, plots movement parameters and between session dislocation for every participant
     movReg = 0;  %if 1, finds spike movement and saves noise regressors that can be used in first level analysis
     check_movement(subIDs,checkMov,plotMov,movReg);
 end

 if dispMov == 1
     %show mean epi and all first run epis for every sub
     whichFile = 1; % 1: brain; 2: spinal
     disp_mov_images(subIDs,whichFile);
 end

% %% run tsdiffana
% saveReg = 1; %if 1, saves outlier vols as noise regressors that can be used in first level analysis 
% check_outlier_vols(subIDs,saveReg);

%% check coregistration and normalisation

if dispCoreg == 1
    %check for every sub whether non-linear coreg of mean epi to anat was succesful
    whichFile = 2; % 2: spinal mean + T2
    disp_coreg_images(subIDs,whichFile);
    whichFile = []; %1:9  1 2 4 6 7 8 9
    compare_coreg_images(subIDs,whichFile);

end

if dispNorm == 1
    % show normalised files of all subs, either skull strip or mean epi
    whichFile = 4; % 1: T1; 2: mean epi; 3: T2; 4: spinal mean
    disp_norm_images(subIDs,whichFile);
    % nFiles = [1 7 9 10 11 12 13];
    % compare_norm_images(subIDs,whichFile,nFiles);
end


if dispGM == 1
    %check for every sub whether non-linear coreg of mean epi to anat was succesful
    whichFile = 2; % 2: spinal mean + T2gmseg
    disp_gm_images(subIDs,whichFile);
end

%% check first level analyses

if dispfLMask == 1
    %show normalised first level masks of all subs
    disp_mask_images(subIDs,BIDS,fLevelDir);
end

if dispCon == 1
    %show normalised, smoothed, thresholded t-map for main effect in every sub
    check_flevel_tmap(subIDs,fLevelDir,tMapNumber)
end

end


