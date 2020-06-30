clear
cd Y:\Milan\DriveDataSleep
load('subs.mat')
ca=[]; lp=[]; ps=[]; rs=[]; zs=[]; as=[]; si=[];
for k = 1 : 6%length(subs)
    cd(subs{k})
    load('spkr_sum.mat')
    ca = [ca cellarea_all];
    si = [si ones(1,length(angsa)).*k];
    ps = cat(3,ps,pvsa);
    rs = cat(3,rs,rsa);
    zs = cat(3,zs,zsa);
    as = cat(3,as,angsa);
    if k==3 || k== 4
        lp = [lp zeros(1,length(angsa))];
    else
        lp = [lp ones(1,length(angsa))];
    end
end

kp=zeros(1,6);
for k = 1 : 6
    subplot(2,3,k)
    c = ca(find(si==k));
    z = zs(1,1,find(si==k));
    a = as(1,1,find(si==k));
    scatter(z(find(c==0)),a(find(c==0)))
    hold on
    scatter(z(find(c==1)),a(find(c==1)))
    try
    kp(k)=circ_kuipertest(a(find(c==1)),a(find(c==0)))
    catch
    end
end