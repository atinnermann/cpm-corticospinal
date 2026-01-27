function [problems] = first_level_brain_cc

addpath('..\global');
addpath('..\utils');

subIDs = [1:49]; %1:49

exclude = [3 7 14 19 28 35 36 41 ];
subIDs = subIDs(~ismember(subIDs,exclude));

[path,vars]    = get_study_specs;
baseDir        = path.mriDir;
fLevelDir      = path.fLevelDir;
nSubs          = length(subIDs);
nRuns          = vars.nRuns;
TR             = vars.repTime;
nTrials        = 18;

fLevelName     = 'first_level_brain_hrf_cc';
onsName        = 'onsP_cc';
model          = 1;
vasa           = 0;
smooth         = 1;

if model == 1
    for sub = 1:nSubs
        subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
        outDir      = fullfile(sprintf(strrep(fLevelDir,'\','\\'),subIDs(sub)),fLevelName);

        anatDir     = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'anat1');
        mask        = spm_select('FPList',anatDir,spm_file(sprintf(vars.T1stripID,subIDs(sub)),'prefix','w'));

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

        fprintf('Sub%02d\n',subIDs(sub));
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

         epiFilesCC = []; movCC  = []; physioCC = []; wmCC = []; csfCC = [];bvCC = [];
        pmodPc = [];

        for run = 1:nRuns
            runDir = fullfile(subDir,sprintf('run%d',run),'brain');

            % select scans
            if subIDs(sub) == 5 && run == 3
                prScans = 216;
            else
                prScans = get_pruned_scans(subIDs(sub),run,vars.prDur);
            end
            scanVec(run) = prScans;
            epiFiles = spm_select('ExtFPList',runDir,spm_file(sprintf(vars.rawEpiID,subIDs(sub)),'prefix','w'),1:prScans);
            epiFilesCC = [epiFilesCC;epiFiles(1:prScans,:)];

            %get run conditions
            o  = load(fullfile(logDir,sprintf('sub%03d-run%d-onsets.mat',subIDs(sub),run+1)));

            %create pmod
            if o.conditions == 0
                pmodPc = [pmodPc ones(1,nTrials)];  
            elseif o.conditions == 1   
                pmodPc = [pmodPc ones(1,nTrials)*2];
            end

            %select brain movement regressors
            mov = struct2array(load(fullfile(physioDir,sprintf(vars.noiseFile,subIDs(sub),'motion',run))));
            movCC = [movCC; mov(1:prScans,:)];

            % select physio regressors
            try
                physio = struct2array(load(fullfile(physioDir,sprintf(vars.phyFile,subIDs(sub),run))));
            catch
                physio = zeros(size(nScans,18));
            end
            physioCC = [physioCC; physio(1:prScans,:)];

            % select csf regressor
            load(fullfile(physioDir,sprintf(vars.noiseFile,subIDs(sub),'wm_csf',run)),'wmcsf');
            wmCC = [wmCC; wmcsf{1}(1:prScans,:)];
            csfCC = [csfCC; wmcsf{2}(1:prScans,:)];

            %exclude bad volumes
            try
                bvreg{run} = struct2array(load(fullfile(physioDir,sprintf(vars.noiseFile,subIDs(sub),'badvols',run))));
            catch
                bvreg{run} = [];
            end
        end

        for cr = 1:numel(bvreg)
            if ~isempty(bvreg{cr})
                bv = zeros(sum(scanVec),size(bvreg{cr},2));
                bv(sum(scanVec(1:cr-1))+1:sum(scanVec(1:cr)),:) = bvreg{cr}(1:scanVec(cr),:);
                bvCC = [bvCC bv];
            end
        end

        noiseReg   = [movCC physioCC wmCC csfCC bvCC]; %;
        noiseCon   = zeros(1,size(noiseReg,2));

        for n = 1:size(noiseReg,2)
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(1).regress(n) = struct('name',cellstr(num2str(n)),'val',noiseReg(:,n));
        end

        % select multicond files
        multi = load(fullfile(onsDir,sprintf('sub%02d_multicond_%s.mat',subIDs(sub),onsName)));
         
        for m = 1:numel(multi.names)
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(1).cond(m)      = struct('name',multi.names(m),'onset',multi.onsets{m}(:),'duration',multi.durations{m}(:),'tmod', 0,'pmod',0,'orth',0);%
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(1).cond(m).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(1).cond(m).orth = 1;
        end

        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(1).scans      = cellstr(epiFilesCC);
        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(1).multi_reg  = {''};
        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess(1).hpf        = 240;
       

        matlabbatch{gi,sub}.spm.stats.fmri_spec.dir             = {outDir};
        matlabbatch{gi,sub}.spm.stats.fmri_spec.mask            = {mask};
        matlabbatch{gi,sub}.spm.stats.fmri_spec.mthresh         = -Inf;

        gi = gi + 1;
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{1}.string = fullfile(outDir,'SPM.mat');
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.inputs{2}.evaluated = scanVec;
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.outputs = {};
        matlabbatch{gi,sub}.cfg_basicio.run_ops.call_matlab.fun = 'spm_fmri_concatenate';
   
        gi = gi + 1;
        matlabbatch{gi,sub}.spm.stats.fmri_est.spmmat           = {fullfile(outDir,'SPM.mat')};
        matlabbatch{gi,sub}.spm.stats.fmri_est.method.Classical = 1;

        gi = gi + 1;
        matlabbatch{gi,sub}.spm.stats.con.spmmat                = {fullfile(outDir,'SPM.mat')};

        %----- 1 -----%
        co = 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Rating';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [0 0 1 0 0 0 noiseCon zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

        %----- 2 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Phasic';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [1 1 0 0 0 0 noiseCon zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

        %----- 3 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Tonic_Pain';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [0 0 0 0 1 0 noiseCon zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

        %----- 4 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Tonic_Pain>Control';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [0 0 0 0 1 -1 noiseCon zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

        %----- 5 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Phasic_CPM>Control';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [1 -1 0 0 0 0 noiseCon zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

        %----- 6 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = 'Phasic_Control>CPM';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [-1 1 0 0 0 0 noiseCon zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';
        
        %----- 7 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.fcon.name    = 'eoi';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.fcon.convec  = [eye(6)]; 
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.fcon.sessrep = 'none';

        %----- 8 -----%
        co = co + 1;
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.name    = '-phasic';
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.convec  = [-1 -1 0 0 0 0 noiseCon zeros(1,nRuns)];
        matlabbatch{gi,sub}.spm.stats.con.consess{co}.tcon.sessrep = 'none';

    end
    run_spm_batch(matlabbatch,nSubs);
end

if vasa == 1
    run_vasa(subIDs,fLevelName)
end

if smooth == 1
    imgType = 'con'; %provide image type (beta,con,vcon,ess,spmT), otherwise []:con; all:con,beta,spmT
    smooth_first_level(subIDs,fLevelName,imgType);
end



