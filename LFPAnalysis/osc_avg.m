function [avg,trldf] = osc_avg(data,winlen,refch,frq,gs,maxpk)
rmpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
if isempty(gs)
    gs = 1:length(data.trial{1});
end
%winlen in seconds
cfg=[];
cfg.bpfilter='yes';
cfg.bpfreq=frq;
cfg.bpinstabilityfix='reduce';
alph=ft_preprocessing(cfg,data);
cfg=[];
cfg.channel = refch;
phsref = ft_preprocessing(cfg,alph);
cfg=[];
cfg.hilbert='abs';
phsrefa=ft_preprocessing(cfg,alph);
cfg=[];
cfg.hilbert='angle';
phsref=ft_preprocessing(cfg,phsref);
%     trldf=zeros(length(alph.trial),3);
clear trldf
pk_counter=1;
trlength = length(data.trial{1})./data.fsample;
winlen = winlen./2;
pa=[];
    for i=1:length(alph.trial)
        [~,pk_inds]=findpeaks(-phsref.trial{i}); %pk_inds=pk_inds.loc;
        %[~,pk_inds]=findpeaks(ecdalph.trial{i});
        pk_inds=pk_inds(intersect(find(pk_inds<((trlength-winlen)*data.fsample)),find(pk_inds>(winlen*data.fsample))));
        pk_inds=intersect(pk_inds,gs);
        if isempty(pk_inds)
            continue
        end
        pa=[pa; phsrefa.trial{i}(pk_inds)];
        for ii=1:length(pk_inds)
        new_tr_cnt=pk_inds(ii);
        new_tr_cnt=new_tr_cnt+alph.sampleinfo(i,1);
        trldf(pk_counter,1)=round(new_tr_cnt-alph.fsample.*(winlen));
        trldf(pk_counter,2)=round(new_tr_cnt+alph.fsample.*(winlen));
        trldf(pk_counter,3)=round(-alph.fsample.*(winlen));%fix
        pk_counter=pk_counter+1;
        end
    end
    
    [~,pai]=sort(-pa);
    trldf=trldf(pai,:);
    trldf=trldf(1:round(.1*length(trldf)),:);
    
    bad_tr_inds=zeros(1,length(trldf));
    for trl_ind=1:size(trldf,1)
        if trldf(trl_ind,1)<=0
            bad_tr_inds(trl_ind)=1;
        end
    end
    trldf(find(bad_tr_inds),:)=[];
    
    if length(trldf)>maxpk
        trldf = trldf(randsample(length(trldf),maxpk),:);
    end
    
    cfg=[];
    cfg.trl=trldf;
    alpha_aligned=ft_redefinetrial(cfg,data);
    cfg=[]; avg=ft_timelockanalysis(cfg,alpha_aligned);