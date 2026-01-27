function create_spinal_wm_reg(subIDs)


% add paths
nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;
nRuns        = vars.nRuns;
nScans       = vars.nScans;


for sub = 1:nSubs
    subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
    physioDir   = fullfile(path.physioDir,sprintf('sub%02d',subIDs(sub)),'noise_reg'); 
    firstDir    = fullfile(subDir,'run1','spinal');

    funcDir     = fullfile(subDir,'run1','spinal');
    meanEpi     = fullfile(funcDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix','_2temp'));

    cordMask    = fullfile(baseDir,'mean_t2_template_seg.nii');
    roiName     = 'wm50';

    gmMask      = spm_file(meanEpi,'suffix','_clean_gmseg_d2');
    varMask     = spm_file(sprintf(vars.spFirstEpiID,subIDs(sub)),'suffix','_wmMask');

    gi = 1;
    matlabbatch{gi,sub}.spm.util.imcalc.input          = cellstr(char(gmMask,cordMask));
    matlabbatch{gi,sub}.spm.util.imcalc.output         = varMask;
    matlabbatch{gi,sub}.spm.util.imcalc.outdir         = {firstDir};
    matlabbatch{gi,sub}.spm.util.imcalc.expression     = '(i2.*(i1==0))';
    matlabbatch{gi,sub}.spm.util.imcalc.var            = struct('name', {}, 'value', {});
    matlabbatch{gi,sub}.spm.util.imcalc.options.dmtx   = 0;
    matlabbatch{gi,sub}.spm.util.imcalc.options.mask   = 0;
    matlabbatch{gi,sub}.spm.util.imcalc.options.interp = 0;
    matlabbatch{gi,sub}.spm.util.imcalc.options.dtype  = 4;
    gi = gi + 1;
    
    thresh = [0.9 0.9]; ex_var = 0.5;
    for run = 1:nRuns
        fprintf('Processing Sub%02d Run%d\n',subIDs(sub),run);
        runDir      = fullfile(subDir,sprintf('run%d',run),'spinal');
        epiFiles    = spm_select('ExtFPList',runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'suffix','_2temp'),1:nScans);
        outName     = fullfile(physioDir,sprintf(vars.spNoiseFile,subIDs(sub),roiName,run));

        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{1}.evaluated = epiFiles;
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{2}.string    = char(meanEpi);
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{3}.evaluated = {fullfile(firstDir,varMask)};
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

