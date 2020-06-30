cd Y:\Milan\DriveDataSleep

clear 
load('subs.mat')

spc = []; ra = [];
for kkk = 1 : length(subs)
    cd(subs{kkk})
    load('good_sess.mat')
    spctra_all = []; R_all = [];
for k = 1 : length(good_sess)
    cd(good_sess{k})
    load ('unitdata.mat') 
    load('states.mat')
    spctra = spk_spectra(unitdata,states);
    spctra_sub = []; R_sub = nan(3,length(unitdata));
    for kk = 1 : 3
        R_sub(kk,:) = spctra(kk).R;
        if kk == 1
            spctra_sub = spctra(1).S;
        else
            spctra_sub = cat(3,spctra_sub, spctra(kk).S);
        end
    end
    spctra_all = cat(1,spctra_all,spctra_sub); R_all = cat(2,R_all,R_sub);
end

spc = cat(1,spc,spctra_all); ra = cat(2,ra,R_all);

cd(subs{kkk})
save('spctra_all_sess.mat','spctra_all','R_all')
disp(kkk)
end

f=spctra(1).f;

cd(subdir)

