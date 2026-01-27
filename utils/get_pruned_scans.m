function prunedScans = get_pruned_scans(sub,run,dur)


[path,vars]    = get_study_specs;
logDir         = path.logDir;
TR             = vars.repTime;


subDir    = fullfile(logDir,sprintf('sub%03d',sub),'pain');

load(fullfile(subDir,sprintf('parameters_sub%03d.mat',sub)),'P');

tonicDur = P.pain.CPM.tonicStim.totalDuration;

runStart = (P.mri.mriRunStartTime(run+1)-P.time.scriptStart)+TR;

%onsets tonic
onsTonic = P.time.tonicStimStart(run,2)-runStart;

% a = ceil((P.mri.mriRunEndTime(run+1)-P.mri.mriRunStartTime(run+1)-P.mri.timeExtraVolumes-P.presentation.CPM.blockBetweenText)/TR);
prunedScans = ceil((onsTonic+tonicDur+dur)/TR);
