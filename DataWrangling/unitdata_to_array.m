function x = unitdata_to_array(unitdata)


for k = 1 : length(unitdata)
    ms(k) = max(unitdata(k).ts);
end
ms = max(ms); 
x = zeros(round(ms.*1000)+1,length(unitdata));
for k = 1 : length(unitdata)
    t = unitdata(k).ts;
    t = round(t.*1000); t(t==0) = [];
    x(t,k) = 1;
end

end