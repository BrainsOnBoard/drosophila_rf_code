function rx_gendata_world2drum_isolate
    rmax = 500;
    dname = [mfiledir '/../../../data/arenas'];

    rx_consts;
    for i = 1 %:2
        origfname = sprintf('XYZ_nid%d_training.mat',i);

        disp('generating drum world')

        load(origfname,'X','Y','Z');
        X = X(1:end-2,:); % remove artificial landmark
        Y = Y(1:end-2,:);
        Z = Z(1:end-2,:);
        
        fname = sprintf('%s/nest%d',dname,i);
        
%         savewithdrum(origfname,[fname '_dist'],X,Y,Z,d,ht);

        % remove distant panorama
        sel = all(hypot(X,Y)<rmax,2);
        [X,Y,Z] = deal(X(sel,:),Y(sel,:),Z(sel,:));
        savewithdrum(origfname,fname,X,Y,Z,d,ht);
    end
end

function savewithdrum(origfname,fname,X,Y,Z,d,ht)
    maxanght = atan2(ht,d/2);

    rho = hypot(X,Y);
    
    sc = d./(2*min(rho(:)));
    X = sc*X;
    Y = sc*Y;
    normZ
    if ~exist([fname '.mat'],'file')
        save(fname,'X','Y','Z','origfname');
    end
    
    v1 = getviewfast(0,0,0,0,X,Y,Z,[]);
    
    th = atan2(Y,X);
    [X,Y] = pol2cart(th,d/2);
    normZ
    if ~exist([fname '_drum.mat'],'file')
        save([fname '_drum'],'X','Y','Z','origfname');
    end
    
    v2 = getviewfast(0,0,0,0,X,Y,Z,[]);
    figure(1);clf
    subplot(2,1,1)
    imshow(v1)
    subplot(2,1,2)
    imshow(v2);
    figure(2);clf;fill(X',Y','k');hold on;plot(0,0,'r+')
    figure(3);clf
    showWorld(X,Y,Z)
    keyboard
    
    function normZ
        %norm Z
        hypotxy = hypot(X,Y);
        anght = atan2(Z,hypotxy);
        [cmaxanght,whtallest] = max(anght(:));
        newZ = hypotxy(whtallest).*tan(maxanght);
        Z = Z*newZ./Z(whtallest);
%         anght = maxanght*anght./max(anght(:));
%         Z = hypotxy.*tan(anght);
%         keyboard
    end
end