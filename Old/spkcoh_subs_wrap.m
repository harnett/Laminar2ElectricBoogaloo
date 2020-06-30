cd Y:\Milan\DriveDataSleep

load('subs')

for k = 1 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    load('gch.mat')
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        load('States.mat')
        load('unitdata.mat')
        spkcoh = spk_coh(unitdata,states,1000); save('spkcoh.mat','spkcoh');
    end
    disp(k)
end