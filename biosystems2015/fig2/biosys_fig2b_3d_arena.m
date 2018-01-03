function biosys_fig2b_3d_arena(dosave)
% shows a 3D view of Ofstad et al.'s arena

if ~nargin
    % whether to save figure to disk
    dosave = false;
end

% common constants
rx_consts;

cpoint = 1000; % points on circle
thmax = pi*4/3; % maximum angle (we're drawing the arena with a chunk missing)
thoff = 0; %-pi/6;

% load arena
load('ofstad_etal_arena','X','Y','Z');
[X,Y] = rotatexy(X,Y,thoff);

% coords of arena perimeter
ths = linspace(0,2*pi,cpoint);
[cx,cy] = pol2cart(ths,d/2);

% select only vertices in our desired range of angles
th = mod(atan2(Y,X),2*pi);
sel = th < thmax | isnan(Y);

%% show figure
figure(1);clf

% draw bars/lines
alfill(X(sel),Y(sel),Z(sel),.25*[1 1 1]);
hold on

% draw arena perimeter (top and bottom)
fill(cx,cy,'r')
line(cx,cy,ht*ones(size(cx)),'Color','k')

% draw cool spot
[coolx,cooly] = pol2cart(ths,pm.coold/2);
fill(coolx,cooly,'b')

% axis etc.
set(gca,'CameraPosition',[0.590774 -1.06578 0.367823]);
axis equal off

if dosave
    % save figure
    alsavefig('rx_fig_methods_3d_arena',[15 15])
end
