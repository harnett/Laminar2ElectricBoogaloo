clear
load('spinddelt_cpling_glm_all_fin.mat')

thrsh = 4;

thctxa1(abs(thctxa1)>thrsh) = nan;
thctxa2(abs(thctxa2)>thrsh) = nan;

ni = mean(thctxa1,2);
ni = find(isnan(ni));


ni2 = mean(thctxa2,2);
ni2 = find(isnan(ni));
ni = [ni ni2];

thctxa2(ni,:) = [];
thctxa1(ni,:) = [];

subsi(ni) = [];

pfci = [find(subsi==1) find(subsi==5) find(subsi==6)];
a1i = [find(subsi==3) find(subsi==4)];

%% contrast coupled / uncoupled spindles
figure
subplot(1,2,1)
shadedErrorBar(1:243,nanmean(thctxa1(pfci,:)),nanstd(thctxa1(pfci,:))./sqrt(size(thctxa1(pfci,:),1)),'LineProps',{'Color','b'}), hold on
shadedErrorBar(1:243,nanmean(thctxa2(pfci,:)),nanstd(thctxa2(pfci,:))./sqrt(size(thctxa2(pfci,:),1)),'LineProps',{'Color','r'}), hold on
sig_star_plt(ranksum(mean((thctxa1(pfci,1:10)),2),mean((thctxa2(pfci,1:10)),2)))
xlim([0 50])
set(gca,'FontSize',22)
xlabel('Delay (ms)','FontSize',25)
ylabel('Weight (a.u.)','FontSize',25)
title('Thalamocortical Filters for Coupled vs. Uncoupled MD/PFC Spindles','FontSize',30)

subplot(1,2,2)
shadedErrorBar(1:243,nanmean(thctxa1(a1i,:)),nanstd(thctxa1(a1i,:))./sqrt(size(thctxa1(a1i,:),1)),'LineProps',{'Color','b'}), hold on
shadedErrorBar(1:243,nanmean(thctxa2(a1i,:)),nanstd(thctxa2(a1i,:))./sqrt(size(thctxa2(a1i,:),1)),'LineProps',{'Color','r'}), hold on
sig_star_plt(ranksum(mean((thctxa1(a1i,1:10)),2),mean((thctxa2(a1i,1:10)),2)))
xlim([0 50])
set(gca,'FontSize',22)
xlabel('Delay (ms)','FontSize',25)
ylabel('Weight (a.u.)','FontSize',25)
title('Thalamocortical Filters for Coupled vs. Uncoupled MGB/A1 Spindles','FontSize',30)

figure
shadedErrorBar(1:243,nanmean(thctxa1),nanstd(thctxa1)./sqrt(size(thctxa1,1)),'LineProps',{'Color','b'}), hold on
shadedErrorBar(1:243,nanmean(thctxa2),nanstd(thctxa2)./sqrt(size(thctxa2,1)),'LineProps',{'Color','r'}), hold on
sig_star_plt(ranksum(mean((thctxa1(:,1:10)),2),mean((thctxa2(:,1:10)),2)))
xlim([0 50])
set(gca,'FontSize',22)
xlabel('Delay (ms)','FontSize',25)
ylabel('Weight (a.u.)','FontSize',25)
title('Thalamocortical Filters for Coupled vs. Uncoupled Spindles','FontSize',30)
%% contrast md/pfc and mgb/a1 !!!

figure
subplot(1,2,1)
shadedErrorBar(1:243,nanmean(thctxa1(a1i,:)),nanstd(thctxa1(a1i,:))./sqrt(size(thctxa1(a1i,:),1)),'LineProps',{'Color','b'}), hold on
shadedErrorBar(1:243,nanmean(thctxa1(pfci,:)),nanstd(thctxa1(pfci,:))./sqrt(size(thctxa1(pfci,:),1)),'LineProps',{'Color','r'}), hold on
sig_star_plt(ranksum(mean((thctxa1(a1i,1:10)),2),mean((thctxa1(pfci,1:10)),2)))
xlim([0 50])
set(gca,'FontSize',22)
xlabel('Delay (ms)','FontSize',25)
ylabel('Weight (a.u.)','FontSize',25)
title('Thalamocortical Filters for Coupled MGB/A1 vs. MD/PFC Spindles','FontSize',30)

subplot(1,2,2)
ranksum(mean((thctxa2(a1i,1:10)),2),mean((thctxa2(pfci,1:10)),2))
shadedErrorBar(1:243,nanmean(thctxa2(a1i,:)),nanstd(thctxa2(a1i,:))./sqrt(size(thctxa2(a1i,:),1)),'LineProps',{'Color','b'}), hold on
shadedErrorBar(1:243,nanmean(thctxa2(pfci,:)),nanstd(thctxa2(pfci,:))./sqrt(size(thctxa2(pfci,:),1)),'LineProps',{'Color','r'}), hold on
sig_star_plt(ranksum(mean((thctxa2(a1i,1:10)),2),mean((thctxa2(pfci,1:10)),2)))
xlim([0 50])
set(gca,'FontSize',22)
xlabel('Delay (ms)','FontSize',25)
ylabel('Weight (a.u.)','FontSize',25)
title('Thalamocortical Filters for Uncoupled MGB/A1 vs. MD/PFC Spindles','FontSize',30)

%%
clear
load('spinddelt_cpling_glm_all_fin.mat')

thrsh = 4;

ctxtha1(abs(ctxtha1)>thrsh) = nan;
ctxtha2(abs(ctxtha2)>thrsh) = nan;

ni = mean(ctxtha1,2);
ni = find(isnan(ni));


ni2 = mean(ctxtha2,2);
ni2 = find(isnan(ni));
ni = [ni ni2];

ctxtha2(ni,:) = [];
ctxtha1(ni,:) = [];

subsi(ni) = [];

pfci = [find(subsi==1) find(subsi==5) find(subsi==6)];
a1i = [find(subsi==3) find(subsi==4)];

%% contrast coupled / uncoupled spindles
figure
subplot(1,2,1)
shadedErrorBar(1:243,nanmean(ctxtha1(pfci,:)),nanstd(ctxtha1(pfci,:))./sqrt(size(ctxtha1(pfci,:),1)),'LineProps',{'Color','b'}), hold on
shadedErrorBar(1:243,nanmean(ctxtha2(pfci,:)),nanstd(ctxtha2(pfci,:))./sqrt(size(ctxtha2(pfci,:),1)),'LineProps',{'Color','r'}), hold on
sig_star_plt(ranksum(mean((ctxtha1(pfci,1:10)),2),mean((ctxtha2(pfci,1:10)),2)))
xlim([0 50])
set(gca,'FontSize',22)
xlabel('Delay (ms)','FontSize',25)
ylabel('Weight (a.u.)','FontSize',25)
title('Corticothalamic Filters for Coupled vs. Uncoupled MD/PFC Spindles','FontSize',30)

subplot(1,2,2)
shadedErrorBar(1:243,nanmean(ctxtha1(a1i,:)),nanstd(ctxtha1(a1i,:))./sqrt(size(ctxtha1(a1i,:),1)),'LineProps',{'Color','b'}), hold on
shadedErrorBar(1:243,nanmean(ctxtha2(a1i,:)),nanstd(ctxtha2(a1i,:))./sqrt(size(ctxtha2(a1i,:),1)),'LineProps',{'Color','r'}), hold on
sig_star_plt(ranksum(mean((thctxa1(a1i,1:10)),2),mean((thctxa2(a1i,1:10)),2)))
xlim([0 50])
set(gca,'FontSize',22)
xlabel('Delay (ms)','FontSize',25)
ylabel('Weight (a.u.)','FontSize',25)
title('Corticothalamic Filters for Coupled vs. Uncoupled MGB/A1 Spindles','FontSize',30)

figure
shadedErrorBar(1:243,nanmean(ctxtha1),nanstd(ctxtha1)./sqrt(size(ctxtha1,1)),'LineProps',{'Color','b'}), hold on
shadedErrorBar(1:243,nanmean(ctxtha2),nanstd(ctxtha2)./sqrt(size(ctxtha2,1)),'LineProps',{'Color','r'}), hold on
sig_star_plt(ranksum(mean((thctxa1(:,1:10)),2),mean((thctxa2(:,1:10)),2)))
xlim([0 50])
set(gca,'FontSize',22)
xlabel('Delay (ms)','FontSize',25)
ylabel('Weight (a.u.)','FontSize',25)
title('Corticothalamic Filters for Coupled vs. Uncoupled Spindles','FontSize',30)
%%
figure
subplot(1,2,1)
shadedErrorBar(1:243,nanmean(ctxtha1(a1i,:)),nanstd(ctxtha1(a1i,:))./sqrt(size(ctxtha1(a1i,:),1)),'LineProps',{'Color','b'}), hold on
shadedErrorBar(1:243,nanmean(ctxtha1(pfci,:)),nanstd(ctxtha1(pfci,:))./sqrt(size(ctxtha1(pfci,:),1)),'LineProps',{'Color','r'}), hold on
sig_star_plt(ranksum(mean((ctxtha1(a1i,1:10)),2),mean((ctxtha1(pfci,1:10)),2)))
xlim([0 50])
set(gca,'FontSize',22)
xlabel('Delay (ms)','FontSize',25)
ylabel('Weight (a.u.)','FontSize',25)
title('Corticothalamic Filters for Coupled MGB/A1 vs. MD/PFC Spindles','FontSize',30)

subplot(1,2,2)
shadedErrorBar(1:243,nanmean(ctxtha2(a1i,:)),nanstd(ctxtha2(a1i,:))./sqrt(size(ctxtha2(a1i,:),1)),'LineProps',{'Color','b'}), hold on
shadedErrorBar(1:243,nanmean(ctxtha2(pfci,:)),nanstd(ctxtha2(pfci,:))./sqrt(size(ctxtha2(pfci,:),1)),'LineProps',{'Color','r'}), hold on
sig_star_plt(ranksum(mean((ctxtha2(a1i,1:10)),2),mean((ctxtha2(pfci,1:10)),2)))
xlim([0 50])
set(gca,'FontSize',22)
xlabel('Delay (ms)','FontSize',25)
ylabel('Weight (a.u.)','FontSize',25)
title('Corticothalmic Filters for Uncoupled MGB/A1 vs. MD/PFC Spindles','FontSize',30)
% 
% pv=[];
% for k = 1 : size(thctxa1,2)
%     pv(k) = signrank(thctxa1(:,k),thctxa2(:,k));
% end
% runs = contiguous(pv<=.05);
% runs = runs{2,2};
% for k = 1 : size(runs,1)
%     splot{k} = runs(k,:);
% end
