function compare_coreg_images(subIDs,nFiles)


% resolve paths
[path,vars,qc] = get_study_specs;
baseDir        = path.baseDir;
nSubs          = length(subIDs);


for sub = 1:nSubs
    subDir    = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
    workDir   = fullfile(subDir,'run1');

    anatDir   = fullfile(subDir,'anat2');
    anatFile  = fullfile(anatDir,spm_file(sprintf(vars.T2imgID,subIDs(sub)),'suffix','_crop1'));

    allFiles  = fullfile(workDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix','_2t2'));
    for f = nFiles
        subFile    = fullfile(workDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix',['_2t2' num2str(f)]));
        allFiles = [char(allFiles,subFile)];
    end
    % allFiles(1,:)=[];
    
    spm_check_registration(char(anatFile,deblank(allFiles))); %,subFile4
    xyz = spm_orthviews('Pos');
    spm_orthviews('Reposition',[xyz(1:2); xyz(3)-35])
    spm_orthviews('Zoom',45);
    % spm_orthviews('contour','display',2,[1 3:numel(nFiles)+2])
    fprintf('Press enter in command window to continue\n');
    input('');
end

end






