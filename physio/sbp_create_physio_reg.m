function sbp_create_physio_reg(subIDs)
%Create and Save Physio Regressors

if nargin < 2
    debug = 0;
end

[path,vars]    = get_study_specs;
physioDir      = path.physioDir;
nSubs          = length(subIDs);
nSess          = vars.nSess;
nRuns          = vars.nRuns;
TR             = vars.repTime;

for sub = 1:nSubs
    subDir = fullfile(physioDir,sprintf('sub%02d',subIDs(sub)),'physio');
    for ses = 1:nSess
        fprintf('\nCreating physio regressors for sub%02d\n',subIDs(sub));
        for run = 1:nRuns
            fprintf('Run%d ...\n', run);
            funcDir = fullfile(path.mriDir,sprintf('sub%02d/run%d',subIDs(sub),run),'spinal');
            nScans = length(spm_select('ExtFPList',funcDir,sprintf(vars.spRawEpiID,subIDs(sub),run),Inf));

            % Get tsv data
            fileName = fullfile(subDir,sprintf('sub%02d_physio_run%d',subIDs(sub),run));
            try
                tsv = spm_load([fileName '.tsv.gz']);
            catch
                fprintf('No tsv physio file found for sub%02d. Skipping ...\n',subIDs(sub),ses);
                continue;
            end

            %% Get sample rate from json header
            fid  = fopen(spm_file(fileName,'ext','json'));
            raw  = fread(fid,inf); % Reading the contents
            str  = char(raw');
            info = jsondecode(str);
            samp_int = 1/info.SamplingFrequency;
            fclose(fid); % closing the file

            [physio,beats,breaths] = get_physio(tsv,samp_int);

            if size(physio,1) ~= nScans
                warning('Physio regressors do not have the same length as number of scans! Please check why before continuing');
                return
            end

            %% save physio regs
            physioFile = fullfile(physioDir,sprintf('sub%02d',subIDs(sub)),'noise_reg',sprintf(vars.phyFile,subIDs(sub),run)); % Name of the physio regressor output file
            save(physioFile,'physio');
            fprintf('finished and saved!\n');

            %save beats/breaths per minute for all subs for later quality control
            bpm.cardiac(sub,nRuns*(ses-1)+run) = round(beats/(size(physio,1)*TR)*60);
            bpm.resp(sub,nRuns*(ses-1)+run) = round(breaths/(size(physio,1)*TR)*60);
        end
    end
end
save(fullfile(physioDir,'physio_bpm_all.mat'),'bpm');
end
