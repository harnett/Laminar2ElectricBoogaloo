function spkcoh = spk_coh_spindle(unitdata,st)

gs=[];st_prepad=[];st_postpad=[];
for k = 1 : size(st,1)
gs = [gs st(k,1):st(k,2)];
st_prepad=[st_prepad (st(k,1)-1500):st(k,1)];
st_postpad=[st_postpad st(k,2):(st(k,2)+1500)];
end

st_pad = union(st_prepad,st_postpad);

params.Fs=1000;
params.tapers = [3 5];
params.err = [1 .05];
params.fpass = [.5 100];
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end

[dn,t] = binspikes(spk,1000);
dn = [dn; zeros(max(gs)-length(dn),size(dn,2))]; % pad dn with zeros just in case lfp exceeds spikes
st_pad(st_pad<=0) = []; st_pad(st_pad>=length(dn))=[];
gs = union(gs,st_pad);
dn = dn(gs,:);
% bs = 1 : size(dn,1); bs(gs)=[];
% dn(bs,:) = 0; dn(dn>1)=1;

nUnit = size(dn,2);
[C]=coherencysegpb(dn(:,1),dn(:,2),4,params);
C_all = zeros(nUnit,nUnit,length(C));
phi_all = C_all;
for k = 1 : nUnit
    tic
    for kk = k : nUnit
        [C,phi,S12,S1,S2,f,zerosp,confC,phistd]=coherencysegpb(dn(:,k),dn(:,kk),4,params);
        C_all(k,kk,:) = C; phi_all(k,kk,:) = phi;
        C_all(kk,k,:) = C; phi_all(kk,k,:) = phi;
    end
    toc
    disp(k)
end

spkcoh.C = C_all;
spkcoh.phi=phi_all;
spkcoh.S12=S12;
spkcoh.S1=S1;
spkcoh.S2=S2;
spkcoh.f=f;
spkcoh.zerosp=zerosp;
spkcoh.confC=confC;
spkcoh.phistd=phistd;
end