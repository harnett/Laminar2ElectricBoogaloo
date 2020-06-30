load('LFP_1k.mat')
load('MUA_1k.mat')
load('States.mat')

lfp2 = LFP_ChanDownsamp_Mean_DualLam(lfp,16);

mua_mn = zscore([mean(mua.trial{1}(1:64,:)); mean(mua.trial{1}(65:end,:))],[],2);

cfg=[]; cfg.channel = mua.label(1:2); mua2 = ft_preprocessing(cfg,mua);
mua2.trial{1} = mua_mn;

cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq = [.2 2.2]; cfg.bpinstabilityfix='reduce';
mua2 = ft_preprocessing(cfg,mua2);

[~,pk1] = findpeaks(-mua2.trial{1}(1,:)); pk1 = intersect(pk1,time_STATE2gs(states(1).t));
[~,pk2] = findpeaks(-mua2.trial{1}(2,:)); pk2 = intersect(pk2,time_STATE2gs(states(1).t));

td = pk1 - pk2'; td=td(:); td(abs(td)>=2000)=[]; signrank(td)
h=hist(td,100);
hist(td,100), hold on;
box off, plot([0 0],[0 max(h)],'--','Color','k','LineWidth',5)

cc = zeros(1,length(pk1));
for k = 1 : length(pk1)
    td = pk2 - pk1(k);
    if ~isempty(find(abs(td)<=100))
        cc(k) = 1;
    end
end
mean(cc)

pk = pk1(find(cc==1));

cfg=[]; cfg.trl=zeros(length(pk),3); cfg.trl(:,1) = pk-1500;
cfg.trl(:,2) = pk+1500; osc_avgd = ft_redefinetrial(cfg,lfp2);
cfg=[]; osc_avgd = ft_timelockanalysis(cfg,osc_avgd);
figure
%imagesc(osc_avgd.avg)
imagesc(osc_avgd.avg([1:15 17:31],:))
% for k = 1 : size(mua_mn,1)
%     mua_mn(k,:) = zscore(smooth(mua_mn(k,:),10));
% end

allpks = DSDetector(lfp2,mua_mn,time_STATE2gs(states(1).t),[16 28]);

cfg=[]; cfg.trl=zeros(length(allpks{1}),3); cfg.trl(:,1) = allpks{1}-1500;
cfg.trl(:,2) = allpks{1}+1500; osc_avgd = ft_redefinetrial(cfg,lfp2);
cfg=[]; osc_avgd = ft_timelockanalysis(cfg,osc_avgd);
imagesc(osc_avgd.avg)

cfg=[]; cfg.method='wavelet'; cfg.output = 'pow'; 
cfg.trials = 1:10:3891; 
cfg.toi = [0:.01:3]; cfg.foi=[5:.5:50]; cfg.width=6; frq = ft_freqanalysis(cfg,osc_avgd);

for k = 1 : length(allpks)
    x
end

td

td = allpks{1} - allpks{2}'; td = td(:); td(abs(td)>=800)=[];
h=hist(td,100);
hist(td,100), hold on;
box off, plot([0 0],[0 max(h)],'--','Color','k','LineWidth',5)

times_all = findspindlesv5(lfp2,1000,8,16,time_STATE2gs(states(1).t),2.6);

pk1 = allpks{1}; pk2 = allpks{2};

cc = zeros(1,length(pk1));
for k = 1 : length(pk1)
td = pk2 - pk1(k);
if ~isempty(find(abs(td)<=1000))
cc(k) = 1;
end
end
mean(cc)

figure
pk = pk1(find(cc));
st=(times_all(find(times_all(:,3)==1),1));
td = pk' - st'; %allpks{1}' - st'; 
td = td(:); td(abs(td)>=2500)=[];
subplot(2,1,1)
hist(-td,40), box off%, xlim([-1000 1000])

pk = pk1(find(~cc));
st=(times_all(find(times_all(:,3)==1),1));
td = pk' - st'; %allpks{1}' - st'; 
td = td(:); td(abs(td)>=2500)=[];
subplot(2,1,2)
hist(-td,40), box off, ylim([0 25])%, xlim([-1000 1000])

pk = pk1(find(~cc));
%st=mean(times_all(:,1:2),2);
figure
for k = 1 : 16
st=(times_all(find(times_all(:,3)==k),1));

td = pk' - st'; %allpks{1}' - st'; 
td = td(:); td(abs(td)>=1500)=[];
subplot(4,4,k)
hist(-td,20)
ha3(k,:) = hist(-td,20);
end
%%

spind_dat = lfp2; spind_dat.trial{1} = zeros(size(spind_dat.trial{1},1),size(spind_dat.trial{1},2));
for k = 1 : size(spind_dat.trial{1},1)
    %spind_dat.trial{1}(k,round(mean(times_all(find(times_all(:,3)==k),1:2),1))) = 1;
    spind_dat.trial{1}(k,times_all(find(times_all(:,3)==k),1),1) = 1;
end

pk = allpks{2};%pk1;
cfg=[]; cfg.trl=zeros(length(pk),3); cfg.trl(:,1) = pk-1500;
cfg.trl(:,2) = pk+1500; spind_avgd = ft_redefinetrial(cfg,spind_dat);

x=fieldtrip2mat_epochs(spind_avgd);
x1 = squeeze(x(1,1500:1800,:));
x2 = find(sum(x1));

cfg=[]; cfg.trl=zeros(length(pk),3); cfg.trl(:,1) = pk-1500;
cfg.trl(:,2) = pk+1500; osc_avgd = ft_redefinetrial(cfg,lfp2);
cfg=[]; cfg.trials = x2; osc_avgd = ft_redefinetrial(cfg,osc_avgd);

cfg=[]; spind_avgd = ft_timelockanalysis(cfg,spind_avgd);