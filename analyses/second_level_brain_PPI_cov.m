function second_level_brain_PPI_cov

addpath('..\global');
addpath('..\behav');

subIDs = [1:49]; %1:49

exclude = [3 7 14 19 28 35 36 41];
subIDs = subIDs(~ismember(subIDs,exclude));

[path,vars]    = get_study_specs;
baseDir        = path.mriDir;
nSubs          = length(subIDs);

fLevelName     = 'ppi_brain_tc_PAG-FIRinv_3mm_050_c7';   
sLevelName     = ['ttest_' fLevelName '_covVAS']; 

conNumber = 1;

T = readtable('behav.txt',Delimiter=',');
Tclean = T(~ismember(T.SbId,exclude),:);
cpm = Tclean.mVASInCondition0-Tclean.mVASInCondition1; %    

outDir = fullfile(path.sLevelDir,sLevelName);
if exist(outDir,'dir')
    warning('Folder already exists');
    s = input('Do you really want to overwrite this folder??','s');
    if isempty(s) || strcmp(s,'y')
        rmdir(outDir,'s');
        mkdir(outDir);
    else
        warning('Analysis aborted...');
        return;
    end
end

allCons = [];

for sub = 1:nSubs
    subDir = fullfile(sprintf(strrep(path.fLevelDir,'\','\\'),subIDs(sub)),fLevelName);
    conFile = spm_select('FPList',subDir,sprintf('^s6con_%04d.nii',conNumber));
    allCons = [allCons; conFile];  
end

nCons = size(allCons,1)/nSubs;
disp(nCons);

brainMask = fullfile(baseDir,'mean_mask_sLevel.nii');

matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(allCons);
matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(outDir);
matlabbatch{1}.spm.stats.factorial_design.cov.c = cpm;
matlabbatch{1}.spm.stats.factorial_design.cov.cname = 'cpm';
matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {brainMask};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

matlabbatch{2}.spm.stats.fmri_est.spmmat           = {fullfile(outDir,'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{3}.spm.stats.con.spmmat = {fullfile(outDir,'SPM.mat')};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = sLevelName;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ['-' sLevelName];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'cov';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 1];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = '-cov';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 -1];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

spm_jobman('run', matlabbatch);
clear matlabbatch

