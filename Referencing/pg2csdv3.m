function CSD = pg2csdv3(PG)

%FIGURE OUT AND WRITE HERE IS + IS SI NK OR 

r = 20; %resistance in ohm/mm
h = 0.15; %intercontact distance in mm

[nchans,ntpoints] = size(PG);
PG_orig = PG;

PG = zeros(nchans+2,ntpoints);
PG(2:nchans+1,:) = PG_orig;

CSD = zeros(nchans-2,ntpoints);

for k=2:(nchans-1)
  %CSD(k,:)=.23*(PG(k,:)-PG(k+1,:))+.54*(PG(k+1,:)-PG((k+2),:))+.23*(PG((k+2),:)-PG((k+3),:));
  CSD(k,:)=.23*(PG(k,:)-PG(k-1,:))+.54*(PG(k+1,:)-PG((k),:))+.23*(PG((k+2),:)-PG((k+1),:));
end

CSD=CSD(2:end,:);

CSD=CSD./(r*h^2);

return;