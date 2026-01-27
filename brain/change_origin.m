function change_origin(subIDs)
% Start use 6 dof to "normailze T1 to VBM 8 template

nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;
nRuns        = vars.nRuns;
nScans       = vars.nScans;
template     = fullfile(path.tempDir,vars.tempFile);

for sub = 1:nSubs
    subID      = subIDs(sub);
    anatDir    = fullfile(baseDir,sprintf('sub%02d',subID),'anat1');  
    anatFile   = fullfile(anatDir,sprintf(vars.T1imgID,subID));

    files = [];
    for run = 1:nRuns
        runDir      = fullfile(baseDir,sprintf('sub%02d',subID),sprintf('run%d',run),'brain');
        files       = [files;spm_select('ExtFPList',runDir,sprintf(vars.rawEpiID,subID,run),1:nScans)];
    end

    smoref    = 0;
    smosrc    = 8;

    VG = spm_vol(template);
    VF = spm_vol(anatFile);

    fprintf('Smoothing by %g & %gmm..\n', smoref, smosrc);
    VF1 = spm_smoothto8bit(VF,smosrc);
    % Rescale images so that globals are better conditioned
    VF1.pinfo(1:2,:) = VF1.pinfo(1:2,:)/spm_global(VF1);
    VG1 = spm_smoothto8bit(VG,smoref);
    VG1.pinfo(1:2,:) = VG1.pinfo(1:2,:)/spm_global(VG);

    flags.regtype      = 'rigid';
    flags.globnorm     = 0;
    M                  = spm_matrix([0 -30 -150  0 0 0 1 1 1]);
    [M,scal]           = spm_affreg(VG1,VF1,flags,M);

    smoref    = 0;
    smosrc    = 4;
    fprintf('Smoothing by %g & %gmm..\n', smoref, smosrc);
    VF1 = spm_smoothto8bit(VF,smosrc);
    % Rescale images so that globals are better conditioned
    VF1.pinfo(1:2,:) = VF1.pinfo(1:2,:)/spm_global(VF1);
    VG1 = spm_smoothto8bit(VG,smoref);
    VG1.pinfo(1:2,:) = VG1.pinfo(1:2,:)/spm_global(VG);

    [M,scal]      = spm_affreg(VG1,VF1,flags,M);

    Mv            = spm_imatrix(M);
    Mv(7:9)       = 1;
    Mv(10:12)     = 0;
    Mrigid        = spm_matrix(Mv);

    matlabbatch{sub}.spm.util.reorient.srcfiles = cellstr(char(anatFile,files));
    matlabbatch{sub}.spm.util.reorient.transform.transM = Mrigid;
    matlabbatch{sub}.spm.util.reorient.prefix = '';

    % matlabbatch = [];
    % matlabbatch{1}.spm.util.checkreg.data =  cellstr(char(template,anatFile));
    % spm_jobman('run',matlabbatch);
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
