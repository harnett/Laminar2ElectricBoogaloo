addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
%%
load('LFP_1k.mat')
load('MUA_1k.mat')
load('unitdata.mat')

for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
spklbl{k} = ['u' num2str(k)];
end
[dn,~] = binspikes(spk,1000); dn(dn>1) = 1; dn=dn';
if length(dn) < length(lfp.trial{1})
dn = [dn zeros(size(dn,1),length(lfp.trial{1})-length(dn))];
end
clear spk
spk = lfp; spk.trial{1} = dn; spk.label = spklbl;

%%
[TimeStamps, EventIDs, TTLs, Extras, EventStrings, Header] = ...
                      Nlx2MatEV( 'Events.nev', [1 1 1 1 1], 1,...
                                 1, 1 );
                             
t = TimeStamps - TimeStamps(1); 

%[~,indi] = find( abs(diff(t./1000) - 250 ) <= 5);
[~,indi] = find( abs(diff(t./1000) - 1000 ) <= 5);

t = round(t./1000); t = t(indi);

t = t + 7000;

% lfp.trial{1}(9,:) = 0; lfp.trial{1}(9,t) = 10;

lfp_orig = lfp; mua_orig = mua;
%%
%lfp = lfp_orig; mua = mua_orig;
%t = t_orig;

%[t,inds] = intersect(t,sws); td = td(inds);
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
lfp = lfp_orig;

%[-3100 -100]
%[4900 7900]

cfg=[]; cfg.trl = zeros(length(t),3); cfg.trl(:,1) = t-10000; cfg.trl(:,2) = t + 10000; 
lfp = ft_redefinetrial(cfg,lfp);
cfg=[]; cfg.trl = zeros(length(t),3); cfg.trl(:,1) = t-3100; cfg.trl(:,2) = t - 100; 
lfp1 = ft_redefinetrial(cfg,lfp);
cfg=[]; cfg.trl = zeros(length(t),3); cfg.trl(:,1) = t+4900; cfg.trl(:,2) = t+7900; 
lfp2 = ft_redefinetrial(cfg,lfp);

cfg=[]; cfg.method='mtmfft'; cfg.tapsmofrq=(1./3);
cfg.output='pow'; cfg.keeptrials = 'yes';
cfg.foilim=[0 400]; 
frq1=ft_freqanalysis(cfg,lfp1);
frq2=ft_freqanalysis(cfg,lfp2);

v1 = squeeze(std(frq1.powspctrm))./sqrt(size(frq1.powspctrm,1));
v2 = squeeze(std(frq2.powspctrm))./sqrt(size(frq2.powspctrm,1));
m1 = squeeze(mean(frq1.powspctrm));
m2 = squeeze(mean(frq2.powspctrm));

for k = 1 : 64
subplot(8,8,k)
shadedErrorBar(frq1.freq,m1(k,:),v1(k,:)), hold on, shadedErrorBar(frq1.freq,m2(k,:),v2(k,:)), xlim([0 15])
end

clear pv; for k = 1 : 64
for kk = 1 : 1201
pv(k,kk) = signrank(squeeze(frq1.powspctrm(:,k,kk)),squeeze(frq2.powspctrm(:,k,kk)));
end
end

cfg=[]; cfg.trl = zeros(length(t),3); cfg.trl(:,1) = t-10000; cfg.trl(:,2) = t + 10000; 
lfp = ft_redefinetrial(cfg,lfp); mua = ft_redefinetrial(cfg,mua); 
spk.hdr=lfp.hdr; spk = ft_redefinetrial(cfg,spk);

x = fieldtrip2mat_epochs(mua);

imagesc(-500:2000,1:64,squeeze(nanmean(x(1:64,:,[22:109 112:178]),3)),[7 20])
xlim([-100 400])
colorbar

figure

y = fieldtrip2mat_epochs(lfp);

imagesc(-500:2000,1:64,squeeze(nanmean(y(1:64,:,[22:109 112:178]),3)))
xlim([-100 900])
colorbar

%cfg=[]; cfg.trials = find(y<=50); lfp = ft_redefinetrial(cfg,lfp); 

y=fieldtrip2mat_epochs(lfp);
y=max(y,[],2);
y=max(y,[],1);
y=squeeze(y);

td = td(find(y<=500));
t = t(find(y<=500));

cfg=[]; cfg.trials = find(abs(td-15)<=2);
mua_freq=ft_redefinetrial(cfg,mua);
lfp_freq=ft_redefinetrial(cfg,lfp);
spk_freq=ft_redefinetrial(cfg,spk);
cfg=[];
mua_freq_avg=ft_timelockanalysis(cfg,mua_freq);
lfp_freq_avg=ft_timelockanalysis(cfg,lfp_freq);
spk_freq_avg=ft_timelockanalysis(cfg,spk_freq);

cfg=[]; cfg.trials = find(abs(td-10)<=2);
mua_odd=ft_redefinetrial(cfg,mua);
lfp_odd=ft_redefinetrial(cfg,lfp);
spk_odd=ft_redefinetrial(cfg,spk);
cfg=[];
mua_odd_avg=ft_timelockanalysis(cfg,mua_odd);
lfp_odd_avg=ft_timelockanalysis(cfg,lfp_odd);
spk_odd_avg=ft_timelockanalysis(cfg,spk_odd);

cfg=[]; cfg.trials = find(abs(td-5)<=2);
mua_om=ft_redefinetrial(cfg,mua);
lfp_om=ft_redefinetrial(cfg,lfp);
spk_om=ft_redefinetrial(cfg,spk);
cfg=[];
mua_om_avg=ft_timelockanalysis(cfg,mua_om);
lfp_om_avg=ft_timelockanalysis(cfg,lfp_om);
spk_om_avg=ft_timelockanalysis(cfg,spk_om);