function corrections_rx_fig_pm_showpaths(dosave)
% if ~nargin
%     dosave = false;
% end

picwd = 3; % cm
picdpi = 600;
picdir = [mfiledir '/../../../figures/drosneur/rx_neurons/rx_pm/pathpics'];

if ~exist(picdir,'dir')
    mkdir(picdir)
end

rx_consts;

arenasperfig = min(3,length(fnames));
% panoht = 2;
doload = true;
doprogbar = false;
% dosaveimagesseparately = true;
linecols = [1 0 0; 0 0 1; 0 1 0; 1 1 0; 0 0 0];
viewtypes = {'hires','lores','R2nt', 'R4nt', 'Rxnt' };
% fnames = {'nest1'};

dcm = 100*d;

% xyt = [-6 0 6];
% xyl = (panoht+(dcm/2))*[-1 1];

dname = fullfile(mfiledir,'../../../data/rx_neurons/paths');

shortestpath = pm.startrad-pm.coold/2;

% [drumx,drumy] = pol2cart(linspace(0,2*pi),dcm/2);

cmperin = 2.54;
rtnviews = round(picwd*picdpi/cmperin);

snd = [mfiledir '/../../../data/rx_neurons/snaps/'];
dfiles = dir(fullfile(snd,'*.mat'));
load(fullfile(snd,dfiles(1).name),'snx','sny');
imvals = linspace(-dcm/2,dcm/2,rtnviews);

[madeits,tty] = deal(NaN(25, 90, length(viewtypes), length(fnames)));

for i = 1:length(fnames)
%     if mod(i-1,arenasperfig)==0
%         figure(2);clf
%         alsubplot(length(viewtypes),arenasperfig,1,1)
%     end
%     
%     [unwrappedx,unwrappedy] = rx_unwrapworld(fnames{i+(i==2)},dcm,panoht);
%     if ~dosaveimagesseparately
%         unwrappedy = -unwrappedy;
%     end
    for j = 1:length(viewtypes)
        figdatafn = sprintf('%s/../../../data/rx_neurons/figpreprocess/paths/paths_%s.mat_%s.mat',mfiledir,fnames{i},viewtypes{j});
        if 0 %doload && exist(figdatafn,'file')
            load(figdatafn,'totim','tty','madeits','nfile');
        else
            nfile = 0;
            for k = 1:pm.nstartpos
                fname = sprintf('%s/%s_%s_st%02d_%04dto*.mat',dname,fnames{i}, ...
                                viewtypes{j},k,1);
                cfs = dir(fname);
                if length(cfs) > 1
                        error('too many files!')
                elseif length(cfs)==1
                    nfile = nfile+1;

                    load([dname '/' cfs(1).name],'flyx','flyy','walkdist','madeit');

%                     mx = min(npathmax,size(flyx,1));
                    madeits(:,k,j,i) = madeit;
                    tty(:,k,j,i) = walkdist ./ shortestpath - 1;
                end
            end
        end
    end
end

sz = size(madeits);
g1_viewtypes = repmat(shiftdim(1:length(viewtypes), -1), [sz(1:2), 1, sz(4)]);
g2_fnames = repmat(shiftdim(1:length(fnames), -2), [sz(1:3), 1]);
g1_viewtypes = g1_viewtypes(:);
g2_fnames = g2_fnames(:);

madeits = madeits(:);

[pval_m,tab_m,stats_m] = anovan(madeits, { g1_viewtypes, g2_fnames });
mc_m_viewtypes = multcompare(stats_m)
mc_m_fnames = multcompare(stats_m, 'Dimension', 2)

tty = tty(:);
valids = ~isnan(tty);
[pval_t,tab_t,stats_t] = anovan(tty(valids), { g1_viewtypes(valids), g2_fnames(valids) });
mc_t_viewtypes = multcompare(stats_t)
mc_t_fnames = multcompare(stats_t, 'Dimension', 2)

dump2base(true)