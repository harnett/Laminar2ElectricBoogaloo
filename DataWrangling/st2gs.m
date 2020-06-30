function gs = st2gs(st)

gs=[];
for k = 1 : size(st,1)
    gs = [gs st(k,1):st(k,2)];
end
gs = unique(gs);