function [l_all,u_all] = fr_burst(lfp,unitdata,st)

%get relevant epochs
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
[dn,~] = binspikes(spk,1000); dn(dn>1)=1;
dn = [dn; zeros(length(lfp.trial{1})-length(dn),size(dn,2))]; 
u_all=[]; l_all=[];
for k = 1 : size(st,1)
x = st(k,1):st(k,2);
vlfp = lfp.trial{1}(:,x);
vu = dn(x,:);
xq = linspace(x(1),x(end),1000);
%interp lfp so 1000 samps long
l_tmp = interp1(x,vlfp',xq);
%get unit activity from dn
u_tmp = interp1(x,vu,xq);
% concatenate
u_all = cat(3,u_all,u_tmp);
l_all = cat(3,l_all,l_tmp);
end
%plot average fr
end