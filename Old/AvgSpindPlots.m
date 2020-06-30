cd Y:\Milan\DriveDataSleep\WT14orMGBA1
clear
load spind_avg_sub3
tx = linspace(-500,500,1001);
figure
subplot(3,2,1)
plot(tx,avglfpa(1,:,2),'b')
set(gca,'FontSize',20)
title('MGB/A1','FontSize',30)
ylabel('Voltage (uV)','FontSize',25)
box off
subplot(3,2,3)
plot(tx,avglfpa(2,:,2),'m')
set(gca,'FontSize',20)
ylabel('Voltage (uV)','FontSize',25)
box off
subplot(3,2,5)
plot(tx,mean(rast_avgmeana(uia==2,:)),'r')
set(gca,'FontSize',20)
xlabel('Time (ms)','FontSize',25)
ylabel('Average Firing (a.u.)','FontSize',25)
box off

cd Y:\Milan\DriveDataSleep\WT19
clear
load spind_avg_sub4
tx = linspace(-500,500,1001);
subplot(3,2,2)
plot(tx,-avglfpa(1,:,2),'b')
set(gca,'FontSize',20)
title('MD/PFC','FontSize',30)
box off
subplot(3,2,4)
plot(tx,-avglfpa(2,:,2),'m')
set(gca,'FontSize',20)
box off
subplot(3,2,6)
plot(tx,mean(rast_avgmeana(uia==2,:)),'r')
set(gca,'FontSize',20)
xlabel('Time (ms)','FontSize',25)
box off

