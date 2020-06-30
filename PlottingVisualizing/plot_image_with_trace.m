function plot_image_with_trace(x,PltChs,cl,sm)

nPltChs = length(PltChs);

xs = size(x,1);

plt_cent = linspace(1,xs,nPltChs+2);
plt_wdth = xs ./ nPltChs;
rs = range(x(PltChs,:),2);
rsm = max(rs);

imagesc(x), hold on

for k = 1 : nPltChs
    plt = x(PltChs(k),:);
    if ~isempty(sm)
        plt = smoothdata(plt, 'gaussian',8);
    end
    plt = plt-mean(plt); 
    plt = plt .* (plt_wdth./rsm); 
    plt = -plt;
    plt = plt + plt_cent(k+1);
    plot(plt,'k','LineWidth',2), hold on
end

if ~isempty(cl)
set(gca,'CLim',cl)
end

end