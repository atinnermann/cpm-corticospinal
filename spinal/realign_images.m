function realign_images

rmpath(genpath(fullfile(userpath,'spm12'))); 
addpath(genpath(fullfile(userpath,'spm24'))); 
addpath('..\global');

subIDs      = [1:49];%1:49
exclude     = [3 7 14 19 28 35 36 41 25];
subIDs      = subIDs(~ismember(subIDs,exclude));

nSubs        = length(subIDs);
[path,vars]  = get_study_specsD;
baseDir      = path.mriDir;
nRuns        = vars.nRuns;
nScans       = vars.nScans;

matlabbatch = cell(1,nSubs);

for sub = 1:nSubs
    subDir = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
    for run = 1:nRuns
        runDir      = fullfile(subDir,sprintf('run%d',run),'spinal');
        files       = spm_select('FPList',runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'prefix','^'));
        if isempty(files)
            pause
        end
        
        matlabbatch{run,sub}.spm.tools.spatial.slice2vol.images = cellstr(files);
        matlabbatch{run,sub}.spm.tools.spatial.slice2vol.slice_code = 2;
        matlabbatch{run,sub}.spm.tools.spatial.slice2vol.sd = 0.01;
        matlabbatch{run,sub}.spm.tools.spatial.slice2vol.fwhm = 0;
    end
end
run_spm_batch(matlabbatch,nSubs);

% rename mean files
for sub = 1:nSubs
    subDir     = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));

    for run = 1:nRuns
        runDir  = fullfile(subDir,sprintf('run%d',run),'spinal');

        meanEpi    = fullfile(runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'prefix','mean'));
        newName    = fullfile(runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'suffix','_moco_mean'));
        movefile(meanEpi,newName);
        files   = spm_select('FPList',runDir,'rsub.*');
        movefile(files,fullfile(runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'suffix','_moco')));
    end

end

end


