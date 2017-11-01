function rx_fig_idf(dosave)
% shows heat map & surf plot representing the IDF area over which
% navigation is possible (< thresh) calculated & drawn on.

if ~nargin
    % default to not saving figure to disk
    dosave = false;
end

arenasperfig = 3;
doprogbar = true; % show progress bar
doload = true; % whether to load fig data from cache
panoht = 2;

% common constants
rx_consts;

% convert arena diameter to cm
d = 100*d;

% types of view (image/RF output)
viewtypes = { 'hires', 'lores', 'R2nt', 'R4nt', 'Rxnt' };

nsprow = length(viewtypes);
catchment_area_thresh = pi/4; % error below this value indicates success
xyticks = [-6 0 6]; % axis ticks
xylim = (panoht+(d/2))*[-1 1]; % limits of x and y axes

for i = 1:length(fnames)
    if mod(i-1,arenasperfig)==0
        figure(1);clf
        alsubplot(length(viewtypes),arenasperfig,1,1)
    end
    
    % get views (images/RF outputs)
    [lr_views,superlr_views,kviews,rkernnum,kviews_nothresh,xg,yg] = rx_gendata_getviews(fnames{i},false);

    % convert x,y positions of views to cm
    xg = xg*100;
    yg = yg*100;

    % get x and y reference (snapshot) positions for the four quadrants
    [rotx,roty] = rotatexy(max(xg)/2,0,pi*(0.25:0.5:1.75));
    [~,ref_view_i] = min(hypot(bsxfun(@minus,xg,rotx),bsxfun(@minus,yg,roty)));
    [~,ref_view_i(end+1)] = min(hypot(xg,yg));
    refx = xg(ref_view_i);
    refy = yg(ref_view_i);

    % calculate spacing of grid
    xd = diff(xg);
    dgap = mean(xd(xd~=0));
    
%     % "unwrap" current arena
%     [px,py] = rx_unwrapworld(fnames{i+(i==2)},d,panoht);
    for j = 1:length(viewtypes)
        % make dir if it doesn't exist
        dname = fullfile(mfiledir,'../data/figpreprocess/idfs');
        if ~exist(dname,'dir')
            mkdir(dname)
        end
        
        % figure data file
        figdatafn = fullfile(dname,sprintf('%s_%s.mat',fnames{i},viewtypes{j}));
        
        if doload && exist(figdatafn,'file')
            % fig data is already generated; load from file
            disp([fnames{i} ' - ' viewtypes{j}])
            load(figdatafn);
        else
            switch viewtypes{j}
                case 'hires'
                    cviews = lr_views;
                case 'lores'
                    cviews = superlr_views;
                case 'R2nt'
                    cviews = kviews_nothresh(rkernnum==2,1,:,:,:);
                case 'R4nt'
                    cviews = kviews_nothresh(rkernnum==4,1,:,:,:);
                case 'Rxnt'
                    cviews = kviews_nothresh(rkernnum==1,1,:,:,:);
            end
            if doprogbar
                startprogbar(1,length(refx)*size(cviews,4),[fnames{i} ' - ' viewtypes{j}],true);
            else
                disp([fnames{i} ' - ' viewtypes{j}])
            end
            
            [perimx,perimy] = deal(cell(1,size(cviews,4))); % CA perimeter
            quadcaarea = NaN(length(refx),size(cviews,4)); % CA sizes for each quadrant
            idf = NaN(34,34,size(cviews,4)); % IDF values as 2D matrices
            for k = 1:length(refx)
                % get RMS differences between all views and current
                % reference view
                rms_diffs = shiftdim(getRMSdiff(cviews,cviews(:,:,ref_view_i(k),:)));
                
                for l = 1:size(cviews,4)
                    % get IDF and IDF headings
                    [heads,~,idf(:,:,l)] = getIDFheads(xg,yg,rms_diffs(:,l));
%                     if k==length(refx)
%                         idf = idf+cidf./size(cviews,4);
%                     end

                    % calculate errors, make into matrix
                    errs = circ_dist(heads,atan2(refy(k)-yg,refx(k)-xg));
                    [errs_im,mxh,myh] = makeim(xg,yg,errs);
                    imviewi = mxh==refx(k) & myh==refy(k);

                    % calculate CA
                    success_goodheads = abs(errs_im) < catchment_area_thresh;
                    success_goodheads(imviewi) = true;
                    success_bwl = bwlabeln(success_goodheads);
                    success = success_bwl==success_bwl(imviewi);
                    success = imfill(success,'holes');

                    % calculate size of this CA
                    rp = regionprops(success,'Area');
                    quadcaarea(k,l) = dgap.^2*rp.Area;
                    
                    if k==length(refx)
                        % calculate perimeter of CA
                        perim = bwboundaries(success);
                        perim = perim{1};
                        pind = sub2ind(size(success),perim(:,1),perim(:,2));
                        perimx{l} = mxh(pind);
                        perimy{l} = myh(pind);
                    end
                    
                    if doprogbar && progbar
                        return
                    end
                end
            end
            
            if doload
                disp('Saving...')
                save(figdatafn,'mxh','myh','idf','quadcaarea','perimx','perimy');
            end
        end
        
        % which of the four IDFs to plot
        plotind = 1;
        cpx = perimx{plotind};
        cpy = perimy{plotind};
        cidf = idf(:,:,plotind);

        % place plot in correct subplot
        alsubplot(j,1+mod(i-1,arenasperfig))
        hold on
        set(gca,'FontSize',10,'FontName','Arial');

        % contour plot
        contourf(mxh,myh,cidf);

        % draw catchment area
        maxr = max(xg)+dgap;
        [perimth,perimr] = cart2pol(cpx,cpy);
        [cpx,cpy] = pol2cart(perimth,min(maxr,perimr));
        line([cpx;cpx(1)],[cpy;cpy(1)],'Color','r')

        % show mean (+-stderr) for this quadrant's CA
        xlabel(sprintf('%.1f\n(\\pm %.2f)',mean(quadcaarea(:)),stderr(quadcaarea(:))));

%             % show unwrapped world around edge
%             [cx,cy] = pol2cart(linspace(0,2*pi,1000),maxr);
%             line(cx,cy,'Color','k');
%             alfill(px,py,'b','EdgeColor','b')

        % set axis ticks
        if j==nsprow && mod(i,arenasperfig)==1
            set(gca,'XTick',xyticks,'YTick',xyticks);
        else
            set(gca,'XTick',[],'YTick',[]);
        end
        
        % axis limits
        xlim(xylim)
        ylim(xylim)
        axis square tight

        % colormap for contour plots
        colormap gray

        % show a colour bar
        colorbar
    end
    
    if dosave
        % save figure
        if (i==length(fnames) || mod(i,arenasperfig)==0)
            alsavefig('rx_fig_idfs',[arenasperfig*5 length(viewtypes)*4]);
        end
    end
end
