function s2 = spk_boxcar(s,len)
%len is in samples, 10ms is a reasonable value
%s is units by time by trials

if isempty(len)
    len=10;
end

s2 =s;

for k = 1 : size(s,1)
    for kk = 1 : size(s,3)
        s2(k,:,kk) = smooth(squeeze(s(k,:,kk)),len);
    end
end

end