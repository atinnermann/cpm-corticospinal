function warp_images(subIDs,imgID)

nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;
nRuns        = vars.nRuns;

for sub = 1:nSubs
    subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
    gi = 1;
    for f = 1:length(imgID)
        currID = imgID(f);
        if currID == 1 || currID == 3
            workDir     = fullfile(subDir,'run1','brain');
            workFile    = vars.meanEpiID;
            warpField   = fullfile(workDir,'y_epi2template.nii');
        elseif currID == 2
            workDir     = fullfile(subDir,'anat1');
            workFile    = vars.T1stripID;
            warpField   = fullfile(workDir,spm_file(sprintf(vars.T1imgID,subIDs(sub)),'prefix','u_rc1'));
        elseif currID == 4
            workDir     = fullfile(subDir,'seg');
            workFile    = vars.meanStripID;
            warpField   = fullfile(subDir,'run1','brain','y_epi2template.nii');
            maskFile    = spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','w','suffix','_mask');
        end

        if currID == 1 || currID == 2 || currID == 4
            warpFiles   = fullfile(workDir,sprintf(workFile,subIDs(sub)));
        elseif currID == 3
            runFiles    = [];
            for run = 1:nRuns
                runDir = fullfile(subDir,sprintf('run%d',run),'brain');
                files  = spm_select('FPList',runDir,['^' sprintf(vars.rawEpiID,subIDs(sub),run)]);
                runFiles = [runFiles;files];
            end
            warpFiles   = runFiles;
            % elseif imgID == 4
            %     %to do
            %     warpFiles = conimages;
        end

        if currID == 1 || currID == 3 || currID == 4
            matlabbatch{gi,sub}.spm.util.defs.comp{1}.def = cellstr(warpField);
            matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.fnames = cellstr(warpFiles);
            matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
            matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.interp = 4;
            matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.mask = 1;
            matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
            matlabbatch{gi,sub}.spm.util.defs.out{1}.pull.prefix = 'w';
            gi = gi + 1;
        elseif currID == 2 
            matlabbatch{gi,sub}.spm.tools.dartel.crt_warped.flowfields = cellstr(warpField);
            matlabbatch{gi,sub}.spm.tools.dartel.crt_warped.images = {cellstr(warpFiles)};
            matlabbatch{gi,sub}.spm.tools.dartel.crt_warped.jactransf = 0;
            matlabbatch{gi,sub}.spm.tools.dartel.crt_warped.K = 6;
            matlabbatch{gi,sub}.spm.tools.dartel.crt_warped.interp = 1;
            gi = gi + 1;
        end
        if currID == 4
            matlabbatch{gi,sub}.spm.util.imcalc.input            = cellstr(spm_file(warpFiles,'prefix','w'));
            matlabbatch{gi,sub}.spm.util.imcalc.output           = maskFile;
            matlabbatch{gi,sub}.spm.util.imcalc.outdir           = {workDir};
            matlabbatch{gi,sub}.spm.util.imcalc.expression       = 'i1>25';
            matlabbatch{gi,sub}.spm.util.imcalc.options.dmtx     = 0;
            matlabbatch{gi,sub}.spm.util.imcalc.options.mask     = 0;
            matlabbatch{gi,sub}.spm.util.imcalc.options.interp   = 1;
            matlabbatch{gi,sub}.spm.util.imcalc.options.dtype    = 2;
        end
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
