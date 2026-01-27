function first_level_spinal_FIR_2cond

addpath('..\global');
addpath('..\utils');

subIDs = [1:49]; %1:49

exclude = [3 7 14 19 28 35 36 41 25];
subIDs = subIDs(~ismember(subIDs,exclude));

[path,vars]    = get_study_specs;
baseDir        = path.mriDir;
fLevelDir      = path.fLevelDir;
nSubs          = length(subIDs);
nRuns          = vars.nRuns;
TR             = vars.repTime;

nBins          = 10;
shift          = 2;

fLevelName     = 'first_level_spinal_fir_2cond';
onsName        = 'onsP';
model          = 1;
vasa           = 0;
smooth         = 1;

if model == 1
    mask           = fullfile(baseDir,'mean_t2_template_seg.nii');
    for sub = 1:nSubs
        subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
        outDir      = fullfile(sprintf(strrep(fLevelDir,'\','\\'),subIDs(sub)),fLevelName);

        logDir      = fullfile(path.logDir,sprintf('sub%03d',subIDs(sub)),'pain');
        onsDir      = fullfile(sprintf(strrep(path.fLevelDir,'\','\\'),subIDs(sub)),'onset');
        physioDir   = fullfile(path.physioDir,sprintf('sub%02d',subIDs(sub)),'noise_reg');

        if exist(outDir,'dir')
            rmdir(outDir,'s');
        end
        mkdir(outDir);
        copyfile(which(mfilename),outDir);

        if isempty(mask)
            warning('No mask found');
        end

        noiseReg    = cell(1,nRuns);
        noiseCon    = cell(1,nRuns);
        cond        = nan(1,nRuns);

        gi = 1;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.units   = 'scans';
        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.RT      = TR;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.fmri_t  = 16;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

        matlabbatch{gi,sub}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});

        matlabbatch{gi,sub}.spm.stats.fmri_spec.bases.fir.length = nBins*TR;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.bases.fir.order  = nBins;

        matlabbatch{gi,sub}.spm.stats.fmri_spec.volt             = 1;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.global           = 'None';
        matlabbatch{gi,sub}.spm.stats.fmri_spec.cvi              = 'none';

        for run = 1:nRuns
            runDir = fullfile(subDir,sprintf('run%d',run),'spinal');

            % select scans
            if subIDs(sub) == 5 && run == 3
                prScans = 216;
            else
                prScans = get_pruned_scans(subIDs(sub),run,vars.prDur);
            end
            epiFiles = spm_select('ExtFPList',runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'suffix','_2temp'),1:prScans);
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).scans = cellstr(epiFiles);
            
            % select multicond files
            load(fullfile(onsDir,sprintf('sub%02d_multicond_%s_run%d.mat', subIDs(sub),onsName,run)),'onsets');

            %get run conditions
            o  = load(fullfile(logDir,sprintf('sub%03d-run%d-onsets.mat',subIDs(sub),run+1)));
            cond(run) = o.conditions(1);

            % select brain movement regressors
            n.movB = struct2array(load(fullfile(physioDir,sprintf(vars.noiseFile,subIDs(sub),'motion',run))));

            % select spinal movement regressors
            t = load(fullfile(runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'prefix','rp_','ext','mat')));
            n.mov = permute(mean(t.Q,2),[1 3 2])';

            % select physio regressors
            try
                n.physio = struct2array(load(fullfile(physioDir,sprintf(vars.phyFile,subIDs(sub),run))));
            catch
                n.physio = [];
            end

            % select csf regressor
            n.csf = cell2mat(struct2array(load(fullfile(physioDir,sprintf(vars.spNoiseFile,subIDs(sub),'csf_var95',run)))));

            % select csf regressor
            n.wm = cell2mat(struct2array(load(fullfile(physioDir,sprintf(vars.spNoiseFile,subIDs(sub),'wm50',run)))));

            %exclude bad volumes
            try
                n.bv = struct2array(load(fullfile(physioDir,sprintf(vars.spNoiseFile,subIDs(sub),'badvols',run))));
            catch
                n.bv = [];
            end

            tmp   = [n.mov n.movB n.physio n.csf  n.bv]; % n.wm
            noiseReg{run}   = tmp(1:prScans,:);
            noiseCon{run}   = zeros(1,size(noiseReg{run},2));

            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).cond(1).name     = 'Phasic';
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).cond(1).onset    = onsets{1}/TR-shift;
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).cond(1).duration = 0;

            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).multi = {''};
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).multi_reg = {''};
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).hpf = 240;

            for n = 1:size(noiseReg{run},2)
                matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).regress(n) = struct('name',cellstr(num2str(n)),'val',noiseReg{run}(:,n));
            end

            clear n wmcsf
        end

        matlabbatch{gi,sub}.spm.stats.fmri_spec.dir             = {outDir};
        matlabbatch{gi,sub}.spm.stats.fmri_spec.mask            = {mask};
        matlabbatch{gi,sub}.spm.stats.fmri_spec.mthresh         = -Inf;

        gi = gi + 1;
        matlabbatch{gi,sub}.spm.stats.fmri_est.spmmat           = {fullfile(outDir,'SPM.mat')};
        matlabbatch{gi,sub}.spm.stats.fmri_est.method.Classical = 1;

        gi = gi + 1;
        matlabbatch{gi,sub}.spm.stats.con.spmmat                = {fullfile(outDir,'SPM.mat')};

        co = 1;
        for bin = 1:nBins
            con = [];
            matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = ['Phasic_Pain_' num2str(bin)];
            tpl0        = zeros(1,nBins);
            tpl1        = zeros(1,nBins);
            tpl1(bin)   = 1;
            for run = 1:nRuns
                if cond(run) == 0
                    con = [con tpl0 noiseCon{run}];
                elseif cond(run) == 1
                    con = [con tpl1 noiseCon{run}];
                end
            end
            matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [con zeros(1,nRuns)];
            matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';
            co = co + 1; %increment by 1
        end
        for bin = 1:nBins
            con = [];
            matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = ['Phasic_NoPain' num2str(bin)];
            tpl0        = zeros(1,nBins);
            tpl1        = zeros(1,nBins);
            tpl0(bin)   = 1;
            for run = 1:nRuns
                if cond(run) == 0
                    con = [con tpl0 noiseCon{run}];
                elseif cond(run) == 1
                    con = [con tpl1 noiseCon{run}];
                end
            end
            matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [con zeros(1,nRuns)];
            matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';
            co = co + 1; %increment by 1
        end
    end
    run_spm_batch(matlabbatch,nSubs);
end

if vasa == 1
    run_vasa(subIDs,fLevelName)
end

if smooth == 1
    imgType = 'con'; %provide image type (beta,con,ess,spmT), otherwise []:con; all:con,beta,spmT
    smooth_first_level(subIDs,fLevelName,imgType);
end
end
