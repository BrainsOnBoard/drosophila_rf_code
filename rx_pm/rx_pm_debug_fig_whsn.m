
clear

progbaron = false;
npixapprox = 1000;

rx_consts;
xyjump = 4*pm.reflen/pm.nsnaps;
xyst = xyjump:xyjump:pm.reflen;
[snx,sny] = rotatexy([-xyst,xyst,zeros(1,pm.nsnaps/2)], ...
                     [zeros(1,pm.nsnaps/2),-xyst,xyst],pi/4);

% figure(1);clf
% plot(snx(1:5),sny(1:5),'b+',snx(6:10),sny(6:10),'r+',snx(11:15),sny(11:15),'g+', ...
%      snx(16:end),sny(16:end),'k+');

cols = [1 0 0; 0 0 1; 0 1 0; 1 1 0];

dname = fullfile(mfiledir,'../../../data/rx_neurons/paths');
% files = dir([datadir '*.mat']);

rtnviews = round(2*sqrt(npixapprox/pi));
% vdiff = d/rtnviews;
arenas = fnames;
% arenas = {'ofstad_etal_arena.mat'};
viewtypes = {'hires','lores','R2','R4','Rx'};
% viewtypes = {'R2'};

if progbaron
    startprogbar(50,length(arenas)*length(viewtypes)*pm.nstartpos,'',true)
end

figure(5);clf
alsubplot(length(viewtypes),length(arenas),1,1)
for i = 1:length(arenas)
    for j = 1:length(viewtypes)
        mwhsn = zeros([rtnviews,rtnviews,20]);
        
        nfile = 0;
        for k = 1:pm.nstartpos
            fname = sprintf('%s/%s_%s_st%02d_%04dto%04d.mat',dname,arenas{i}(1:end-4), ...
                            viewtypes{j},k,1,10);
            if exist(fname,'file')
                nfile = nfile+1;
                load(fname,'flyx','flyy','whsn');
%                 whsn = reshape(whsn,[size(flyx), 5]);
                sel = ~isnan(whsn);
%                 whsn = ceil(whsn(sel)./5);
%                 sel = all(sel,3);
                flyx = 1+round((rtnviews-1)*(0.5+flyx(sel)./d));
                flyy = 1+round((rtnviews-1)*(0.5+flyy(sel)./d));

                [cnt,cind] = countvals(sub2ind(size(mwhsn),flyy,flyx,whsn(sel)));
                mwhsn(cind) = mwhsn(cind)+cnt;

                if progbaron && progbar
                    return
                end
            end
        end
%         pwhsn = mwhsn./max(mwhsn(:));
        pwhsn = bsxfun(@rdivide,mwhsn,sum(mwhsn,3));
%         pwhsn = bsxfun(@rdivide,pwhsn,max(pwhsn,[],3));
        pwhsn(isnan(pwhsn)) = 0;
        
        whim = ones(rtnviews);
        for k = 1:4
            cim = repmat(shiftdim(cols(k,:),-1),rtnviews,rtnviews);
            cim(:,:,4) = sum(pwhsn(:,:,(k-1)*5+(1:5)),3);
            whim = imageadd(whim,cim);
        end
        
        alsubplot(j,i)
        imshow(whim)
        axis equal tight

        if j==1
            title(arenas{i},'Interpreter','none')
        end
%         if j==length(viewtypes)
%             set(gca,'XTick',[-6 0 6]);
%         else
%            set(gca,'XTick',[]);
%         end
        if i==1
            ylabel(viewtypes{j})
%             set(gca,'YTick',[-6 0 6]);
%         else
%            set(gca,'YTick',[]);
        end
        
        %%
%         figure(6);clf
%         tots = shiftdim(sum(sum(mwhsn)));
%         bar(tots)
% 
%         load(sprintf('%s/../../../data/rx_neurons/snaps/rx_pm_snaps_%s_%s',mfiledir,viewtypes{j},arenas{i}),'snaps')
%         figure(7);clf
%         csnaps = snaps(:,:,:,1);
%         csnaps = bsxfun(@rdivide,bsxfun(@minus,csnaps,min(csnaps)),range(csnaps));
%         sndiffs = zeros(size(csnaps,3),size(csnaps,3));
%         for k = 1:size(csnaps,3)-1
%             compi = k+1:size(csnaps,3);
%             cdf = getRMSdiff(csnaps(:,:,k),csnaps(:,:,compi));
%             sndiffs(k,compi) = cdf;
%             sndiffs(compi,k) = cdf;
%         end
%         sndifftot = sum(sndiffs)./(size(csnaps,3)-1);
%         
% %         meanks = shiftdim(mean(mean(snaps),2));
% %         errorbar(mean(meanks,2),std(meanks,[],2),'LineStyle','none')
%         bar(sndifftot)
%         ylim([0 1])
    end
end
