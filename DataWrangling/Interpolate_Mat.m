function data = Interpolate_Mat(data,x)
% NOTE: Will crash if channel to be interpolated is last on probe.
% to be interpolated channel sets should be fed in as vectors in a cell
% array. i.e. if you want to interpolate channels 14-15 and 21, x would be
% {[14 15], 21}
for k = 1 : length(x)
    bch = x{k}; 
    nb = length(bch);
    intpf = 1./(nb+1);
    if bch(1) == 1
        lc = zeros(1,size(data,2));
    else
    lc = data(bch(1) - 1,:);
    end
    hc = data(bch(end) + 1,:);
    for kk = 1 : nb
        data(bch(kk),:) = lc .* (1 - (kk*intpf)) + hc .* (kk*intpf);
    end
end
end