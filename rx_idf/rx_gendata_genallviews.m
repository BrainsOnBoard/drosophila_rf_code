function rx_gendata_genallviews
% generates the images and gets kernel activations for the arenas listed in
% wharenas.txt

% common constants
rx_consts;

% generate views for each of the arenas
for i = 1:length(fnames)
    rx_gendata_getviews(fnames{i});
end
