clear
cd Y:\Milan\DriveDataSleep
load('subs.mat')
% loop thru subs
for k = 1:5
    cd(subs{k})
    load('good_sess.mat')
    % loop thru sessions
    for kk = 1 : length(good_sess)
        cd(good_sess{kk})
        if ~isfile('MUA_1k.mat')
        mua = MUA_Writer_Mapped(good_sess{kk},1000,[],[],[]);
        save('MUA_1k.mat','mua','-v7.3')
        clear mua
        end
    end
    disp(k)
end