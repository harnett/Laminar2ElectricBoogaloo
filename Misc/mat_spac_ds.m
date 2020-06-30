function x = mat_spac_ds(dat,nch)
x = zeros(nch,size(dat,2));
for k = 1 : nch
x(k,:) = mean(dat( ...
( (1 + (k-1) * floor(size(dat,1)./nch)) : (k * floor(size(dat,1)./nch)) ) , :));
end