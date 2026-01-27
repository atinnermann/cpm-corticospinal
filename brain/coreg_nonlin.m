function coreg_nonlin(subIDs)
% function nonlin_coreg
% performs a nonlinear coregistration between mean EPI and T1
% writes a cmean* file that is the mean EPI in the space of the T1
% also does a segmentation of the T1, and the Dartel export, so we don't
% have to do this again


nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;

for sub = 1:nSubs
    
    subDir       = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)));
    anatDir      = fullfile(subDir,'anat1');
    anatFile     = fullfile(anatDir,sprintf(vars.T1imgID,subIDs(sub)));
    
    funcDir      = fullfile(subDir,'run1','brain');
    meanFile     = fullfile(funcDir,sprintf(vars.meanEpiID,subIDs(sub)));
    
    gi    = 1;
    for f = 1:6
        matlabbatch{gi,sub}.spm.spatial.smooth.data(f,:) = cellstr(fullfile(spm_file(anatFile,'prefix',sprintf('c%d',f)))); % Now smooth segments
    end
    matlabbatch{gi,sub}.spm.spatial.smooth.fwhm      = [3 3 3];
    matlabbatch{gi,sub}.spm.spatial.smooth.dtype     = 0;
    matlabbatch{gi,sub}.spm.spatial.smooth.im        = 0;
    matlabbatch{gi,sub}.spm.spatial.smooth.prefix    = 's';
    delcFiles = matlabbatch{gi,sub}.spm.spatial.smooth.data(4:6,:);
    gi = gi + 1;
    
    for f = 1:6
        matlabbatch{gi,sub}.spm.util.cat.vols(f,:)  = cellstr(fullfile(spm_file(anatFile,'prefix',sprintf('sc%d',f)))); % assemble all segments into a 4D file which is a TPM for later
    end
    
    matlabbatch{gi,sub}.spm.util.cat.name       = vars.tmpTPM;
    matlabbatch{gi,sub}.spm.util.cat.dtype      = 16;
    delscFiles = matlabbatch{gi,sub}.spm.util.cat.vols; % handy for deletion
    gi = gi + 1;
    
    reg = 1;    
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.subj.vol          = cellstr(meanFile); % now normalize mean EPI using the generated TPM 
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.subj.resample     = cellstr(meanFile);
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.eoptions.biasreg  = 0.0001;
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.eoptions.tpm(1,:) = cellstr(fullfile(anatDir,vars.tmpTPM));
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.eoptions.affreg   = 'subj';
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.eoptions.reg      = reg*[0 1e-05 0.005 0.0005 0.002];%if reg is bigger nonlinear will be less aggressive
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.eoptions.fwhm     = 3;
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.eoptions.samp     = 3;
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.woptions.bb       = [NaN NaN NaN; NaN NaN NaN];
    % matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.woptions.bb       = [-78 -112 -70;78 76 85]; % bigger for larger diffs between T1 and EPI
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.woptions.vox      = [1.5 1.5 1.5];
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.woptions.interp   = 4;
    matlabbatch{gi,sub}.spm.spatial.normalise.estwrite.woptions.prefix   = 'c';
    gi = gi + 1;
    
    matlabbatch{gi,sub}.cfg_basicio.file_dir.file_ops.file_move.files    = cellstr(deblank(char(char(delcFiles),char(delscFiles))));
    matlabbatch{gi,sub}.cfg_basicio.file_dir.file_ops.file_move.action.delete = false; % delete all the stuff we do not need anymore
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

