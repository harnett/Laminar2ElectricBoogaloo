% loop thru all sessions / states compute XCorrs!
clear

cd Y:\Milan\DriveDataSleep
sname = {'nrem','rem','wake'};
load('subs')
statename = {'nrem','rem','wake'};
bfile=[]; bfile_ind = 1; subi=[];
for s = 1 : 3
    aa = []; xca=[]; xcsiga=[]; xcpa = [];
for k = 1 : length(subs)
    xc = []; xcsig = []; xcp = [];
    cd(subs{k})
    load('good_sess.mat')
    for kk = 1 : length(good_sess)
        xc_tmp = []; xcsig_tmp = []; xcp=[];
        cd(good_sess{kk}) 
        if isfile(['xcorr_out_' sname{s} '.mat'])
        load('unitdata.mat')
        a = cell(1,length(unitdata));
        for ui = 1 : length(unitdata)
            a{ui} = unitdata(ui).area;
        end
        load(['xcorr_out_' sname{s} '.mat'])
        ThCh = union(find(strcmp(a,'MD')),find(strcmp(a,'MGB')));
        CtxCh = union(find(strcmp(a,'PFC')),find(strcmp(a,'A1')));
        xcsig_tmp = sigflag(ThCh,CtxCh)+(2.*sigflag(CtxCh,ThCh)');
        xcsig_tmp = reshape(xcsig_tmp,[size(xcsig_tmp,1).*size(xcsig_tmp,2) 1]);
        xc_tmp = cch_rl(CtxCh,ThCh,:);
        xc_tmp = reshape(xc_tmp,[size(xc_tmp,1).*size(xc_tmp,2) size(xc_tmp,3)]);
        xcp_tmp = cch_prob(CtxCh,ThCh,:);
        xcp_tmp = reshape(xcp_tmp,[size(xcp_tmp,1).*size(xcp_tmp,2) size(xcp_tmp,3)]);
        end
        xc = [xc; xc_tmp];
        xcsig = [xcsig; xcsig_tmp];
        xcp = [xcp; xcp_tmp];
        disp(kk)
    end
    a2 = zeros(1,size(xc,1));
    if ~isempty(find(strcmp(a,'MD' ))) || ~isempty(find(strcmp(a,'PFC' )))% if there is MD...
        a2 = a2 + 1;
    end
    cd(subs{k})
    %save(['XCorr_ThalamoCort_' statename{s} '.mat'],'xc','xcsig','a')
    aa = [aa a2]; xca = [xca; xc]; xcsiga = [xcsiga; xcsig]; xcpa = [xcpa; xcp]; subi = [subi ones(1,length(a2)).*k];
    disp(k)
end

cd Y:\Milan\DriveDataSleep

%save(['XCorr_ThalamoCort_All_' statename{s} '.mat'],'xca','xcsiga','aa','xcpa')

end
