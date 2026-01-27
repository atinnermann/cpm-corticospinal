function create_multicond_cc_sp

addpath('..\global');

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

    onsPw = []; onsPp = []; onsTw = []; onsTp = []; onsVAS = []; vasRT =[];
    sumScans = 0;

    for run = 1:nRuns

        logFile  = fullfile(subDir,sprintf('sub%03d_VAS_rating_block%d_phasicstim.mat',subIDs(sub),run));
        load(logFile,'VAS');

        %get run conditions
        o  = load(fullfile(subDir,sprintf('sub%03d-run%d-onsets.mat',subIDs(sub),run+1)));

        onsT = []; onsVASb = []; onsP = [];

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
            onsP = [onsP sort(a(:))'];

            %onsets VAS
            if subIDs(sub) == 5 && run == 3 && block == 2
                onsVASb = [onsVASb onsP(10:15)+6];
            else
                onsVASb = [onsVASb permute(P.time.phasicStimVASStart(run,block,:)-runStart,[1 3 2])];
            end
        end

        if o.conditions(1) == 0
            onsPw = [onsPw onsP+sumScans];
            onsTw = [onsTw onsT+sumScans];
        elseif o.conditions(1) == 1
            onsPp = [onsPp onsP+sumScans];
            onsTp = [onsTp onsT+sumScans];
        end

        onsVAS = [onsVAS onsVASb+sumScans];
        tmp = [VAS.phasicStim];
        tmp2 = [tmp.reactionTime];
        vasRT = [vasRT ([tmp2(1:2:end) tmp2(2:2:end)])];

        prRun = ceil((onsT(end)+tonicDur+vars.prDur)/TR)*TR;
        sumScans = sumScans + prRun;

    end
    names       = {'PhasicP','PhasicC','Rating','TonicP','TonicC'};
    onsets      = [{onsPp+shift},{onsPw+shift},{onsVAS},{onsTp},{onsTw}];
    durations   = [{phasicDur},{phasicDur},{vasRT},{tonicDur},{tonicDur}];

    %save one file per session
    outName = sprintf('sub%02d_multicond_onsP_cc_sp', subIDs(sub));
    outDir = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'analyses','onset');
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
    save(fullfile(outDir,outName),'names','onsets','durations');

end


