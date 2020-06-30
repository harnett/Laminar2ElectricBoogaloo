clear
cd Y:\Milan\DriveDataSleep
load('unitdata_all.mat')
for k = 1 : length(unitdata)
%subplot(5,10,k), isi = log(diff(unitdata(k).ts)); 
isi = log(diff(unitdata(k).ts)); 
%bi(k) = HartigansDipTest(isi);

[dip, p_value, xlow,xup]=HartigansDipSignifTest(isi,200);

all_dip(k) = dip;

bi(k) = p_value;

xl(k) = xlow; xu(k) = xup;

disp(k)

%HistISIMilan(unitdata(k).ts,'k'), title(bi(k))
end

%%
sig = zeros(1,length(bi)); sig(bi<=.01) = 1;

a = cell(1,length(unitdata));
for k = 1 : length(unitdata)
a{k} = unitdata(k).area;
%HistISIMilan(unitdata(k).ts,'k'), title(bi(k))
end
[lbl,~,a]=unique(a);

nburst = [];
for k = 1 : length(unique(a))
    nburst_tmp = bi(a==k);
    dips{k} = all_dip(a==k);
    nburst(k) = length(find(nburst_tmp<=.01))./length(nburst_tmp);
end

%%
g=gramm('x',lbl,'y',nburst);
g.geom_bar()
g.draw()
%%

[~,i] = sort(all_dip);% unitdata = unitdata(i);
unitdata2=unitdata(i); %bi = bi(i);
figure
si=1;
for k = 1 : 10: length(unitdata)
subplot(7,7,si), HistISIMilan(unitdata(k).ts,'k')%, title(bi(k))
si = si + 1;
title(10.^xl(k))
end