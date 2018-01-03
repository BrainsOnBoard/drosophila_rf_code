function biosys_gendata_genallpaths
% this function generates data with the same parameters as
% sub_rx_pm_newpath.sh (or ought to, anyway)

% common constants
biosys_consts;

% types of view to run simulations on
viewtypes = {'hires','lores','R2nt','R4nt','Rxnt'};

% number of simulations at each starting position
npaths = 25;

% number of starting positions
nstartpos = pm.nstartpos;

%% run simulations
for i = 1:length(fnames)
    for j = 1:length(viewtypes)
        for k = 1:nstartpos
            biosys_gendata_newpath(fnames{i},viewtypes{j},k,1:npaths);
        end
    end
end
