function disp_coreg_images(subIDs,whichFile)


% resolve paths
[path,vars]   = get_study_specs;
baseDir       = path.mriDir;
nSubs         = length(subIDs);


for sub = 1:nSubs
    subDir    = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)));

    if whichFile == 1
        funcDir   = fullfile(subDir,'run1','brain');
        anatDir   = fullfile(subDir,'anat1');

        meanFile  = fullfile(funcDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','c'));
        anatFile  = fullfile(anatDir,sprintf(vars.T1imgID,subIDs(sub)));
    elseif whichFile == 2
        funcDir   = fullfile(subDir,'run1','spinal');
        anatDir   = fullfile(subDir,'anat2');

        meanFile  = fullfile(funcDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix','_2temp_clean'));
        anatFile  = fullfile(funcDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix','_2temp_clean_gmseg_d2'));
    end

    spm_check_registration(char(meanFile,anatFile));
    if whichFile == 2
        xyz = spm_orthviews('Pos');
        % spm_orthviews('Reposition',[xyz(1:2); xyz(3)-35])
        spm_orthviews('Zoom',45);
    end
        spm_orthviews('contour','display',2,1)
    % global st
    %     % your desired params
    % nLines = 2;
    % styleLines = 'r-' % Line properties z.B. via line
    % % contour to modify
    % ctm = 1;
    % hM = findobj(st.vols{ctm}.ax{1}.cm,'Label','Contour');
    % UD = get(hM,'UserData');
    % UD.nblines = nLines;
    % UD.style = styleLines;
    % set(hM,'UserData',UD);
    % spm_ov_contour('display',ctm,Inf)

        % spm_orthviews('contour','display','Lines',2)
    
    
    fprintf('Checking Subject %d \nPress enter in command window to continue\n',subIDs(sub));
    input('');
end

end






