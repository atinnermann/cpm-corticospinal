function create_multicond

addpath('..\global');

subIDs = [1:49]; %1:49

exclude = [3 14 19 28 35 36 41 ];
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

    for run = 1:nRuns

        logFile  = fullfile(subDir,sprintf('sub%03d_VAS_rating_block%d_phasicstim.mat',subIDs(sub),run));
        load(logFile,'VAS');

        onsTonic = []; onsPhasicP = []; onsVAS = []; onsPhasicR = []; durPhasicR = []; vasRT = [];

        for block = 1:vars.nBlocks
            runStart = (P.mri.mriRunStartTime(run+1)-P.time.scriptStart)+TR;

            %onsets tonic
            if subIDs(sub) == 5 && run == 3 && block == 2
                onsTonic = [onsTonic (onsTonic+onsVAS(end)+scaleDur+5+P.presentation.CPM.tonicStim.totalITI)];
            else
                onsTonic = [onsTonic P.time.tonicStimStart(run,block)-runStart];
            end
            
            %onsets phasic planned
            a = P.pain.CPM.phasicStim.onsets(run,block,:,:) + onsTonic(block);
            onsPhasicP = [onsPhasicP sort(a(:))'];
 
            %onsets VAS
            if subIDs(sub) == 5 && run == 3 && block == 2
                onsVAS = [onsVAS onsPhasicP(10:15)+6];
            else
                onsVAS = [onsVAS permute(P.time.phasicStimVASStart(run,block,:)-runStart,[1 3 2])];
            end

            clear dataPhasic
        end

       
        tmp = [VAS.phasicStim];
        tmp2 = [tmp.reactionTime];
        vasRT = [tmp2(1:2:end) tmp2(2:2:end)];

        names       = {'Phasic','Rating','Scale','Tonic'};
        onsets      = [{onsPhasicP+shift},{onsVAS},{onsVAS+vasRT},{onsTonic}];
        durations   = [{phasicDur},{vasRT},{scaleDur-vasRT},{tonicDur}]; %durPhasicR 

        %save one file per session
        outName = sprintf('sub%02d_multicond_onsP_run%d', subIDs(sub),run);
        outDir = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'analyses','onset');
        if ~exist(outDir,'dir')
            mkdir(outDir)
        end
        save(fullfile(outDir,outName),'names','onsets','durations');
        clear t names onsets durations
    end
   
end


