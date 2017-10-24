% function rx_noisypath(arenafname,viewtype,startposi,whpaths,randseed)
% dosave = true;

close all
clear

tottimer = tic;

% if nargin==5
%     rng(randseed);
% elseif nargin==0
    dosave = false;
    arenafname = 'artificial2';
    viewtype = 'hires';
    startposi = randi(90);
    whpaths = 1;
    randseed = 0;
% end

% try
    %% load variables and set up initial values for agent
    
    load(arenafname,'X','Y','Z');
    load(sprintf('rx_pm_snaps_%s_%s',viewtype,arenafname));
    
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
    imth = linspace(0,2*pi,imsz(2)+1);
    imth = imth(1:end-1);
    imth(imth > pi) = imth(imth > pi)-2*pi;
    
    sz4 = size(snaps,4);
    snaps = snaps(:,:,:,round(1:sz4/imsz(2):sz4));
    
    nstepmax = ceil(pm.maxlen/pm.maxsteplen);
    npath = length(whpaths);
    
    if ~doscalesteplen
        [flyx,flyy,flyth,flystep,thnoise,qmatch,whsn] = deal(NaN(nstepmax+1,npath));
        madeit = false(npath,1);
        [walkdist,nsteps,wallhits] = deal(zeros(npath,1));
        randseed = [randseed, NaN(1,npath-1)];
    end
    flyx(1,:) = stx(startposi);
    flyy(1,:) = sty(startposi);
    flyth(1,:) = 0;
    qmatch(1,:) = 0.5;
    lastview = ones(size(snaps,1),size(snaps,2));
    
    vwts = [0 1];
    
    vwts = vwts/sum(vwts);
    
    figure(1);clf
    subplot(5,1,1:2)
    drawcirc(0,0,d/2,0,0,pm.coold/2);
    axis equal tight
    hold on
    
    
        for i = 1:npath
            rstate = rng;
            randseed(i) = rstate.Seed;
            
            csteps = 0;
            while walkdist(i)<=pm.maxlen
                csteps = csteps+1;
                
                %% get current view
                if csteps==1
                    curview = startims(:,:,startposi);
                else
                    im = getviewfast(flyx(csteps,i),flyy(csteps,i),0,flyth(csteps,i),X,Y,Z,imsz,60,origimsz);
                    if iskernel
                        curview = getacts(im(:,xoff+(1:rkernsz(2))),rkerns);
                    else
                        curview = im;
                    end
                end
                
                cview = lastview*vwts(1)+curview*vwts(2);
                
                %% rIDF
                diffs = getRMSdiff(cview,snaps);
                [minvals,whths] = min(diffs,[],4);
                [qmatch(csteps+1,i),whsn(csteps+1,i)] = min(minvals);
                
                diffs2 = getRMSdiff((cview+1)/2,snaps);
                [minvals2,whths2] = min(diffs2,[],4);
                [~,whsn2] = min(minvals2);
                
                %% current fly step length
                if doscalesteplen
                    recq = qmatch(max(csteps-5,1):csteps);
                    qstd(csteps) = nanstd(recq);
                    qmean(csteps) = nanmean(recq);
                    cq(csteps) = min(1,max(0,0.5+(qmean(csteps)-qmatch(csteps+1))/(2*10*qstd(csteps))));
                    flystep(csteps+1,i) = cq(csteps)*(pm.maxsteplen-pm.minsteplen)+pm.minsteplen;
                else
                    flystep(csteps+1,i) = pm.maxsteplen;
                end
                walkdist(i) = walkdist(i)+flystep(csteps+1,i);
                
                %% get new heading and position
                thnoise(csteps+1,i) = pm.thnoise*randn; % *(1-qmatch(i+1)); %((qmatch(i)-qmatch(i+1)+1)/2);#
                whth = whths(whsn(csteps+1,i));
                newth = thnoise(csteps+1,i)+flyth(csteps,i)-imth(whth);
                newx = flyx(csteps,i)+flystep(csteps+1,i)*cos(newth);
                newy = flyy(csteps,i)+flystep(csteps+1,i)*sin(newth);
                [th,newrho] = cart2pol(newx,newy);
                if newrho >= d/2 % hit wall!
                    [newx,newy] = pol2cart(th,d/2-pm.maxsteplen/2);
                    wallhits(i) = wallhits(i)+1;
                end
                
                if ~ishandle(1)
                    return
                end
                
                subplot(5,1,1:2)
                line([flyx(csteps,i) newx],[flyy(csteps,i) newy])
                
                subplot(5,1,3)
                imshow(curview)
                
                subplot(5,1,4)
                imshow(cview)
                
                subplot(5,1,5)
                imshow(snaps(:,:,whsn(csteps+1,i),whth))
                
                drawnow
                
                lastview = cview;
                
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
            fprintf('completed in %d steps (%.2f)\n',csteps,walkdist(i)./(pm.startrad-pm.coold/2)-1)
        end
        
        maxns = 1+max(nsteps);
        flyx = flyx(1:maxns,:);
        flyy = flyy(1:maxns,:);
        flyth = flyth(1:maxns,:);
        thnoise = thnoise(1:maxns,:);
%         qmatch = qmatch(1:maxns,:);
        whsn = whsn(1:maxns,:);
        
        %% save data, if required
        runtime = toc(tottimer);
%         if dosave
%             nargs = nargin; %flyx,flyy,flyth,flystep,thnoise,qmatch,whsn
%             savemeta(datafname,'flyx','flyy','flyth','thnoise','whsn','walkdist', ...
%                                'madeit','nsteps','pm','runtime', ...
%                                'randseed','doscalesteplen','nargs','wallhits');
%         else
%             dump2base(true);
%         end
        
%         fprintf('\nCompleted in %d mins %.2f secs.\n',floor(runtime/60),mod(runtime,60));
        
%         system(sprintf('top -n 1 -p %d',feature('getpid')));
%     end
    
    %% catch/save exceptions
% catch joberror
%     runtime = toc(tottimer);
%     if dosave && ~isempty(jobid)
%         savemeta(['../ERROR_' jobid]);
%     else
%         dump2base;
%     end
%     
%     disp(runtime)
%     rethrow(joberror);
% end

% end

% function varstats(varargin)
%     maxlen = max(cellfun(@length,varargin));
%     for i = 1:length(varargin)
%         vname = varargin{i};
%         val = evalin('caller',vname);
%         vname = [' '*ones(1,maxlen-length(vname)), vname]; %#ok<AGROW>
%         fprintf('%s: M=%.3f (+/-%.3f); rng=[%.3f-%.3f]\n',vname,nanmean(val),nanstd(val),max(val),min(val));
%     end
% end
