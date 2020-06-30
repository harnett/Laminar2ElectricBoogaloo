clear
load xcorrs.mat
s = sigflaga(:,:,1);
[p,~]=numSubplots(length(find(s==1)));
subi = 1;
du = length(find(triu(s)));
ud = length(find(tril(s)));
for k = 1 : size(s,1)
    x = find(s(k,:));
    if ~isempty(x)
        for kk = 1 : length(x)
            subplot(p(1),p(2),subi)
            plot(squeeze(cch_rla(k,x(kk),:,1)))
            subi = subi+1;
        end
    end
end

%6 8;3 3; 1 2
%10 13 