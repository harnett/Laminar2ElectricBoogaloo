
function pac = pac_v2(phsb,ampb,lfp,gs)

% phs bands
%phsb = [1 3;3 6];
% amp bands
%ampb = [8 12;13 17;17 25];

if isempty(gs)
    gs = 1 : length(lfp.trial{1});
end

nCh = size(lfp.trial{1},1);

pac = nan(size(phsb,1),size(ampb,1),nCh,nCh);

% filter in a phase band, use for all amp bands

parfor k = 1 : size(ampb,1)
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[ampb(k,1) ampb(k,2)]; cfg.bpinstabilityfix='reduce'; amp=ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='abs';  amp=ft_preprocessing(cfg,amp);
amps{k} = amp.trial{1}(:,gs);
end

parfor k = 1 : size(phsb,1)
    pac(k,:,:,:) = squeeze(pac_subfun2([phsb(k,1) phsb(k,2)],amps,lfp,gs));
    disp(k)
end
  
pac = squeeze(pac);

end

function p = pac_subfun2(phsb,amps,lfp,gs)

nCh = size(lfp.trial{1},1);
  
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=phsb; cfg.bpinstabilityfix='reduce'; ang=ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='angle';  ang=ft_preprocessing(cfg,ang);
ang = ang.trial{1}(:,gs);

ma = mean(exp(1i.*ang),2);

for kk = 1 : length(amps)

amp = amps{kk};

for kkk = 1 : nCh
p(kk,kkk,:) = squeeze(abs( mean( amp .* repmat(exp(1i.*ang(kkk,:)) - ma(kkk),[nCh 1]) ,2)));
end

end
end