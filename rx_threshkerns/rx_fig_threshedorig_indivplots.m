function rx_fig_threshedorig_indivplots(dosave)
if ~nargin
    dosave = false;
end

rx_whichkernsforfig;
sz = [8.5 7];
xrng = [-135 135];
yrng = [-60 60];
ftype = 'pdf';
ext = 'pdf';

% show stuff
figure(1);clf
showkernel(kern(1),[],xrng,yrng);
axis equal tight off
set(gca,'box','off');
if dosave
    savefig('threshkern',sz,ext,ftype)
end

figure(2);clf
hold on
ac = mean([kern(1).cent;kern(2).cent]);
showkernels(kern,[],kalpha,xrng,yrng);
% plot(ac(1),ac(2),'y+')
hold off
axis equal tight off
set(gca,'box','off');
if dosave
    savefig('layer2',sz,ext,ftype)
end

figure(3);clf
ckern = centerkernson(kern,ac);
showkernels(ckern,[],kalpha,xrng,yrng);
axis equal tight off
set(gca,'box','off');
if dosave
    savefig('centre2',sz,ext,ftype)
end

figure(4);clf
acs = mean(cell2mat({kerns.cent}'));
ckerns = centerkernson(kerns,acs);
showkernels(ckerns,[],kalpha,xrng,yrng);
axis equal tight off
set(gca,'box','off');
if dosave
    savefig('layerall',sz,ext,ftype)
end

figure(5);clf
showkernel(centerkernson(avkern,ac),[],xrng,yrng);
axis equal tight off
set(gca,'box','off');
if dosave
    savefig('centreall',sz,ext,ftype);
end

figure(6);clf
im = imread(kernfn);
image(xrng,yrng,im);
axis equal tight off
set(gca,'box','off');
if dosave
    savefig('origkern',sz,ext,ftype)
    close all
end