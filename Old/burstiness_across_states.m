clear
cd Y:\Milan\DriveDataSleep
sname = {'nrem','rem','wake'};
all_dip = nan(3,461);
bi = all_dip; xl = all_dip; xu = all_dip;
for s = 1 : 3
    load(['unitdata_' sname{s} '.mat'])
    for k = 1 : length(unitdata)
    %subplot(5,10,k), isi = log(diff(unitdata(k).ts)); 
    isi = log(diff(unitdata(k).ts)); 
    %bi(k) = HartigansDipTest(isi);
    try
        [dip, p_value, xlow,xup]=HartigansDipSignifTest(isi,200);
    catch
        continue
    end
    all_dip(s,k) = dip;

    bi(s,k) = p_value;

    xl(s,k) = xlow; xu(k) = xup;

    %disp(k)

    %HistISIMilan(unitdata(k).ts,'k'), title(bi(k))
    end
    disp(s)
end

%%

clear
cd Y:\Milan\DriveDataSleep
sname = {'nrem','rem','wake'};
all_dip = nan(3,461);
bi = all_dip; xl = all_dip; xu = all_dip;
for s = 1 : 3
    load(['unitdata_' sname{s} '.mat'])
    for k = 1 : length(unitdata)
    %subplot(5,10,k), isi = log(diff(unitdata(k).ts)); 
    isi = (diff(unitdata(k).ts)); 
    %bi(k) = HartigansDipTest(isi);
    i1 = isi(find(isi<=.05)); i1 = length(find(i1>=.002));
    i2 = isi(find(isi<=.3)); i2 = length(find(i2>=.2));
    all_dip(s,k) = i1./i2;

    %disp(k)

    %HistISIMilan(unitdata(k).ts,'k'), title(bi(k))
    end
    disp(s)
end

