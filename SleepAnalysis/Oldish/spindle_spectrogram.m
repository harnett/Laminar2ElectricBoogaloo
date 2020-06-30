[s,f,t] = spectrogram(lfp2.trial{1}(1,:),125,124,2000,1000);
s=s(1:60,:);
[x,y] = meshgrid(1:size(s,2),1:size(s,1)); [x2,y2] = meshgrid(linspace(1,size(s,2),1000),1:size(s,1)); Vq = interp2(x,y,s,x2,y2);
s_all = zeros(size(lfp.trial{1},1),size(Vq,1),size(Vq,2));
for k = 1 : length(lfp2.trial)
    for kk = 1 : size(lfp2.trial{k},1)
        [s,f,t] = spectrogram(lfp2.trial{k}(kk,:),250,249,1000,1000);
        s=s(1:60,:); s = s .* conj(s);
        [x,y] = meshgrid(1:size(s,2),1:size(s,1)); [x2,y2] = meshgrid(linspace(1,size(s,2),1000),1:size(s,1)); Vq = interp2(x,y,s,x2,y2); Vq = reshape(Vq,1,size(Vq,1),size(Vq,2));
        s_all(kk,:,:) = s_all(kk,:,:) + (Vq./length(lfp2.trial));
    end
    disp(k)
end