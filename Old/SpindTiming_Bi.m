%%
clear

cd Y:\Milan\DriveDataSleep

load('subs')

subsi=[]; tdaa=[];
for k = 1 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    tda=[];
    for kk = 1 : length(good_sess)
        td=[];
        cd(good_sess{kk}) 
        load('LFPBi_StCh.mat')
        st = mean(times_all(:,1:2),2);
        td=(st(find(times_all(:,3)==ctxmx))'-st(find(times_all(:,3)==thmx)));
        td=td(:);
        if isempty(td)
            continue
        end
    end
    tda = [tda; td]; subsi=[subsi ones(1,length(tda)).*k];
    tdaa = [tdaa; tda];
    save('spindtiming_bi.mat','tda')
    cd(subs{k})
    disp(k)
end
cd Y:\Milan\DriveDataSleep
save('spindtiming_bi_all.mat','tdaa','subsi')