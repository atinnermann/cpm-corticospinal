function get_backwards_trans(subIDs)
%-------------------------------
%Get backwards deformations

nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;

matlabbatch = cell(1,nSubs);

for sub = 1:nSubs

    subDir = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
    anatDir = fullfile(subDir,'anat1');

    u_rc1_file = cellstr(spm_select('FPList', anatDir, sprintf(vars.T1transID,subIDs(sub))));

    matlabbatch{sub}.spm.util.defs.comp{1}.dartel.flowfield = u_rc1_file;
    matlabbatch{sub}.spm.util.defs.comp{1}.dartel.times     = [1 0];
    matlabbatch{sub}.spm.util.defs.comp{1}.dartel.K         = 6;
    matlabbatch{sub}.spm.util.defs.comp{1}.dartel.template  = {''};
    matlabbatch{sub}.spm.util.defs.out{1}.savedef.ofname    = 'template2t1';
    matlabbatch{sub}.spm.util.defs.out{1}.savedef.savedir.saveusr = {anatDir};
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