

gi = 1;
load('C:\Users\tinnermann\Documents\data\cpm\mri\masks\brainstem\cPAG_2mm_mask_final_reorient.mat','M');
matlabbatch{gi}.spm.util.reorient.srcfiles = {'C:\Users\tinnermann\Documents\data\cpm\mri\masks\brainstem\cPAG_2mm_mask_final.nii,1'};
matlabbatch{gi}.spm.util.reorient.transform.transM = M;
matlabbatch{gi}.spm.util.reorient.prefix = 'r';

gi = gi + 1;
load('C:\Users\tinnermann\Documents\data\cpm\mri\masks\brainstem\RVMmask_reorient.mat','M');
matlabbatch{gi}.spm.util.reorient.srcfiles = {'C:\Users\tinnermann\Documents\data\cpm\mri\masks\brainstem\RVMmask_symm_2mm.nii,1'};
matlabbatch{gi}.spm.util.reorient.transform.transM = M;
matlabbatch{gi}.spm.util.reorient.prefix = 'r';

gi = gi + 1;
matlabbatch{gi}.spm.spatial.smooth.data = {'rRVMmask_symm_2mm.nii'};
matlabbatch{gi}.spm.spatial.smooth.fwhm = [1 1 1];
matlabbatch{gi}.spm.spatial.smooth.dtype = 0;
matlabbatch{gi}.spm.spatial.smooth.im = 0;
matlabbatch{gi}.spm.spatial.smooth.prefix = 's1';

gi = gi + 1;
matlabbatch{gi}.spm.util.imcalc.input = {
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\brainstem\rcPAG_2mm_mask_final.nii,1'
                                        'C:\Users\tinnermann\Documents\data\cpm\mri\masks\brainstem\s1rRVMmask.nii,1'
                                        'C:\Users\tinnermann\Documents\atlas\prefrontal_vega\pgACC.nii,1'
                                        'C:\Users\tinnermann\Documents\atlas\prefrontal_vega\vmPFC.nii,1'
                                        };
matlabbatch{gi}.spm.util.imcalc.output = 'descending_mask_final';
matlabbatch{gi}.spm.util.imcalc.outdir = {'C:\Users\tinnermann\Documents\data\cpm\mri\masks'};
matlabbatch{gi}.spm.util.imcalc.expression = 'i1+i2+i3+i4';
matlabbatch{gi}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{gi}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{gi}.spm.util.imcalc.options.mask = 0;
matlabbatch{gi}.spm.util.imcalc.options.interp = 1;
matlabbatch{gi}.spm.util.imcalc.options.dtype = 4;

spm_jobman('run', matlabbatch);
clear matlabbatch
