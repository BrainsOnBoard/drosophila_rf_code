fid = fopen('wharenas.txt','r');
fnames = textscan(fid,'%s\n');
fnames = fnames{:};
fclose(fid);
clear fid

flabels = fnames;

origimsz = [240 720];
lrimsz = [120 360];
superlrimsz = [2 14];
rkernsz = [120 270];
% warning('rkernsz %dx%d',rkernsz(1),rkernsz(2))
d = .123;
ht = .128;
vpitch = 30;

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