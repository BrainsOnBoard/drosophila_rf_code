function rx_gendata_pm_newpath(arenafname,viewtype,startposi,whpaths,randseed)
dosave = logical(nargin);
nsnapstoweight = 1;

jobid = getenv('JOB_ID');
tottimer = tic;

if nargin==5
    rng(randseed);
elseif nargin==0
    dosave = false;
    arenafname = 'ofstad_etal_arena';
    viewtype = 'lores';
    startposi = 1;
    whpaths = 1:10;
    randseed = 0;
else
    randseed = NaN;
end

fprintf('jobid: %s\narena: %s\nviewtype: %s\nstart pos: %d\nwhpaths: [%d %d]\nrandom seed: %d\n\n', ...
    jobid,arenafname,viewtype,startposi,whpaths(1),whpaths(end),randseed);

try
    %% load variables and set up initial values for agent
    
    load(arenafname,'X','Y','Z');
    load(sprintf('%s/../data/rx_neurons/snaps/rx_pm_snaps_%s_%s.mat',mfiledir,viewtype,arenafname));
    
    rx_consts;
    refx = 0;
    refy = 0;
    doscalesteplen = false;
    
    iskernel = viewtype(1)=='R';
    if strcmp(viewtype,'lores')
        imsz = superlrimsz;
    else
        imsz = lrimsz;
        
        if iskernel
            xoff = round((360-rkernsz(2))/2);
            
            if strcmp('nt',viewtype(end-1:end))
                [rkerns,rkernnum] = rx_gendata_rx_kerns_nothresh;
                switch viewtype
                    case 'R2nt'
                        rkerns = rkerns(:,:,rkernnum==2);
                    case 'R4nt'
                        rkerns = rkerns(:,:,rkernnum==4);
                    case 'Rxnt'
                        rkerns = rkerns(:,:,rkernnum==1);
                end
            else
                [rkerns,rkernnum] = rx_gendata_rx_kerns;
                switch viewtype
                    case 'R2+R4'
                        rkerns = rkerns(:,:,rkernnum>1);
                    case 'R2'
                        rkerns = rkerns(:,:,rkernnum==2);
                    case 'R4'
                        rkerns = rkerns(:,:,rkernnum==4);
                    case 'Rx'
                        rkerns = rkerns(:,:,rkernnum==1);
                end
            end
        end
    end
    imth = linspace(0,2*pi,imsz(2)+1);
    imth = imth(1:end-1);
    imth(imth > pi) = imth(imth > pi)-2*pi;
    
    sz4 = size(snaps,4);
    snaps = snaps(:,:,:,round(1:sz4/imsz(2):sz4));
    
    nstepmax = ceil(pm.maxlen/pm.maxsteplen);
    npath = length(whpaths);
    
    if ~doscalesteplen
        [flyx,flyy,flyth,flystep,thnoise] = deal(NaN(nstepmax+1,npath));
        [snweights,whsn] = deal(NaN(nstepmax+1,npath,nsnapstoweight));
        madeit = false(npath,1);
        [walkdist,nsteps,wallhits] = deal(zeros(npath,1));
        randseed = [randseed, NaN(1,npath-1)];
    end
    flyx(1,:) = stx(startposi);
    flyy(1,:) = sty(startposi);
    flyth(1,:) = 0;
    
    dname = fullfile(mfiledir,'../data/rx_neurons/paths');
    if ~exist(dname,'dir')
        mkdir(dname)
    end
    datafname = fullfile(dname,sprintf('%s_%s_st%02d_%04dto%04d.mat',arenafname, ...
        viewtype,startposi,whpaths(1),whpaths(end)));
    if dosave && exist(datafname,'file')
        warning('%s already exists! -- skipping',datafname)
        return
    end
    
    for i = 1:npath
        rstate = rng;
        randseed(i) = rstate.Seed;
        
        csteps = 0;
        while walkdist(i)<=pm.maxlen
            csteps = csteps+1;
            
            %% get current view
            if csteps==1
                cview = startims(:,:,startposi);
            else
                im = getviewfast(flyx(csteps,i),flyy(csteps,i),0,flyth(csteps,i),X,Y,Z,imsz,rkernsz(1)-vpitch,origimsz,vpitch);
                if iskernel
                    cview = normalizevals(getacts(im(:,xoff+(1:rkernsz(2))),rkerns));
                else
                    cview = im;
                end
            end
            
            %% rIDF
            diffs = getRMSdiff(cview,snaps);
            [minvals,whths] = min(diffs,[],4);
            [qmatches,whsns] = sort(minvals);
            cwt = 1-qmatches(1:nsnapstoweight);
            csn = whsns(1:nsnapstoweight);
            
            snweights(csteps+1,i,:) = cwt;
            whsn(csteps+1,i,:) = csn;
            
            %% current fly step length
            if doscalesteplen
                recq = snweights(max(csteps-5,1):csteps);
                qstd(csteps) = nanstd(recq);
                qmean(csteps) = nanmean(recq);
                cwt(csteps) = min(1,max(0,0.5+(qmean(csteps)-snweights(csteps+1))/(2*10*qstd(csteps))));
                flystep(csteps+1,i) = cwt(csteps)*(pm.maxsteplen-pm.minsteplen)+pm.minsteplen;
            else
                flystep(csteps+1,i) = pm.maxsteplen;
            end
            walkdist(i) = walkdist(i)+flystep(csteps+1,i);
            
            %% get new heading and position
            thnoise(csteps+1,i) = pm.thnoise*randn; % *(1-qmatch(i+1)); %((qmatch(i)-qmatch(i+1)+1)/2);
            newth = thnoise(csteps+1,i)+flyth(csteps,i)-circ_mean(imth(whths(csn)),cwt,3);
            newx = flyx(csteps,i)+flystep(csteps+1,i)*cos(newth);
            newy = flyy(csteps,i)+flystep(csteps+1,i)*sin(newth);
            [th,newrho] = cart2pol(newx,newy);
            if newrho >= d/2 % hit wall!
                [newx,newy] = pol2cart(th,d/2-pm.maxsteplen/2);
                wallhits(i) = wallhits(i)+1;
            end
            flyx(csteps+1,i) = newx;
            flyy(csteps+1,i) = newy;
            flyth(csteps+1,i) = newth;
            if wallhits(i) >= pm.maxwallhits % hit wall too many times
                break;
            end
            
            %% made it successfully to cool spot
            if hypot(refy-newy,refx-newx) <= pm.coold/2
                madeit(i) = true;
                break;
            end
        end
        
        nsteps(i) = csteps;
        fprintf('step %d/%d completed\n',i,npath);
    end
    
    maxns = 1+max(nsteps);
    flyx = flyx(1:maxns,:);
    flyy = flyy(1:maxns,:);
    flyth = flyth(1:maxns,:);
    thnoise = thnoise(1:maxns,:);
    %         qmatch = qmatch(1:maxns,:);
    whsn = whsn(1:maxns,:,:);
    
    %% save data, if required
    runtime = toc(tottimer);
    if dosave
        nargs = nargin; %flyx,flyy,flyth,flystep,thnoise,qmatch,whsn
        save(datafname,'flyx','flyy','flyth','thnoise','whsn','walkdist', ...
            'madeit','nsteps','pm','runtime', ...
            'randseed','doscalesteplen','nargs','wallhits');
    end
    
    fprintf('\nCompleted in %d mins %.2f secs.\n',floor(runtime/60),mod(runtime,60));
    
    %% catch/save exceptions
catch joberror
    runtime = toc(tottimer);
%     if dosave && ~isempty(jobid)
%         save(['../ERROR_' jobid]);
%     end
    
    disp(runtime)
    rethrow(joberror);
end

end
