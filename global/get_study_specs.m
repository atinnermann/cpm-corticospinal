function [path,vars,qc] = get_study_specs(varargin)

%% path definitions

%%%%%%%%this need to be adapted to your study%%%%%%%%%%%%%%%%%%
path.baseDir     = 'C:\Users\tinnermann\Documents\data\cpm'; %'D:\projects\cpm';
% path.baseDir     = 'D:\projects\cpm'; %'D:\projects\cpm';
path.codeDir     = 'C:\Users\tinnermann\Documents\code\cpm';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

path.physioDir   = fullfile(path.baseDir,'noise'); 
path.logDir      = fullfile(path.baseDir,'logs');
path.mriDir      = fullfile(path.baseDir,'mri'); % 
path.rawData     = fullfile(path.mriDir,'rawdata');
path.fLevelDir   = fullfile(path.mriDir,'sub%02d','analyses');
path.sLevelDir   = fullfile(path.mriDir,'analyses');
path.tempDir     = fullfile(path.mriDir,'templates','templates_brain');
path.spTempDir   = fullfile(path.mriDir,'templates','templates_spinal');

vars.runParallel    = 1;
vars.nWorkers       = 6;

vars.nRuns          = 4;
vars.nSess          = 1;
vars.nDummy         = 5;
vars.nScans         = 227;
vars.nBlocks        = 2;
vars.nTrials        = 9;
vars.repTime        = 1.991;
vars.smKern         = 6;
vars.smKernSp       = [1];
vars.prDur          = 10;

vars.rawEpiID       = 'sub%02d_fmri_brain_run%d.nii';
vars.firstEpiID     = 'sub%02d_fmri_brain_run1.nii';
vars.meanEpiID      = 'sub%02d_fmri_brain_mean.nii';
vars.T1imgID        = 'sub%02d_t1.nii';
vars.T2imgID        = 'sub%02d_t2.nii';
vars.T1stripID      = spm_file(vars.T1imgID,'suffix','_strip');
vars.T1maskID       = spm_file(vars.T1imgID,'suffix','_mask');
vars.T1transID      = spm_file(vars.T1imgID,'prefix','u_rc1');
vars.meanStripID    = spm_file(vars.meanEpiID,'suffix','_strip');

vars.spRawEpiID     = 'sub%02d_fmri_spinal_run%d.nii';
vars.spFirstEpiID   = 'sub%02d_fmri_spinal_run1.nii';
vars.spMeanID       = 'sub%02d_fmri_spinal_mean.nii';
vars.T2normID       = 'anat2template.nii';
vars.spTempFile     = 'PAM50_t2_crop_5v.nii';

vars.tempFile       = 'cb_Template_Strip.nii';
vars.tempDartel     = 'cb_Template_Dartel.nii';
vars.tpmFile        = 'enhanced_TPM.nii';
vars.tmpTPM         = 'TPM_tmp.nii';

vars.phyFile        = 'sub%02d_noise_physio_run%d.mat';
vars.noiseFile      = 'sub%02d_noise_brain_%s_run%d.mat';
vars.spNoiseFile    = 'sub%02d_noise_spinal_%s_run%d.mat';
% vars.fLevelMaskID    = 'sub-%02d_mask.nii';

%% movement related qc

%thresholds for movement inspection
qc.threshSpike     = 0.7; %threshold for spikes
qc.threshMov       = 3; %threshold for overall movement within 1 run or between runs
qc.percSpike       = 0.05; %threshold in % in number of volumes that are discarded because of spikes

%% tsdiffana 

qc.thresh          = 3;

%% display options

qc.maxDisImg       = 7; %number of subject images displayed at once (not all numbers make sense here, 7 means a 4x2 display including template, otherwise try 5(3x2))
qc.contour         = 0; %1: template contour is displayed on images; 0: is not displayed

%% first level related qc

qc.tThresh         = 1.7; %t-value threshold, only values above this threshold will be shown
qc.tMapSmoothK     = 4; %smoothing kernel for t-map
qc.overlayColor    = [1 0 0]; %color for overlay (here red)

end