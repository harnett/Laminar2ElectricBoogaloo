load('lfpcoh_all2.mat')

ploti = 1; plotl = [1 4 5 2 3];
acoordx = [.135 .135; .26 .26; .37 .37];
acoordy = [.98 .95; .98 .95; .98 .95;.98 .95;.98 .95;.98 .95];
for k = [1 3:6]
    subplot(2,3,plotl(ploti))
    if k==3 || k==4
        cs = 'b';
    else
        cs = 'r';
    end
    plot(fx,mean(ca(:,subsi==k),2).^2,cs)
    box off
    xlabel('Frequency (Hz)'), ylabel('Magnitude-Squared Coherence')
    [~,mx] = max(mean(ca(:,subsi==k),2));
    X = [.135 .135].*k;
    Y = [.98   .95];
    annotation('arrow',X,Y);
    ploti = ploti +1;
end

% only pfc/md have big delta coherence, mgb/a1 has big spindle coherence