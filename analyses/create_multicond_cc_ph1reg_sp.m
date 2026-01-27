function create_multicond

addpath('..\global');
addpath('..\utils');

subIDs = [1:49]; %1:49

exclude = [3 14 19 28 35 36 41];
subIDs = subIDs(~ismember(subIDs,exclude));

[path,vars]    = get_study_specs;
baseDir        = path.mriDir;
logDir         = path.logDir;
nSubs          = length(subIDs);
nRuns          = vars.nRuns;
TR             = vars.repTime;

shift  = 0;

for sub = 1:nSubs
    subDir    = fullfile(logDir,sprintf('sub%03d',subIDs(sub)),'pain');
    fprintf('sub%02d\n',subIDs(sub));

    load(fullfile(subDir,sprintf('parameters_sub%03d.mat',subIDs(sub))),'P');

    phasicDur = P.pain.CPM.phasicStim.duration;
    tonicDur = P.pain.CPM.tonicStim.totalDuration;
    scaleDur  = P.presentation.CPM.phasicStim.durationVAS;

    onsP = []; onsTw = []; onsTp = []; onsVAS = []; vasRT =[];
    sumScans = 0;

    for run = 1:nRuns

        logFile  = fullfile(subDir,sprintf('sub%03d_VAS_rating_block%d_phasicstim.mat',subIDs(sub),run));
        load(logFile,'VAS');

        %get run conditions
        o  = load(fullfile(subDir,sprintf('sub%03d-run%d-onsets.mat',subIDs(sub),run+1)));

        onsT = []; onsVASb = []; onsPb = [];

        for block = 1:vars.nBlocks
            runStart = (P.mri.mriRunStartTime(run+1)-P.time.scriptStart)+TR;

            %onsets tonic
            if subIDs(sub) == 5 && run == 3 && block == 2
                onsT = [onsT (onsT+onsVASb(end)+scaleDur+5+P.presentation.CPM.tonicStim.totalITI)];
            else
                onsT = [onsT P.time.tonicStimStart(run,block)-runStart];
            end

            %onsets phasic planned
            a = P.pain.CPM.phasicStim.onsets(run,block,:,:) + onsT(block);
            onsPb = [onsPb sort(a(:))'];

            %onsets VAS
            if subIDs(sub) == 5 && run == 3 && block == 2
                oVAS = onsPb(10:15)+6;
            else
                oVAS = permute(P.time.phasicStimVASStart(run,block,:)-runStart,[1 3 2]);
            end
            onsVASb = [onsVASb oVAS];
        end

        onsP = [onsP onsPb+sumScans];

        if o.conditions(1) == 0
            onsTw = [onsTw onsT+sumScans];
        elseif o.conditions(1) == 1
            onsTp = [onsTp onsT+sumScans];
        end

        onsVAS = [onsVAS onsVASb+sumScans];
        tmp = [VAS.phasicStim];
        tmp2 = [tmp.reactionTime];
        vasRT = [vasRT ([tmp2(1:2:end) tmp2(2:2:end)])];

        prRun = ceil((onsT(end)+tonicDur+vars.prDur)/TR)*TR;
        sumScans = sumScans + prRun;
    end

    names       = {'Phasic','Rating','TonicP','TonicC'};
    onsets      = [{onsP+shift},{onsVAS},{onsTp},{onsTw}];
    durations   = [{phasicDur},{vasRT},{tonicDur},{tonicDur}];
    

    %save one file per session
    outName = sprintf('sub%02d_multicond_onsP_cc_ph1reg_sp', subIDs(sub));
    outDir = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'analyses','onset');
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
    save(fullfile(outDir,outName),'names','onsets','durations');

end


