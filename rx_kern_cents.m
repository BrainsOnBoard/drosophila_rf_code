function rx_kern_cents
    close all
    load('vf_kernels_nothresh','vf_avkernels*')
    centrng(vf_avkernels_r2,'R2')
    centrng(vf_avkernels_r4,'R4d')
end

function centrng(k,str)
    ksz = size(k(1).k);
    cpx = cell2mat({k.cent}');
    cx = cpx(1:length(k)/2,1);
    cy = cpx(:,2);
    xrng = 270*(-0.5+([min(cx) max(cx)]-1)./(ksz(2)-1));
    yrng = 120*(0.5-([min(cy) max(cy)]-1)./(ksz(1)-1));
    
    figure
    plot(270*(-0.5+cx./ksz(2)),120*(-0.5+cy(1:length(cy)/2)./ksz(1)),'b+')
    xlim([-135 0]);ylim([-60 60])
    
    fprintf('%s\nx: [%3.2f %3.2f]\ny: [%3.2f %3.2f]\n=============\n',str,xrng(1),xrng(2),yrng(1),yrng(2));
end