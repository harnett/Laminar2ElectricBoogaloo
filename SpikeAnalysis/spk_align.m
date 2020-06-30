function dat = spk_align(x,tr,win)
%tr is trial center times in samples
%win is samples before and after trial
%x is channels by samples spike matrix

btr1 = find((tr - win)<=0); btr2 = find((tr+win)>=size(x,2)); btr = union(btr1,btr2);
tr(btr) = [];
dat = nan(size(x,1),(2*win)+1,length(tr));

for k = 1 : length(tr)
    dat(:,:,k) = x(:,(tr(k)-win):(tr(k)+win));
end

end