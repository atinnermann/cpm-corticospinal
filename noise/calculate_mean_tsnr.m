function calculate_mean_tsnr

addpath('..\global');
addpath('..\utils');

subIDs = [1:49]; %1:49

exclude = [3 7 14 19 28 35 36 41 25];
subIDs = subIDs(~ismember(subIDs,exclude));

% add paths
nSubs        = length(subIDs);
[path,vars]  = get_study_specs;
baseDir      = path.mriDir;
nRuns        = vars.nRuns;

subSNR = 0;
meanSNR = 0;
plotSNR = 1;

grouptSNR = 'mean_tSNR_template_cut.nii';
t2Seg    = 'mean_t2_template_seg.nii';

if subSNR
    for sub = 1:nSubs
        subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));

        funcDir     = fullfile(subDir,'run1','spinal');
        meantSNR    = fullfile(funcDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix','_tsnr_2temp'));
        meantSNRcut = fullfile(funcDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix','_tsnr_2temp_cut'));

        epiFiles = [];

        for run = 1:nRuns
            fprintf('Processing Sub%02d Run%d\n',subIDs(sub),run);
            runDir      = fullfile(subDir,sprintf('run%d',run),'spinal');
            epiFile     = fullfile(runDir,spm_file(sprintf(vars.spRawEpiID,subIDs(sub),run),'suffix','_tsnr_2temp'));
            epiFiles    = [epiFiles; epiFile];
        end

        gi = 1;
        matlabbatch{gi,sub}.spm.util.imcalc.input          = cellstr(epiFiles);
        matlabbatch{gi,sub}.spm.util.imcalc.output         = meantSNR;
        matlabbatch{gi,sub}.spm.util.imcalc.outdir         = {funcDir};
        matlabbatch{gi,sub}.spm.util.imcalc.expression     = 'mean(X)';
        matlabbatch{gi,sub}.spm.util.imcalc.var            = struct('name', {}, 'value', {});
        matlabbatch{gi,sub}.spm.util.imcalc.options.dmtx   = 1;
        matlabbatch{gi,sub}.spm.util.imcalc.options.mask   = 0;
        matlabbatch{gi,sub}.spm.util.imcalc.options.interp = 0;
        matlabbatch{gi,sub}.spm.util.imcalc.options.dtype  = 4;

        gi = gi + 1;
        matlabbatch{gi,sub}.spm.util.imcalc.input = cellstr(char(meantSNR,fullfile(baseDir,t2Seg)));
        matlabbatch{gi,sub}.spm.util.imcalc.output = meantSNRcut;
        matlabbatch{gi,sub}.spm.util.imcalc.outdir = {funcDir};
        matlabbatch{gi,sub}.spm.util.imcalc.expression = 'i1.*i2';
        matlabbatch{gi,sub}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{gi,sub}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{gi,sub}.spm.util.imcalc.options.mask = 0;
        matlabbatch{gi,sub}.spm.util.imcalc.options.interp = 1;
        matlabbatch{gi,sub}.spm.util.imcalc.options.dtype = 4;

    end

    if nSubs < vars.nWorkers
        nProcs = nSubs;
    else
        nProcs = vars.nWorkers;
    end

    if vars.runParallel == 1
        run_spm_parallel(matlabbatch,nProcs);
    else
        run_spm_sequential(matlabbatch);
    end

    clear matlabbatch
end


if meanSNR
    meanFiles = [];

    for sub = 1:nSubs
        subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));

        funcDir     = fullfile(subDir,'run1','spinal');
        meantSNRcut = fullfile(funcDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix','_tsnr_2temp_cut'));
        meanFiles    = [meanFiles; meantSNRcut];
    end

    gi = 1;
    matlabbatch{gi}.spm.util.imcalc.input          = cellstr(meanFiles);
    matlabbatch{gi}.spm.util.imcalc.output         = grouptSNR;
    matlabbatch{gi}.spm.util.imcalc.outdir         = {baseDir};
    matlabbatch{gi}.spm.util.imcalc.expression     = 'mean(X)';
    matlabbatch{gi}.spm.util.imcalc.var            = struct('name', {}, 'value', {});
    matlabbatch{gi}.spm.util.imcalc.options.dmtx   = 1;
    matlabbatch{gi}.spm.util.imcalc.options.mask   = 0;
    matlabbatch{gi}.spm.util.imcalc.options.interp = 0;
    matlabbatch{gi}.spm.util.imcalc.options.dtype  = 4;

    run_spm_sequential(matlabbatch);
end

if plotSNR
    for sub = 1:nSubs
        subDir      = fullfile(baseDir,sprintf('sub%02d',subIDs(sub)));

        funcDir     = fullfile(subDir,'run1','spinal');
        meantSNRcut = fullfile(funcDir,spm_file(sprintf(vars.spMeanID,subIDs(sub)),'suffix','_tsnr_2temp_cut'));

        V = spm_vol(meantSNRcut);
        [y,xyz] = spm_read_vols(V);
        for sl = 1:size(y,3)
            slice = y(:,:,sl);
            snrsl(sl) = mean(slice(slice>0));
        end
        tSNRsl(:,sub) = interp1(1:91,snrsl,1:10:91)';
        tSNR(sub) = mean(y(y>0));
    end
    meanSlice = mean(tSNRsl,2);

    sf = 2;
    ms  = 15;
    afs = 8;
    xfs = 10;
    yfs = 10;
    bw  = 0.5;
    lw = 1.5;

    col.diff = [16 144 144]/255;

    a = -0.15;
    b = 0.15;

    hFig = figure;
    set(hFig,'units','pixel','pos',[900 400 150 200]);

    plot(1+(a+(b-a)*(rand(nSubs,1))),tSNR,'.','MarkerSize',ms,'Color',col.diff); hold on;
    % plot([0.5 1.5],zeros(1,2),'Color',[0 0 0],'LineWidth',lw);
    h = bar(1,mean(tSNR),'EdgeColor','none','BarWidth',bw,'FaceColor',col.diff);
    set(h,'FaceAlpha',0.6);
    errorbar(mean(tSNR),std(tSNR)/sqrt(nSubs),'.','Color','k', 'LineWidth',lw,'CapSize',0);

    ax = gca;
    ax.YAxis.FontSize = afs;
    ylabel('tSNR','FontSize',yfs);
    set(gca,'xtick',[1],'xticklabel',{''});
    ax.XLabel.FontSize = xfs;
    xlim([0.5 1.5]);
    ylim([0 40]);

    box off
    set(gcf,'color','w');
    set(gcf,'PaperPositionMode','auto');

    print -dtiff -r500 C:\Users\tinnermann\Documents\paper\plots\tsnr_bar.tiff

    % hFig = figure;
    % set(hFig,'units','pixel','pos',[900 400 220 200]);
    %
    % rm_raincloud({tSNR'},[col.diff],'sem',ms,sf); hold on
    %
    % xlim([0 50]);
    % ax = gca;
    % ax.XAxis.FontSize = afs;
    % ax.YAxis.FontSize = xfs;
    % xlabel('tSNR','FontSize',yfs);
    %
    % box off
    % set(gcf,'color','w');
    % set(gcf,'PaperPositionMode','auto');

    % print -dtiff -r500 C:\Users\tinnermann\Documents\paper\plots\tsnr_raincloud.tiff
    ms = 8;
    hFig = figure;
    set(hFig,'units','pixel','pos',[900 400 400 200]);
    
    % plot([0.5 1.5],zeros(1,2),'Color',[0 0 0],'LineWidth',lw);
    h = bar(1:10,mean(tSNRsl,2),'EdgeColor','none','BarWidth',bw,'FaceColor',col.diff); hold on;
    set(h,'FaceAlpha',0.6);
    errorbar(mean(tSNRsl,2),std(tSNRsl,[],2)/sqrt(nSubs),'.','Color','k', 'LineWidth',lw,'CapSize',0);
    for d = 1:10
        plot(d+(a+(b-a)*(rand(nSubs,1))),tSNRsl(d,:),'.','MarkerSize',ms,'Color',col.diff); 
    end

    ax = gca;
    ax.YAxis.FontSize = afs;
    ylabel('tSNR','FontSize',yfs);
    % set(gca,'xtick',[1],'xticklabel',{''});
    ax.XLabel.FontSize = xfs;
    % xlim([0.5 1.5]);
    ylim([0 40]);

    box off
    set(gcf,'color','w');
    set(gcf,'PaperPositionMode','auto');

    print -dtiff -r500 C:\Users\tinnermann\Documents\paper\plots\tsnr_slice_bar.tiff

end
