clear

dosave = true;
imx = linspace(-180,180,360)';
ksz = [120 270];
imwds = [130 230];

load('vf_kernels_nothresh.mat','vf_avkernels*');
kerns = [vf_avkernels_r2,vf_avkernels_r4];
rk = NaN([ksz(2),ksz(1),length(kerns)]);
for i = 1:size(rk,3)
    rk(:,:,i) = resizekernel_nothresh(kerns(i).k,ksz)';
end
r2l = 1:14;
r2r = 14+(1:14);
r4l = 28+(1:7);
r4r = 28+7+(1:7);

ths = -180:180;
xoff = floor((361-270)/2);
for i = 1:length(imwds)
    im = abs(imx) > imwds(i)/2;
    acts = NaN(length(kerns),length(imx)+1);
    for j = 1:length(imx)+1
        rim = circshift(im,ths(j));
        acts(:,j) = getacts(rim(xoff+1:end-xoff),rk);
    end
    
    figure(i);clf
    hold on
    fill(imwds(i)*[-.5 .5 .5 -.5],imwds(i)*[-.5 -.5 .5 .5],'k')
    plot(ths,mean(acts(r2l,:)),'b',ths,mean(acts(r2r,:)),'b--', ...
         ths,mean(acts(r4l,:)),'g',ths,mean(acts(r4r,:)),'g--')
    set(gca,'Box','on','XTick',-180:90:180,'XTickLabel',[], ...
            'YTick',-.4:.2:.4,'YTickLabel',[], ...
            'TickDir','out','Units','normalized')
    xlim([-180 180])
    ylim(0.4*[-1 1])
    
    if dosave
        alsavefig(sprintf('barpano_%d',imwds(i)),[6.5 2.5]);
    end
end