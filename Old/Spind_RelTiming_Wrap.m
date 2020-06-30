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
for k = 1 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    load('good_ctx_th_ch.mat')
    tda=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        load('spind_res_findspind.mat')
        %st = mean(times_all(:,1:2),2);
        st = (times_all(:,1));
        td=(st(find(times_all(:,3)==1))'-st(find(times_all(:,3)==2)));
        td = td(:);
        tda = [tda; td(find(abs(td)<=tl))];
                %end
    end
    cd(subs{k})
    save('spind_rel_timing.mat','tda')
    tdaa = [tdaa; tda];
    subsi = [subsi ones(1,length(tda)).*k];
%     save('spkr_sum.mat','rsa','zsa','pvsa','angsa','sessia')
    disp(signrank(tda))
end
signrank(tdaa)

for k = 1 : 5
subplot(2,3,k), hist(tdaa(subsi==k),20)
end
%%
cd Y:\Milan\DriveDataSleep
save('spind_reltiming_all.mat','tdaa','subsi')