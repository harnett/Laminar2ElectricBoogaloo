function scatline(x)
if size(x,1)~=2
    x=x';
end

xa = [ones(1,length(x)) ones(1,length(x)).*2];
scatter(xa,[x(1,:) x(2,:)]), hold on
for k = 1 : size(x,2)
    line([1 2],[x(1,k) x(2,k)])
end
end