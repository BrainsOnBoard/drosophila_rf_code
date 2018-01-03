function biosys_fig2c_birds_eye(dosave)
% shows a top-down view of the natural 3D world

if ~nargin
    % whether to save figure to disk
    dosave = false;
end

set(0,'DefaultAxesFontName','Arial','DefaultAxesFontSize',8)

fn = 'nest1.mat'; % which arena
cpoint = 1000; % points on circle

% common constants
biosys_consts;

% load arena and scale to cm
load(fn);
X = 100*X;
Y = 100*Y;

% coords for hot and cool parts of arena
ths = linspace(0,2*pi,cpoint);
[hotx,hoty] = pol2cart(ths,100*d/2);
[coolx,cooly] = pol2cart(ths,100*pm.coold/2);

%% show figure
figure(1);clf
hold on

% draw objects (tussocks etc.)
fill(X',Y','k')

% draw arena
fill(hotx,hoty,'r')
fill(coolx,cooly,'b')

% mess around with axes etc.
axis equal
xlim([-20 30])
ylim([-20 40])
set(gca,'XTick',-20:10:30,'YTick',-20:10:40)
andy_setbox

if dosave
    % save figure
    alsavefig('rx_arena_nest',[6 6])
end