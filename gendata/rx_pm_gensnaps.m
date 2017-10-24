function rx_pm_gensnaps(fname)
    dodebug = false;
    dokernels = false;
    dokernelsnt = false;
    dolores = false;
    
    do120 = true;

    rx_consts;
    
    if nargin
        fnames = { fname };
    end
    
    if dokernels
        [rkerns,rkernnum] = rx_gendata_rx_kerns;
    end
    if dokernelsnt
        [rkernsnt,rkernnum] = rx_gendata_rx_kerns_nothresh(do120,rkernsz);
    end
    
    xyjump = 4*pm.reflen/pm.nsnaps;
    xyst = xyjump:xyjump:pm.reflen;
    [snx,sny] = rotatexy([-xyst,xyst,zeros(1,pm.nsnaps/2)], ...
                         [zeros(1,pm.nsnaps/2),-xyst,xyst],pi/4);
	snth = atan2(-sny,-snx);
                     
    thjump = 2*pi/pm.nstartpos;
    [stx,sty] = pol2cart(0:thjump:2*pi-thjump,pm.startrad);
    
    dname = fullfile(mfiledir,'../../../data/arenas');
    
    imrot = 2*(0:359);
    xoff = (360-rkernsz(2))/2;
    if ~dodebug
        startprogbar(50,length(fnames)*(pm.nstartpos+pm.nsnaps*length(imrot)),'generating snaps')
    end
    for i = 1:length(fnames)
        load([dname '/' fnames{i}],'X','Y','Z');
        
        lrst = NaN([lrimsz,length(stx)]);
        if dolores
            superlrst = NaN([superlrimsz,length(stx)]);
            if dokernels
                kst = NaN([size(rkerns,3),1,length(stx)]);
            end
            if dokernelsnt
                kstnt = NaN([size(rkernsnt,3),1,length(stx)]);
            end
        end
        for k = 1:length(stx)
            cst = im2double(getviewfast(stx(k),sty(k),0,0,X,Y,Z,[],60,origimsz,vpitch));
            
            lrst(:,:,k) = imresize(cst,lrimsz,'bilinear');
            
            if dolores
                superlrst(:,:,k) = imresize(cst,superlrimsz,'bilinear');

                if dokernels
                    kst(:,1,k) = getacts(lrst(:,xoff+(1:rkernsz(2)),k),rkerns);
                end
                if dokernelsnt
                    kstnt(:,1,k) = getacts(lrst(:,xoff+(1:rkernsz(2)),k),rkernsnt);
                end
            end
            
            if ~dodebug && progbar
                return
            end
        end
        if dolores
            if dokernels
                kst = (kst+1)/2;
                kviews = NaN([size(rkerns,3),1,length(snx),length(imrot)]);
            end
            if dokernelsnt
                kstnt = (kstnt+1)/2;
                kviewsnt = NaN([size(rkernsnt,3),1,length(snx),length(imrot)]);
            end
        end

        lrviews = NaN([lrimsz,length(snx),length(imrot)]);
        if dolores
            superlrviews = NaN([superlrimsz,length(snx),length(imrot)]);
        end
        for k = 1:length(snx)
            cview = im2double(getviewfast(snx(k),sny(k),0,snth(k),X,Y,Z,[],rkernsz(1)-vpitch,origimsz,vpitch));

            for l = 1:length(imrot)
                rcview = circshift(cview,[0 imrot(l)]);

                lrviews(:,:,k,l) = imresize(rcview,lrimsz,'bilinear');
                if dolores
                    superlrviews(:,:,k,l) = imresize(rcview,superlrimsz,'bilinear');

                    if dokernels
                        kviews(:,:,k,l) = getacts(lrviews(:,xoff+(1:rkernsz(2)),k,l),rkerns);
                    end
                    if dokernelsnt
                        kviewsnt(:,:,k,l) = getacts(lrviews(:,xoff+(1:rkernsz(2)),k,l),rkernsnt);
                    end
                end

                if ~dodebug && progbar
                    return
                end
            end
        end
        if dolores
            if dokernels
                kviews = (kviews+1)/2;
            end
            if dokernelsnt
                kviewsnt = (kviewsnt+1)/2;
            end
        end

        if ~dodebug
            savesnaps('hires',fnames{i},lrst,stx,sty,lrviews,snx,sny,vpitch);
            
            if dolores
                savesnaps('lores',fnames{i},superlrst,stx,sty,superlrviews,snx,sny,vpitch);

                if dokernels
                    %savesnaps('R2+R4',fn{i},kst(rkernnum>1,:,:),stx,sty,kviews(rkernnum>1,:,:,:),snx,sny);
                    savesnaps('R2',fnames{i},kst(rkernnum==2,:,:),stx,sty,kviews(rkernnum==2,:,:,:),snx,sny,vpitch);
                    savesnaps('R4',fnames{i},kst(rkernnum==4,:,:),stx,sty,kviews(rkernnum==4,:,:,:),snx,sny,vpitch);
                    savesnaps('Rx',fnames{i},kst(rkernnum==1,:,:),stx,sty,kviews(rkernnum==1,:,:,:),snx,sny,vpitch);
                end
                if dokernelsnt
                    savesnaps('R2nt',fnames{i},kstnt(rkernnum==2,:,:),stx,sty,kviewsnt(rkernnum==2,:,:,:),snx,sny,vpitch);
                    savesnaps('R4nt',fnames{i},kstnt(rkernnum==4,:,:),stx,sty,kviewsnt(rkernnum==4,:,:,:),snx,sny,vpitch);
                    savesnaps('Rxnt',fnames{i},kstnt(rkernnum==1,:,:),stx,sty,kviewsnt(rkernnum==1,:,:,:),snx,sny,vpitch);
                end
            end
        end
    end
end

function savesnaps(viewtype,fn,startims,stx,sty,snaps,snx,sny,vpitch)
    if size(startims,2)==1 % kernels
        startims = normalizevals(startims);
        snaps = normalizevals(snaps);
    end

    fname = fullfile(mfiledir,['../../../data/rx_neurons/snaps/rx_pm_snaps_' viewtype '_' fn]);
    savemeta(fname,'-v7.3','startims','stx','sty','snaps','snx','sny','vpitch')
end