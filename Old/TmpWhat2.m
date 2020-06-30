shadedErrorBar(1:1001,rast_avgmean{1,2}(10,:)-mean(rast_avgmean{1,2}(10,:)),1.96*rast_avgstd{1,2}(10,:)./sqrt(size(rast_avgmean{1,2},2)),'lineprops',{'color','b'}), hold on, shadedErrorBar(1:1001,rast_avgmean{1,2}(66,:)-mean(rast_avgmean{1,2}(66,:)),1.96*rast_avgstd{1,2}(66,:)./sqrt(size(rast_avgmean{1,2},2)),'LineProps',{'Color','r'}), xlim([200 600]), ylim([-1 1])
title ('Superficial and Deep Cells Fire Counterphase During Spindles')
xlabel('Time from Spindle Trough (ms)')
ylabel('Firing Rate (Hz)')