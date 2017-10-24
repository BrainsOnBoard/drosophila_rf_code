function rx_gendata_genallpaths
% this function generates data with the same parameters as
% sub_rx_pm_newpath.sh (or ought to, anyway)

viewtypes = {'hires','lores','R2nt','R4nt','Rxnt'};
npaths = 25;
nstartpos = 90;

rx_consts;

for i = 1:length(fnames)
    for j = 1:length(viewtypes)
        for k = 1:nstartpos
            rx_gendata_pm_newpath(fnames{i},viewtypes{j},k,1:npaths);
        end
    end
end