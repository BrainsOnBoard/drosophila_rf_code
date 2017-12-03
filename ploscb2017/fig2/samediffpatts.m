function samediffpatts(dosave)
if ~nargin
    dosave = false;
end

dname = fullfile(mfiledir,'/../../data/patterns');
patts = {'*triangles.png','*triangles_com.png'};
load('vf_kernels_nothresh.mat','vf_avkernels_r2');
rk = resizekernel_nothresh(vf_avkernels_r2,[120 270]);

figure(1);clf
xoff = (360-size(rk,2))/2;
diffs = NaN(28,length(patts));
avdiff = NaN(1,length(patts));
for i = 1:length(patts)
    fn = dir(fullfile(dname,patts{i}));
    im = im2double(rgb2gray(imread(fullfile(dname,fn(1).name))));
    im = im(:,xoff+1:end-xoff);
    acts1 = getacts(flipud(im),rk);
    acts2 = getacts(im,rk);
    diffs(:,i) = abs(acts1-acts2);
    avdiff(i) = mean(abs(diffs(:,i)));
end
cols = 'wk';
figure(1);clf
h=bar(diffs);
for i = 1:length(h)
    set(h(i),'FaceColor',cols(i))
end
hold on
xl = xlim;
lstyle = {':','--'};
for i = 1:length(patts)
    line([xl(1) xl(2)],avdiff(i)*[1 1],'Color','k','LineStyle',lstyle{i})
end
ylim([0 0.3])
xlim([0 29])
set(gca,'YTick',0:0.1:0.3,'YTickLabel',[],'XTick',1:28,'XTickLabel',[]); %[1:14, 1:14])
andy_setbox

if dosave
    alsavefig('samediffpatts',[18 4])
end