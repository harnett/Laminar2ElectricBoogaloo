clear

cd Y:\Milan\DriveDataSleep
load subs.mat

gt=[]; p2t=[];
for k = [1 3:6]
    cd(subs{k})
    load('good_sess.mat')
    for kk = 1 : length(good_sess)
        cd(good_sess{kk})
        load('unitdata')
        for kkk = 1 : length(unitdata)
            if strcmp(unitdata(kkk).area,'MD') || strcmp(unitdata(kkk).area,'MGB')
            x = unitdata(kkk).waveform_mean;
            [~,mx] = max(max(x') - min(x'));
            spk = x(mx,:);
            [~,mx] = max(spk); [~,mi] = min(spk);
            p2t = [p2t mi-mx];
            gt = [gt; spk];
            
            end
        end
    end

end