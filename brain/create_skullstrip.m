function create_skullstrip(subIDs,imgID)

nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;

matlabbatch = cell(1,nSubs);

for sub = 1:nSubs
    if imgID == 1
        subDir    = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'seg');
        workFile  = vars.meanEpiID;
        imgCalc   = 'i1.*((i2+i3+i4)>0.1)';
    elseif imgID == 2
        subDir    = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'anat1');
        workFile  = vars.T1imgID;
        imgCalc   = 'i1.*((i2+i3))';
    end
    
    anatFile = fullfile(subDir,sprintf(workFile,subIDs(sub)));
    outFile = fullfile(subDir,spm_file(sprintf(workFile,subIDs(sub)),'suffix','_strip'));

    c1File = fullfile(subDir,spm_file(sprintf(workFile,subIDs(sub)),'prefix','c1'));
    c2File = fullfile(subDir,spm_file(sprintf(workFile,subIDs(sub)),'prefix','c2'));
    c3file = fullfile(subDir,spm_file(sprintf(workFile,subIDs(sub)),'prefix','c3'));

    matlabbatch{sub}.spm.util.imcalc.input            = cellstr(char(anatFile,c1File,c2File,c3file));
    matlabbatch{sub}.spm.util.imcalc.output           = outFile;
    matlabbatch{sub}.spm.util.imcalc.outdir           = {subDir};
    matlabbatch{sub}.spm.util.imcalc.expression       = imgCalc;
    matlabbatch{sub}.spm.util.imcalc.options.dmtx     = 0;
    matlabbatch{sub}.spm.util.imcalc.options.mask     = 0;
    matlabbatch{sub}.spm.util.imcalc.options.interp   = 1;
    matlabbatch{sub}.spm.util.imcalc.options.dtype    = 4;
end

% run matlabbatch
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
