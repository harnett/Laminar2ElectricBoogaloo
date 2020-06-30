% loop thru all sessions / states compute XCorrs!
clear

cd Y:\Milan\DriveDataSleep
sname = {'nrem','rem','wake'};
load('subs')
statename = {'nrem','rem','wake'};
bfile=[]; bfile_ind = 1;
aa = []; xca=[]; xcsiga=[]; xcpa = []; aa_cc=[];
xca_cc = []; xcpa_cc = [];
for k = 1 : length(subs)
    xc = []; xcsig = []; xcp = [];
    xc_cc = []; xcp_cc=[];
    cd(subs{k})
    load('good_sess.mat')
    for kk = 1 : length(good_sess)
        xc_tmp = []; xcsig_tmp = [];
        cd(good_sess{kk}) 
        %if isfile('xcorr_out_nrem.mat')
        load('unitdata.mat')
        a = cell(1,length(unitdata));
        for ui = 1 : length(unitdata)
            a{ui} = unitdata(ui).area;
        end
        load(['xcorr_out_allstate.mat'])
        ThCh = union(find(strcmp(a,'MD')),find(strcmp(a,'MGB')));
        CtxCh = union(find(strcmp(a,'PFC')),find(strcmp(a,'A1')));
        
        xcsig_tmp = sigflag(ThCh,CtxCh)+(2.*sigflag(CtxCh,ThCh)');
        xcsig_tmp = reshape(xcsig_tmp,[size(xcsig_tmp,1).*size(xcsig_tmp,2) 1]);
        
        xc_tmp = cch_rl(CtxCh,ThCh,:);
        xc_tmp = reshape(xc_tmp,[size(xc_tmp,1).*size(xc_tmp,2) size(xc_tmp,3)]);
        xcp_tmp = cch_prob(CtxCh,ThCh,:);
        xcp_tmp = reshape(xcp_tmp,[size(xcp_tmp,1).*size(xcp_tmp,2) size(xcp_tmp,3)]);
        
        xc_tmp_cc = cch_rl(CtxCh,CtxCh,:);
        xc_tmp_cc = reshape(xc_tmp_cc,[size(xc_tmp_cc,1).*size(xc_tmp_cc,2) size(xc_tmp_cc,3)]);
        xcp_tmp_cc = cch_prob(CtxCh,CtxCh,:);
        xcp_tmp_cc = reshape(xcp_tmp_cc,[size(xcp_tmp_cc,1).*size(xcp_tmp_cc,2) size(xcp_tmp_cc,3)]);
        
        %end
        xc = [xc; xc_tmp];
        xcsig = [xcsig; xcsig_tmp];
        xcp = [xcp; xcp_tmp];
        
        xc_cc = [xc_cc; xc_tmp_cc];
        xcp_cc = [xcp_cc; xcp_tmp_cc];
        
        disp(kk)
    end
    a2 = zeros(1,size(xc,1));
    if ~isempty(find(strcmp(a,'MD' ))) || ~isempty(find(strcmp(a,'PFC' )))% if there is MD...
        a2 = a2 + 1;
    end
    
    a3 = zeros(1,size(xc_cc,1));
    if ~isempty(find(strcmp(a,'MD' ))) || ~isempty(find(strcmp(a,'PFC' )))% if there is MD...
        a3 = a3 + 1;
    end
    
    cd(subs{k})
    
    save(['XCorr_ThalamoCort_AllState.mat'],'xc','xcsig','a')
    save(['XCorr_IntraCort_AllState.mat'],'xc','xcsig','a')
    
    aa = [aa a2]; xca = [xca; xc]; xcsiga = [xcsiga; xcsig]; xcpa = [xcpa; xcp];
    
    aa_cc = [aa_cc a3]; xca_cc = [xca_cc; xc_cc]; xcpa_cc = [xcpa_cc; xcp_cc];
    
    disp(k)
end

cd Y:\Milan\DriveDataSleep

save(['XCorr_ThalamoCort_AllState_All.mat'],'xca','xcsiga','aa','xcpa')

save(['XCorr_IntraCort_AllState_All.mat'],'xca_cc','aa_cc','xcpa_cc')
