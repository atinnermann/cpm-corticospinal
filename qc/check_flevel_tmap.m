function check_flevel_tmap(subIDs,fLevelDir,tMapNumber)


[path,vars,qc] = get_study_specs;
baseDir        = path.baseDir;
nSubs          = length(subIDs);


tempFile       = fullfile(path.tempDir,vars.tempFile);
rawtMapID      = sprintf('spmT_0%03d.nii',tMapNumber);

for sub = 1:nSubs
    workDir   = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'results',fLevelDir);
    rawtMapFile  = fullfile(workDir,rawtMapID);

    tMapID    = spm_file(rawtMapID,'prefix',['s' num2str(qc.tMapSmoothK)],'suffix',['_t' num2str(qc.tThresh*10)]);
    tMapFile  = fullfile(workDir,tMapID);
    
    
    if ~exist(tMapFile,'file')
        % spec           = rmmissing([subIDs(sub),(nSess-1)/(nSess-1)]);
        % flowFieldDir   = fullfile(preprocPath,sprintf(vars.subDirID,spec),'func'); 
        % flowFieldFile  = fullfile(flowFieldDir,vars.flowField);
        % 
        % rawtMapFile    = fullfile(workDir,vars.rawtMapID);
        % warptMapFile   = fullfile(workDir,vars.rawtMapID);
        smoothtMapFile = fullfile(workDir,spm_file(rawtMapID,'prefix',['s' num2str(qc.tMapSmoothK)]));
  
        % matlabbatch{1}.spm.util.defs.comp{1}.def = {flowFieldFile};
        % matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = cellstr(rawtMapFile);
        % matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
        % matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
        % matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
        % matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
        % matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = 'w';
        
        matlabbatch{1}.spm.spatial.smooth.data = cellstr(rawtMapFile);
        matlabbatch{1}.spm.spatial.smooth.fwhm = repmat(qc.tMapSmoothK,1,3);
        matlabbatch{1}.spm.spatial.smooth.prefix = ['s' num2str(qc.tMapSmoothK)];

        matlabbatch{2}.spm.util.imcalc.input = {smoothtMapFile};
        matlabbatch{2}.spm.util.imcalc.output = tMapFile;
        matlabbatch{2}.spm.util.imcalc.outdir = {workDir};
        matlabbatch{2}.spm.util.imcalc.expression = ['i1.*(i1>' num2str(qc.tThresh) ')'];
        matlabbatch{2}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        
        spm_jobman('run',matlabbatch);
        clear matlabbatch
    end
    
    spm_check_registration(tempFile);
    
    tempFileInd = 1;
    overlayInd = 1;
    spm_orthviews('addcolouredimage',tempFileInd,tMapFile,qc.overlayColor)
    spm_orthviews('redraw',tempFileInd);
    spm_orthviews('addcolourbar',tempFileInd,overlayInd);
    spm_orthviews('redraw',tempFileInd);
    
    fprintf('Checking Sub%d \nPress enter in command window to continue\n',subIDs(sub));
    input('');
    
end
