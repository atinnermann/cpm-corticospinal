function run_vasa(subIDs,fLevelName)

nSubs        = length(subIDs);
path         = get_study_specs;


for sub = 1:nSubs
    subDir = fullfile(sprintf(strrep(path.fLevelDir,'\','\\'),subIDs(sub)),fLevelName);

    gi = 1;
    matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{1}.string = fullfile(subDir,'SPM.mat');
    matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.outputs = {};
    matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.fun = 'calc_vasa_img';
    gi = gi + 1;

    conFiles = spm_select('FPList',subDir,'^con*'); 
    vasaFile = fullfile(subDir,'vasa_res.nii');

    for co = 1:size(conFiles,1)
        cFile = strtrim(conFiles(co,:));
        matlabbatch{gi,sub}.spm.util.imcalc.input  = {cFile,vasaFile}';
        matlabbatch{gi,sub}.spm.util.imcalc.output = spm_file(cFile,'prefix','v');
        matlabbatch{gi,sub}.spm.util.imcalc.outdir = {''};
        matlabbatch{gi,sub}.spm.util.imcalc.expression = 'i1./i2'; % simply scale by vasa image
        matlabbatch{gi,sub}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{gi,sub}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{gi,sub}.spm.util.imcalc.options.mask = 0;
        matlabbatch{gi,sub}.spm.util.imcalc.options.interp = 1;
        matlabbatch{gi,sub}.spm.util.imcalc.options.dtype = 16;
        gi = gi + 1;
    end
end

run_spm_batch(matlabbatch,nSubs);

end



