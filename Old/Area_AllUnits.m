clear

cd Y:\Milan\DriveDataSleep

load('subs')

tl = 1000;
unitarea=[]; subsi = [];
    uarea=[];
for k = [1 3:6]
    cd(subs{k})
    load('good_sess.mat')
    load('all_good_ctx_th_ch.mat')
    load('gch.mat')
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        load('unitdata.mat')
        for ui = 1 : length(unitdata)
            if strcmp('PFC',unitdata(ui).area)
                uarea = [uarea 1];
            elseif strcmp('MD',unitdata(ui).area)
                uarea = [uarea 2];
                elseif strcmp('A1',unitdata(ui).area)
                uarea = [uarea 3];
                elseif strcmp('MGB',unitdata(ui).area)
                uarea = [uarea 4];
            else
                disp('AIYAAAA')
            end
        end
        subsi = [subsi ones(1,length(unitdata)).*k];
    end
    
    endf
cd Y:\Milan\DriveDataSleep
save('area_all_units.mat','uarea','subsi')