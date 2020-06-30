addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\djh'))
%%
clear

cd Y:\Milan\DriveDataSleep

load('subs')

tl = 1000;
tdaa = []; subsi = [];
for k = 3 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    load('all_good_ctx_th_ch.mat')
    load('gch.mat')
    tda=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        load('LFP_1k.mat')
        load('States.mat')
        times_all = findspindlesv5(data,1000,9,17,time_STATE2gs(states(1).t),2.2);
        st = mean(times_all(:,1:2),2);
        %st = (times_all(:,1));
        if isempty(st)
            continue
        end
        CtxCh = intersect(gch,CtxCh); ThCh = intersect(gch,ThCh);
        for kkk = CtxCh%loop thru ctx ch
            for kkkk = ThCh%loop thru thal ch
                td=(st(find(times_all(:,3)==kkk))'-st(find(times_all(:,3)==kkkk)));
                if isempty(td)
                    continue
                end
                td = td(:);
                tda = [tda; td(find(abs(td)<=tl))];
            end
        end
        
                %end
    end
    cd(subs{k})
    if isempty(tda)
        continue
    end
    save('spind_rel_timing_allch.mat','tda')
    tdaa = [tdaa; tda];
    subsi = [subsi ones(1,length(tda)).*k];
%     save('spkr_sum.mat','rsa','zsa','pvsa','angsa','sessia')
    disp(signrank(tda))
end

cd Y:\Milan\DriveDataSleep

save('spind_reltiming_all_v2.mat','tdaa','subsi')

%%
clear
load('spind_reltiming_all_v2.mat')
% for k = 1 : 6
% subplot(2,3,k)
% if ~isempty(find(subsi==k))
% hist(tdaa(subsi==k),20)
% %title(mean(tdaa(subsi==k)))
% %xlabel(signrank(tdaa(subsi==k)))
% end
% end

ploti = 1; plotip = [1 3 4 2];
for k = [1 3:6]
    if ~isempty(find(subsi==k))
    subplot(2,2,plotip(ploti))
    hist(tdaa(subsi==k),20)
    set(gca,'fontsize',20)
    box off
    xlabel('Spindle onset lag (ms)','FontSize',25), ylabel('# of spindles','FontSize',25)
    h = findobj(gca,'Type','patch');
    if k ==1 || k==5 || k==6
    h.FaceColor = 'red';
    end
    ploti = ploti + 1;
    end
end
%%
clear
load('spind_reltiming_all_v2.mat')

subplot(1,2,2)
hist(tdaa([find(subsi==1) find(subsi==6)]),20)
set(gca,'FontSize',20)
box off
    xlabel('Spindle onset lag (ms)','FontSize',25), ylabel('# of spindles','FontSize',25)
    title('MD/PFC Spindle-Spindle Coupling','FontSize',30)
    h = findobj(gca,'Type','patch');
    h.FaceColor = 'red';
subplot(1,2,1)
hist(tdaa([find(subsi==3) find(subsi==4)]),20)
set(gca,'FontSize',20)
    title('MGB/A1 Spindle-Spindle Coupling','FontSize',30)
box off
    xlabel('Spindle onset lag (ms)','FontSize',25), ylabel('# of spindles','FontSize',25)

%%
clear
load('spind_reltiming_all_v2.mat')
nShuff = 1000;
kurtall = nan(6,nShuff);
for k = 1 : 6
    ts = tdaa(find(subsi==k));
    slen = 500;
    if isempty(ts)
        continue
    end
    for kk = 1 : nShuff
        tss = ts(randperm(length(ts))); tss = tss(1:slen);
        kurtall(k,kk) = kurtosis(tss);
    end
end

kurtall = kurtall([3 4 1 6],:);
boxplot(kurtall')

cl = [ones(1,1000).*1 ones(1,1000).*2 ones(1,1000).*3 ones(1,1000).*4];

for k = 1 : length(cl)
    if cl(k)==1 || cl(k)==2
    clb{k} = 'MGB/A1';
    elseif cl(k)==3 || cl(k)==4
        clb{k} = 'MD/PFC';
    end
end

figure

g=gramm('x',cl,...
    'y',reshape(kurtall',[1 4000]),'color',clb);
g.stat_boxplot();
g.set_names('x','Ms #','y','Peakedness','color','Area')
g.set_title('Spindle-Spindle Synchrony (bootstrap)','FontSize',30)
g.axe_property('XTick',1:4,'FontSize',25)
g.draw();
