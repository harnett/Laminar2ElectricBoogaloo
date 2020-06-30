for s = 1 : 4
hd = squeeze(nansum(h_all(:,:,s,:),3));
hd = (squeeze(mean(hd(:,75:80,:),2)) - squeeze(mean(hd(:,[1:60 100:160],:),2))) ./ squeeze(mean(hd(:,[1:60 100:160],:),2));

sd = squeeze(nanstd(h_all,[],3));
sd = (squeeze(mean(sd(:,75:80,:),2)) - squeeze(mean(sd(:,[1:60 100:160],:),2))) ./ squeeze(mean(sd(:,[1:60 100:160],:),2));
sd = sd ./ sqrt(7);

cs = {'b','r','g'};
figure, for k = 1 : 3
    subplot(1,2,1)
plot(squeeze(hd(1:15,k)).*100,cs{k}), ylim([0 35])%errorbar(squeeze(hd(1:15,k)),squeeze(sd(1:15,k))), ylim([0 .35])
ylabel('% increase in spindle rate after DS')
xlabel('channel #')
hold on
end, set(gcf,'PaperSize',[15 15])
title('PFC spindles')
box off
legend('PFC DS alone','A1 DS alone','PFC and A1 DS')
set(gca,'Fontsize',25)
for k = 1 : 3
    subplot(1,2,2)
plot(squeeze(hd(16:30,k)).*100,cs{k}), ylim([0 35])
ylabel('% increase in spindle rate after DS')
xlabel('channel #')
hold on
end
title('A1 spindles')
box off
legend('PFC DS alone','A1 DS alone','PFC and A1 DS')
set(gca,'Fontsize',25)
% print('pfcvsa1','-dpdf','-bestfit')
end
%%
nCh = 23;
hd = squeeze(nansum(h_all_ss(:,:,:,:,:),4));
hd = (squeeze(mean(hd(:,:,70:90,:),3)) - squeeze(mean(hd(:,:,[1:60 100:160],:),3))) ./ squeeze(mean(hd(:,:,[1:60 100:160],:),3));

x=(hd(24:end,1:23,1));
spindt{1,1}=(x(:));
x=(hd(24:end,1:23,2));
spindt{1,2}=(x(:));
x=(hd(24:end,1:23,3));
spindt{1,3}=(x(:));
x=(hd(1:23,24:end,1));
spindt{2,1}=(x(:));
x=(hd(1:23,24:end,2));
spindt{2,2}=(x(:));
x=(hd(1:23,24:end,3));
spindt{2,3}=(x(:));

for k = 1 : 2
    for kk = 1 : 3
        for kkk = 1 : 2
            for kkkk = 1 : 3
                sdt(k,kk,kkk,kkkk) = signrank(spindt{k,kk},spindt{kkk,kkkk});
            end
        end
    end
end

clear hdd
hd = squeeze(nansum(h_all_ss(:,:,:,:,:),4));
for k = 1 : nCh
    hdd(k,:,:) = mean(hd(k,(nCh+1:end),:,:),2);
end
for k = (nCh+1) : (nCh*2)
    hdd(k,:,:) = mean(hd(k,(1:nCh),:,:),2);
end
hdd = mea