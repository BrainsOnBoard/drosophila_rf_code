function [lr_views,superlr_views,kviews,rkernnum,kviews_nothresh,xg,yg]=rx_gendata_getviews(origfname,dogen,do120)
if nargin < 3
    do120 = false;
end
% if nargin < 2
%     dogen = true;
% end

if do120
    z120 = 0;
else
    z120 = 0;
end

rx_consts;

if do120
    str120 = '_120';
    if z120 > 0
        str120 = sprintf('%s_z%f',str120,z120);
    end
    origimsz = [180 720];
    padview = 60;
    lrimsz = [120 360];
    rkernsz = [120 270];
    elmax = 90;
else
    str120 = '';
    elmax = 75;
end

fname = sprintf('%s/../../../data/rx_neurons/views/rx_views_%s%s.mat',mfiledir,origfname,str120);
if exist(fname,'file')
    load(fname);
elseif ~dogen
    error('%s doesn''t exist',origfname)
else
    nviewsapprox = 1000;
    load(origfname,'X','Y','Z');
    
    rtnviews = round(2*sqrt(nviewsapprox/pi));
    [xg,yg] = meshgrid(linspace(-d/2,d/2,rtnviews));
    sel = hypot(xg,yg) < d/2;
    xg = xg(sel);
    yg = yg(sel);

    startprogbar(10,numel(xg),[origfname ' - getting views'],true);
    views = NaN([origimsz,numel(xg)]);
    for i = 1:numel(xg)
        views(:,:,i) = getviewfast(xg(i),yg(i),z120,0,X,Y,Z,[],elmax,origimsz,vpitch);

%         disp([xg(i) yg(i)])

%         figure(1);clf
%         imshow(views(:,:,i))
%         keyboard

        if progbar
            return
        end
    end
    
    savemeta(fname,'views','xg','yg','vpitch');
end

if ~exist('lr_views','var')
    if ~dogen
        error('no lr views in %s',origfname)
    else
        lr_views = NaN([lrimsz,length(xg)]);
        superlr_views = NaN([superlrimsz,length(xg)]);
        startprogbar(100,length(xg),[origfname ' - averaging images'],true);
        for i = 1:length(xg)
%             if do120
%                 cview = [views(:,:,i); ones(padview,origimsz(2))];
%             else
                cview = views(:,:,i);
%             end
            lr_views(:,:,i) = imresize(cview,lrimsz);
            superlr_views(:,:,i) = imresize(cview,superlrimsz);

            if progbar
                return;
            end
        end

        save(fname,'-append','lr_views','superlr_views');
    end
end

% if ~exist('kviews','var')
%     if ~dogen
%         error('no kviews in %s',origfname)
%     else
%         norient = 16;
% 
%         [rkerns,rkernnum] = rx_gendata_rx_kerns;
% 
%         kth = round(linspace(0,size(lr_views,2),norient+1));
%         kth = kth(1:end-1);
% 
%         nkern = size(rkerns,3);
%         kviews_nothresh = NaN(nkern,1,length(xg),norient);
%         startprogbar(10,nkern*norient,[origfname ' - getting kviews'],true);
%         for i = 1:norient
%             cviews = circshift(lr_views,[0 kth(i)]);
%             tviews = cviews(:,round((size(lr_views,2)-rkernsz(2))/2)+(1:rkernsz(2)),:);
% 
%             for j = 1:nkern
%                 kviews_nothresh(j,1,:,i) = getacts(tviews,rkerns(:,:,j))';
% 
%                 if progbar
%                     return
%                 end
%             end
%         end
% 
%         kviews_nothresh = normalizevals(kviews_nothresh);
% 
%         save(fname,'-append','kviews','rkernnum');
%     end
% end

if ~exist('kviews_nothresh','var')
    if ~dogen
        error('no kviews_nothresh in %s',origfname)
    else
        norient = 16;

        [rkerns,rkernnum_nothresh] = rx_gendata_rx_kerns_nothresh(do120,rkernsz);

        kth = round(linspace(0,size(lr_views,2),norient+1));
        kth = kth(1:end-1);

        nkern = size(rkerns,3);
        kviews_nothresh = NaN(nkern,1,length(xg),norient);
        startprogbar(10,nkern*norient,[origfname ' - getting kviews - no thresh'],true);
        for i = 1:norient
            cviews = circshift(lr_views,[0 kth(i)]);
            tviews = cviews(:,round((size(lr_views,2)-rkernsz(2))/2)+(1:rkernsz(2)),:);

            for j = 1:nkern
                kviews_nothresh(j,1,:,i) = getacts(tviews,rkerns(:,:,j))';

                if progbar
                    return
                end
            end
        end

        save(fname,'-append','kviews_nothresh','rkernnum_nothresh');
    end
end

kviews = [];
rkernnum = rkernnum_nothresh;
