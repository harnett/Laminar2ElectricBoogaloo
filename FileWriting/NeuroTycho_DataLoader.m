clear
nch = 128;
load(['ECoG_ch1.mat'])
dlen = length(ECoGData_ch1);
dat=nan(nch,dlen); ls=[];
for k = 1 : nch
    load(['ECoG_ch' num2str(k) '.mat'])
    eval(['dat(k,:) = ECoGData_ch' num2str(k) ';'])
    eval(['clear ECoGData_ch' num2str(k)] )
    disp(k)
end

data = dat2fieldtrip(dat,1000);

%%

ChiBi_BadBipolarInds = [4 13 22 33 44 51 55 62 64 79 91 104 108 114 118 120 128]
data.trial{1}(1:(end-1),:) = diff(data.trial{1});
lbg = 1:128; lbg(ChiBi_BadBipolarInds) = []; 

cfg=[]; cfg.channel = data.label(1:2:end); data=ft_preprocessing(cfg,data);

[coh] = Coh_Fieldtrip(data,5,[0 80],[]);

%%

c = abs(coh.cohspctrm);
cd C:\Users\Loomis\Documents\HO_FO_Spindles\NeurotychoData
load('ChibiMAP.mat')

CoordBi = [X Y];
CoordBi(ChiBi_BadBipolarInds,:)= [];
CoordBi = CoordBi(1:2:end,:);

cplt=(squeeze(c(4,:,75)))

figure
image(I);axis equal
hold on
%for i=1:length(CoordBi)
scatter(CoordBi(:,1),CoordBi(:,2),100,cplt,'filled');
%hold off
%%
dat = contgs2seg(data,4,1:length(data.trial{1}));
cfg=[]; cfg.method='mtmfft'; cfg.tapsmofrq=1./(length(dat.trial{1})./1000);
cfg.output='pow'; 
cfg.foilim=[0 400]; frq=ft_freqanalysis(cfg,dat);
pow=frq.powspctrm;

pow = pow ./ repmat(max(pow,[],2),[1 size(pow,2)]);

cplt=(squeeze(pow(:,76)));

figure
image(I);axis equal
hold on
%scatter(CoordBi(:,1),CoordBi(:,2),100,cplt,'filled');
scatter(X,Y,100,cplt,'filled');