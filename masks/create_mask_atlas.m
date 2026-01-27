

regions = [59 60 138 139 102 103 172 173 112 113 118 119 174 175 176 177];
for r = 1:size(regions,2)

matlabbatch{1}.spm.util.imcalc.input = {                                      
                                        'C:\Users\tinnermann\Documents\MATLAB\spm12\atlas\MNI_Asym_neuromorphometrics.nii,1'                                        
                                        };
matlabbatch{1}.spm.util.imcalc.output = sprintf('nmorph_mask_%d',regions(r));
matlabbatch{1}.spm.util.imcalc.outdir = {'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas'};
matlabbatch{1}.spm.util.imcalc.expression = sprintf('i1==%d',regions(r));
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch);
clear matlabbatch
end

for r = 1:size(regions,2)

matlabbatch{1}.spm.util.imcalc.input = {                                      
                                        'C:\Users\tinnermann\Documents\MATLAB\spm12\atlas\MNI_Asym_neuromorphometrics.nii,1'                                        
                                        };
end
matlabbatch{1}.spm.util.imcalc.output = sprintf('nmorph_mask_%d',regions(r));
matlabbatch{1}.spm.util.imcalc.outdir = {'C:\Users\tinnermann\Documents\data\cpm\mri\masks\atlas'};
matlabbatch{1}.spm.util.imcalc.expression = sprintf('i1==%d',regions(r));
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch);
clear matlabbatch

