function create_wm_csf_reg(subIDs,segID)

% add paths
nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;
nRuns        = vars.nRuns;
nScans       = vars.nScans;

for sub = 1:nSubs
    subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
    anatDir     = fullfile(subDir,'seg');
    funcDir     = fullfile(subDir,'run1','brain');
    physioDir   = fullfile(path.physioDir,sprintf('sub%02d',subIDs(sub)),'noise_reg');

    meanEpi     = fullfile(funcDir,sprintf(vars.meanEpiID,subIDs(sub)));

    if isempty(segID)
        cFiles{1}   = fullfile(anatDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','c2'));
        cFiles{2}   = fullfile(anatDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','c3'));
        roiName     = 'wm_csf';
    elseif segID == 1
        cFiles{1}   = fullfile(anatDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','c2'));
        roiName     = 'wm';
    elseif segID == 2
        cFiles{1}   = fullfile(anatDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','c3'));
        roiName     = 'csf';
    end
         
    thresh = [0.9 0.9]; ex_var = 24; %either number of pcs or threshold for variance explained
    gi = 1;
    for run = 1:nRuns
        fprintf('Processing Sub%02d Run%d\n',subIDs(sub),run);
        runDir      = fullfile(subDir,sprintf('run%d',run),'brain');
        epiFiles    = spm_select('ExtFPList',runDir,spm_file(sprintf(vars.rawEpiID,subIDs(sub),run),'prefix','^r'),1:nScans);
        outName     = fullfile(physioDir,sprintf(vars.noiseFile,subIDs(sub),roiName,run));
        
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{1}.evaluated = epiFiles;
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{2}.string    = char(meanEpi);
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{3}.evaluated = cFiles;
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{4}.evaluated = thresh;
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{5}.evaluated = ex_var;
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{6}.string    = outName;
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.outputs = {};
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.fun = 'extract_segment';
        gi = gi + 1;
    end
end

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

