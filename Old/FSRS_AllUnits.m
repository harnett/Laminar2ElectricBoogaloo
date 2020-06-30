clear

cd Y:\Milan\DriveDataSleep

load('subs')

tl = 1000;
tdaa = []; subsi = [];
for k = [1 3:6]
    cd(subs{k})
    load('good_sess.mat')
    load('all_good_ctx_th_ch.mat')
    load('gch.mat')
    tda=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        load('unitdata.mat')
        
    end
    
end