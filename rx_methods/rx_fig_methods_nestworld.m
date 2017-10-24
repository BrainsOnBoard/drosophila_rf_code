function rx_fig_methods_nestworld(dosave)
if ~nargin
    dosave = false;
end

set(0,'DefaultAxesFontName','Arial','DefaultAxesFontSize',8)

lm = .45;
fn = 'nest1.mat';
cpoint = 1000;
arenac = 'b--';
camerapos = [0 -3.5485 1.6119];

load(fn);

% sel = all(Y>=0,2);
% sel = true(size(Y,1),1);
% 
% X = X(sel,:);
% Y = Y(sel,:);
% Z = Z(sel,:);

X = 100*X;
Y = 100*Y;

ths = linspace(0,2*pi,cpoint);

rx_consts;
[cx,cy] = pol2cart(ths,100*d/2);

[coolx,cooly] = pol2cart(ths,100*pm.coold/2);

% figure(1);clf
% hold on
% plot3(cx,cy,zeros(size(cx)),arenac,cx,cy,ht*ones(size(cx)), ...
%       arenac,-d/2*[1 1],[0 0],[0 ht],arenac,d/2*[1 1],[0 0],[0 ht],arenac)
% fill([cx,coolx],[cy,cooly],'r','LineStyle','none')
% fill3(coolx,cooly,zeros(size(coolx)),'b')
% fill3(X',Y',Z','k')
% axis equal
% set(gca,'ZTick',[],'CameraPosition',camerapos);
% xlabel('x')
% ylabel('y')

figure(1);clf
% set(gca,'FontSize',8,'FontName','Arial')
hold on

fill(X',Y','k')

fill(cx,cy,'r')
fill(coolx,cooly,'b')

axis equal
xlim([-20 30])
ylim([-20 40])
set(gca,'XTick',-20:10:30,'YTick',-20:10:40)

andy_setbox

if dosave
    savefig('rx_arena_nest',[6 6])
end