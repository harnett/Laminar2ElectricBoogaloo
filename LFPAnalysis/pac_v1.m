function pac = pac_v1(phsb,ampb,lfp)

% phs bands
%phsb = [1 3;3 6];
% amp bands
%ampb = [8 12;13 17;17 25];

nCh = size(lfp.trial{1},1);

pac = nan(length(phsb),length(ampb),nCh,nCh);

% filter in a phase band, use for all amp bands

parfor k = 1 : size(phsb,1)

    pac(k,:,:,:) = squeeze(pac_subfun([phsb(k,1) phsb(k,2)],ampb,lfp));
    disp(k)
end
  

end

function p = pac_subfun(phsb,ampb,lfp)

nCh = size(lfp.trial{1},1);
  
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=phsb; cfg.bpinstabilityfix='reduce'; ang=ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='angle';  ang=ft_preprocessing(cfg,ang);
ang = ang.trial{1};

ma = mean(exp(1i.*ang),2);

for kk = 1 : size(ampb,1)
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[ampb(kk,1) ampb(kk,2)]; cfg.bpinstabilityfix='reduce'; amp=ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='abs';  amp=ft_preprocessing(cfg,amp);
amp = amp.trial{1};

for kkk = 1 : nCh

p(kk,kkk,:) = squeeze(abs( mean( amp .* repmat(exp(1i*ang(kkk,:)) - ma(kkk),[nCh 1]) ,2) ));
end

end
end