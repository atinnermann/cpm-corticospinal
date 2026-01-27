function warp_images2(subIDs)
% function create_noise
% creates noise regressors for 1st ´level analysis
% 1) WM and CSF


% add paths
nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.baseDir;


for sub = 1:nSubs
    subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));

    anatDir     = fullfile(subDir,'seg');
    funcDir     = fullfile(subDir,'run1','brain');

    cFile1   = fullfile(anatDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','c2'));
    cFile2   = fullfile(anatDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','c3'));

    warpField   = fullfile(funcDir,'y_epi2template.nii');

    gi = 1;
    matlabbatch{gi,sub}.spm.util.defs.comp{1}.def = cellstr(warpField);
    matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.fnames = {cFile1;cFile2};
    matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
    matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.interp = 4;
    matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.mask = 1;
    matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
    matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.prefix = 'w';
    gi = gi + 1;

end

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

