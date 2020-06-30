
function [pac, pacz] = pac_v3(phsb,ampb,lfp,gs)

% phs bands
%phsb = [1 3;3 6];
% amp bands
%ampb = [8 12;13 17;17 25];

if isempty(gs)
    gs = 1 : length(lfp.trial{1});
end

nCh = size(lfp.trial{1},1);

pac = nan(size(phsb,1),size(ampb,1),nCh,nCh);
pacz = pac;
% filter in a phase band, use for all amp bands

parfor k = 1 : size(ampb,1)
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[ampb(k,1) ampb(k,2)]; cfg.bpinstabilityfix='reduce'; amp=ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='abs';  amp=ft_preprocessing(cfg,amp);
amps{k} = amp.trial{1}(:,gs);
end

ampsa = nan(size(amps{1},1),size(amps{1},2),size(ampb,1));

for k = 1 : size(ampb,1)
    ampsa(:,:,k) = amps{k};
end

parfor k = 1 : size(phsb,1)
    [tmp, tmpz] = pac_subfun3([phsb(k,1) phsb(k,2)],ampsa,lfp,gs);
    tmp = squeeze(tmp); tmpz = squeeze(tmpz);
    pac(k,:,:,:) = tmp;
    pacz(k,:,:,:) = tmpz;
    disp(k)
end
  
pac = squeeze(pac);

end

function [p, pz] = pac_subfun3(phsb,ampsa,lfp,gs)

nCh = size(lfp.trial{1},1);
  
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=phsb; cfg.bpinstabilityfix='reduce'; ang=ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='angle';  ang=ft_preprocessing(cfg,ang);
ang = ang.trial{1}(:,gs);

ma = mean(exp(1i.*ang),2);

for kkk = 1 : nCh
p(:,kkk,:) = squeeze(abs( mean( ampsa .* repmat(exp(1i.*ang(kkk,:)) - ma(kkk),[nCh 1 size(ampsa,3)]) ,2)));
end

for nshf = 1 : 100
random_timepoint = randi(length(gs)); inds = [ random_timepoint:length(gs) 1:random_timepoint-1 ];
for kkk = 1 : nCh
pz(:,kkk,:,nshf) = squeeze(abs( mean( ampsa(:,inds,:) .* repmat(exp(1i.*ang(kkk,:)) - ma(kkk),[nCh 1 size(ampsa,3)]) ,2)));
end
end

pz = ( p - squeeze(mean(pz,4)) ) ./ squeeze(std(pz,[],4));

end