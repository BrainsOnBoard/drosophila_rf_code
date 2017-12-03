function ploscb_fig2ab_singleRF(dosave)
if ~nargin
    dosave = false;
end

gnum = 7;
tsz = [88.976 266.572];

load('vf_kernels','vf_avkernels_r2')

k = vf_avkernels_r2(gnum).k;
sz = size(k);
cols = any(k);
rows = any(k,2);
cpx = find(cols,1,'last')-find(cols,1);
rpx = find(rows,1,'last')-find(rows,1);
psz = [(rpx/sz(1))*tsz(1), (cpx/sz(2))*(270/360)*tsz(2)];
offs = [36.761, 332.768]+tsz(2)*45/360;

fprintf('ht: %f; wd: %f\noff1: %f; off2: %f\n\n',psz(1),psz(2),offs(1),offs(2));

figure(1);clf
showkernels(k,[],1)
axis off

if dosave
    alsavefig('patt_RF',[5 5])
end

%%
% patt1 = imread(sprintf('%s/../../data/antoinestim/touse/09_3_34_162_1_+232_triangles.png',mfiledir));
% patt2 = imread(sprintf('%s/../../data/antoinestim/touse/09_4_00_162_1_-107_triangles_com.png',mfiledir));
% 
% close all
% for i = gnum
%     figure(i);clf
%     subplot(1,2,1)
%     imshow(patt1)
%     hold on
%     showkernels(vf_avkernels_r2(i),[],1,45+[1 270],[1 size(patt1,1)])
%     
%     subplot(1,2,2)
%     imshow(patt2)
%     hold on
%     showkernels(vf_avkernels_r2(i),[],1,45+[1 270],[1 size(patt2,1)])
% end