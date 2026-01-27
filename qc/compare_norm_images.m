function compare_norm_images(subIDs,whichFile,nFiles)


% resolve paths
[path,vars]    = get_study_specs;
baseDir        = path.mriDir;
nSubs          = length(subIDs);

tempFile   = spm_select('FPList',baseDir,'mean_t2_template.nii');

for sub = 1:nSubs
    subDir    = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
    if whichFile == 3
        workDir    = fullfile(subDir,'anat2');
        fileID     = vars.T2imgID;
    elseif whichFile == 4
        workDir   = fullfile(subDir,'run1','spinal');
        fileID     = vars.spMeanID;
    end
    allFiles  = [];
    for f = nFiles
        subFile    = fullfile(workDir,spm_file(sprintf(fileID,subIDs(sub)),'suffix',['_2temp' num2str(f)]));
        allFiles = [char(allFiles,subFile)];
    end
    allFiles(1,:)=[];
    spm_check_registration(char(tempFile,deblank(allFiles))); %,subFile4
    fprintf('Press enter in command window to continue\n');
    input('');
end

end






