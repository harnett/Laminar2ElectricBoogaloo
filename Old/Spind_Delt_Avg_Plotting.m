clear
cd Y:\Milan\DriveDataSleep
load subs.mat
for k = [1 3:6]
    cd(subs{k})
    load('delta_avg_sub2.mat')
    subplot(2,3,k)
    plot(zscore(mean(rast_avgmeana(uia==1,:)))), hold on
    plot(zscore(mean(rast_avgmeana(uia==2,:))))
end

%% ADD SOME PIZZAZ
clear
cd Y:\Milan\DriveDataSleep
load subs.mat
for k = [4 5]
    cd(subs{k})
    load('spind_avg_sub2.mat')
    subplot(1,2,k-3)
    plot(zscore(mean(rast_avgmeana(uia==2,:))))
%     if k==3
%         avglfpa = -avglfpa;
%     end
    hold on, plot(zscore(mean(avglfpa,1)))
%     hold on
%     plot(zscore(mean(rast_avgmeana(uia==1,:))))
end