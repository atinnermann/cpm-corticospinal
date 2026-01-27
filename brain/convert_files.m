function convert_files(subIDs,delFiles)

nSubs        = length(subIDs);
[path, vars] = get_study_specs;
baseDir      = path.baseDir;
nRuns        = vars.nRuns;
nScans       = vars.nScans;


for sub = 1:nSubs
    subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
    fprintf('Sub%02d\n',subIDs(sub));
    for run = 1:nRuns
        runDir  = fullfile(subDir,sprintf('run%d',run),'brain');
        files   = spm_select('FPList',runDir,'fPRISMA.*.nii');
        fprintf('Run%d\n',run);

        %check number of images
        if (size(files,1)) ~= nScans
            disp('Wrong number of images! Doing nothing here\n');
            break
        end

        writematrix(files,fullfile(runDir,'file_names.txt'));

        newName = fullfile(runDir,sprintf(vars.rawEpiID,subIDs(sub),run));

        matlabbatch{run,sub}.spm.util.cat.vols = cellstr(files);
        matlabbatch{run,sub}.spm.util.cat.name = newName;
        matlabbatch{run,sub}.spm.util.cat.dtype = 4;
        matlabbatch{run,sub}.spm.util.cat.RT = NaN;
    end

end

run_spm_batch(matlabbatch,nSubs);

if delFiles == 1
    for sub = 1:nSubs
        for run = 1:nRuns
            subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
            runDir  = fullfile(subDir,sprintf('run%d',run),'brain');
            files   = spm_select('FPList',runDir,'fPRISMA.*.nii');

            for f = 1:size(files,1)
                delete(files(f,:));
            end
        end
    end
end

end