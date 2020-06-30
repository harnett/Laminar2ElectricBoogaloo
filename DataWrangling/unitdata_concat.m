clear

cd Y:\Milan\DriveDataSleep

load('subs')

uall = [];
for k = 1 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    for kk = 1 : length(good_sess)
        cd(good_sess{kk})
        load('unitdata.mat')
        if isfield(unitdata,'fsrs')
        unitdata=rmfield(unitdata,'fsrs');
        end
        uall = [uall unitdata];
    end
    disp(k)
end

cd Y:\Milan\DriveDataSleep
save('unitdata_all.mat','uall')

%%

clear

cd Y:\Milan\DriveDataSleep

load('subs')
state_name = {'nrem','rem','wake'};

for s = 1 : 3
    uall = [];
for k = 1 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    for kk = 1 : length(good_sess)
        cd(good_sess{kk})
        load('unitdata.mat')
        load('States.mat')
        if isfield(unitdata,'fsrs')
        unitdata=rmfield(unitdata,'fsrs');
        end
        gs=time_STATE2gs(states(s).t);
        spk = [];
        for kkk = 1 : length(unitdata)
            spk(kkk).time = unitdata(kkk).ts;
        end
        [dn,t] = binspikes(spk,1000);
        dn = [dn; zeros(max(gs)-length(dn),size(dn,2))]; % pad dn with zeros just in case lfp exceeds spikes
        dn=dn(gs,:);
        for kkk = 1 : length(unitdata)
            unitdata(kkk).ts = find(dn(:,kkk)>=1)./1000;
        end
        uall = [uall unitdata];
    end
    disp(k)
end
unitdata = uall;
cd Y:\Milan\DriveDataSleep
save(['unitdata_' state_name{s} '.mat'],'unitdata')
end