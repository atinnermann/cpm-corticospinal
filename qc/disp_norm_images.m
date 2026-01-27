function disp_norm_images(subIDs,whichFile)


% resolve paths
[path,vars,qc] = get_study_specs;
baseDir        = path.mriDir;
nSubs          = length(subIDs);

maxImg        = qc.maxDisImg;


allFiles = [];

for sub = 1:nSubs
    subDir    = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
    if whichFile == 1
        workDir    = fullfile(subDir,'anat1');
        subFile    = fullfile(workDir,spm_file(sprintf(vars.T1stripID,subIDs(sub)),'prefix','w'));
        tempFile   = spm_select('FPList',path.tempDir,vars.tempFile);
    elseif whichFile == 2
        workDir    = fullfile(subDir,'run1','brain'); 
        subFile    = fullfile(workDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','w'));
        tempFile   = spm_select('FPList',path.tempDir,vars.tempFile);
    elseif whichFile == 3
        workDir    = fullfile(subDir,'anat2');
        subFile    = fullfile(workDir,spm_file(sprintf(vars.T2imgID,subIDs(sub)),'suffix','_2temp'));
        tempFile   = spm_select('FPList',path.spTempDir,vars.spTempFile);
    elseif whichFile == 4
        workDir    = fullfile(subDir,'run1','spinal');
        subFile    = fullfile(workDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix','_2temp_clean'));
        % tempFile   = spm_select('FPList',path.spTempDir,vars.spTempFile);
        tempFile   = spm_select('FPList',baseDir,'mean_t2_template_crop.nii');
    end
    allFiles   = [allFiles;subFile]; 
end

    
for i = 1:ceil(nSubs/maxImg)  
    if i == ceil(nSubs/maxImg)
        spm_check_registration(char(tempFile,allFiles(maxImg*(i-1)+1:end,:)));
        fprintf('Press enter in command window to continue\n');
        if i == 1
            % spm_orthviews('contour','display',1,2:nSubs+1);
        else
            % spm_orthviews('contour','display',1,2:nSubs-((i-1)*maxImg));
        end
        input('');
    else
        spm_check_registration(char(tempFile,allFiles(maxImg*(i-1)+1:maxImg*(i-1)+maxImg,:)));
        
        % spm_orthviews('contour','display',1,2:maxImg+1)
        fprintf('Press enter in command window to continue\n');
        input('');
    end
    
end

end






