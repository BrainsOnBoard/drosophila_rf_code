type = 'r4';
glomnum = 1;
flynum = [4 5];
isleft = true;
kalpha = 1;

%% load stuff
load('vf_kernels.mat');
kerns = eval(['vf_kernels_',type]);
kerns = kerns(cell2mat({kerns.glomnum})==glomnum & ...
              cell2mat({kerns.isleft})==isleft);
kern(1) = kerns(cell2mat({kerns.flynum})==flynum(1));
kern(2) = kerns(cell2mat({kerns.flynum})==flynum(2));
avkerns = eval(['vf_avkernels_',type]);
avkern = avkerns(cell2mat({avkerns.glomnum})==glomnum & ...
                 cell2mat({avkerns.isleft})==isleft);

dname = fullfile(mfiledir,'../../data/receptive_fields_pics');
if strcmp(type,'r2')
    kernfn = fullfile(dname,sprintf('g%02df%d.jpg',glomnum,flynum(1)));
else
    kernfn = fullfile(dname,sprintf('r4d/g%02df%d_r4d.jpg',glomnum,flynum(1)));
end