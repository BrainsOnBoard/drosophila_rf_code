function fig_RFintensitymap_3d_new
    r2_or_r4 = 'r4';
    glomnum = 6;

    load('vf_kernels.mat');
    kerns = eval(['vf_avkernels_' r2_or_r4]);
    main(kerns(cell2mat({kerns.glomnum})==glomnum));
end

function main(kstruct)
    xlims = [-135 135];
    ylims = [-60 60];
    filtsize = 5;
    
%     kstruct = kstruct(cell2mat({kstruct.isleft}));% & cell2mat({kstruct.glomnum})==8);
    kernels = {kstruct.k};
    
    cylr = 1;
    xlimsr = pi*xlims/180;
    xrng = range(xlimsr);
    yrng = range(pi*ylims/180);
    cylht = yrng;
    
    figure(1);clf
    hold on
    
    %% draw stim
    fov = 270;
    im = im2double(rgb2gray(imread(fullfile(mfiledir,'../../data/patterns/09_3_34_162_1_+232_triangles.png'))));
    xoff = size(im,2)-fov;
    im = im(:,xoff/2+1:end-xoff/2);
    draw3d(~im,'k',1,false);
    
    %% draw kernels
    nkern = numel(kernels);
    for i = 1:nkern
        curk = kernels{i};
        draw3d(curk>0,'r',1/nkern,true);
        draw3d(curk<0,'b',1/nkern,true);
    end

    %% draw arena
    lwid = 1;
    
    ang = pi*135/180;
    ths = pi+linspace(-ang,ang,1000);
    [linex,liney] = pol2cart(ths,cylr);
    linez = zeros(size(linex));

    line(linex,liney,linez,'Color','k','LineWidth',lwid);
    line(linex,liney,linez+cylht,'Color','k','LineWidth',lwid);
%     line([0 0],-cylr*[1 1],[0 cylht],'Color','k','LineWidth',lwid);
%     line([0 0],cylr*[1 1],[0 cylht],'Color','k','LineWidth',lwid);
    
    axis equal off
    xlim(2*cylr*[-1 1]);
    ylim(2*cylr*[-1 1]);
    
    set(gca,'CameraPosition',[27.3036 0 15.7676],'CameraViewAngle',7.55833);
    
%     [cx,cy] = pol2cart(pi+[-135 135]*pi/180,cylr);
%     plot(cx,cy,'g+','markersize',5)
    
%     alsavefig('drum',[15 15],'png');
    
%     fprintf('min: %f\nmax: %f\n',minth,maxth);

    [xx,xy] = pol2cart(0,cylr);
    plot3(xx,xy,cylht/2,'g+')

%     keyboard
    
    function draw3d(cim,col,facealpha,domedfilt)
        if domedfilt
            cim = medfilt2(cim,filtsize*[1 1]);
        end
        
        [x,y] = bw2polygon(cim);
        sz = size(cim);
        
        th = xrng*(sz(2)-x+1)/(sz(2)-1)+(2*pi-xrng)/2;
        [X3,Y3] = pol2cart(th,cylr);
        Z3 = yrng*(sz(1)-y)/(sz(1)-1);
        
%         cminth = min(th);
%         if cminth < minth
%             minth = cminth;
%         end
%         cmaxth = max(th);
%         if cmaxth > maxth
%             maxth = cmaxth;
%         end
%         
%         fprintf('ang range: %f\n',circ_rad2ang(range(th)));
        nans = [0;find(isnan(x))];
        for n = 2:length(nans)
            ind = nans(n-1)+1:nans(n)-1;
%             fprintf('%d gap: x=%f; y=%f; z=%f\n',n-1,max(circdiff(X3(ind))),max(circdiff(Y3(ind))),max(circdiff(Z3(ind))));
            
            h=fill3(X3(ind),Y3(ind),Z3(ind),col,'edgecolor',col); %,'facealpha',facealpha);
%             keyboard
        end
    end
end