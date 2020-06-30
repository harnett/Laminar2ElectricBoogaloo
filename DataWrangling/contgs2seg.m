function lfp = contgs2seg(lfp,seglen,gs)
%seglen in seconds
cfg=[]; cfg.length=seglen; lfp = ft_redefinetrial(cfg,lfp);

si = lfp.sampleinfo;

if si(1,1) ~= 1
    disp('first sample not 1, changing sample space')
    si = si - si(1,1) + 1;
end

gtr = zeros(1,size(si,1));

for k = 1 : length(si)
    if length(intersect(gs, si(k,1):si(k,2) ) ) == length(si(k,1):si(k,2))
        gtr(k) = 1;
    end
end

gtr = find(gtr);

cfg=[]; cfg.trials = gtr; lfp=ft_redefinetrial(cfg,lfp);

end