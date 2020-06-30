function [rs,rz,rp,angs] = spk_rtest_shuffv2(lfp,unitdata,fqs,gs,fs,nPrm)

if isempty(gs)
    gs = 1 : length(lfp.trial{1});
end

addpath(genpath('C:\Users\Loomis\Documents\Packages\CircStat2012a'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12\chronux_2_12'))
% generic function which takes unitdata and lfp, finds rayleigh and phase
% distribution for each unit / frequency of interest

%loop thru each frequency, filter, phase, append data from fieldtrip2mat
phsdat=[];

nLfpCh = length(lfp.label);

% lfp.label{length(lfp.label)+1} = 'u1';
% %interpolate 
% bs = 1 : length(lfp.trial{1}); bs(gs)=[];
% for k = 1 : length(unitdata)
%     
%     ts = unitdata(k).ts; ts = round(ts.*fs); ts = intersect(ts,gs);
%     
%     spk(1).time = unitdata(k).ts;
%     
%     dn = binspikes(spk,fs,[lfp.time{1}(1) lfp.time{1}(end)]); dn = dn'; dn(dn>1)=1;
% 
%     %dn = [dn zeros(1,length(lfp.trial{1})-length(dn))];  
%     
%     dn(bs)=0;
%     
%     lfp.trial{1}((nLfpCh+1),:) = dn;
%     
%     cfg=[]; cfg.method='linear'; cfg.interptoi=.015; cfg.spikechannel = 'u1'; lfp = ft_spiketriggeredinterpolation(cfg,lfp);
% 
% end
% 
% cfg=[]; cfg.channel = lfp.label(1:nLfpCh); lfp=ft_preprocessing(cfg,lfp);

phsdat = nan(size(lfp.trial{1},1),size(lfp.trial{1},2),size(fqs,1));

parfor k = 1 : size(fqs,1)
cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[fqs(k,1) fqs(k,2)]; spindle = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='angle'; tmp = ft_preprocessing(cfg,spindle);

phsdat(:,:,k) = tmp.trial{1};

disp(['done with frequency ' num2str(k) ' out of ' num2str(size(fqs,1))])

end

rs = nan(length(lfp.label),size(fqs,1),length(unitdata));
angs = nan(length(lfp.label),size(fqs,1),length(unitdata));

for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
[dn,~] = binspikes(spk,fs,[lfp.time{1}(1) lfp.time{1}(end)]); dn = dn'; dn(dn>1) = 1;

bs = 1 : length(dn); bs(gs) = []; dn(:,bs) = 0;

% loop thru each unit
parfor k = 1 : length(unitdata)
    
    ts=find(dn(k,:));
    
    % get matrix which only has phase across channels at spike times
    % (chsxnspikes)

    % get r-value
    r = abs(mean(exp(1i.*phsdat(:,ts,:)),2));
    
    ang = angle(mean(exp(1i.*phsdat(:,ts,:)),2));
    
    % save in struct (nunits long)
    rs(:,:,k) = squeeze(r);
    angs(:,:,k) = squeeze(ang);
        
end

rsprm = nan(length(lfp.label),size(fqs,1),length(unitdata),nPrm);

parfor np = 1 : nPrm
    dnshff = circshift(dn,randi(size(dn,2)),2);
    [ra] = spk_rtest_shuffv2_subfun(phsdat,fqs,unitdata,dnshff)
    rsprm(:,:,:,np) = squeeze(ra);
    disp(np)
end

rmu = mean(rsprm,4); rstd = std(rsprm,[],4); 

rz = (rs - rmu) ./ rstd;

rp = erfc(rz./sqrt(2))/2;

rs = squeeze(rs); rp=squeeze(rp); rz=squeeze(rz); angs=squeeze(angs);

end

function [ra] = spk_rtest_shuffv2_subfun(phsdat,fqs,unitdata,dnshff)
ra = nan(size(phsdat,1),size(fqs,1),length(unitdata));
for k = 1 : length(unitdata)
        
    % get matrix which only has phase across channels at spike times
    % (chsxnspikes)

    % get r-value
    r = abs(mean(exp(1i.*phsdat(:,dnshff(k,:)==1,:)),2));

    % save in struct (nunits long)
    ra(:,:,k) = squeeze(r);
        
end
end
