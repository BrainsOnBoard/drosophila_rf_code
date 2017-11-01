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
lrimsz = [120 360];   % low-res image size
superlrimsz = [2 14]; % super low-res image size
rkernsz = [120 270];  % size of resized kernels
d = .123;
ht = .128;
vpitch = 30;

% parameters for perfect memory simulations
pm.maxlen = 2*pi*d;
pm.maxsteplen = 0.0025;
pm.minsteplen = 0.001; % only with varying step length
pm.compth = pi/4;
pm.reflen = d/6;
pm.nsnaps = 20;
pm.coold = 0.025;
pm.goalrad = d/3;
pm.thnoise = pi/64;

pm.nstartpos = 90;
pm.startrad = 0.8*d/2;

pm.maxwallhits = inf;