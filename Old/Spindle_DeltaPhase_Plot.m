clear
cd Y:\Milan\DriveDataSleep
load('subs')
subsiplot=[];
bi = [1 0 0 0 1 0];
ploti = 1; plotip = [1 4 5 3 2];
pfc = []; a1 = []; dphsa=[]; subsi=[];
for k = [1 3:6]
    cd(subs{k})
	if bi(k)
        load('spind_delta_subbi')
    else
        load('spind_delta_sub')
    end
    if k ~=3 && k~=4
    pfc = [pfc dphss];
    else
        a1 = [a1 dphss];
    end
    dphsa = [dphsa dphss];
    subplot(2,3,plotip(ploti))
    plot_dphs(dphss)
    h = findobj(gca,'Type','patch');
    if k ==1 || k==5 || k==6
    h.FaceColor = 'red';
    end
    cm(ploti) = circ_mean(dphss');
    ploti = ploti + 1;
    subsi = [subsi ones(1,length(dphss)).*k];
end
figure
plot_dphs([pfc a1])
title('Spindles Follow Downstates (all spindles)','FontSize',30)
h = findobj(gca,'Type','patch');
h.FaceColor = [1 .6571 0];
%[~,cds] = sort(abs(circ_dist(dphsa,circ_mean(dphsa'))));
line(circ_mean(dphsa')-[.55296 .55296],[0 1200],'Color','red','LineStyle','--','LineWidth',10)
line(circ_mean(dphsa')+[.55296 .55296],[0 1200],'Color','red','LineStyle','--','LineWidth',10)

line(circ_mean(dphsa')-[2.0901 2.0901],[0 1200],'Color','blue','LineStyle','--','LineWidth',10)
line(circ_mean(dphsa')+[2.0901 2.0901],[0 1200],'Color','blue','LineStyle','--','LineWidth',10)

% figure
% compass(cos(cm),sin(cm))
% plot histogram for each
figure
subplot(1,2,1)
plot_dphs(pfc)
title('All PFC Spindles (r = .14)','FontSize',30)
h = findobj(gca,'Type','patch');
h.FaceColor = 'red';
subplot(1,2,2)
plot_dphs(a1)
title('All A1 Spindles (r = .35)','FontSize',30)
circ_r(pfc')
%suptitle('A1 Spindles more locked to downstates than PFC Spindles')
kurtall = nan(5,500); ploti=1;
for kk = [1 3:6]
for k = 1 : 500
    shffphs = dphsa(subsi==kk);
    shffphs = shffphs(randperm(length(shffphs)));
    shffphs = shffphs(1:300);
    kurtall(ploti,k) = circ_r(shffphs');
end
ploti = ploti+1;
end
cl = [ones(1,500) ones(1,1000).*2 ones(1,1000)];
for k = 1 : length(cl)
    if cl(k)==1
    clb{k} = 'MD/PFC';
    else
        clb{k} = 'MGB/A1';
    end
end
figure
g=gramm('x',[ones(1,500).*3 ones(1,500) ones(1,500).*2 ones(1,500).*4 ones(1,500).*5],...
    'y',reshape(kurtall',[1 2500]),'color',clb);
g.stat_boxplot();
g.set_names('x','Ms #','y','R-value','color','Area')
g.set_title('SO-Spindle Phase Locking (bootstrap)','FontSize',30)
g.axe_property('XTick',1:5,'FontSize',25)
g.draw();
%%
kurtall = nan(2,200);
for k = 1 : 200
    pfcs = pfc(randperm(length(pfc)));
    a1s = a1(randperm(length(a1)));
    pfcs = pfcs(1:300); a1s = a1s(1:300);
    kurtall(1,k) = circ_kurtosis(pfcs'); kurtall(2,k) = circ_kurtosis(a1s');
end
% figure
% hist(kurtall(1,:)), hold on, hist(kurtall(2,:),'r')
ranksum(kurtall(1,:),kurtall(2,:))
    