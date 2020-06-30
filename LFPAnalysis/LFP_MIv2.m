function [PACma, PACzma, ModIndma, ModIndZma] = LFP_MIv2(lfp,phsb,ampb,nPerms,gs)

if isempty(gs)
    gs = 1 : length(lfp.trial{1});
end

nch = length(lfp.label);

ha = nan(length(lfp.label),length(lfp.trial{1}),size(ampb,1));
for amp = 1 : size(ampb,1)
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[ampb(amp,1) ampb(amp,2)]; cfg.bpinstabilityfix='reduce'; mua = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='abs'; mua = ft_preprocessing(cfg,mua); 
htmp=fieldtrip2mat(mua);
ha(:,:,amp) = htmp;
end

for frq = 1 : size(phsb,1)
    tic
    disp(frq)
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[phsb(frq,1) phsb(frq,2)]; cfg.bpinstabilityfix='reduce'; phs = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='abs'; phsp = ft_preprocessing(cfg,phs); 
cfg=[]; cfg.hilbert='angle'; phs = ft_preprocessing(cfg,phs); 
pa = fieldtrip2mat(phs); phsp = fieldtrip2mat(phsp);

%% Do MUA Mod Ind
%nPerms=100;
for ch_ind=1:nch
    [~,inds]=sort(phsp(ch_ind,gs),'descend');
    inds = gs(inds);
    inds=inds(1:round(length(inds)*.2));

     p=pa(ch_ind,inds);
     hatmp = ha(:,inds,:);
     [PACm, PACzm, ModIndm, ModIndZm] = miv2_subfun(p,hatmp,ampb,nPerms,nch);
      
     PACma(ch_ind,:,:,frq,:)=PACm;
     PACzma(ch_ind,:,:,:,frq,:)=PACzm;
     ModIndma(ch_ind,:,frq,:)=ModIndm;
     ModIndZma(ch_ind,:,frq,:)=ModIndZm;  
end
toc
end
end

function [PACm, PACzm, ModIndm, ModIndZm] = miv2_subfun(p,ha,ampb,nPerms,nch)
    PACm=NaN(size(ha,1),37,size(ampb,1));
    p = p * 360.0 / (2.0*pi);                 %Use phase in degrees.
      j=1;
      for k=-180:10:180
          inds2 = find(p >= k & p < k+10);  %Find phase values in a 10 degree band.
          PACm(:,j,:) = squeeze(mean(ha(:,inds2,:),2));       %Compute mean amplitude at these phases.
          j=j+1;
      end
      
      PACzm=NaN(nch,37,nPerms,size(ampb,1));
      for perm=1:nPerms
          shuffpoint=randi(round(length(p).*.6))+round(length(p).*.2);
          p_shuff=p([shuffpoint:end 1:(shuffpoint-1)]);
          j=1;
      for k=-180:10:180
          inds2 = find(p_shuff >= k & p_shuff < k+10);  %Find phase values in a 10 degree band.
          PACzm(:,j,perm,:) = squeeze(mean(ha(:,inds2,:),2));       %Compute mean amplitude at these phases.
          j=j+1;
      end
      end
      
      PACm=PACm(:,1:36,:);
      PACzm=squeeze(PACzm(:,1:36,:,:));
      
      %% calculate Modulation Index
      
      PACm=PACm./repmat(sum(PACm,2),[1 36 1]);
      PACzm=PACzm./repmat(sum(PACzm,2),[1 36 1 1]);
      
      ModIndm=squeeze(sum(PACm.*log(PACm),2));
      ModIndNullm=squeeze(sum(PACzm.*log(PACzm),2));
      
      ModIndZm=(ModIndm-squeeze(mean(ModIndNullm,2)))./squeeze(std(ModIndNullm,[],2));
end