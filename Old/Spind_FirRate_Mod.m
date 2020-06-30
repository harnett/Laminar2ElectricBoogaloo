cd Y:\Milan\DriveDataSleep
clear
load subs.mat

bi = [1 0 0 0 1 0];
fr_mu_all = []; fr_cpld_mu_all=[]; fr_uncpld_mu_all=[]; subsi=[];
cpl_diffa = []; sp_diffa = [];
for k = [1 3:6]
    cd(subs{k})
    load('good_sess.mat')
    fr_mu_sub = []; fr_cpld_mu_sub=[]; fr_uncpld_mu_sub=[]; 
    cpl_diff_sub = []; sp_diff_sub = [];
    for kk = 1 : length(good_sess)
        dphs=[]; cpl_diff=[]; sp_diff=[];
    cd(good_sess{kk})
    if bi(k)
        load('spind_delt_couplingBi.mat')
        load('LFPBi_StCh.mat')
    else
        load('sess_dphs.mat')
        load('LFP_1k.mat')
    end
    load('unitdata.mat')
    spk=[];
    for ks = 1 : length(unitdata)
        spk(ks).time = unitdata(ks).ts;
    end
    [dn,~] = binspikes(spk,1000,[data.time{1}(1) data.time{1}(end)]); dn = dn'; dn(dn>1) = 1;
    load('spind_res_findspind2.mat')
    nspk = zeros(size(dn,1),size(st,1));
    % spindle vs non spindle
    for ks = 1:size(st,1)
        nspk(:,ks,1) = sum(dn(:,st(ks,1):st(ks,2)),2)./length(st(ks,1):st(ks,2));
        nspk(:,ks,2) = sum(dn(:,st_nons(ks,1):st_nons(ks,2)),2)./length(st(ks,1):st(ks,2));
    end
    nspk = nspk.*1000;
    % coupled spindle vs non-coupled spindle
    [~,cds] = sort(abs(circ_dist(dphs,circ_mean(dphs'))));
    tstd = length(dphs) - size(st,1);
    nspk = nspk(:,sort(cds),:);
    nspk_cpld = nspk(:,1:round(length(cds)/4),:);
    nspk_uncpld = nspk(:,(round(length(cds).*.75)+1):end,:);
    
    for sk =1 : size(nspk_cpld,1)
        cpl_diff(sk) = ranksum(squeeze(nspk_cpld(sk,:,1)),squeeze(nspk_uncpld(sk,:,1)));
    end
    
    for sk =1 : size(nspk,1)
        sp_diff(sk) = signrank(squeeze(nspk(sk,:,1)),squeeze(nspk(sk,:,2)));
    end
    
    fr_mu_sess = squeeze(mean(nspk,2));
    fr_cpld_mu_sess = squeeze(mean(nspk_cpld,2));
    fr_uncpld_mu_sess = squeeze(mean(nspk_uncpld,2));
    save('fr_spind_sess.mat','nspk','nspk_cpld','nspk_uncpld','fr_mu_sess','fr_cpld_mu_sess','fr_uncpld_mu_sess','tstd')
    fr_mu_sub = [fr_mu_sub; fr_mu_sess];
    fr_cpld_mu_sub = [fr_cpld_mu_sub; fr_cpld_mu_sess];
    fr_uncpld_mu_sub = [fr_uncpld_mu_sub; fr_uncpld_mu_sess];
    cpl_diff_sub = [cpl_diff_sub cpl_diff];
    sp_diff_sub = [sp_diff_sub sp_diff];
    end
    cd(subs{k})
    save('FR_All_Sub.mat','fr_mu_sub','fr_cpld_mu_sub',...
        'fr_uncpld_mu_sub','cpl_diff_sub','sp_diff_sub')
    fr_mu_all = [fr_mu_all; fr_mu_sub];
    fr_cpld_mu_all = [fr_cpld_mu_all; fr_cpld_mu_sub];
    fr_uncpld_mu_all = [fr_uncpld_mu_all; fr_uncpld_mu_sub];
    subsi = [subsi ones(1,size(fr_mu_sub,1)).*k];
    cpl_diffa = [cpl_diffa cpl_diff_sub];
    sp_diffa = [sp_diffa sp_diff_sub];
    disp(k)
end

cd Y:\Milan\DriveDataSleep
save('FR_All.mat','fr_mu_all','fr_cpld_mu_all','fr_uncpld_mu_all','subsi','cpl_diffa','sp_diffa')