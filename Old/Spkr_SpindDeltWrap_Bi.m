addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\djh'))

clear

cd Y:\Milan\DriveDataSleep

load('subs')

%usebi = [1 0 0 0 1 0];

subsi=[]; dphsa=[]; sdpva=[]; sdza=[]; sessia=[];
for k = [1 3:6]
    cd(subs{k})
    load('good_sess.mat')
    rsa=[]; zsa=[]; pvsa=[]; angsa=[]; sdpv=[]; sdz=[]; dphss=[]; sessi=[];
    for kk = 1 : length(good_sess)
        dphs=[];
        cd(good_sess{kk}) 
        %if ~isfile('spkr_res.mat')
        load('LFPBi_StCh.mat')
        load('States.mat')
        load('unitdata.mat')
        if ~isempty(times_all(:,3)==ctxmx)
        spind_gs = st2gs(times_all);
        [dphs,pv,z] = spind_delta_phscoupling(data,times_all(times_all(:,3)==ctxmx,1:2));
        sdpv = [sdpv pv]; sdz = [sdz z]; dphss = [dphss dphs]; sessi = [sessi ones(1,length(dphs)).*kk];
        save('spind_delt_couplingBi.mat','pv','z','dphs')
        data.fsample = 1000;
        % get r-value for all
        [rs,zs,pvs,angs] = spk_rtest(data,unitdata,[.5 3.5;9 17],spind_gs,1000);
        rsa = cat(3,rsa,rs); zsa = cat(3,zsa,zs); pvsa = cat(3,pvsa,pvs); angsa = cat(3,angsa,angs);
        save('spkr_resbi.mat','rs','zs','pvs','angs') 
        end
    end
    subsi=[subsi ones(1,length(dphss)).*k];
    sdpva = [sdpva sdpv]; sdza = [sdza sdz]; dphsa = [dphsa dphss]; sessia = [sessia sessi];
    cd(subs{k})
    
     save('spkr_sumbi.mat','rsa','zsa','pvsa','angsa','sessia')
    
    save('spind_delta_subbi.mat','sdpv','sdz','dphss','sessi')
    disp(k)
end
cd Y:\Milan\DriveDataSleep
save('spind_delta_allbi.mat','sdpva','sdza','subsi','dphsa','sessia')