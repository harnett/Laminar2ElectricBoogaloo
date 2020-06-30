function bi = mono2bi(lfp)

bi = lfp;

cind = 1;
for k = 1 : length(lfp.label)
    for kk = k : length(lfp.label)
        if kk~=k
        bi.trial{1}(cind,:) = lfp.trial{1}(k,:) - lfp.trial{1}(kk,:);
        bi.label{cind} = [lfp.label{k} '-' lfp.label{kk}]; cind = cind+1;
        end
    end
end