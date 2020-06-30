function [PACma, PACzma, ModIndma, ModIndZma] = LFPMUA_MI(lfp,mua,nPerms,gs)

if isempty(gs)
    gs = 1 : length(lfp.trial{1});
end

cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[9 17]; cfg.bpinstabilityfix='reduce'; phs = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='angle'; phs = ft_preprocessing(cfg,phs); 
pa = fieldtrip2mat(phs); pa = pa(:,gs);

%% Do MUA Mod Ind
PACm=NaN(length(mua.label),37);
h=fieldtrip2mat(mua); h = h(:,gs);
%nPerms=100;
for ch_ind=1:(length(lfp.label))
        p=pa(ch_ind,:);
        disp(ch_ind)

      p = p * 360.0 / (2.0*pi);                 %Use phase in degrees.
      j=1;
      for k=-180:10:180
          inds = find(p >= k & p < k+10);  %Find phase values in a 10 degree band.
          PACm(:,j) = squeeze(mean(h(:,inds),2));       %Compute mean amplitude at these phases.
          j=j+1;
      end
      
      PACzm=NaN(length(mua.label),37,nPerms);
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
      
      UnDist = ones(size(PACm,1),size(PACm,2))./36;
      UnDistZ = ones(size(PACzm,1),size(PACzm,2),size(PACzm,2))./36;
      
      ModIndm=squeeze(sum(PACm.*log(PACm./UnDist),2));
      ModIndNullm=squeeze(sum(PACzm.*log(PACzm./UnDistZ),2));
      
      ModIndZm=(ModIndm-mean(ModIndNullm,2))./std(ModIndNullm,[],2);
      
      PACma(ch_ind,:,:)=PACm;
      PACzma(ch_ind,:,:,:)=PACzm;
      ModIndma(ch_ind,:)=ModIndm;
      ModIndZma(ch_ind,:)=ModIndZm;  
end

end