
cfg=[]; cfg.trl=zeros(size(st,1),3); cfg.trl(:,1) = st(:,1)-500; cfg.trl(:,2) = st(:,2)+500; lfp2=ft_redefinetrial(cfg,lfp);

ya=[];
for k = 1 : size(st,1)
f = fft(lfp2.trial{k}(15,:)); f = f(1:round(length(f)/2)); f = f.*conj(f); y = interp1(linspace(0,500,length(f)),f,linspace(0,500,1000));
ya = [ya; y];
disp(k)
end