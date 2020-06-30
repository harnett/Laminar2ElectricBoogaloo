function plot_dphs(dphss)
h = hist(dphss);
m = max(h)./2;
hist(dphss), hold on, plot(linspace(-pi,pi,1000),sin(2*pi*linspace(0,1,1000)+pi/2).*m+m,'k','LineWidth',6)
h = findobj(gca,'Type','patch');
h.EdgeColor='w';
xlim([-pi pi])
set(gca,'fontsize',20)
box off
xlabel('Delta phase (rad)','FontSize',25), ylabel('# of spindles','FontSize',25)
end