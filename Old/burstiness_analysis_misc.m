for s = 1 : 3
    for k = 1 : 4
        for kk = 1 : 4
            pv(k,kk,s) = ranksum(all_dip(s,find(a==k)),all_dip(s,find(a==kk)));
        end
    end
end

pv=[];
for s = 1 : 3
    for ss = 1 : 3
    for k = 1 : 4
        pv(s,ss,k) = ranksum(all_dip(s,find(a==k)),all_dip(ss,find(a==k)));
    end
    end
end
           