

%%
matlabbatch{1}.spm.util.imcalc.input = {
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_102.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_103.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_112.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_113.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_118.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_119.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_138.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_139.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_172.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_173.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_174.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_175.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_177.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_59.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas\nmorph_mask_60.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\brainstem\s1rRVMmask.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\brainstem\rcPAG_2mm_mask_final.nii,1'
                                        };
%%
matlabbatch{1}.spm.util.imcalc.output =  'pain_mask_atlas.nii,1';
matlabbatch{1}.spm.util.imcalc.outdir = {'C:\Users\tinnermann\Documents\data\cpm\mri\masks\'};
matlabbatch{1}.spm.util.imcalc.expression = 'sum(X)';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

spm_jobman('run', matlabbatch);
clear matlabbatch

matlabbatch{1}.spm.util.imcalc.input = {
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\mean_mask_sLevel.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\pain_mask_atlas.nii,1'
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'pain_mask_atlas_cut';
matlabbatch{1}.spm.util.imcalc.outdir = {'C:\Users\tinnermann\Documents\data\cpm\mri\masks\'};
matlabbatch{1}.spm.util.imcalc.expression = 'i1.*(i2)';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;


spm_jobman('run', matlabbatch);
clear matlabbatch
