function rx_gendata_world3
    dosave = false;
    
    minworldn = 19;
    nworlds = 1;
    objsc = .025;
    
    ntuss = 3;
    nbushtree = 3;
    pbush = 2/3;
    ngrays = 3;
    
    tussslice = 2*pi/ntuss;
    btslice = 2*pi/nbushtree;
    
    rx_consts;
    
    load([mfiledir '/../../../data/arenas/nest1.mat'],'X','Y');
    rho = hypot(X,Y);
    rpanomax = max(rho(:));
    rtussockmin = d/2;
    rpanobnd = rtussockmin+0.75*(rpanomax-rtussockmin);
    
    maxanght = mod(tan(2*ht/d),pi);
    
    tbndwd = rpanobnd-rtussockmin;
    pbndwd = rpanomax-rpanobnd;
    
%     lm = 0.5*d*[-1 1];
    
    for i = 1:nworlds
        [X,Y,Z,whobj,col] = deal([]);
        for j = 1:ntuss
            [Xc,Yc,Zc] = tussockBuilderAuto(13);
            [Xc,Yc,Zc] = deal(objsc*(Xc-mean(Xc(:))),objsc*(Yc-mean(Yc(:))),objsc*Zc);

            cmaxr = max(hypot(Xc(:),Yc(:)));

            tussth = tussslice*(j-1+rand);
            [xoff,yoff] = pol2cart(tussth,rtussockmin+cmaxr+rand*(tbndwd-2*cmaxr));
            Xc = Xc+xoff;
            Yc = Yc+yoff;
            
            whobj = [whobj;j*ones(size(Xc,1),1)];
            col = [col; 1-randi(ngrays)./ngrays];

            X = [X;Xc];
            Y = [Y;Yc];
            Z = [Z;Zc];
        end

        for j = 1:nbushtree
            if rand > pbush
                [Xc,Yc,Zc] = randomTree(rand/2+0.5,1.5+rand);
            else
                [Xc,Yc,Zc] = randomBush(rand/5+0.8);
            end

            [Xc,Yc,Zc] = deal(objsc*(Xc-mean(Xc(:))),objsc*(Yc-mean(Yc(:))),objsc*Zc);
            thc = btslice*(j-0.5+rand);
            [Xc,Yc] = rotatexy(Xc,Yc,thc);
            [xoff,yoff] = pol2cart(thc,rpanobnd+rand*pbndwd);
            Xc = Xc+xoff;
            Yc = Yc+yoff;

            X = [X;Xc];
            Y = [Y;Yc];
            Z = [Z;Zc];
        end

        %norm Z
        hypotxy = hypot(X,Y);
        anght = atan2(Z,hypotxy);
        anght = maxanght*anght./max(anght(:));
        Z = hypotxy.*tan(anght);

        worldnum = minworldn;
        while true
            fname = sprintf('%s/../../../data/arenas/artificial%d',mfiledir,worldnum);
            if ~exist([fname '.mat'],'file') && ~exist([fname '_drum.mat'],'file')
                break;
            end
            worldnum = worldnum+1;
        end
        
        if dosave
            fprintf('saving world %d\n',worldnum)
            save(fname,'X','Y','Z');
        else
            figure(1);clf
            subplot(2,2,1)
            fill(X',Y','k')
            drawcirc(0,0,d/2)
            axis equal
%             xlim(lm)
%             ylim(lm)
            
            subplot(2,2,3)
            imshow(getviewfast(0,0,0,0,X,Y,Z,[]));
        end

        th = atan2(Y,X);
        [X,Y] = pol2cart(th,d/2);
        
        %norm Z
        Z = (d/2)*tan(anght);
        
        if dosave
            save([fname '_drum'],'X','Y','Z');
        else
            subplot(2,2,2)
            fill(X',Y','k')
            axis equal
%             xlim(lm)
%             ylim(lm)
            
            subplot(2,2,4)
            imshow(getviewfast(0,0,0,0,X,Y,Z,[]));
            
            return
        end
    end
    
end