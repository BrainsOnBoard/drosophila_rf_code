% shows heat map & surf plot representing the IDF area over which
% navigation is possible (< thresh) calculated & drawn on.

function rx_fig_idf(dosave)
if ~nargin
    dosave = false;
end
do120 = true;
z120 = 0;

doplotallrots = false;
nrots = 16;
whrot = 5;

arenasperfig = 3;
doprogbar = true;
doload = true;
panoht = 2;

rx_consts;
d = 100*d;

if do120
    str120 = '_120';
    if z120 > 0
        str120 = sprintf('%s_z%f',z120);
    end
else
    str120 = '';
end

% fnames = {'nest1'};
viewtypes = { 'hires', 'lores', 'R2nt', 'R4nt', 'Rxnt' };
% viewtypes = { 'R2nt', 'R4nt', 'Rxnt' };

nsprow = length(viewtypes);
catchment_area_thresh = pi/4;
xyt = [-6 0 6];
xyl = (panoht+(d/2))*[-1 1];

if doplotallrots
    close all
end
for i = 1:length(fnames)
    if doplotallrots
        figure(i);clf
        alsubplot(length(viewtypes),nrots,1,1)
    elseif mod(i-1,arenasperfig)==0
        figure(1);clf
        alsubplot(length(viewtypes),arenasperfig,1,1)
    end
    
    [lr_views,superlr_views,kviews,rkernnum,kviews_nothresh,xg,yg] = rx_gendata_getviews(fnames{i},false,do120);

    xg = xg*100; % convert to cm
    yg = yg*100;

    [rotx,roty] = rotatexy(max(xg)/2,0,pi*(0.25:0.5:1.75));
    [~,ref_view_i] = min(hypot(bsxfun(@minus,xg,rotx),bsxfun(@minus,yg,roty)));
    [~,ref_view_i(end+1)] = min(hypot(xg,yg));
    refx = xg(ref_view_i);
    refy = yg(ref_view_i);

    xd = diff(xg);
    dgap = mean(xd(xd~=0));
    
    [px,py] = rx_unwrapworld(fnames{i+(i==2)},d,panoht);
    for j = 1:length(viewtypes)
        figdatafn = sprintf('%s/../../../data/rx_neurons/figpreprocess/idfs/%s_%s%s.mat',mfiledir,fnames{i},viewtypes{j},str120);
        
        if doload && exist(figdatafn,'file')
            disp([fnames{i} ' - ' viewtypes{j}])
            load(figdatafn);
        else
            switch viewtypes{j}
                case 'hires'
                    cviews = lr_views;
                case 'lores'
                    cviews = superlr_views;
                case 'loresnorm'
                    cviews = normalizevals(superlr_views);
                case 'R2'
                    cviews = kviews(rkernnum==2,1,:,:,:);
                case 'R4'
                    cviews = kviews(rkernnum==4,1,:,:,:);
                case 'Rx'
                    cviews = kviews(rkernnum==1,1,:,:,:);
                case 'R2nt'
                    cviews = kviews_nothresh(rkernnum==2,1,:,:,:);
                case 'R4nt'
                    cviews = kviews_nothresh(rkernnum==4,1,:,:,:);
                case 'Rxnt'
                    cviews = kviews_nothresh(rkernnum==1,1,:,:,:);
            end
            quadcaarea = NaN(length(refx),size(cviews,4));
%             idf = zeros(szxy);
            if doprogbar
                startprogbar(1,length(refx)*size(cviews,4),[fnames{i} ' - ' viewtypes{j}],true);
            else
               disp([fnames{i} ' - ' viewtypes{j}])
            end
            
            [perimx,perimy] = deal(cell(1,size(cviews,4)));
            idf = NaN(34,34,size(cviews,4));
            for k = 1:length(refx)
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

                    % CA area
                    rp = regionprops(success,'Area');
                    quadcaarea(k,l) = dgap.^2*rp.Area;
                    
                    if k==length(refx)
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
        
        if doplotallrots
            plotind = 1:length(perimx);
        else
            plotind = min(whrot,length(perimx));
        end
        
        for k = plotind
            cpx = perimx{k};
            cpy = perimy{k};
            cidf = idf(:,:,k);

            if doplotallrots
                alsubplot(j,k)
%                 if j==1 && k==1
%                     title(fnames{i});
%                 end
            else
                alsubplot(j,1+mod(i-1,arenasperfig))
            end
            
            hold on
            set(gca,'FontSize',10,'FontName','Arial');

            contourf(mxh,myh,cidf);

%             maxr = max(xg)+dgap;
%             [perimth,perimr] = cart2pol(cpx,cpy);
%             [cpx,cpy] = pol2cart(perimth,min(maxr,perimr));
%             line([cpx;cpx(1)],[cpy;cpy(1)],'Color','r')
% 
%             [cx,cy] = pol2cart(linspace(0,2*pi,1000),maxr);
%             line(cx,cy,'Color','k');
% 
%             alfill(px,py,'b','EdgeColor','b')

            if ~doplotallrots
                xlabel(sprintf('%.1f\n(\\pm %.2f)',mean(quadcaarea(:)),stderr(quadcaarea(:))));
                
                if j==nsprow && mod(i,arenasperfig)==1
                    set(gca,'XTick',xyt,'YTick',xyt);
                else
                    set(gca,'XTick',[],'YTick',[]);
                end
            else
                set(gca,'XTick',[],'YTick',[]);
            end

            axis square tight

            colormap gray
            
            colorbar

    %         if j==1
    %             title(fnames{i},'Interpreter','none');
    %         end

            xlim(xyl)
            ylim(xyl)
        end
    end
    
    if dosave
        if doplotallrots
            savefig(['rx_fig_allrots_' fnames{i}],[nrots*5 length(viewtypes)*4]);
        elseif (i==length(fnames) || mod(i,arenasperfig)==0)
            savefig('rx_fig_idfs',[arenasperfig*5 length(viewtypes)*4]);
        end
    end
end


