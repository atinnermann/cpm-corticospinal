function realign_images(subIDs,mask)

nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;
nRuns        = vars.nRuns;
nScans       = vars.nScans;

matlabbatch = cell(1,nSubs);

for sub = 1:nSubs
    subDir = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
     
    files = cell(1,nRuns);
    for run = 1:nRuns
        runDir      = fullfile(subDir,sprintf('run%d',run),'brain');
        files{run}  = cellstr(spm_select('ExtFPList',runDir,spm_file(sprintf(vars.rawEpiID,subIDs(sub),run),'prefix','^'),1:nScans));
    end

    if mask == 1
        maskImg = fullfile(subDir,'anat1',spm_file(sprintf(vars.T1imgID,subIDs(sub)),'prefix','c','suffix','_mask'));
        meanDir = fullfile(subDir,'run1','brain');
        meanEpi = fullfile(meanDir,sprintf(vars.meanEpiID,subIDs(sub)));
        newName = fullfile(meanDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'suffix','_old'));
        movefile(meanEpi,newName);
    elseif mask == 0
        maskImg = '';
    end

    matlabbatch{sub}.spm.spatial.realign.estwrite.data             = files;
    matlabbatch{sub}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{sub}.spm.spatial.realign.estwrite.eoptions.sep     = 4;
    matlabbatch{sub}.spm.spatial.realign.estwrite.eoptions.fwhm    = 5;
    matlabbatch{sub}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
    matlabbatch{sub}.spm.spatial.realign.estwrite.eoptions.interp  = 4;
    matlabbatch{sub}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
    matlabbatch{sub}.spm.spatial.realign.estwrite.eoptions.weight  = {maskImg};
    if mask == 1
        matlabbatch{sub}.spm.spatial.realign.estwrite.roptions.which   = [0 1];
    elseif mask == 0
        matlabbatch{sub}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
    end
    matlabbatch{sub}.spm.spatial.realign.estwrite.roptions.interp  = 4;
    matlabbatch{sub}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
    matlabbatch{sub}.spm.spatial.realign.estwrite.roptions.mask    = 1;
    matlabbatch{sub}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';

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

%rename mean files
for sub = 1:nSubs
    subDir     = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
    meanDir    = fullfile(subDir,'run1','brain');
    meanEpi    = fullfile(meanDir,spm_file(sprintf(vars.firstEpiID,subIDs(sub)),'prefix','mean'));
    newName    = fullfile(meanDir,sprintf(vars.meanEpiID,subIDs(sub)));
    movefile(meanEpi,newName);

    % for run = 1:nRuns
    %     runDir  = fullfile(subDir,sprintf('run%d',run),'brain');
    %     files   = spm_select('FPList',runDir,'rsub.*');
    %     for f = 1:size(files,1)
    %         delete(files(f,:));
    %     end
    % end

end

end


