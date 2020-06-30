function [PACma, PACzma, ModIndma, ModIndZma] = LFP_MI(lfp,phsb,ampb,nPerms,gs)

if isempty(gs)
    gs = 1 : length(lfp.trial{1});
end

ha = nan(length(lfp.label),length(gs),size(ampb,1));
for amp = 1 : size(ampb,2)
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[ampb(amp,1) ampb(amp,2)]; cfg.bpinstabilityfix='reduce'; mua = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='abs'; mua = ft_preprocessing(cfg,mua); 
htmp=fieldtrip2mat(mua); htmp = htmp(:,gs);
ha(:,:,amp) = htmp;
end

for frq = 1 : size(phsb,1)
    disp(frq)
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[phsb(frq,1) phsb(frq,2)]; cfg.bpinstabilityfix='reduce'; phs = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='angle'; phs = ft_preprocessing(cfg,phs); 
pa = fieldtrip2mat(phs); pa = pa(:,gs);

for amp = 1 : size(ampb,2)
%% Do MUA Mod Ind
PACm=NaN(length(lfp.label),37);
h = squeeze(ha(:,:,amp));
%nPerms=100;
for ch_ind=1:(length(lfp.label))
        p=pa(ch_ind,:);
        
      p = p * 360.0 / (2.0*pi);                 %Use phase in degrees.
      j=1;
      for k=-180:10:180
          inds = find(p >= k & p < k+10);  %Find phase values in a 10 degree band.
          PACm(:,j) = squeeze(mean(h(:,inds),2));       %Compute mean amplitude at these phases.
          j=j+1;
      end
      
      PACzm=NaN(length(lfp.label),37,nPerms);
      for perm=1:nPerms
          shuffpoint=randi(round(length(p).*.6))+round(length(p).*.2);
          p_shuff=p([shuffpoint:end 1:(shuffpoint-1)]);
          j=1;
      for k=-180:10:180
          inds = find(p_shuff >= k & p_shuff < k+10);  %Find phase values in a 10 degree band.
          PACzm(:,j,perm) = squeeze(mean(h(:,inds),2));       %Compute mean amplitude at these phases.
          j=j+1;
      end
      end
      
      PACm=PACm(:,1:36);
      PACzm=squeeze(PACzm(:,1:36,:));
      
      %% calculate Modulation Index
      
      PACm=PACm./repmat(sum(PACm,2),[1 36]);
      PACzm=PACzm./repmat(sum(PACzm,2),[1 36]);
      
      ModIndm=squeeze(sum(PACm.*log(PACm),2));
      ModIndNullm=squeeze(sum(PACzm.*log(PACzm),2));
      
      ModIndZm=(ModIndm-mean(ModIndNullm,2))./std(ModIndNullm,[],2);
      
      PACma(ch_ind,:,:,:,:)=PACm;
      PACzma(ch_ind,:,:,:,:,:)=PACzm;
      ModIndma(ch_ind,:,:,:)=ModIndm;
      ModIndZma(ch_ind,:,:,:)=ModIndZm;  
end
end
end