function [PACma, PACzma, ModIndma, ModIndZma, ModIndNullma] = LFPMUA_MIv2(lfp,phsb,mua,nPerms,gs)

if isempty(gs)
    gs = 1 : length(lfp.trial{1});
end

nch = length(lfp.label);

ha =fieldtrip2mat(mua);

for frq = 1 : size(phsb,1)
    tic
    disp(frq)
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[phsb(frq,1) phsb(frq,2)]; cfg.bpinstabilityfix='reduce'; phs = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='abs'; phsp = ft_preprocessing(cfg,phs); 
cfg=[]; cfg.hilbert='angle'; phs = ft_preprocessing(cfg,phs); 
pa = fieldtrip2mat(phs); phsp = fieldtrip2mat(phsp);

%% Do MUA Mod Ind
%nPerms=100;
parfor ch_ind=1:nch
    [~,inds]=sort(phsp(ch_ind,gs),'descend');
    inds = gs(inds);
    inds=inds(1:round(length(inds)*.2));

     p=pa(ch_ind,inds);
     hatmp = ha(:,inds);
     [PACm, PACzm, ModIndm, ModIndZm, ModIndNullm] = miv3_subfun(p,hatmp,nPerms,nch);
      
     PACma(ch_ind,:,:,frq,:)=PACm;
     PACzma(ch_ind,:,:,:,frq,:)=PACzm;
     ModIndma(ch_ind,:,frq,:)=ModIndm;
     ModIndZma(ch_ind,:,frq,:)=ModIndZm;
     ModIndNullma(ch_ind,:,:,frq,:)=ModIndNullm;
end
toc
end
end

function [PACm, PACzm, ModIndm, ModIndZm, ModIndNullm] = miv3_subfun(p,ha,nPerms,nch)
    PACm=ones(size(ha,1),37).*eps;
    p = p * 360.0 / (2.0*pi);                 %Use phase in degrees.
      j=1;
      for k=-180:10:180
          inds2 = find(p >= k & p < k+10);  %Find phase values in a 10 degree band.
          PACm(:,j) = (mean(ha(:,inds2),2));       %Compute mean amplitude at these phases.
          j=j+1;
      end
      
      PACzm=NaN(nch,37,nPerms).*eps;
      for perm=1:nPerms
          shuffpoint=randi(length(p));%randi(round(length(p).*.6))+round(length(p).*.2);
          p_shuff=p([shuffpoint:end 1:(shuffpoint-1)]);
          j=1;
      for k=-180:10:180
          inds2 = find(p_shuff >= k & p_shuff < k+10);  %Find phase values in a 10 degree band.
          PACzm(:,j,perm) = (mean(ha(:,inds2),2));       %Compute mean amplitude at these phases.
          j=j+1;
      end
      end
      
      PACm=PACm(:,1:36);
      PACzm=(PACzm(:,1:36,:));
      
      %% calculate Modulation Index
      
      PACm=PACm./repmat(sum(PACm,2),[1 36]);
      PACzm=PACzm./repmat(sum(PACzm,2),[1 36 1]);
      
      UnDist = ones(size(PACm,1),size(PACm,2))./36;
      UnDistZ = ones(size(PACzm,1),size(PACzm,2),size(PACzm,3))./36;
      
      ModIndm=squeeze(sum(PACm.*log(PACm./UnDist),2));
      if size(ModIndm,1) ~= size(ha,1)
          ModIndm = ModIndm';
      end
      ModIndNullm=squeeze(sum(PACzm.*log(PACzm./UnDistZ),2));
      tmpsz = size(ModIndNullm); tmpsz = find(tmpsz == nPerms);
      ModIndZm=squeeze((ModIndm-squeeze(mean(ModIndNullm,tmpsz)))./squeeze(std(ModIndNullm,[],tmpsz)));
end