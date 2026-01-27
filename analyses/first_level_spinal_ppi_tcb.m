function [problems] = first_level_spinal_ppi

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

xY.def  = 'sphere';
xY.xyz  = [-9 -28 -9]'; %vmPFC:  6 45 -14 -10 54 -2
xY.spec = 3;
xY.rad  = 3;
xY.str  = 'PAG-FIRinv';
xY.Ic   = 7; %eoi
xY.T    = 7; %eoi
xY.thresh = 0.5;

fLevelName     = 'first_level_spinal_hrf_cc';
fLevelVoi      = 'first_level_brain_hrf_cc';
if isfield(xY,'thresh')
    ppiName        = sprintf('ppi_spinal_tc_%s_%dmm_0%d_c%d',xY.str,xY.rad,100*xY.thresh,xY.T);
else
    ppiName        = sprintf('ppi_spinal_tc_%s_%dmm',xY.str,xY.rad);
end

model          = 1;
smooth         = 1;

if model == 1
    mask           = fullfile(baseDir,'mean_t2_template_seg.nii');
    for sub = 1:nSubs
        subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));
        outDir      = fullfile(sprintf(strrep(fLevelDir,'\','\\'),subIDs(sub)),ppiName);
        fLDir       = fullfile(sprintf(strrep(fLevelDir,'\','\\'),subIDs(sub)),fLevelName);
        voiDir      = fullfile(sprintf(strrep(fLevelDir,'\','\\'),subIDs(sub)),fLevelVoi);

        anatDir     = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'anat1');

        % firstRunDir = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'run1','spinal');
        % meanEpiSp   = fullfile(firstRunDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix','_2temp_clean'));

        firstRunDir = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)),'run1','brain');
        meanEpi  = fullfile(firstRunDir,spm_file(sprintf(vars.meanEpiID,subIDs(sub)),'prefix','w'));

        physioDir   = fullfile(path.physioDir,sprintf('sub%02d',subIDs(sub)),'noise_reg');

        if exist(outDir,'dir')
            rmdir(outDir,'s');
        end
        mkdir(outDir);
        copyfile(which(mfilename),outDir);

        fprintf('Sub%02d\n',subIDs(sub));

        VOI = get_timeseries(fullfile(voiDir,'SPM.mat'),meanEpi,[],2,xY);
        save(fullfile(outDir,'VOI.mat'),'VOI');

        % load(fullfile(outDir,'VOI.mat'),'VOI');
        Uu ={[1 1 -1; 2 1 1]};
        load(fullfile(fLDir,'SPM.mat'),'SPM');
        PPI = spm_peb_gppi(SPM,VOI,Uu,ppiName);
        save(fullfile(outDir,'PPI.mat'),'PPI');

        epiFilesCC = []; movCC  = []; physioCC = []; wmCC = []; csfCC = []; bvCC = []; movBCC = [];
        for run = 1:nRuns
            runDir = fullfile(subDir,sprintf('run%d',run),'spinal');

            % select scans
            if subIDs(sub) == 5 && run == 3
                prScans = 216;
            else
                prScans = get_pruned_scans(subIDs(sub),run,vars.prDur);
            end
            scanVec(run) = prScans;
            epiFiles = spm_select('ExtFPList',runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'suffix','_2temp'),1:prScans);
            epiFilesCC = [epiFilesCC;epiFiles(1:prScans,:)];

            %select brain movement regressors
            mov = struct2array(load(fullfile(physioDir,sprintf(vars.noiseFile,subIDs(sub),'motion',run))));
            movBCC = [movBCC; mov(1:prScans,:)];

            % select spinal movement regressors
            t = load(fullfile(runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'prefix','rp_','ext','mat')));
            mov = permute(mean(t.Q,2),[1 3 2])';
            movCC = [movCC; mov(1:prScans,:)];

            % select physio regressors
            try
                physio = struct2array(load(fullfile(physioDir,sprintf(vars.phyFile,subIDs(sub),run))));
            catch
                physio = zeros(size(nScans,18));
            end
            physioCC = [physioCC; physio(1:prScans,:)];

            % select csf regressor
            csfreg{run} = cell2mat(struct2array(load(fullfile(physioDir,sprintf(vars.spNoiseFile,subIDs(sub),'csf_var95',run)))));

            % select csf regressor
            wmreg{run} = cell2mat(struct2array(load(fullfile(physioDir,sprintf(vars.spNoiseFile,subIDs(sub),'wm50',run)))));

            %exclude bad volumes
            try
                bvreg{run} = struct2array(load(fullfile(physioDir,sprintf(vars.spNoiseFile,subIDs(sub),'badvols',run))));
            catch
                bvreg{run} = [];
            end
        end

        nScans = sum(scanVec);
        for cr = 1:numel(csfreg)
            csf = zeros(sum(scanVec),size(csfreg{cr},2));
            csf(sum(scanVec(1:cr-1))+1:sum(scanVec(1:cr)),:) = csfreg{cr}(1:scanVec(cr),:);
            csfCC = [csfCC csf];
            wm = zeros(sum(scanVec),size(wmreg{cr},2));
            wm(sum(scanVec(1:cr-1))+1:sum(scanVec(1:cr)),:) = wmreg{cr}(1:scanVec(cr),:);
            wmCC = [wmCC wm];
            if ~isempty(bvreg{cr})
                bv = zeros(sum(scanVec),size(bvreg{cr},2));
                bv(sum(scanVec(1:cr-1))+1:sum(scanVec(1:cr)),:) = bvreg{cr}(1:scanVec(cr),:);
                bvCC = [bvCC bv];
            end
        end

        noiseReg   = [movCC physioCC wmCC csfCC bvCC]; %;


        r = 1;
        gi = 1;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.regress(r).name = 'PPI_interaction';
        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.regress(r).val = PPI{1}.o_ppi;
        r = r + 1;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.regress(r).name = 'TC';
        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.regress(r).val = PPI{1}.Y;
        r = r + 1;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.regress(r).name = 'Pain';
        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.regress(r).val = PPI{1}.P;

        % conVec = zeros(nScans,1);
        % for run = 1:nRuns-1
        %     r = r + 1;
        %     conVec(sum(scanVec(1:run-1))+1:sum(scanVec(1:run))) = 1;
        %     matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.regress(r).name = sprintf('constant_run%d',run);
        %     matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.regress(r).val = conVec;
        % end

        for n = 1:size(noiseReg,2)
            matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.regress(n+r) = struct('name',cellstr(num2str(n)),'val',noiseReg(:,n));
        end

        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.units     = 'secs';
        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.RT        = TR;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.fmri_t    = 16;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.timing.fmri_t0   = 8;

        matlabbatch{gi,sub}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});
        matlabbatch{gi,sub}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{gi,sub}.spm.stats.fmri_spec.volt             = 1;
        matlabbatch{gi,sub}.spm.stats.fmri_spec.global           = 'none';
        matlabbatch{gi,sub}.spm.stats.fmri_spec.cvi              = 'none'; % none


        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.scans      = cellstr(epiFilesCC);
        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.multi_reg  = {''};
        matlabbatch{gi,sub}.spm.stats.fmri_spec.sess.hpf        = 240;


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

        gi = gi + 1;
        matlabbatch{gi,sub}.spm.stats.con.spmmat                = {fullfile(outDir,'SPM.mat')};

        matlabbatch{gi,sub}.spm.stats.con.consess{1}.tcon.name = 'PPI-Interaction';
        matlabbatch{gi,sub}.spm.stats.con.consess{1}.tcon.weights = [1 0 0];
        matlabbatch{gi,sub}.spm.stats.con.consess{2}.tcon.name = 'TC';
        matlabbatch{gi,sub}.spm.stats.con.consess{2}.tcon.weights = [0 1 0];

    end
    run_spm_batch(matlabbatch,nSubs);
end

if smooth == 1
    imgType = 'con'; %provide image type (beta,con,ess,spmT), otherwise []:con; all:con,beta,spmT
    smooth_first_level(subIDs,ppiName,imgType);
end







