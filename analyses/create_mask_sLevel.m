function create_mask_sLevel

% function create_means(all_sub_ids)
% creates mean skullstrip and mean epi
subIDs      = [1:49]; %
exclude     = [3 7 14 19 28 35 36 41 40 ];
subIDs      = subIDs(~ismember(subIDs,exclude));

% resolve paths
nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;

if nSubs < 2
    error('need at least 2 images to create means')
end

maskFiles  = [];
fLevelName = 'first_level_brain_hrf';

for sub = 1:nSubs 
    subDir     =  fullfile(sprintf(strrep(path.fLevelDir,'\','\\'),subIDs(sub)),fLevelName);
    maskFile    = fullfile(subDir,'mask.nii'); 
    maskFiles   = [maskFiles; maskFile];
    
end


matlabbatch{1}.spm.util.imcalc.input = cellstr(maskFiles);
matlabbatch{1}.spm.util.imcalc.output = 'mean_mask_sLevel';
matlabbatch{1}.spm.util.imcalc.outdir = cellstr(baseDir);
matlabbatch{1}.spm.util.imcalc.expression = 'all(X)';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;


spm_jobman('run',matlabbatch);

end