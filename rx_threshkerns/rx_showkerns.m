function rx_showkerns

load('vf_kernels_nothresh')

figure(1);clf
writekerns('r2',vf_avkernels_r2,neuroncolormap);
figure(2);clf
writekerns('r4',vf_avkernels_r4,neuroncolormap);

end

function writekerns(str,ks,cm)
    ks = kstr2k(ks);
    
    wd = ceil(size(ks,3)./4);
    for i = 1:size(ks,3)/2
        im = stretchkern(ks(:,:,i));
        fname = sprintf('%s/../../../figures/drosneur/rx_neurons/rx_threshkerns/%s_%02d.png',mfiledir,str,i);
        imwrite(uint8(round(im)),cm,fname);
        
        subplot(2,wd,i)
        imagesc(im)
        colormap(cm)
    end
end

function k=stretchkern(k)
    neg = k<0;
    pos = k>0;
    k(neg) = -k(neg)./min(k(neg));
    k(pos) = k(pos)./max(k(pos));
    
    k = 185*(k+1)./2;
end