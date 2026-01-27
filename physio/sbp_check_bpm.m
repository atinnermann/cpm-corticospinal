function sbp_check_bpm(subIDs)
%Create and Save Physio Regressors

[path,vars]    = get_study_specs;
physioDir      = path.physioDir;
nSubs          = length(subIDs);
nSess          = vars.nSess;
nRuns          = vars.nRuns;


load(fullfile(physioDir,'physio_bpm_all.mat'),'bpm');
disp('Checking plausibility of heart and respiration rate....');
for sub = 1:nSubs
    subDir = fullfile(physioDir,sprintf('sub%02d',subIDs(sub)),'physio');
    for ses = 1:nSess
        for run = 1:nRuns
            fileName = fullfile(subDir,sprintf('sub%02d_physio_run%d.tsv.gz',subIDs(sub),run));

            if bpm.cardiac(sub,run) < 50 || bpm.cardiac(sub,run) > 90
                fprintf('Sub%02d run%d: heart rate of %1.0f outside normal range, please check physio data\n',subIDs(sub),run,bpm.cardiac(sub,run));
                %load data
                tsv = spm_load(fileName);
                puls = spm_conv(spm_detrend(tsv(:,1)),5);

                %plot data
                peak_LMS(puls,500,1);
            end

            if bpm.resp(sub,run) < 12 || bpm.resp(sub,run) > 22
                fprintf('Sub%02d run%d: respiration rate of %1.0f outside normal range, please check physio data\n',subIDs(sub),run,bpm.resp(sub,run));
                tsv = spm_load(fileName);
                resp = spm_conv(spm_detrend(tsv(:,2)),50);
                resp    = -(resp - spm_conv(resp,10./0.01));
                peak_LMS(resp,100,1);
            end
        end
    end
end
end
