function [PACma, PACzma, ModIndma, ModIndZma] = LFPMUA_MI_Spind(lfp,mua,nPerms,times_all)

cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[9 17]; cfg.bpinstabilityfix='reduce'; phs = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='angle'; phs = ft_preprocessing(cfg,phs); 
pa = fieldtrip2mat(phs);

%% Do MUA Mod Ind
PACm=NaN(length(mua.label),37);
ha=fieldtrip2mat(mua);
%nPerms=100;
parfor ch_ind=1:(length(lfp.label))
    gs = st2gs(times_all(find(times_all(:,3)==ch_ind),1:2));
    h = ha(:,gs);
        p=pa(ch_ind,gs);
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
      
      ModIndm=squeeze(sum(PACm.*log(PACm),2));
      ModIndNullm=squeeze(sum(PACzm.*log(PACzm),2));
      
      ModIndZm=(ModIndm-mean(ModIndNullm,2))./std(ModIndNullm,[],2);
      
      PACma(ch_ind,:,:)=PACm;
      PACzma(ch_ind,:,:,:)=PACzm;
      ModIndma(ch_ind,:)=ModIndm;
      ModIndZma(ch_ind,:)=ModIndZm;  
end

end