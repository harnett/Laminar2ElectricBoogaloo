clear
% for pfc lam - dont worry about sync vs async DS
addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
cd C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam
sess_folders = {'C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-06-23_18-23-06','C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-06-26_11-10-11','C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-06-27_11-48-55','C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-06-28_14-09-44',...
'C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-07-05_11-13-50',...
'C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-07-16_15-02-42','C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-08-07_15-55-34'};
nCh = 64;%15;
sfrqa=[]; fda=[]; %loop thru sessions
for sessf = 1 : length(sess_folders)
cd(sess_folders{sessf})
%detect downstates
load('LFP_1k.mat')

%load('MUA_1k.mat')

load('States.mat')

%get CSD
% bchan = [1 3 9 11 34 57];
% for k = bchan
%     if k == 1
%         lfp.trial{1}(k,:) = .5*lfp.trial{1}(2,:);
%     elseif k==size(lfp.trial{1},1)
%         lfp.trial{1}(k,:) = .5*lfp.trial{1}(k-1,:);
%     else 
%         lfp.trial{1}(k,:) = (lfp.trial{1}((k-1),:) + lfp.trial{1}((k+1),:)) ./ 2;
%     end
% 
% end

% lfp = LFP_ChanDownsamp_Mean_DualLam(lfp,15+1);
% lfp.trial{1}(1:(end-1),:) = diff(lfp.trial{1});
% cfg=[]; cfg.channel = lfp.label([1:15 17:(end-1)]); lfp = ft_preprocessing(cfg,lfp);

[sfrq,~,fq_ax] = state_freqv2(lfp,states,5);

if isempty(sfrqa)
    sfrqa = nan(nCh*2,length(fq_ax),3,length(sessf));
    fda = sfrqa;
end

sfrqa(:,:,:,sessf) = sfrq;

disp(sessf)

end
fda = sfrqa;
fda(1:64,:,:,:) = fdnormv2(fda(1:64,:,:,:));
fda(65:128,:,:,:) = fdnormv2(fda(65:128,:,:,:));

% csd.trial{1}(1:13,:)=pg2csdv3(lfp2.trial{1}(1:15,:));
% csd.trial{1}(14:26,:)=pg2csdv3(lfp2.trial{1}(17:31,:));

%spindle power / number of spindles per channel

%MUA / rasters averaged on spindles detected every channel

%spindle SO phase locking by PAC...

%... and by PLV of detected events

% [PACma, PACzma, ModIndma, ModIndZma] = LFPMUA_MI(lfp2,mua,200,time_STATE2gs(states(1).t))