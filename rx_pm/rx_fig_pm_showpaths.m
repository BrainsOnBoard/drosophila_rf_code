function rx_fig_pm_showpaths(dosave)
if ~nargin
    dosave = false;
end

picwd = 3; % cm
picdpi = 600;
picdir = [mfiledir '/../../../figures/drosneur/rx_neurons/rx_pm/pathpics'];

if ~exist(picdir,'dir')
    mkdir(picdir)
end

rx_consts;

arenasperfig = min(3,length(fnames));
panoht = 2;
doload = true;
doprogbar = true;
dosaveimagesseparately = true;
linecols = [1 0 0; 0 0 1; 0 1 0; 1 1 0; 0 0 0];
viewtypes = {'hires','lores','R2nt', 'R4nt', 'Rxnt' };
% fnames = {'nest1'};

dcm = 100*d;

xyt = [-6 0 6];
xyl = (panoht+(dcm/2))*[-1 1];

dname = fullfile(mfiledir,'../../../data/rx_neurons/paths');

shortestpath = pm.startrad-pm.coold/2;

[drumx,drumy] = pol2cart(linspace(0,2*pi),dcm/2);

cmperin = 2.54;
rtnviews = round(picwd*picdpi/cmperin);

snd = [mfiledir '/../../../data/rx_neurons/snaps/'];
dfiles = dir(fullfile(snd,'*.mat'));
load(fullfile(snd,dfiles(1).name),'snx','sny');
imvals = linspace(-dcm/2,dcm/2,rtnviews);
for i = 1:length(fnames)
    if mod(i-1,arenasperfig)==0
        figure(2);clf
        alsubplot(length(viewtypes),arenasperfig,1,1)
    end
    
    [unwrappedx,unwrappedy] = rx_unwrapworld(fnames{i+(i==2)},dcm,panoht);
    if ~dosaveimagesseparately
        unwrappedy = -unwrappedy;
    end
    for j = 1:length(viewtypes)
        figdatafn = sprintf('%s/../../../data/rx_neurons/figpreprocess/paths/paths_%s.mat_%s.mat',mfiledir,fnames{i},viewtypes{j});
        if doload && exist(figdatafn,'file')
            load(figdatafn,'totim','tty','madeits','nfile');
        else
            totim = zeros([rtnviews,rtnviews,size(linecols,1)]);
            tty = NaN(pm.nstartpos,1);
            madeits = NaN(pm.nstartpos,1);
            nfile = 0;
            if doprogbar
                startprogbar(10,pm.nstartpos,[fnames{i} ' - ' viewtypes{j}],true);
%             else
%                 disp([arenas{i} ' - ' viewtypes{j}])
            end
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

                    madeits(k)=mean(madeit);
                    tty(k) = mean(walkdist(madeit))/shortestpath-1;
                    if tty(k)<0
                        error('negative tortuosity')
                    end

                    ccol = 1+mod(k-1,size(linecols,1));

                    flyx = 1+round((rtnviews-1)*(0.5+flyx./d));
                    flyy = 1+round((rtnviews-1)*(0.5+flyy./d));
                    dy = diff(flyy);
                    sgny = sign(dy);
                    dx = diff(flyx);
                    sgnx = sign(dx);
                    derr = abs(dy./dx);

                    for l = 1:size(flyx,2)
                        for m = 1:size(dy,1)
                            if isnan(dy(m,l))
                                continue;
                            end

                            if dy(m,l)==0 % horizontal line or single pixel
                                if sgnx(m,l)==0
                                    cind = sub2ind(size(totim),flyy(m,l),flyx(m,l),ccol);
                                else
                                    xind = flyx(m,l):sgnx(m,l):flyx(m+1,l);
                                    cind = sub2ind(size(totim),flyy(m,l)*ones(1,length(xind)),xind,ccol*ones(1,length(xind)));
                                end
                            elseif isinf(derr(m,l)) % vertical line
                                yind = flyy(m,l):sgny(m,l):flyy(m+1,l);
                                cind = sub2ind(size(totim),yind,flyx(m,l)*ones(1,length(yind)),ccol*ones(1,length(yind)));
                            else
                                cind = [];
                                err = 0;
                                cy = flyy(m,l);
                                for cx = flyx(m,l):sgnx(m,l):flyx(m+1,l)
                                    cind(end+1) = sub2ind(size(totim),cy,cx,ccol);
                                    err = err+derr(m,l);
                                    while err >= 0.5
                                        cind(end+1) = sub2ind(size(totim),cy,cx,ccol);
                                        cy = max(1,min(rtnviews,cy+sgny(m,l)));
                                        err = err-1;
                                    end
                                end
                            end

                            totim(cind) = totim(cind)+1;
                        end
                    end
                end
                
                if doprogbar && progbar
                    return
                end
            end

            if nfile==pm.nstartpos
                if doload
                    savemeta(figdatafn,'totim','tty','madeits','nfile');
                end
            else
                warning('only %d files for %s:%s',nfile,fnames{i},viewtypes{j});
            end
        end
        ptotim = bsxfun(@rdivide,totim,sum(totim,3));
        ptotim(isnan(ptotim)) = 0;
        
        whim = ones([rtnviews,rtnviews,3]);
        for k = 1:size(ptotim,3)
            cim = repmat(shiftdim(linecols(k,:),-1),rtnviews,rtnviews);
            cim(:,:,4) = ptotim(:,:,k);
            whim = imageadd(whim,cim);
        end
        
        alsubplot(j,1+mod(i-1,arenasperfig))
        if ~dosave || ~dosaveimagesseparately
            image(imvals,imvals,whim)
        end
        hold on
        
        plot(100*snx,100*sny,'k.')
        
        plot(drumx,drumy,'k');
        
        alfill(unwrappedx,unwrappedy,'b','EdgeColor','b')
        
        axis equal
        
        if j==1
            title(fnames{i},'Interpreter','none')
        end
        if j==length(viewtypes)
            set(gca,'XTick',xyt);
        else
            set(gca,'XTick',[]);
        end
        if mod(i,arenasperfig)==1
            ylabel(viewtypes{j})
            set(gca,'YTick',xyt);
        else
           set(gca,'YTick',[]);
        end
        
        xlim(xyl)
        ylim(xyl)
        
        xlabel(sprintf('%.2f (%.2f)',nanmean(madeits),nanmean(tty)));
        
        if dosave && dosaveimagesseparately
            fname = sprintf('%s/%s_%s.png',picdir,fnames{i},viewtypes{j});
            if exist(fname,'file')
                error('%s already exists',fname)
            end
            
            fprintf('Writing image to %s...\n',fname)
            imwrite(whim,fname)
        end
    end
    
    if dosave && (i==length(fnames) || mod(i,arenasperfig)==0)
        savefig('rx_pm_showpaths',[5*arenasperfig 20])
    end
end

% dump2base(true)