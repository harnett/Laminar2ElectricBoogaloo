function [sta] = LaminarSTAv2(unitdata,lfp,winlen,fs,unit_selected,gs)

%winlen in samples

if isempty(unit_selected)
    unit_selected = 1 : length(unitdata);
end

if isempty(gs)
    gs = 1:length(lfp.trial{1});
end

%lowpass filter lfp
cfg=[]; cfg.lpfilter='yes'; cfg.lpfreq=100; lfp=ft_preprocessing(cfg,lfp);
sta = zeros(length(lfp.label),winlen*2+1,length(unit_selected));

x = fieldtrip2mat_epochs(lfp);

parfor u = 1 : length(unit_selected)
    
    ts = unitdata(unit_selected(u)).ts;

    ts = round(fs.*ts);
    
    ts = intersect(ts,gs);
    
    %ts = ts(1:2:end);
    
    if ~isempty(ts)
    
    sta(:,:,u) = dat_align_avg(x,ts,winlen);
    
    end
    
    disp(u)
end
end