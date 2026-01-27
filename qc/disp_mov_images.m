function disp_mov_images(subIDs,whichFile)

% resolve paths
[path,vars]   = get_study_specs;
baseDir       = path.mriDir;
nSubs         = length(subIDs);
nRuns         = vars.nRuns;

for sub = 1:nSubs
    subDir    = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)));
    % allFiles = [];
    for run = 1:nRuns
        if whichFile == 1
            runDir  = fullfile(subDir,sprintf('run%d',run),'brain');
            if run == 1
                meanFile  = fullfile(runDir,sprintf(vars.meanEpiID,subIDs(sub)));
            end
            % sliceFiles = spm_select('ExtFPList',runDir,sprintf(vars.rawEpiID,subIDs(sub),run),Inf);
            % allFiles = [allFiles;sliceFiles];
            realignFiles(run,:) = spm_select('ExtFPList',runDir,['^' sprintf(vars.rawEpiID,subIDs(sub),run)],1);
        elseif whichFile == 2
            runDir  = fullfile(subDir,sprintf('run%d',run),'spinal');
            if run == 1
               meanFile  = fullfile(runDir,sprintf(vars.spMeanID,subIDs(sub)));
            end
            realignFiles(run,:) = spm_select('FPList',runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'suffix','_moco_mean_2mean')); %mean_reg
        end
    end

    spm_check_registration(char(meanFile,realignFiles));
    if whichFile == 2
        spm_orthviews('Zoom',30);
        spm_orthviews('contour','display',1,2:nRuns+1);
    end

    fprintf('Checking Subject %d \nPress enter in command window to continue\n',subIDs(sub));
    input('');
end

end






