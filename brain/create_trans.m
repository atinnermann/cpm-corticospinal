function create_trans(subIDs)
% function create_trans
% creates all required spatial transformation matrices based on nonlinear coreg and dartel


nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;
tempDir      = path.tempDir;

for sub = 1:nSubs
    
    subDir       = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)));
    anatDir      = fullfile(subDir,'anat1');
    anatFile     = fullfile(anatDir,sprintf(vars.T1imgID,subIDs(sub)));
    
    funcDir      = fullfile(subDir,'run1','brain');
    meanImg      = fullfile(funcDir,sprintf(vars.meanEpiID,subIDs(sub)));
    
    warpField    = spm_file(anatFile,'prefix','u_rc1');
    nlinDefField = spm_file(meanImg,'prefix','y_'); 
    nlinRegMean  = spm_file(meanImg,'prefix','c'); 

    gi    = 1;
    % get deformation from EPI to T1 space
    matlabbatch{gi,sub}.spm.util.defs.comp{1}.def               = cellstr(nlinDefField);
    matlabbatch{gi,sub}.spm.util.defs.comp{2}.id.space          = cellstr(nlinRegMean);
    matlabbatch{gi,sub}.spm.util.defs.out{1}.savedef.ofname     = 'epi2t1';
    matlabbatch{gi,sub}.spm.util.defs.out{1}.savedef.savedir.saveusr = {funcDir};
    gi = gi + 1;
    
    % get deformation from EPI to T1 space
    % ie combine nonlin coreg with Dartel (EPI --> T1 --> Template)
    matlabbatch{gi,sub}.spm.util.defs.comp{1}.def               = cellstr(nlinDefField);
    matlabbatch{gi,sub}.spm.util.defs.comp{2}.dartel.flowfield  = cellstr(warpField);
    matlabbatch{gi,sub}.spm.util.defs.comp{2}.dartel.times      = [1 0];
    matlabbatch{gi,sub}.spm.util.defs.comp{2}.dartel.K          = 6;
    matlabbatch{gi,sub}.spm.util.defs.comp{2}.dartel.template   = {''};
    matlabbatch{gi,sub}.spm.util.defs.out{1}.savedef.ofname     = 'epi2template';
    matlabbatch{gi,sub}.spm.util.defs.out{1}.savedef.savedir.saveusr = {funcDir};
    gi = gi + 1;
    
    
    % get the backwards transformation (Template --> EPI)
    matlabbatch{gi,sub}.spm.util.defs.comp{1}.inv.comp{1}.def   = cellstr(fullfile(funcDir,'y_epi2template.nii'));
    matlabbatch{gi,sub}.spm.util.defs.comp{1}.inv.space         = cellstr(fullfile(tempDir,'cb_Template_T1.nii'));
    matlabbatch{gi,sub}.spm.util.defs.out{1}.savedef.ofname     = 'template2epi';
    matlabbatch{gi,sub}.spm.util.defs.out{1}.savedef.savedir.saveusr = {funcDir};
    gi = gi + 1;

    % get the backwards transformation (T1 --> EPI)
    matlabbatch{gi,sub}.spm.util.defs.comp{1}.inv.comp{1}.def   = cellstr(fullfile(funcDir,'y_epi2t1.nii'));
    matlabbatch{gi,sub}.spm.util.defs.comp{1}.inv.space = cellstr(anatFile);
    matlabbatch{gi,sub}.spm.util.defs.out{1}.savedef.ofname = 't12epi';
    matlabbatch{gi,sub}.spm.util.defs.out{1}.savedef.savedir.saveusr = {funcDir};
    
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