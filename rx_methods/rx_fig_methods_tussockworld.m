clear

dosave = true;

load([mfiledir '/../../../data/arenas/artificial2.mat'],'X','Y','Z');

rx_consts;
rtussockmin = d/2;
rpanomax = 4*d/2;
rpanobnd = 3*d/2;

figure(1);clf
fill(100*X',100*Y','k')
hold on
drawcirc(0,0,100*rtussockmin,0,0,100*rpanobnd,0,0,100*rpanomax);
% lm = 100*1.25*rpanomax*[-1 1];
lm = 30*[-1 1];
tks = lm(1):6:lm(2);
set(gca,'XTick',tks,'YTick',tks)
axis equal tight
ylim(lm)
xlim(lm)

if dosave
    savefig('rx_fig_methods_tussockworld',[12 6])
end