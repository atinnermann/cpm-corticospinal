function [problems] = first_level_brain

addpath('..\global');
addpath('..\utils');

subIDs = [1:49]; %1:49

exclude = [3 7 14 19 28 35 36 41];
subIDs = subIDs(~ismember(subIDs,exclude));

[path,vars]    = get_study_specs;
baseDir        = path.mriDir;
fLevelDir      = path.fLevelDir;
nSubs          = length(subIDs);
nRuns          = vars.nRuns;
TR             = vars.repTime;

fLevelName     = 'first_level_brain_hrf';
onsName        = 'onsP';
model          = 1;
smooth         = 1;


if model == 1
    for sub = 1:nSubs
        subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
        outDir      = fullfile(sprintf(strrep(fLevelDir,'\','\\'),subIDs(sub)),fLevelName);

        anatDir     = fullfile(subDir,'seg');
        mask        = spm_select('FPList',anatDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','w','suffix','_mask'));

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

        gi = 1;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.units     = 'secs';
        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.RT        = TR;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.fmri_t    = 16;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.fmri_t0   = 8;

        matlabbatch{gi,sub}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});
        matlabbatch{gi,sub}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{gi,sub}.spm.stats.fmri_spec.volt             = 1;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.global           = 'None';
        matlabbatch{gi,sub}.spm.stats.fmri_spec.cvi              = 'none'; % none

        for run = 1:nRuns
            runDir = fullfile(subDir,sprintf('run%d',run),'brain');

            % select scans
            if subIDs(sub) == 5 && run == 3
                prScans = 216;
            else
                prScans = get_pruned_scans(subIDs(sub),run,vars.prDur);
            end
            epiFiles = spm_select('ExtFPList',runDir,spm_file(sprintf(vars.rawEpiID,subIDs(sub)),'prefix','w'),1:prScans);
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).scans = cellstr(epiFiles);

            % select multicond files
            onsetFile = fullfile(onsDir,sprintf('sub%02d_multicond_%s_run%d.mat',subIDs(sub),onsName,run));
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).cond  = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).multi = cellstr(onsetFile);

            %get run conditions
            o  = load(fullfile(logDir,sprintf('sub%03d-run%d-onsets.mat',subIDs(sub),run+1)));

            %select brain movement regressors
            n.mov = struct2array(load(fullfile(physioDir,sprintf(vars.noiseFile,subIDs(sub),'motion',run))));

            % select physio regressors
            try
                n.physio = struct2array(load(fullfile(physioDir,sprintf(vars.phyFile,subIDs(sub),run))));
            catch
                n.physio = [];
            end

            % select csf regressor
            load(fullfile(physioDir,sprintf(vars.noiseFile,subIDs(sub),'wm_csf',run)),'wmcsf');

            %exclude bad volumes
            try
                n.bv = struct2array(load(fullfile(physioDir,sprintf(vars.noiseFile,subIDs(sub),'badvols',run))));
            catch
                n.bv = [];
            end

            tmp   = [n.mov n.physio wmcsf{1} wmcsf{2} n.bv]; %
            noiseReg{run}   = tmp(1:prScans,:);
            noiseCon{run}   = zeros(1,size(noiseReg{run},2));

            for n = 1:size(noiseReg{run},2)
                matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).regress(n) = struct('name',cellstr(num2str(n)),'val',noiseReg{run}(:,n));
            end
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).multi_reg  = {''};
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(run).hpf        = 240;

            %vectors for contrasts
            %names = {'Phasic','Rating','Scale','Tonic'};

            %phasic
            p1{run}     = [1 0 0 0]; %pain

            if o.conditions(1) == 0
                p2{run} = [-1 0 0 0];
                p3{run} = [1 0 0 0];
                p4{run} = [1 0 0 0];
                p5{run} = [0 0 0 0];
            elseif o.conditions(1) == 1
                p2{run} = [1 0 0 0];
                p3{run} = [-1 0 0 0];
                p4{run} = [0 0 0 0];
                p5{run} = [1 0 0 0];
            end

            %tonic
            if o.conditions(1) == 0
                t1{run}     = [0 0 0 0]; %pain
                t2{run}     = [0 0 0 -1]; %painC
            elseif o.conditions(1) == 1
                t1{run}     = [0 0 0 1]; %pain
                t2{run}     = [0 0 0 1]; %painC
            end

            %rating
            r1{run}     = [0 1 0 0]; %vas

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

        %----- 1 -----%
        co = 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Rating';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [r1{1} noiseCon{1} r1{2} noiseCon{2} r1{3} noiseCon{3} r1{4} noiseCon{4} zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

        %----- 2 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Phasic';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [p1{1} noiseCon{1} p1{2} noiseCon{2} p1{3} noiseCon{3} p1{4} noiseCon{4} zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

        %----- 3 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Tonic_Painful';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [t1{1} noiseCon{1} t1{2} noiseCon{2} t1{3} noiseCon{3} t1{4} noiseCon{4} zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

        %----- 4 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Tonic_Painful>Control';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [t2{1} noiseCon{1} t2{2} noiseCon{2} t2{3} noiseCon{3} t2{4} noiseCon{4} zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

        %----- 5 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Phasic_CPM>Control';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [p2{1} noiseCon{1} p2{2} noiseCon{2} p2{3} noiseCon{3} p2{4} noiseCon{4} zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

        %----- 6 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Phasic_Control>CPM';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [p3{1} noiseCon{1} p3{2} noiseCon{2} p3{3} noiseCon{3} p3{4} noiseCon{4} zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

        %----- 7 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Phasic_Control';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [p4{1} noiseCon{1} p4{2} noiseCon{2} p4{3} noiseCon{3} p4{4} noiseCon{4} zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';  

        %----- 8 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Phasic_CPM';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [p5{1} noiseCon{1} p5{2} noiseCon{2} p5{3} noiseCon{3} p5{4} noiseCon{4} zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none'; 


    end
    run_spm_batch(matlabbatch,nSubs);
end

if smooth == 1
    imgType = 'con'; %provide image type (beta,con,ess,spmT), otherwise []:con; all:con,beta,spmT
    smooth_first_level(subIDs,fLevelName,imgType);
end







