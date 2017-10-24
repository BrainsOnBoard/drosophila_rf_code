
rx_consts;
% fnames = {'ofstad_etal_arena.mat', 'rx_naturaldrum.mat'};

for i = 1:length(fnames)
    rx_gendata_getviews(fnames{i},true,true);
end