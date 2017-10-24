function rx_fig_ellipses(dosave)
    if ~nargin
        dosave = false;
    end
    
    set(0,'DefaultAxesFontName','Arial','DefaultAxesFontSize',8)
    
    [kernsr2,kernsrx] = rx_gendata_rx_kerns_nothresh_noresize;
    
    figure(1);clf
    kells(kernsr2,'R2',0,dosave)
    
    kells(kernsrx,'Rx',1,dosave)
    
    if dosave
        savefig('RF_ellipses')
    end
end

function kells(kerns,yl,spoff,dosave)
    ksz = [size(kerns(1).k,1),size(kerns(1).k,2)];

    thresh = 1/4;
    ellconf = .8;
    facealpha = 0.2;
    edgealpha = 1;

    if dosave
        facealpha = 1;
        edgealpha = 1;
    end
    
    [mx,my] = deal(size(kerns,3),1);
    
    subplot(1,2,spoff+1)
    hold on
%     figure(100);clf
    for i = 1:length(kerns)
        k = kerns(i).k;
        neg = k<0;
        pos = k>0;
        k(neg) = -k(neg)./min(k(:));
        k(pos) = k(pos)./max(k(:));
        
        k(abs(k)<=thresh) = 0;
%         tk = k~=0;
        
%         [y,x] = find(tk);
%         covmat = cov([x,y]);
        
%         mx(i) = mean(x);
%         my(i) = mean(y);
        mx(i) = kerns(i).cent(1);
        my(i) = kerns(i).cent(2);
       
%         [ellx,elly]=error_ellipse_points(covmat,[mx(i),my(i)],'conf',ellconf);
%         
%         subplot(2,1,spoff+1)
%         hold on
%         plot([ellx;ellx(1)],[elly;elly(1)],'b')
%         fill(ellx,elly,'r','FaceAlpha',palpha,'LineStyle','none');

        bwl = bwlabeln(k>0);
        [cnt,vals] = countvals(bwl);
        sel = vals>0;
        cnt = cnt(sel);
        vals = vals(sel);
        [~,whval] = max(cnt);
        ck = bwl==whval;
        bnd = bwboundaries(ck);
        bnd = bnd{1};
        [bx,by] = xy2rf(bnd(:,2),bnd(:,1));
        
%         subplot(1,2,1)
        patch(bx,by,'r','EdgeColor','r', ...
              'FaceAlpha',facealpha,'EdgeAlpha',edgealpha)
%         title(i)
%         ylim([-60 60])
%         xlim([-135 0])
%         subplot(1,2,2)
%         showkernel_nothresh(kerns(i).k)
%         keyboard
    end
    
%     subplot(2,2,spoff+1)
%     hold on
%     plot(mx,my,'g+')
%     ylim([1 size(k,1)])
%     xlim([1 size(k,2)])
    title(yl)
%     if spoff==0
%         title('centred on exc')
%     end
    [mx,my] = xy2rf(mx,my);
    
    fprintf('%s\nx: [%.2f %.2f]\ny: [%.2f %.2f]\n============\n',yl,min(mx),max(mx(mx<0)),min(my),max(my))
    
    subplot(1,2,spoff+1)
    hold on
    plot(mx,my,'k+')
    
    axis equal
    
    ylim([-60 60])
    xlim([-135 0])
    set(gca,'XTick',-135:45:0)
    
    if spoff==0
        set(gca,'YTick',-60:30:60)
    else
        set(gca,'YTick',[])
    end
    
    andy_setbox
    
%     if spoff==0
%         title('exc shown')
%     end
    function [x,y]=xy2rf(x,y)
        x = 270*(-0.5+(x-1)./(ksz(2)-1));
        y = 120*(0.5-(y-1)./(ksz(1)-1));
    end
end