function y = cont_to_segment(x,tlen)
%x is time x chs
%tlen is length of trials in samples
x = permute(x,[2 1 3]);
ntr=floor(size(x,2)./tlen);
x=x(:,1:(ntr*tlen));

y = reshape(x,size(x,1),tlen,ntr);
y=permute(y,[2 1 3]);
end