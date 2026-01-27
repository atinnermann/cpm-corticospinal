function segment_image(subIDs,imgID)

nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;
tempDir      = path.tempDir;

template = fullfile(tempDir,vars.tpmFile);

matlabbatch = cell(1,nSubs);

for sub = 1:nSubs
    if imgID == 1
        subDir    = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'seg');
        meanDir   = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'run1','brain');
        meanEpi   = fullfile(meanDir,sprintf(vars.meanEpiID,subIDs(sub)));
        %copy mean epi to new folder for segmentation
        mkdir(subDir);
        copyfile(meanEpi,subDir);
        workFile   = fullfile(subDir,sprintf(vars.meanEpiID,subIDs(sub)));
    elseif imgID == 2
        subDir    = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'anat1');
        workFile  = fullfile(subDir,sprintf(vars.T1imgID,subIDs(sub)));
    end

    matlabbatch{sub}.spm.spatial.preproc.channel.vols     = cellstr(workFile);
    matlabbatch{sub}.spm.spatial.preproc.channel.biasreg  = 0.001;
    matlabbatch{sub}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{sub}.spm.spatial.preproc.channel.write    = [0 0];

    paramG = [1 1 2 3 4 2];
    paramN = [1 1; 1 1;1 1;1 0;1 0;1 0];
    
    for p = 1:numel(paramG)
        matlabbatch{sub}.spm.spatial.preproc.tissue(p).tpm    = {[template sprintf(',%d',p)]};
        matlabbatch{sub}.spm.spatial.preproc.tissue(p).ngaus  = paramG(p);
        matlabbatch{sub}.spm.spatial.preproc.tissue(p).native = paramN(p,:);
        matlabbatch{sub}.spm.spatial.preproc.tissue(p).warped = [0 0];
    end
    matlabbatch{sub}.spm.spatial.preproc.warp.mrf         = 1;
    matlabbatch{sub}.spm.spatial.preproc.warp.cleanup     = 1;
    matlabbatch{sub}.spm.spatial.preproc.warp.reg         = [0 0.001 0.5 0.05 0.2];
    matlabbatch{sub}.spm.spatial.preproc.warp.affreg      = 'mni';
    matlabbatch{sub}.spm.spatial.preproc.warp.fwhm        = 0;
    matlabbatch{sub}.spm.spatial.preproc.warp.samp        = 3;
    matlabbatch{sub}.spm.spatial.preproc.warp.write       = [0 0];
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
