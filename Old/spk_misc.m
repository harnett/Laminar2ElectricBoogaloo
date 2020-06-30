% for k = 1 : length(unitdata)
%     ms(k) = max(unitdata(k).ts);
% end
% ms = max(ms); 
% x = zeros(600000,length(unitdata));
% for k = 1 : length(unitdata)
%     t = unitdata(k).ts; t(t>=600) = [];
%     x(round(t.*1000),k) = 1;
% end

for k = 1 : length(unitdata)
    ms(k) = max(unitdata(k).ts);
end
ms = max(ms); 
x = zeros(round(ms.*1000)+1,length(unitdata));
for k = 1 : length(unitdata)
    t = unitdata(k).ts;
    x(round(t.*1000),k) = 1;
end