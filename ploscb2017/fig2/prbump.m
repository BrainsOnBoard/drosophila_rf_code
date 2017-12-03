function prbump(dosave)
if ~nargin
    dosave = false;
end

% cd(fullfile(mfiledir,'..'))

dname = fullfile(mfiledir,'../../data/patterns/');
fnames = { '09_4_00_162_1_-107_triangles_com.png','09_2_00_162_1_+067_triangles_hollow_com.png' };
im_size = [120 360];
fov = 270;
offrad = 10;
nreps = 1000;

knum = [2,4];

newsz = [im_size(1), im_size(2)*fov/360];

load('vf_kernels','vf_avkernels_r2');
kerns = vf_avkernels_r2;

rkerns = resizekernel(kerns,newsz,.25);
nkerns = size(rkerns,3)*knum;

kcents = cell2mat({kerns.cent}');
ksz = cell2mat(cellfun(@size,{kerns.k},'UniformOutput',false)');
rcents = 1+bsxfun(@times,(kcents-1)./(ksz(:,[2 1])-1),newsz([2 1]));

% first step: figure out which positions we can put RFs in (i.e.
% outside a given radius of existing RFs)
canplace = true(newsz);
[yi,xi] = ndgrid(1:newsz(1),1:newsz(2));
for j = 1:size(rcents,1)
    exrad(rcents(j,:));
end

canplaceorig = canplace;

% % show where RFs can be placed
% figure(1);clf
% imshow(canplace)
% keyboard

figdatdname = fullfile(mfiledir,'../../data/figpreprocess');
if ~exist(figdatdname,'dir')
    mkdir(figdatdname);
end

% if fig data is already generated, load
figdatfn = fullfile(figdatdname,sprintf('prbump_%d.mat',nreps));
if exist(figdatfn,'file')
    load(figdatfn)
else
    [cim,rim,tcim,trim] = deal(cell(1,length(fnames)));
    diff1 = NaN(1,length(fnames));
    for i = 1:length(fnames)
        cim{i} = im2double(rgb2gray(imread([dname,fnames{i}])));
        rim{i} = circshift(cim{i},[0 round(size(cim{i},2)*90/360)]);
        xdiff = (im_size(2)-newsz(2))/2;
        tcim{i} = cim{i}(:,xdiff+1:end-xdiff);
        trim{i} = rim{i}(:,xdiff+1:end-xdiff);
        diff1(i) = getRMSdiff(getacts(tcim{i},rkerns),getacts(trim{i},rkerns));
    end
    
    diffs = NaN(nreps,length(knum),length(fnames));
    
    % run the simulation nreps times
    startprogbar(1,nreps)
    for r = 1:nreps
        % knum indicates multiplier for number of kernels (we also test 
        % just using originals)
        for i = 1:length(knum)
            canplace = canplaceorig; % reset each time
            szfac = 1/sqrt(knum(i)); % scale each kernel appropriately, giving area == 1/knum(i)
            
            % randomly place each kernel, meaning each kernel is placed
            % knum(i) times (inc. its original position)
            ks = zeros(size(rkerns,1),size(rkerns,2),nkerns(i));
            for j = 1:length(kerns)
                ck = kerns(j).k;
                ccent = kerns(j).cent;
                
                % trim kernel
                anyy = any(ck,2);
                anyx = any(ck);
                ybeg = find(anyy,1);
                yend = find(anyy,1,'last');
                xbeg = find(anyx,1);
                xend = find(anyx,1,'last');
                sck = ck(ybeg:yend,xbeg:xend);
                
                % resize kernel
                sck = resizekernel(sck,szfac,0.25);
                scent = szfac*[ccent(1)-xbeg+1,ccent(2)-ybeg+1];
                
%                 figure(2);clf
%                 showkernel(sck,scent)
%                 keyboard
                
                addexkern(sck,rcents(j,:),scent,j);
                
                for k = 1:knum(i)-1
                    placei = find(canplace); % posible points to place
                    [ky,kx] = ind2sub(newsz,placei(randi(length(placei))));
                    addexkern(sck,[kx ky],scent,k*length(kerns)+j);
                    exrad([kx ky]);
                end
                
%                 figure(1);clf
%                 subplot(1,4,1)
%                 showkernel(exkerns(:,:,i),rcents(i,:));
%                 subplot(1,4,2)
%                 showkernel(rkerns(:,:,i),rcents(i,:));
%                 title(sprintf('%.2f ',rcents(i,:)))
%                 subplot(1,4,3)
%                 showkernel(kerns(i))
%                 title(sprintf('%.2f ',kerns(i).cent));
%                 subplot(1,4,4)
%                 showkernel(exkerns(:,:,i+nkerns),[kx ky]);
%                 keyboard
            end
            
            for j = 1:length(fnames)
                diffs(r,i,j) = getRMSdiff(getacts(tcim{j},ks),getacts(trim{j},ks));
            end
        end
        
        if progbar
            return
        end
    end
    
    % save fig data
    save(figdatfn,'rkerns','tcim','trim','diffs','diff1','cim','rim');
end

    function exrad(c)
        canplace = canplace & hypot(yi-c(2),xi-c(1)) > offrad;
    end

    function addexkern(kern,newcent,oldcent,ind)
        toshift = floor(newcent-oldcent);
        
        % make new shifted and resized kernel
        ckern = zeros(newsz);
        ckern(1:size(kern,1),1:size(kern,2)) = kern;
        ckern = shiftmat(ckern,toshift(1),toshift(2));
        
        % renormalise values
        pos = ckern>0;
        neg = ckern<0;
        ckern(pos) = 1/sum(pos(:));
        ckern(neg) = -1/sum(neg(:));
        
        % add to array
        ks(:,:,ind) = ckern;
    end

figure(1);clf
% alsubplot(3,length(fnames),1,1);
set(gca,'FontSize',8,'FontName','Arial')
for i = 1:length(fnames)
    cdiffs = diffs(:,:,i);
    
%     alsubplot(1,i)
%     imshow(cim{i});
% 
%     alsubplot(2,i)
%     imshow(rim{i});

    means = mean(cdiffs);
    
%     alsubplot(3,i)
    subplot(1,length(fnames),i)
    barerr([diff1(i),means],[0 std(cdiffs)])
    andy_setbox
    set(gca,'XTick',1:length(nkerns)+1,'XTickLabel',[length(kerns),nkerns])
    xlabel('number of RFs')
    if i==1
        ylabel('r.m.s. difference')
    else
        set(gca,'YTickLabel',[])
    end
    ylim([0 .25])
end

if dosave
    alsavefig('prbump',[21 5]);
end

end