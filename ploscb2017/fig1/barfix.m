%% SET PARAMETERS

function barfix(dosave)
if ~nargin
    dosave = false;
end

%% constants
barr = .1;
barx = .5;
bary = 1-barr;
ngrid = 20;
lowbound = 0;
arrowlen = .04;
linewid = 1;
tgain = 2;
r2wt = 0.5;
ksz = [120 271];

%% load kernels
load('vf_kernels.mat','vf_avkernels*');
kerns = [vf_avkernels_r2,vf_avkernels_r4];
ckerns = NaN([ksz(2),ksz(1),length(kerns)]);
for i = 1:length(kerns)
    ckerns(:,:,i) = resizekernel(kerns(i).k,ksz,.25)';
end

%% arrow positions
jump = 1/(ngrid+2);
[gx,gy] = meshgrid(jump:jump:1-jump);
sel = hypot(gx-barx,gy-bary) > barr*1.25;
gx = gx(sel);
gy = gy(sel);

%% get views
[thoff,roff]=cart2pol(bary-gy,barx-gx);
views = false(ksz(2),1,length(gx));
acts = NaN(length(kerns),1,length(gx));
vth = (pi/180)*linspace(-135,135,size(views,1)+1);
vth = vth(2:end)';
for i = 1:length(gx)
    va = thoff(i)+atan(roff(i).\[-barr barr]);
    views(:,1,i) = vth < va(1) | vth > va(2);
    acts(:,1,i) = max(lowbound,getacts(views(:,1,i),ckerns));
end

%% get acts & heads
% acts = acts/2;
isl = cell2mat({kerns.isleft});
isr2 = [true(1,28),false(1,14)];
r2l = mean(acts(isr2 & isl,:,:));
r2r = mean(acts(isr2 & ~isl,:,:));
r4l = mean(acts(~isr2 & isl,:,:));
r4r = mean(acts(~isr2 & ~isl,:,:));
heads = shiftdim(0.5*pi*(1+tgain*(r2wt*(r2l-r2r)+(1-r2wt)*(r4l-r4r))));

%% plotting
figure(1);clf
hold on
[barcx,barcy] = pol2cart(linspace(0,2*pi,1000),barr);
fill(barcx+barx,barcy+bary,'k');
anglequiver(gx,gy,heads,arrowlen,'b',false,'LineWidth',linewid);
xlim([0 1]);
ylim([0 1]);
axis square off

if dosave
    alsavefig('barfix',[7 7]);
end