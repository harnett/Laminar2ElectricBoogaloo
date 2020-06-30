function [sta,dat] = LaminarSTA(unitdata,lfp,winlen,fs,unit_selected,gs)

if isempty(unit_selected)
    unit_selected = 1 : length(unitdata);
end

if isempty(gs)
    gs = [lfp.time{1}(1):lfp.time{1}(end)];
end

%lowpass filter lfp
cfg=[]; cfg.lpfilter='yes'; cfg.lpfreq=100; lfp=ft_preprocessing(cfg,lfp);
sta = zeros(length(lfp.label),winlen*2+1,length(unit_selected));
for u = 1 : length(unit_selected)
    
    ts = unitdata(unit_selected(u)).ts;

    ts = round(fs.*ts);
    
    ts = intersect(ts,gs);
        
    if ~isempty(ts)
    
    cfg=[]; cfg.trl=zeros(length(ts),3);

    cfg.trl(:,1) = ts-winlen;
    cfg.trl(:,2) = ts+winlen;
    cfg.trl(:,3) = winlen;

	sing_trial = ft_redefinetrial(cfg,lfp);
    cfg=[]; avg = ft_timelockanalysis(cfg,sing_trial);
    dat{u} = sing_trial;
    sta(:,:,u) = avg.avg;
    end
end
end