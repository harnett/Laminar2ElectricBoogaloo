function [fr_z,fr_p,fr_mu,fr_std,fr_spindle] = spindle_fr(st,gs,unitdata,nPrm)

for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
[dn,~] = binspikes(spk,1000); dn = dn'; dn(dn>=1) = 1;

if length(dn) < max(gs)
dn = [dn zeros(size(dn,1),max(gs)-length(dn))];
end

st_samp=[]; 
for k = 1 : size(st,1)
    st_samp = [st_samp st(k,1):st(k,2)];
end

fr_spindle = mean(dn(:,st_samp),2).*1000;

gs_nospindle = setdiff(gs,st_samp);

fr = nan(size(dn,1),nPrm);

for k = 1 : nPrm
    % get random samples in nrem which do not overlap with st_samp
    y = randsample(gs_nospindle,length(st_samp));
    % store firing rate for each unit
    fr(:,k) = mean(dn(:,y),2).*1000;
end

% get mean, sd of distribution

fr_mu = mean(fr,2); fr_std = std(fr,[],2);

% find z-score / p-value of actual spindle firing rate

fr_z = (fr_spindle - fr_mu) ./ fr_std;

fr_p = erfc(fr_z./sqrt(2))/2;

end