function copy_raw_data(subIDs,folderID)

[path,vars]  = get_study_specsD;
baseDir      = path.mriDir;
rawDir       = path.rawData;
nSubs        = length(subIDs);

for sub = 1:nSubs
    subID      = subIDs(sub);
    subDir     = fullfile(baseDir,sprintf('sub%02d',subID));
    subRawDir  = fullfile(rawDir,sprintf('sub%02d',subID));

    if folderID == 1
        for run = 1:vars.nRuns
            runDir      = fullfile(subDir,sprintf('run%d',run),'brain');
            runRawDir   = fullfile(subRawDir,sprintf('run%d',run+1));
            if exist(runDir,'dir')
                rmdir(runDir,'s')
            end
            mkdir(runDir);
            copyfile(fullfile(runRawDir,sprintf(vars.rawEpiID,subID,run+1)),fullfile(runDir,sprintf(vars.rawEpiID,subID,run)));
        end
        anatDir     = fullfile(subDir,'anat1');
        anatRawDir  = fullfile(subRawDir,'anat1');
        if exist(anatDir,'dir')
            rmdir(anatDir,'s')
        end
        copyfile(anatRawDir,anatDir);
    elseif folderID == 2
        for run = 1:vars.nRuns
            runDir      = fullfile(subDir,sprintf('run%d',run),'spinal');
            mkdir(runDir)
            runRawDir   = fullfile(subRawDir,sprintf('run%d',run+1));
            % if exist(runDir,'dir')
            %     rmdir(runDir,'s')
            % end
            copyfile(fullfile(runRawDir,sprintf(vars.spRawEpiID,subID,run+1)),fullfile(runDir,sprintf(vars.spRawEpiID,subID,run)));
        end
        anatDir     = fullfile(subDir,'anat2');
        % movefile(anatDir,fullfile(subDir,'anat2_old'));
        anatRawDir  = fullfile(subRawDir,'anat2');
        if exist(anatDir,'dir')
            rmdir(anatDir,'s')
        end
        copyfile(anatRawDir,anatDir);
    elseif isempty(folderID)
        if exist(subDir,'dir')
            rmdir(subDir,'s')
        end
        copyfile(subRawDir,subDir);
    end
    fprintf(1,'Sub%d: raw data moved to subject directory\n',subID);


end
end