function [px,py] = rx_unwrapworld(fname,d,panoht)
    npt = 1000;
    
    thgap = 2*pi/npt;

    load(sprintf('%s/../../data/arenas/%s.mat',mfiledir,fname),'X','Y','Z');
    [th,phi] = cart2sph(X,Y,Z);
    th = mod(th,2*pi);
    if size(th,2)>1
       [th,phi,X,Y] = deal(addnans(th),addnans(phi),addnans(X),addnans(Y));
    end

    outth = [];
    outphi = [];
    i1 = 1;
    c = 0;
    while c < length(th)
        c = c+1;
        
        if isnan(th(c))
            [outth(end+1),outphi(end+1)] = deal(NaN);
            i1 = c+1;
            continue;
        end
        
        if isnan(th(c+1))
%             continue
            c2 = i1;
        else
            c2 = c+1;
        end
        
%         if abs(circ_dist(th(c),nxt)) > thgap
        if ((th(c2)>pi)~=(th(c)>pi)) && (X(c)+X(c2))>0
            cth = th(c)-sign(Y(c2)-Y(c))*2*pi;
        else
            cth = th(c);
        end
        
        nval = ceil((th(c2)-cth)./thgap);
        if nval <= 1
            outth(end+1) = cth;
            outphi(end+1) = phi(c);
        else
            cths = linspace(cth,th(c2),nval);
            cphis = linspace(phi(c),phi(c2),nval);
            outth = [outth, cths(1:end-1)];
            outphi = [outphi, cphis(1:end-1)];
        end
    end

    outphi = outphi*(panoht./max(phi(:)));
    [px,py] = pol2cart(outth',outphi'+d/2);
end

function m=addnans(m)
    m = m';
    m(end+1,:) = NaN;
    m = m(:);
end