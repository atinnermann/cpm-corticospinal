function create_outlier_tsda_spinal(subIDs)

% resolve paths
[path,vars,qc] = get_study_specs;
baseDir        = path.mriDir;
nSubs          = length(subIDs);
nRuns          = vars.nRuns;
nScans         = vars.nScans;

addpath('C:\Users\tinnermann\Documents\MATLAB\spm12\toolbox\tsdiffana');

for sub = 1:nSubs
    subDir    = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)));
    physioDir = fullfile(path.physioDir,sprintf('sub%02d',subIDs(sub)),'noise_reg');
    fprintf('Processing Sub%02.0f\n',subIDs(sub));
    for run = 1:nRuns
        runDir  = fullfile(subDir,sprintf('run%d',run),'spinal');
        fprintf('Run%d\n',run);
        workFiles = spm_select('ExtFPList',runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'suffix','_moco'),Inf);
        [imdiff,globals] = timediff(workFiles,0);

        vvar = imdiff/mean(globals);
        m = mean(vvar); s = std(vvar);
        nOutliers = find(vvar>m+s*qc.thresh);
        fprintf('Sub%02.0f, Run%d: %d outlier volumes detected\n',subIDs(sub),run,numel(nOutliers));
        % if saveReg == 1
            badvols = zeros(nScans,length(nOutliers));
            for out = 1:length(nOutliers)
                badvols(nOutliers(out),out) = 1;
            end
            outFilename = sprintf(vars.spNoiseFile,subIDs(sub),'badvols',run);
            save(fullfile(physioDir,outFilename),'badvols');
        % end
    end
end
