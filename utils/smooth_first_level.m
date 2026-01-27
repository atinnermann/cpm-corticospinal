function smooth_first_level(subIDs,fLevelName,imgStr)

nSubs        = length(subIDs);
[path,vars]  = get_study_specs;

if contains(fLevelName,'brain')
   sKernel = vars.smKern;
elseif contains(fLevelName,'spinal')
    sKernel = vars.smKernSp;
end
if length(sKernel) == 1
    sKernel    = repmat(sKernel,1,3);
end

for sub = 1:nSubs
    name = sprintf('sub%02d',subIDs(sub));

    disp([name ' ' fLevelName]);
    subDir = fullfile(sprintf(strrep(path.fLevelDir,'\','\\'),subIDs(sub)),fLevelName);

    if isempty(imgStr)
        smFiles  = spm_select('FPList',subDir,'^con_.*.nii');
        smFiles2 = spm_select('FPList',subDir,'^ess_.*.nii');
        if ~isempty(smFiles2)
            smFiles = {cellstr(smFiles),cellstr(smFiles2)};
        end
    elseif strcmp(imgStr,'all')
        smFiles1 = spm_select('FPList',subDir,'^con_.*.nii');
        smFiles2 = spm_select('FPList',subDir,'^beta_.*.nii');
        smFiles3 = spm_select('FPList',subDir,'^spmT_.*.nii');
        smFiles  = {cellstr(smFiles1),cellstr(smFiles2),cellstr(smFiles3)};
    else
        smFiles = spm_select('FPList',subDir,sprintf('^%s_.*.nii',imgStr));
    end

    if isempty(smFiles)
        error('no files for smoothing found');
    end

    matlabbatch{1,sub}.spm.spatial.smooth.data = cellstr(smFiles);
    matlabbatch{1,sub}.spm.spatial.smooth.fwhm = sKernel;
    matlabbatch{1,sub}.spm.spatial.smooth.prefix = ['s' num2str(sKernel(1))];

end

run_spm_batch(matlabbatch,nSubs);

end



