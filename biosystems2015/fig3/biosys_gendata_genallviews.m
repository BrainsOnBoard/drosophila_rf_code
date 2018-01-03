function biosys_gendata_genallviews
% generates the images and gets kernel activations for the arenas listed in
% wharenas.txt

% common constants
rx_consts;

% generate views for each of the arenas
for i = 1:length(fnames)
    biosys_gendata_getviews(fnames{i});
end
