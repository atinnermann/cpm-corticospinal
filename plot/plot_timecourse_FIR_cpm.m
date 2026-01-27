
TR = 1.991;
bins = 10;
xyz = round(ans);

phasic_cpm = contrast.contrast(1:bins);
phasic_ctr = contrast.contrast(bins+1:bins*2);

phasic_cpm_se = contrast.standarderror(1:bins);
phasic_ctr_se = contrast.standarderror(bins+1:bins*2);

col.pain = [2 81 150]/255;
col.inno = [253 179 56]/255;

lw = 1.4;
lw2 = 0.6;
afs = 8;
xfs = 11;
yfs = 11;
alpha = 0.5;
    
ylims = [round(min(contrast.contrast-contrast.standarderror)*1.3*100)/100 round(max(contrast.contrast+contrast.standarderror)*1.3*100)/100];
% ylims = [-0.1 0.15];

hFig = figure;
set(hFig,'units','pixel','pos',[900 200 325 250]);

p1 = plot((-2:bins-3)*TR,phasic_cpm,'Color',col.pain,'LineWidth',lw);hold on;
p2 = plot((-2:bins-3)*TR,phasic_ctr,'Color',col.inno,'LineWidth',lw);
plot((-2:bins-3)*TR,zeros(1,bins),'Color',[0 0 0],'LineWidth',lw2);
plot([0 0],[0 -sum(abs(ylims))*0.07],'Color',[0 0 0],'LineWidth',lw2);
plot([5 5],[0 -sum(abs(ylims))*0.07],'Color',[0 0 0],'LineWidth',lw2);

fi_p1 = fill([(-2:bins-3)*TR (bins-3:-1:-2)*TR], [(phasic_cpm-phasic_cpm_se); flipud(phasic_cpm+phasic_cpm_se)]',col.pain,'EdgeColor', 'none'); 
set(fi_p1, 'facealpha',alpha);
fi_p2 = fill([(-2:bins-3)*TR (bins-3:-1:-2)*TR], [(phasic_ctr-phasic_ctr_se); flipud(phasic_ctr+phasic_ctr_se)]',col.inno,'EdgeColor', 'none'); 
set(fi_p2, 'facealpha',alpha);

set(gca,'FontSize',afs);
xlabel('Time (s)','FontSize',yfs);
ylabel('fMRI signal change (au)','FontSize',yfs);

set(gcf,'color','w');
box off

xlim([-4 12]);
ylim(ylims);
% legend('CPM','Control');
set(gcf,'color','w');
box off

set(gcf,'PaperPositionMode','auto');

eval(sprintf('print -dsvg -vector C:\\Users\\tinnermann\\Documents\\paper\\plots\\TC_cpm_%d_%d_%d.svg',xyz(1),xyz(2),xyz(3)))
eval(sprintf('print -dtiff -r200 C:\\Users\\tinnermann\\Documents\\paper\\plots\\TC_cpm_%d_%d_%d.tiff',xyz(1),xyz(2),xyz(3)))
