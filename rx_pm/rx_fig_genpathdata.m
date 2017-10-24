function rx_fig_genpathdata(fname,viewtype)
figdatafn = sprintf('%s/../../../data/rx_neurons/figpreprocess/paths/paths_%s.mat_%s.mat', ...
    mfiledir,fname,viewtype);
if exist(figdatafn,'file')
    disp('data file already exists!')
else
    totim = zeros([rtnviews,rtnviews,size(linecols,1)]);
    tty = NaN(pm.nstartpos,1);
    madeits = NaN(pm.nstartpos,1);
    nfile = 0;
    startprogbar(10,pm.nstartpos,[fname ' - ' viewtype],true);
    for k = 1:pm.nstartpos
        fname = sprintf('%s/%s_%s_st%02d_%04dto*.mat',dname,fname, ...
                        viewtype,k,1);
        cfs = dir(fname);
        if length(cfs) > 1
            error('too many files!')
        elseif length(cfs)==1
            nfile = nfile+1;

            load([dname '/' cfs(1).name],'flyx','flyy','walkdist','madeit');

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

        if progbar
            return
        end
    end

    if nfile==pm.nstartpos
        if doload
            save(figdatafn,'totim','tty','madeits','nfile');
        end
    else
        warning('only %d files for %s:%s',nfile,fname,viewtype);
    end
end