function rx_fig_methods_3d_arena(dosave)
if ~nargin
    dosave = false;
end

cpoint = 1000;
thhi = pi*4/3;
thoff = 0; %-pi/6;

load('ofstad_etal_arena','X','Y','Z');
[X,Y] = rotatexy(X,Y,thoff);

rx_consts;

ths = linspace(0,2*pi,cpoint);
[cx,cy] = pol2cart(ths,d/2);
th = mod(atan2(Y,X),2*pi);
sel = th < thhi | isnan(Y);

[coolx,cooly] = pol2cart(ths,pm.coold/2);

figure(1);clf
alfill(X(sel),Y(sel),Z(sel),.25*[1 1 1]);
hold on
fill(cx,cy,'r')
line(cx,cy,ht*ones(size(cx)),'Color','k')
fill(coolx,cooly,'b')
set(gca,'CameraPosition',[0.590774 -1.06578 0.367823]);

axis equal off

if dosave
    savefig('rx_fig_methods_3d_arena',[15 15])
end