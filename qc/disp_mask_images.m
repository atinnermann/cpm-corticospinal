function disp_mask_images(subIDs,BIDS,fLevelDir)


% resolve paths
[path,vars]   = get_study_specs(BIDS);
fLevelPath    = path.fLevelDir;
nSubs         = length(subIDs);

maxImg        = vars.maxDisImg;

tempFile      = fullfile(path.tempDir,vars.tempFile);
allFiles   = [];
    
for sub = 1:nSubs
    workDir    = fullfile(fLevelPath,fLevelDir,sprintf('sub-%02d',subIDs(sub)));
    subFile    = fullfile(workDir,spm_file(sprintf(vars.fLevelMaskID,subIDs(sub)),'prefix','w'));
    allFiles   = [allFiles;subFile]; 
end

    
for i = 1:ceil(nSubs/maxImg)  
    if i == ceil(nSubs/maxImg)
        spm_check_registration(char(tempFile,allFiles(maxImg*(i-1)+1:end,:)));
        fprintf('Press enter in command window to continue\n');
        input('');
    else
        spm_check_registration(char(tempFile,allFiles(maxImg*(i-1)+1:maxImg*(i-1)+maxImg,:)));
        fprintf('Press enter in command window to continue\n');
        input('');
    end
end

end






