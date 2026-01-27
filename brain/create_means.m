function create_means(subIDs)

% function create_means(all_sub_ids)
% creates mean skullstrip and mean epi


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
 
    anatDir     = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)),'anat1');
    anatFile    = fullfile(anatDir,spm_file(sprintf(vars.T1stripID,subIDs(sub)),'prefix','w'));

    funcDir     = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)),'run1','brain');
    meanFile    = fullfile(funcDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','w'));
    
    stripFiles  = [stripFiles; anatFile];
    meanFiles   = [meanFiles; meanFile];
    
end
matlabbatch{1}.spm.util.imcalc.input = cellstr(stripFiles);
matlabbatch{1}.spm.util.imcalc.output = 'mean_t1_template';
matlabbatch{1}.spm.util.imcalc.outdir = cellstr(path.baseDir);
matlabbatch{1}.spm.util.imcalc.expression = 'mean(X)';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

matlabbatch{2} = matlabbatch{1};
matlabbatch{2}.spm.util.imcalc.input = cellstr(meanFiles);
matlabbatch{2}.spm.util.imcalc.output = 'mean_epi_template';
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