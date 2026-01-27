function create_motion_outlier_spinal(subIDs)

[path,vars,qc] = get_study_specs;
baseDir        = path.baseDir;
nSubs          = length(subIDs);
nRuns          = vars.nRuns;

% find spike movement and create noise regressors for first level
for sub = 1:nSubs
    subDir   = fullfile(baseDir,sprintf('sub%02.2d',subIDs(sub)));
    noiseDir = fullfile(subDir,'noise');
    for run = 1:nRuns
        runDir  = fullfile(subDir,sprintf('run%d',run),'brain');
        rpFile  = fullfile(runDir,spm_file(sprintf(vars.rawEpiID,subIDs(sub),run),'prefix','rp_','ext','txt'));
        mParams = load(rpFile);
        diffParams = abs(diff(mParams(:,1:3)));
        [nSpikes,c] = find(diffParams>qc.threshSpike);
        nSpikes = unique(nSpikes);
        disp(nSpikes);
        if numel(nSpikes) ~= 0
            if numel(nSpikes) > floor(size(mParams,1)*qc.percSpike)
                fprintf('Sub%0d Run%d: spike movement in more than %.1f%% of volumes detected, please check participant\n',subIDs(sub),run,qc.percSpike*100);
            end
            fprintf('Sub%02d, Run%d: %d spikes detected\n',subIDs(sub),run,numel(nSpikes));
            badvols = zeros(size(mParams,1),numel(nSpikes));
            for m = 1:length(nSpikes)
                badvols(nSpikes(m)+1,m) = 1;
            end
            fprintf('Saving noise regressors for respective images\n');
            outFilename = sprintf(qc.movFilename,subIDs(sub),run);
            save(fullfile(noiseDir,outFilename),'badvols');
        end
    end
end