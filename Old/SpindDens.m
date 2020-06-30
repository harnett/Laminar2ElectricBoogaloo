cd Y:\Milan\DriveDataSleep
clear
load subs.mat

spind_dens_all=[]; subsi=[];
for k = [1 3:6]
    cd(subs{k})
    load('good_sess.mat')
    spind_dens_sess = [];
    for kk = 1 : length(good_sess)
        st=[];
    cd(good_sess{kk})
    load('spind_res_findspind2.mat')
    load('States')
    sg = time_STATE2gs(states(1).t);
    spind_dens_sess = size(st,1)./((length(sg))./1000);
    spind_dens_all = [spind_dens_all spind_dens_sess];
    subsi = [subsi k];
    save('spind_dens_sess.mat','spind_dens_sess')
    end
    disp(k)
end

cd Y:\Milan\DriveDataSleep
save('spind_dens_all.mat','spind_dens_all','subsi')