function plot_ratings

addpath('..\global');

subIDs = [1:49]; %1:49

exclude = [3 14 19 28 35 36 41 ]; %
subIDs = subIDs(~ismember(subIDs,exclude));
nSubs = length(subIDs);

[ratings,conds] = extract_ratings(subIDs);


bw  = 0.7;
dev = 0.14;
lw  = 0.5;
lw2  = 1.8;
ms  = 15;
fs1 = 12;
fs2 = 10;
afs = 8;
xfs = 10;
yfs = 10;
alpha = 0.3;

col.cpm = [2 81 150]/255;
col.ctr = [253 179 56]/255;
col.diff = [16 144 144]/255;


% ratings(ratings<1) = NaN;

for sub = 1:nSubs
    c = conds(:,:,sub);
    r = ratings(:,:,sub);
    cpm(:,sub) = r(c==1)';
    ctr(:,sub) = r(c==0)';
    
    for run = 1:4
        run_rat(sub,run) = nanmean(r(:,run));
        run_cond(sub,run) = c(1,run);
    end
    if c(1,1) == 0
        first_ctr_ctr(:,sub) = r(:,1);
        if c(1,2) == 1
            first_ctr_cpm(:,sub) = r(:,2);
        elseif c(1,3) == 1
            first_ctr_cpm(:,sub) = r(:,3);
        end
    elseif c(1,1) == 1
        first_cpm_cpm(:,sub) = r(:,1);
        if c(1,2) == 0
            first_cpm_ctr(:,sub) = r(:,2);
        elseif c(1,3) == 0
            first_cpm_ctr(:,sub) = r(:,3);
        end
    end
end
gr_ctr = mean(nanmean(ctr));
gr_cpm = mean(nanmean(cpm));

all_ctr = nanmean(ctr);
all_cpm = nanmean(cpm);

gr_ctr_se = std(nanmean(ctr))/sqrt(nSubs);
gr_cpm_se = std(nanmean(cpm))/sqrt(nSubs);

cpm_effect = nanmean(ctr)-nanmean(cpm);
mean(cpm_effect(cpm_effect>0))
mean(cpm_effect(cpm_effect<0))

time_ctr = nanmean(ctr,2);
time_cpm = nanmean(cpm,2);
time_ctr_se = nanstd(ctr,[],2)/sqrt(nSubs);
time_cpm_se = nanstd(cpm,[],2)/sqrt(nSubs);

run_mean.one_ctr = mean(run_rat(run_cond(:,1)==0,1));
run_mean.one_cpm = mean(run_rat(run_cond(:,1)==1,1));
run_mean.two_ctr = mean(run_rat(run_cond(:,2)==0,2));
run_mean.two_cpm = mean(run_rat(run_cond(:,2)==1,2));
run_mean.three_ctr = mean(run_rat(run_cond(:,3)==0,3));
run_mean.three_cpm = nanmean(run_rat(run_cond(:,3)==1,3));
run_mean.four_ctr = mean(run_rat(run_cond(:,4)==0,4));
run_mean.four_cpm = mean(run_rat(run_cond(:,4)==1,4));
%% control vs cpm bar

hFig = figure;
set(hFig,'units','pixel','pos',[900 400 250 250]);

val_bar = [gr_ctr gr_cpm];
val_se = [gr_ctr_se gr_cpm_se];

bar(1,val_bar(1),'EdgeColor','none','BarWidth',bw,'FaceColor',col.ctr); hold on;
bar(2,val_bar(2),'EdgeColor','none','BarWidth',bw,'FaceColor',col.cpm);
errorbar([1 2],val_bar,val_se,'.','Color','k', 'LineWidth',lw,'CapSize',0);

ax = gca;
ax.YAxis.FontSize = afs;
ylabel('Pain Rating (VAS)','FontSize',yfs);
set(gca,'xtick',[1 2],'xticklabel',{'Control','CPM'});
ax.XLabel.FontSize = xfs;
ylim([0 60]);

box off
set(gcf,'color','w');
set(gcf,'PaperPositionMode','auto');

print -dtiff -r500 C:\Users\tinnermann\Documents\paper\plots\behavior_me.tiff

%% control vs cpm raincloud
sf = 2;

hFig = figure;
set(hFig,'units','pixel','pos',[900 400 220 200]);

% h = daviolinplot([all_ctr' all_cpm'],'groups',[1 2],'colors',[col.ctr;col.cpm]);
h = rm_raincloud({all_ctr' all_cpm'},[col.ctr;col.cpm],'sem',ms,sf); hold on

xlim([0 100]);
ax = gca;
ax.XAxis.FontSize = afs;
ax.YAxis.FontSize = xfs;
% ax.YAxis.FontSize = yfs;
xlabel('Pain Rating (VAS)','FontSize',yfs);
% set(gca,'yticklabel',{'Control','CPM'});

box off
set(gcf,'color','w');
set(gcf,'PaperPositionMode','auto');

print -dtiff -r500 C:\Users\tinnermann\Documents\paper\plots\behavior_me_raincloud.tiff

%% distribution of cpm effects
a = -0.15;
b = 0.15;

hFig = figure;
set(hFig,'units','pixel','pos',[900 400 150 200]);

plot(1+(a+(b-a)*(rand(nSubs,1))),cpm_effect,'.','MarkerSize',ms,'Color',col.diff); hold on;
plot([0.5 1.5],zeros(1,2),'Color',[0 0 0],'LineWidth',lw);
% bar(2,val_bar(2),'EdgeColor','none','BarWidth',bw,'FaceColor',col.cpm);

ax = gca;
ax.YAxis.FontSize = afs;
ylabel('Difference Rating (\DeltaVAS)','FontSize',yfs);
set(gca,'xtick',[1],'xticklabel',{'Control-CPM'});
ax.XLabel.FontSize = xfs;
xlim([0.5 1.5]);
ylim([-20 22]);

box off
set(gcf,'color','w');
set(gcf,'PaperPositionMode','auto');

print -dtiff -r500 C:\Users\tinnermann\Documents\paper\plots\behavior_distribution.tiff

%%%%%%%%%%%%%%%%%%%%%%%%%%
hFig = figure;
set(hFig,'units','pixel','pos',[900 200 400 160]);

fi_p1 = fill([1:length(time_cpm) length(time_cpm):-1:1], [(time_cpm-time_cpm_se); flipud(time_cpm+time_cpm_se)]',col.cpm,'EdgeColor', 'none'); 
set(fi_p1, 'facealpha',alpha);hold on;
fi_p2 = fill([1:length(time_ctr) length(time_ctr):-1:1], [(time_ctr-time_ctr_se); flipud(time_ctr+time_ctr_se)]',col.ctr,'EdgeColor', 'none'); 
set(fi_p2, 'facealpha',alpha+0.1);

% plot(1:length(time_cpm),time_cpm,'.','Color',col.cpm,'MarkerSize',ms);
p1 = plot(1:length(time_cpm),time_cpm,'Color',col.cpm,'LineWidth',lw);
% errorbar(1:length(time_cpm),time_cpm,time_cpm_se,'Color',col.cpm,'CapSize',0)

% plot(1:length(time_ctr),time_ctr,'.','Color',col.ctr,'MarkerSize',ms);
p2 = plot(1:length(time_ctr),time_ctr,'Color',col.ctr,'LineWidth',lw);
% errorbar(1:length(time_ctr),time_ctr,time_ctr_se,'Color',col.ctr,'CapSize',0)

P = polyfit(0:35,time_ctr,1);
plot(1:length(time_ctr),P(2)+(1:length(time_ctr))*P(1),'Color',col.ctr,'LineWidth',lw2+0.2);
P = polyfit(0:35,time_cpm,1);
plot(1:length(time_cpm),P(2)+(1:length(time_cpm))*P(1),'Color',col.cpm,'LineWidth',lw2);

set(gca,'FontSize',afs);
xlabel('Trial Number','FontSize',yfs);
ylabel('Pain Rating (VAS)','FontSize',yfs);
% legend([p1 p2],'CPM','Control');

set(gcf,'color','w');
box off

xlim([1 36]);
ylim([40 65]);
% legend('CPM','Control');
set(gcf,'color','w');
box off

set(gcf,'PaperPositionMode','auto');

print -dtiff -r500 C:\Users\tinnermann\Documents\paper\plots\behavior_time.tiff








% 
% %% individual participants
% 
% plotsFig = 9;
% nFigs = ceil(length(subs)/plotsFig);
% nrRow = sqrt(plotsFig);
% nrCol = sqrt(plotsFig);
% 
% 
% for nFig = 1:nFigs
% 
% hFig = figure;
% set(hFig,'units','pixel','pos',[900 400 480 450]);
% 
% for i = 1:plotsFig
%     g = plotsFig*(nFig-1)+i;
%     val_bar = [condRatings(g,1:2:end);condRatings(g,2:2:end)]';
%     val_se = [condRatingsSTD(g,1:2:end);condRatingsSTD(g,2:2:end)]';
% 
%     subplot(nrRow,nrCol,i)
% 
%     h = bar(val_bar,'EdgeColor','none','BarWidth',bw); hold on;
%     set(h(1),'FaceColor',col.control);
%     if treatOrd(g) == 1
%         set(h(2),'FaceColor',col.decrease);
%     elseif treatOrd(g) == 2
%         set(h(2),'FaceColor',col.increase);
%     end
% 
%     errorbar([(1:nRuns)'-dev (1:nRuns)'+dev],val_bar,val_se,'.','Color','k', 'LineWidth',0.2);
% set(gca,'xtick',[1;nRuns],'xticklabel',{'B1','B2','B3','test'},'FontSize',7);
%     ylabel('Pain rating (VAS)','FontSize',8);
%     ylim([0 100]);
%     box off
%     set(gcf,'color','w');
%     set(gcf,'PaperPositionMode','auto');
%     title(sprintf('Sub%02.2d',subs(g)),'FontSize',8);
% end
% end
% 
