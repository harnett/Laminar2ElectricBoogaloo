cd Y:\Milan\DriveDataSleep

clear

load subs.mat

ploti = 1; plotip = [1 4 5 3 2]; bi = [1 0 0 0 1 0];
ttls = {'MD/PFC Ms 1','MGB/A1 Ms 1','MGB/A1 Ms 2','MD/PFC Ms 3','MD/PFC Ms 2'};
for k = [1 3:6]
    dphss=[]; yaa=[];
        cd(subs{k})
        clear yaa dphs dphss
    if bi(k)
load('spindfft_sum2.mat')
load('spind_delta_subbi.mat')
    else
    load('spind_dist_dphs.mat')
    load('spindfft_sum2.mat')
    end
    
    disp(length(dphss))
    disp(size(yaa,3))
    
[~,cds] = sort(abs(circ_dist(dphss,circ_mean(dphss'))));

y = squeeze(yaa(1,:,cds))';

yc = y(1:round(size(y,1).*.25),:);
yuc = y(round(1+(size(y,1).*.75)):end,:);

subplot(2,3,plotip(ploti))
shadedErrorBar(fx,mean(yc),std(yc)./sqrt(size(yc,1)),'LineProps',{'Color','b'})
hold on
shadedErrorBar(fx,mean(yuc),std(yuc)./sqrt(size(yuc,1)),'LineProps',{'Color','r'})
xlabel('Frequency (Hz)','FontSize',25)
ylabel('Power (uV^2/Hz)','FontSize',25)
title(ttls{ploti})
xlim([0 40])
sd(ploti) = ranksum(mean(yc(:,15:38),2),mean(yuc(:,15:38),2));
ploti = ploti + 1;
end