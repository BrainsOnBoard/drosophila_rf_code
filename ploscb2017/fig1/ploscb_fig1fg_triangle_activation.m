function ploscb_fig1fg_triangle_activation(dosave)
if ~nargin
    dosave = false;
end
ymax = 0.45;

set(0,'defaulttextfontsize',8,'defaulttextfontname','Arial')

patt1 = rgb2gray(im2double(imread(sprintf('%s/../../data/patterns/09_3_34_162_1_+232_triangles.png',mfiledir))));
patt2 = rgb2gray(im2double(imread(sprintf('%s/../../data/patterns/09_4_00_162_1_-107_triangles_com.png',mfiledir))));

patt1 = patt1(:,[1:180, 180:-1:1]);
patt2 = patt2(:,[1:180, 180:-1:1]);

load('vf_kernels_nothresh','vf_avkernels_r2')
rkr2 = resizekernel_nothresh(vf_avkernels_r2,[120 270]);
% rkr4 = resizekernel_nothresh(vf_avkernels_r4,[120 270]);

p1r2 = mypanoconv(patt1,rkr2);
% p1r4 = mypanoconv(patt1,rkr4);
[p2r2,ths] = mypanoconv(patt2,rkr2);
% [p2r4,ths] = mypanoconv(patt2,rkr4);

figure(1);clf
subplot(1,2,1)
plot(ths,p1r2,'b')
% plot(ths,p1r4,'g',ths,p1r2,'b')
ylabel('r.m.s. difference')
set(gca,'XTick',-180:90:180,'FontName','Arial','FontSize',8)
ylim([0 ymax])
xlim(ths([1 end]))
andy_setbox
subplot(1,2,2)
plot(ths,p2r2,'b')
% plot(ths,p2r4,'g',ths,p2r2,'b')
set(gca,'XTick',-180:90:180,'FontName','Arial','FontSize',8,'YTickLabel',[])
andy_setbox
ylim([0 ymax])
xlim(ths([1 end]))

if dosave
    alsavefig('triacts',[13 4.560])
end

% dump2base(true)
end

function [mact,ths]=mypanoconv(im,rk)
	wd = size(im,2);
    xoff = (wd-size(rk,2))/2;
    ths = -wd/2:wd/2;
    mact = NaN(1,length(ths));
    th0acts = getacts(im(:,xoff+1:end-xoff),rk);
    for i = 1:length(ths)
        rim = circshift(im,[0 ths(i)]);
        mact(i) = getRMSdiff(th0acts,getacts(rim(:,xoff+1:end-xoff),rk));
    end
end