function sr = fr_dyn(lfp,unitdata,st)
nBins=5;
sr = zeros(length(unitdata),size(st,1));
%get relevant epochs
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
[dn,~] = binspikes(spk,1000);
dn = [dn; zeros(length(lfp.trial{1})-length(dn),size(dn,2))]; 
dn=dn'; dn(dn==2) = 1;
for k =1 : size(dn,1)
    dn(k,:) = smooth(dn(k,:),50);
end
for k = 1 : size(st,1)
    x=st(k,1):st(k,2);
    [~,tmp] = max(dn(:,x),[],2);
    sr(:,k) = tmp;
end
%plot average fr
end