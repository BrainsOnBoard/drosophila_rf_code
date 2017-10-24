% fnames = { 'debugworld.mat' }; %'nest1_drum.mat', 'nest1.mat', ...'ofstad_etal_arena.mat',
% %            'nest2_drum.mat', 'nest2.mat', ...
% %            'artificial1_drum.mat', 'artificial1.mat', ...
% %            'artificial2_drum.mat', 'artificial2.mat' };
% % fnames = {};           
% % %            'artificial2_drum.mat', 'artificial2.mat' };
% % %            'nest2_drum.mat', 'nest2.mat', ...
% % %            'nest1_dist_drum.mat', 'nest1_dist.mat', ...
% % %            'nest2_dist_drum.mat', 'nest2_dist.mat', ...
% % %            
% for fni = 14:16
%     st = sprintf('artificial%d',fni);
%     fnames = [ fnames, {[st '_drum.mat'], [st '.mat']} ];
% end
% clear fni st

% fnames = { 'ofstad_etal_arena' };
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