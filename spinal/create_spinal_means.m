function create_spinal_means

% function create_means(all_sub_ids)

addpath('..\global');
addpath('..\utils');

subIDs      = [1:49]; %8:98 
exclude     = [3 14 19 28 35 36 41 7 25 ];
subIDs      = subIDs(~ismember(subIDs,exclude));

% resolve paths
nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;

if nSubs < 2
    error('need at least 2 images to create means')
end

stripFiles = [];
meanFiles  = [];

for sub = 1:nSubs
 
    anatDir     = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)),'anat2');
    anatFile    = fullfile(anatDir,spm_file(sprintf(vars.T2imgID,subIDs(sub)),'suffix','_2temp_crop1'));

    funcDir     = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)),'run1','spinal');
    meanFile    = fullfile(funcDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix','_2temp_clean'));
    % 
    stripFiles  = [stripFiles; anatFile];
    meanFiles   = [meanFiles; meanFile];
    
end
matlabbatch{1}.spm.util.imcalc.input = cellstr(stripFiles);
matlabbatch{1}.spm.util.imcalc.output = 'mean_t2_template_new';
matlabbatch{1}.spm.util.imcalc.outdir = cellstr(baseDir);
matlabbatch{1}.spm.util.imcalc.expression = 'mean(X)';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

matlabbatch{2} = matlabbatch{1};
matlabbatch{2}.spm.util.imcalc.input = cellstr(meanFiles);
matlabbatch{2}.spm.util.imcalc.output = 'mean_epi_template_spinal';
matlabbatch{2}.spm.util.imcalc.expression = 'mean(X)';


% matlabbatch{3} = matlabbatch{1};
% matlabbatch{3}.spm.util.imcalc.input = all_wskull_files;
% matlabbatch{3}.spm.util.imcalc.output = 'var_wskull';
% matlabbatch{3}.spm.util.imcalc.expression = 'var(X)';
% 
% matlabbatch{4} = matlabbatch{1};
% matlabbatch{4}.spm.util.imcalc.input = all_wmean_files;
% matlabbatch{4}.spm.util.imcalc.output = 'var_wmean';
% matlabbatch{4}.spm.util.imcalc.expression = 'var(X)';

spm_jobman('run',matlabbatch);

end