clear
%%
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
%%
load('LFP_1k.mat')
load('MUA_1k.mat')
%%
l = lfp.label;
for k = 1 : length(l)
    inds(k) = str2double(l{k}(5:end));
end

inds(inds>=33)=100;
inds(inds~=100) = 0;
inds(inds==100) = 1;
%%
lfp.trial{1}(find(inds==0),:) = lfp.trial{1}(find(inds==0),:)-mean(lfp.trial{1}(find(inds==0),:));
lfp.trial{1}(find(inds==1),:) = lfp.trial{1}(find(inds==1),:) - mean(lfp.trial{1}(find(inds==1),:));
%%
[TimeStamps, EventIDs, TTLs, Extras, EventStrings, Header] = ...
                      Nlx2MatEV( 'Events.nev', [1 1 1 1 1], 1,...
                                 1, 1 );
%%                             
t = TimeStamps - TimeStamps(1); t=t(2:(end-1));
%t=t(1:2:end);
t = round(t./1000);
lfp.trial{1}(15,:) = 0; lfp.trial{1}(15,t) = 20;

td=diff(t);
gtr=find(abs(td-3103)<=10);
t=t(gtr-1);

% td=td(1:2:end);
% td = round(td./1000);
% t = t(1:2:end);


bch = [];

lfp_orig = lfp;
mua_orig = mua;

cfg=[]; cfg.trl = zeros(length(t),3); cfg.trl(:,1) = t-1000; cfg.trl(:,2) = t + 1400; lfp = ft_redefinetrial(cfg,lfp);
mua=ft_redefinetrial(cfg,mua);

cfg=[];
mua_avg=ft_timelockanalysis(cfg,mua);
lfp_avg=ft_timelockanalysis(cfg,lfp);
imagesc(lfp_avg.avg,[-15 15])
figure, imagesc(zscore(mua_avg.avg,[],2))