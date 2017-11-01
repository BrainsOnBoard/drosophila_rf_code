%% constants used throughout simulations

% read the "arenas" (worlds) on which to run the simulations from the file
% wharenas.txt
fid = fopen('wharenas.txt','r');
fnames = textscan(fid,'%s\n');
fnames = fnames{:};
fclose(fid);
clear fid
flabels = fnames;

% image sizes
origimsz = [240 720]; % original image size
lrimsz = [120 360];   % size for high-res views
superlrimsz = [2 14]; % size for low-res views 
rkernsz = [120 270];  % size of resized kernels

vpitch = 30; % pitch of agent (deg)

d = .123; % diameter of arena
ht = .128; % height of arena

% parameters for perfect memory simulations
pm.maxlen = 2*pi*d; % maximum path length for agent before simulation stops
pm.maxsteplen = 0.0025;
pm.minsteplen = 0.001; % only with varying step length
pm.compth = pi/4;
pm.reflen = d/6;
pm.nsnaps = 20; % number of snapshots
pm.coold = 0.025; % diameter of cool spot
pm.goalrad = d/3; % radius of goal from centre of arena
pm.thnoise = pi/64; % noise on heading for agent
pm.maxwallhits = inf; % number of wall collisions before simulation stops

pm.nstartpos = 90; % number of starting positions for agent
pm.startrad = 0.8*d/2; % radius at which the agent starts
