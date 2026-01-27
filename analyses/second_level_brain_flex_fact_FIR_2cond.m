function second_level_brain_flex_fact_FIR_2cond

addpath('..\global');

subIDs = [1:49]; %1:49

exclude = [3 7 14 19 28 35 36 41];
subIDs = subIDs(~ismember(subIDs,exclude));

path           = get_study_specs;
baseDir        = path.mriDir;
nSubs          = length(subIDs);

nBins          = 10;
nCond          = 2;
fLevelName     = 'first_level_brain_fir_2cond';  
sLevelName     = 'flex_fact_brain_FIR_2cond'; 

mask = fullfile(baseDir,'mean_mask_sLevel.nii');

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
    conFile = spm_select('FPList',subDir,'^s6con.*.nii');
     allCons = [allCons; conFile];
     
end
nCons = size(allCons,1)/nSubs;
disp(nCons);


a = ones(nBins,1);
b = [1:10]';
c = ones(nBins*nCond*nSubs,1);
subj = repelem(1:nSubs,nBins*nCond)';
bin = repmat(b,nSubs*nCond,1);
cond = repmat([a;a*2],nSubs,1);
mat = [c subj cond bin];
matlabbatch{1}.spm.stats.factorial_design.dir = {outDir};
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'subj';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'cond';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = 'bin';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;
%%
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.scans = cellstr(allCons);
%%
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix = mat;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = [2 3];                                                                                 
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {mask};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;

matlabbatch{2}.spm.stats.fmri_est.spmmat           = {[outDir filesep 'SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{3}.spm.stats.con.spmmat = {[outDir filesep 'SPM.mat']};

matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'eoi';
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [zeros(nBins*nCond,nSubs) eye(nBins*nCond)-1/(nBins*nCond)];
matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'diff';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [zeros(1,nSubs) 0 0 0 -1 -1 -1 -1 0 0 0 0 0 0 1 1 1 1 0 0 0];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'diff_inv';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [zeros(1,nSubs) 0 0 0 1 1 1 1 0 0 0 0 0 0 -1 -1 -1 -1 0 0 0];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

spm_jobman('run', matlabbatch);
clear matlabbatch











