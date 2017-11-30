function rx_gendata_gensnaps(fname)
% Generates the needed snapshots for the simulations (cross shape in centre
% of arena). Also saves images from each of the 90 starting positions.

dodebug = false;
dokernelsnt = true; % get snapshots for kernels
dolores = true; % get snapshots for low-res images

% common constants
rx_consts;

if nargin
    fnames = { fname };
end

if dokernelsnt
    % load kernels
    [rkernsnt,rkernnum] = rx_gendata_rx_kerns_nothresh(rkernsz);
end

% calculate x,y,theta for snapshots
xyjump = 4*pm.reflen/pm.nsnaps; % spacing of snapshots
xystart = xyjump:xyjump:pm.reflen;
[snx,sny] = rotatexy([-xystart,xystart,zeros(1,pm.nsnaps/2)], ...
    [zeros(1,pm.nsnaps/2),-xystart,xystart],pi/4);
snth = atan2(-sny,-snx);

% starting positions for simulations (we save images for these too)
thjump = 2*pi/pm.nstartpos;
[startx,starty] = pol2cart(0:thjump:2*pi-thjump,pm.startrad);

dname = fullfile(mfiledir,'../../data/arenas'); % arena directory

imrot = 2*(0:359); % "rotations" of images (left/right circshift)
xoff = (360-rkernsz(2))/2; % x offset, accounting for FOV
if ~dodebug
    startprogbar(50,length(fnames)*(pm.nstartpos+pm.nsnaps*length(imrot)),'generating snaps')
end
for i = 1:length(fnames)
    % load arena
    load([dname '/' fnames{i}],'X','Y','Z');
    
    %% get starting images (high-res, low-res and kernel)
    lrstart = NaN([lrimsz,length(startx)]);
    if dolores
        superlrstart = NaN([superlrimsz,length(startx)]);
        if dokernelsnt
            kstartnt = NaN([size(rkernsnt,3),1,length(startx)]);
        end
    end
    for k = 1:length(startx)
        cst = im2double(getviewfast(startx(k),starty(k),0,0,X,Y,Z,[],60,origimsz,vpitch));
        
        % high-res
        lrstart(:,:,k) = imresize(cst,lrimsz,'bilinear');
        if dolores
            % low-res
            superlrstart(:,:,k) = imresize(cst,superlrimsz,'bilinear');
            if dokernelsnt
                % activations for RFs
                kstartnt(:,1,k) = getacts(lrstart(:,xoff+(1:rkernsz(2)),k),rkernsnt);
            end
        end
        
        if ~dodebug && progbar
            return
        end
    end
    if dolores && dokernelsnt
        % normalise values
        kstartnt = (kstartnt+1)/2;
        
        % array for snapshots (kernels)
        kviewsnt = NaN([size(rkernsnt,3),1,length(snx),length(imrot)]);
    end
    
    %% get snapshots
    lrviews = NaN([lrimsz,length(snx),length(imrot)]);
    if dolores
        superlrviews = NaN([superlrimsz,length(snx),length(imrot)]);
    end
    for k = 1:length(snx)
        cview = im2double(getviewfast(snx(k),sny(k),0,snth(k),X,Y,Z,[],rkernsz(1)-vpitch,origimsz,vpitch));
        
        % iterate over image rotations (we save rotated images for speed)
        for l = 1:length(imrot)
            % note that "rotation" is circshift (cf. imrotate)
            rcview = circshift(cview,[0 imrot(l)]);
            
            % high-res
            lrviews(:,:,k,l) = imresize(rcview,lrimsz,'bilinear'); % high-res
            if dolores
                % low-res
                superlrviews(:,:,k,l) = imresize(rcview,superlrimsz,'bilinear');
                
                if dokernelsnt
                    % get activations for RF outputs
                    kviewsnt(:,:,k,l) = getacts(lrviews(:,xoff+(1:rkernsz(2)),k,l),rkernsnt);
                end
            end
            
            if ~dodebug && progbar
                return
            end
        end
    end
    if dolores && dokernelsnt
        % normalise
        kviewsnt = (kviewsnt+1)/2;
    end
    
    %% save
    if ~dodebug
        savesnaps('hires',fnames{i},lrstart,startx,starty,lrviews,snx,sny,vpitch);
        
        if dolores
            savesnaps('lores',fnames{i},superlrstart,startx,starty,superlrviews,snx,sny,vpitch);
            
            if dokernelsnt
                savesnaps('R2nt',fnames{i},kstartnt(rkernnum==2,:,:),startx,starty,kviewsnt(rkernnum==2,:,:,:),snx,sny,vpitch);
                savesnaps('R4nt',fnames{i},kstartnt(rkernnum==4,:,:),startx,starty,kviewsnt(rkernnum==4,:,:,:),snx,sny,vpitch);
                savesnaps('Rxnt',fnames{i},kstartnt(rkernnum==1,:,:),startx,starty,kviewsnt(rkernnum==1,:,:,:),snx,sny,vpitch);
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

dname = fullfile(mfiledir,'../../data/rx_neurons/snaps');
if ~exist(dname,'dir')
    mkdir(dname)
end
fname = fullfile(dname,['rx_pm_snaps_' viewtype '_' fn]);
save(fname,'-v7.3','startims','stx','sty','snaps','snx','sny','vpitch')
end