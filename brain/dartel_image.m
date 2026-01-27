function dartel_image(subIDs,imgID)

nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;
tempDir      = path.tempDir;

matlabbatch = cell(1,nSubs);

for sub = 1:nSubs
    
    if imgID == 1
        subDir      = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)),'seg');
        workFile    = vars.meanEpiID;    
    elseif imgID == 2
        subDir      = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)),'anat1');
        workFile    = vars.T1imgID;
    end
    
    rc1File     = fullfile(subDir,spm_file(sprintf(workFile,subIDs(sub)),'prefix','rc1'));
    rc2File     = fullfile(subDir,spm_file(sprintf(workFile,subIDs(sub)),'prefix','rc2'));

    matlabbatch{sub}.spm.tools.dartel.warp1.images = {cellstr(rc1File),cellstr(rc2File)};
    matlabbatch{sub}.spm.tools.dartel.warp1.settings.rform = 0;
    matlabbatch{sub}.spm.tools.dartel.warp1.settings.optim.lmreg = 0.01;
    matlabbatch{sub}.spm.tools.dartel.warp1.settings.optim.cyc = 3;
    matlabbatch{sub}.spm.tools.dartel.warp1.settings.optim.its = 3;
    
    paramR = [4 2 1e-06;2 1 1e-06;1 0.5 1e-06;0.5 0.25 1e-06;0.25 0.125 1e-06;0.25 0.125 1e-06];
    paramK = [0 0 1 2 4 6];

    for p = 1:length(paramK)
        matlabbatch{sub}.spm.tools.dartel.warp1.settings.param(p).its = 3;
        matlabbatch{sub}.spm.tools.dartel.warp1.settings.param(p).rparam = paramR(p,:);
        matlabbatch{sub}.spm.tools.dartel.warp1.settings.param(p).K = paramK(p);
        matlabbatch{sub}.spm.tools.dartel.warp1.settings.param(p).template = {[fullfile(tempDir,spm_file(vars.tempDartel,'suffix',['_' num2str(p)]))]};
    end

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
