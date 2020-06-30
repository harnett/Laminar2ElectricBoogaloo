d = dir;
d = {d.name};

d = d(3:12);

ma=[];
for k = 8 : length(d)
    cd(strcat('C:\Users\Loomis\Documents\HO_FO_Spindles\Laminar1_PFC\',d{k}))
    load('MUA_1k.mat')
    m = mean(mua.trial{1},2)';
    ma = [ma; m];
    disp(k)
end