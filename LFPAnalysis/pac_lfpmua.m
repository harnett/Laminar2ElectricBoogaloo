
function [pac, pacz] = pac_lfpmua(phsb,lfp,mua,gs,nPrm)

% phs bands
%phsb = [1 3;3 6];
% amp bands
%ampb = [8 12;13 17;17 25];

if isempty(gs)
    gs = 1 : length(lfp.trial{1});
end

nCh = size(lfp.trial{1},1);

pac = nan(size(phsb,1),nCh,nCh);
pacz = pac;
% filter in a phase band, use for all amp bands

ampsa = mua.trial{1};

parfor k = 1 : size(phsb,1)
    [tmp, tmpz] = pac_subfun3([phsb(k,1) phsb(k,2)],ampsa,lfp,gs,nPrm);
    tmp = squeeze(tmp); tmpz = squeeze(tmpz);
    pac(k,:,:) = tmp;
    pacz(k,:,:) = tmpz;
    disp(k)
end
  
pac = squeeze(pac);

end

function [p, pz] = pac_subfun3(phsb,ampsa,lfp,gs,nPrm)

nCh = size(lfp.trial{1},1);
  
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=phsb; cfg.bpinstabilityfix='reduce'; ang=ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='abs';  phsp=ft_preprocessing(cfg,ang); phsp = fieldtrip2mat(phsp);
cfg=[]; cfg.hilbert='angle';  ang=ft_preprocessing(cfg,ang);
ang = ang.trial{1};

indsa = nan(nCh,round(length(gs)*.2));

p = nan(nCh,nCh);

for kkk = 1 : nCh
    [~,inds]=sort(phsp(kkk,gs),'descend');
    inds = gs(inds);
    inds=inds(1:round(length(inds)*.2));
    indsa(kkk,:) = inds;
    ma(kkk) = mean(exp(1i.*ang(kkk,inds)),2);
    p(:,kkk) = squeeze(abs( mean( ampsa(:,inds) .* repmat(exp(1i.*ang(kkk,inds)) - ma(kkk),[nCh 1]) ,2)));
end

pz = nan(size(ang,1),size(ang,1),nPrm);

for shf = 1 : nPrm
random_timepoint = randi(length(indsa));
for kkk = 1 : nCh
    inds2 = indsa(kkk,[ random_timepoint:length(indsa) 1:random_timepoint-1 ]);
    pz(:,kkk,shf) = squeeze(abs( mean( ampsa(:,inds2) .* repmat(exp(1i.*ang(kkk,inds2)) - ma(kkk),[nCh 1]) ,2)));
end
end

pz = ( p - squeeze(mean(pz,3)) ) ./ squeeze(std(pz,[],3));

end