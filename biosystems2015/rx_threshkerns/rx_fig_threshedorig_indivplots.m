function rx_fig_threshedorig_indivplots(dosave)
if ~nargin
    dosave = false;
end

type = 'r4'; % type of kernel
glomnum = 1; % glomerulus number
flynum = [4 5]; % fly number
isleft = true; % LHS/RHS kernels
kalpha = 1; % transparency

%% load stuff
load('vf_kernels.mat');

% get original RFs (for individual flies)
kerns = eval(['vf_kernels_',type]);
kerns = kerns(cell2mat({kerns.glomnum})==glomnum & ...
              cell2mat({kerns.isleft})==isleft);
kern(1) = kerns(cell2mat({kerns.flynum})==flynum(1));
kern(2) = kerns(cell2mat({kerns.flynum})==flynum(2));

% get our averaged RFs
avkerns = eval(['vf_avkernels_',type]);
avkern = avkerns(cell2mat({avkerns.glomnum})==glomnum & ...
                 cell2mat({avkerns.isleft})==isleft);

% RF image
dname = fullfile(mfiledir,'../data/receptive_fields_pics');
if strcmp(type,'r2')
    kernfn = fullfile(dname,sprintf('g%02df%d.jpg',glomnum,flynum(1)));
else
    kernfn = fullfile(dname,sprintf('r4d/g%02df%d_r4d.jpg',glomnum,flynum(1)));
end

sz = [8.5 7];
xrng = [-135 135];
yrng = [-60 60];
ftype = 'pdf';
ext = 'pdf';

%% show stuff
figure(1);clf
showkernels(kern(1),[],1,xrng,yrng);
axis equal tight off
set(gca,'box','off');
if dosave
    alsavefig('threshkern',sz,ext,ftype)
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
    alsavefig('layer2',sz,ext,ftype)
end

figure(3);clf
ckern = centerkernson(kern,ac);
showkernels(ckern,[],kalpha,xrng,yrng);
axis equal tight off
set(gca,'box','off');
if dosave
    alsavefig('centre2',sz,ext,ftype)
end

figure(4);clf
acs = mean(cell2mat({kerns.cent}'));
ckerns = centerkernson(kerns,acs);
showkernels(ckerns,[],kalpha,xrng,yrng);
axis equal tight off
set(gca,'box','off');
if dosave
    alsavefig('layerall',sz,ext,ftype)
end

figure(5);clf
showkernels(centerkernson(avkern,ac),[],1,xrng,yrng);
axis equal tight off
set(gca,'box','off');
if dosave
    alsavefig('centreall',sz,ext,ftype);
end

figure(6);clf
im = imread(kernfn);
image(xrng,yrng,im);
axis equal tight off
set(gca,'box','off');
if dosave
    alsavefig('origkern',sz,ext,ftype)
    close all
end
