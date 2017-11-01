function rx_fig_methods_panorama_r2(dosave)
% shows a panoramic view with RFs overlaid

    if ~nargin
        dosave = false;
    end
    
    crosscol = 0;
    crosslen = 31;
    panoalpha = .5; % transparency of panorama im
    kernalpha = .9; % transparency of overlaid kernels
    hfov = 270; % horizontal field of view
    elmax = 70; % maximum elevation
    elup = elmax/5;
    
    % position and pose
    x = -10.7770;
    y = 2.7356;
    th = pi;
    
    crossoff = floor(crosslen/2);
    crossi = -crossoff:crossoff;
    
    % load kernels and colour map
    load('vf_kernels_nothresh.mat','vf_avkernels_r2','neuroncolormap');
    kerns = vf_avkernels_r2;
    
    % colour for excitation/inhibition
    excol = neuroncolormap(end,:);
    incol = neuroncolormap(1,:);
    
    % load world and get view
    load('XYZ_nid1_training.mat','X','Y','Z');
    pano = getviewfast_20140312(x,y,0,th,X(1:end-2,:),Y(1:end-2,:),Z(1:end-2,:),[],elmax);
    pixup = round(size(pano,1)*(elup/elmax));
    pano = [pano(pixup+1:end,:);false(pixup,size(pano,2))];
    
    ksz = size(vf_avkernels_r2(1).k);
    rsz = [size(pano,1),size(pano,2)*(hfov/360)];
    xdiff = (size(pano,2)-rsz(2))/2;
    cents = cell2mat({kerns.cent}');
    rcents = 1+round(bsxfun(@times,rsz([2 1]),bsxfun(@rdivide,cents-1,ksz([2 1])-1)));
    crossim = NaN(size(pano));
    rx = round(xdiff)+rcents(:,1);
    ry = rcents(:,2);
%     yi = [repmat(ry,1,crosslen); bsxfun(@plus,ry,crossi)];
%     xi = [bsxfun(@plus,rx,crossi); repmat(rx,1,crosslen)];
%     crossim(sub2ind(size(pano),yi,xi)) = crosscol;
    
    rkerns = resizekernel(kerns,rsz,0.25);
    exim = makekim(rkerns>0,excol);
    inim = makekim(rkerns<0,incol);
    comboim = imageadd(pano,'alpha',panoalpha,inim,exim);
    figure(2);clf
    imshow(comboim)
    
    if dosave
        dname = fullfile(mfiledir,'../figures/rx_methods');
%         if ~exist(dname,'dir')
%             mkdir(dname)
%         end
        figure(1);clf
        hold on
        plot([xdiff xdiff],[1 size(pano,1)],'k--',size(pano,2)+1-[xdiff xdiff],[1 size(pano,1)],'k--',rx,ry,'k+','MarkerSize',3);
        axis equal tight
        xlim([1 size(pano,2)])
        ylim([1 size(pano,1)])
        set(gca,'YDir','reverse','XTick',[],'YTick',[])
        alsavefig('rx_fig_methods_panorama_r2_crosses',8*[1 size(pano,1)/size(pano,2)])

        fnum = 1;
        while true
            fname = sprintf('%s/rx_fig_methods_panorama_r2 (%04d).png',dname,fnum);
            if ~exist(fname,'file')
                break;
            end
            fnum = fnum+1;
        end
        fprintf('Writing to %s...\n',fullfile(fname));
        imwrite(comboim,fname);
    end
    
    function kim=makekim(sel,imcol)
        calpha = sum(sel,3);
        calpha = calpha./max(calpha(:));
        kim = repmat(shiftdim([imcol,0],-1),size(pano));
        kim(:,floor(xdiff)+1:size(pano,2)-ceil(xdiff),4) = kernalpha*calpha;
    end
end