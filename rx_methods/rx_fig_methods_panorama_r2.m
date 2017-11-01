function rx_fig_methods_panorama_r2(dosave)
% shows a panoramic view with RFs overlaid

    if ~nargin
        % whether to save figure to disk
        dosave = false;
    end
    
    panoalpha = .5; % transparency of panorama im
    kernalpha = .9; % transparency of overlaid kernels
    hfov = 270; % horizontal field of view
    elmax = 70; % maximum elevation
    elup = elmax/5;
    
    % position and pose
    x = -10.7770;
    y = 2.7356;
    th = pi;
    
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
    
    ksz = size(vf_avkernels_r2(1).k); % original kernel size
    rsz = [size(pano,1),size(pano,2)*(hfov/360)]; % resized kernel size
    xdiff = (size(pano,2)-rsz(2))/2; % diff caused by difference in FOV
    cents = cell2mat({kerns.cent}'); % kernel centroids
    rkerns = resizekernel(kerns,rsz,0.25); % resized kernels
    
    % kernel centroids for resized kernels
    rcents = 1+round(bsxfun(@times,rsz([2 1]),bsxfun(@rdivide,cents-1,ksz([2 1])-1)));
    rx = round(xdiff)+rcents(:,1);
    ry = rcents(:,2);
    
    % make separate "images" for excitation and inhibition
    exim = makekim(rkerns>0,excol);
    inim = makekim(rkerns<0,incol);
    
    % combine bits into single image
    comboim = imageadd(pano,'alpha',panoalpha,inim,exim);
    
    %% show image
    figure(2);clf
    imshow(comboim)
    
    if dosave
        dname = fullfile(mfiledir,'../figures/rx_methods');

        % if and only if we're saving the figure, also draw crosses/lines
        % and save this part separately
        figure(1);clf
        hold on
        plot([xdiff xdiff],[1 size(pano,1)],'k--',size(pano,2)+1-[xdiff xdiff],[1 size(pano,1)],'k--',rx,ry,'k+','MarkerSize',3);
        axis equal tight
        xlim([1 size(pano,2)])
        ylim([1 size(pano,1)])
        set(gca,'YDir','reverse','XTick',[],'YTick',[])
        alsavefig('rx_fig_methods_panorama_r2_crosses',8*[1 size(pano,1)/size(pano,2)])

        % save image part of figure
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
        % calculate transparency
        calpha = sum(sel,3);
        calpha = calpha./max(calpha(:));
        
        % convert to RGBa image (for imageadd function)
        kim = repmat(shiftdim([imcol,0],-1),size(pano));
        kim(:,floor(xdiff)+1:size(pano,2)-ceil(xdiff),4) = kernalpha*calpha;
    end
end