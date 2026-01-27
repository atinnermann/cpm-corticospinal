

matlabbatch{1}.spm.util.imcalc.input = {
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\spinal\spinal_level_06_resized.nii,1'                                       
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'spinal_level_06_resized_cut015';
matlabbatch{1}.spm.util.imcalc.outdir = {'C:\Users\tinnermann\Documents\data\cpm\mri\masks\spinal'};
matlabbatch{1}.spm.util.imcalc.expression = '(i1)>0.015';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch);
clear matlabbatch

matlabbatch{1}.spm.util.imcalc.input = {
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\spinal\spinal_level_06_resized_cut015.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\spinal\gm_masks\mean_epi_template_spinal_gmseg_dhr.nii,1'                                        
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'dorsal_horn_c6_right';
matlabbatch{1}.spm.util.imcalc.outdir = {'C:\Users\tinnermann\Documents\data\cpm\mri\masks\spinal'};
matlabbatch{1}.spm.util.imcalc.expression = 'i1.*i2';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch);
clear matlabbatch

