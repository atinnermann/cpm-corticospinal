function create_mask(subIDs)
% function create_mask
% creates a mask based on WM and GM from the T1 (brainmaks.nii)
% This mask is then warped into EPI space (rbrainmass.nii) and 
% smoothed (s3rbrainmask) to be used as a mask for 1st level GLMs

% add paths
nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;
preFix       = 'c';

for sub = 1:nSubs

    anatDir    = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)),'anat1');
        
    funcDir   = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)),'run1','brain');
    stripFile = fullfile(anatDir,sprintf(vars.T1stripID,subIDs(sub)));
   
    maskFile = fullfile(anatDir,spm_file(sprintf(vars.T1maskID,subIDs(sub)),'prefix',preFix));
    
    gi    = 1;  
    matlabbatch{gi,sub}.spm.util.defs.comp{1}.def                 = cellstr(fullfile(funcDir,'y_epi2T1.nii'));
    matlabbatch{gi,sub}.spm.util.defs.out{1}.push.fnames          = cellstr(stripFile); %also create a skullstrip in EPI space
    matlabbatch{gi,sub}.spm.util.defs.out{1}.push.weight          = {''};
    matlabbatch{gi,sub}.spm.util.defs.out{1}.push.savedir.saveusr = {anatDir};
    matlabbatch{gi,sub}.spm.util.defs.out{1}.push.fov.bbvox.bb    = [NaN NaN NaN; NaN NaN NaN]; % same as nlin coreg
    matlabbatch{gi,sub}.spm.util.defs.out{1}.push.fov.bbvox.vox   = [NaN NaN NaN];
    matlabbatch{gi,sub}.spm.util.defs.out{1}.push.preserve        = 0; % simple
    matlabbatch{gi,sub}.spm.util.defs.out{1}.push.fwhm            = [0 0 0];
    matlabbatch{gi,sub}.spm.util.defs.out{1}.push.prefix          = preFix;
    gi = gi + 1;
    
    matlabbatch{gi,sub}.spm.util.imcalc.input            = cellstr(spm_file(stripFile,'prefix',preFix));
    matlabbatch{gi,sub}.spm.util.imcalc.output           = maskFile;
    matlabbatch{gi,sub}.spm.util.imcalc.outdir           = {funcDir};
    matlabbatch{gi,sub}.spm.util.imcalc.expression       = 'i1>0';
    matlabbatch{gi,sub}.spm.util.imcalc.options.dmtx     = 0;
    matlabbatch{gi,sub}.spm.util.imcalc.options.mask     = 0;
    matlabbatch{gi,sub}.spm.util.imcalc.options.interp   = 1;
    matlabbatch{gi,sub}.spm.util.imcalc.options.dtype    = 2; %uint 8

     
end

% run matlabbatch
if nSubs < vars.nWorkers
    nProcs = nSubs;
else
    nProcs = vars.nWorkers;
end

if vars.runParallel == 1
    run_spm_parallel(matlabbatch,nProcs);
else
   run_spm_sequential(matlabbatch);
end