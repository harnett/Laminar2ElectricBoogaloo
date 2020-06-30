addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
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
                             
t = TimeStamps - TimeStamps(1); t=t(2:(end-1));

t = round(t./1000);

t(t>=(1000*((80*60))))=[];

lfp.trial{1}(9,:) = 0; lfp.trial{1}(9,t) = 10;

td=diff(t);
td=td(1:2:end);

%td = td(2:end);

t = t(1:2:end);% t = t(1:(end-1));

%td = td(2:end);% t = t(1:(end-1));
% 
% bch = [9 86 89 91 99 113]; %[9 53 86 89 91 99 113]; !!! 53 should be on it but we'll use as trig channel instead
% 
% for k = bch
% lfp.trial{1}(k,:) = (lfp.trial{1}((k-1),:) + lfp.trial{1}((k+1),:))./2;
% end

% lfp.trial{1}(72,:) = lfp.trial{1}(75,:).*.25 + lfp.trial{1}(71,:).*.75;
% lfp.trial{1}(73,:) = lfp.trial{1}(75,:).*.5 + lfp.trial{1}(71,:).*.5;
% lfp.trial{1}(74,:) = lfp.trial{1}(75,:).*.75 + lfp.trial{1}(71,:).*.25;

lfp_orig = lfp; mua_orig = mua;
%%
%lfp = lfp_orig; mua = mua_orig;
%t = t_orig;

%[t,inds] = intersect(t,sws); td = td(inds);

cfg=[]; cfg.trl = zeros(length(t),3); cfg.trl(:,1) = t-200; cfg.trl(:,2) = t + 400; 
lfp = ft_redefinetrial(cfg,lfp); mua = ft_redefinetrial(cfg,mua); spk.hdr=lfp.hdr; spk = ft_redefinetrial(cfg,spk);

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