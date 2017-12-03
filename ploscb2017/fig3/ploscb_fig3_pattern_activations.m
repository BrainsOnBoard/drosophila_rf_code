function ploscb_fig3_pattern_activations(dosave)
    if ~nargin
        dosave = false;
    end
    
    showprogbar = true;
    usenothreshkerns = true;
    scattermarkersize = 2;
    
    colcnt = [17 19];
    ncol = length(colcnt);
    colmax = max(colcnt);
    ymax = 0.6;
    baroffs = 0.5;
    
    showrng = [45 135 225];
    im_size = [120 360];

    if usenothreshkerns
        threshstr = '_nothresh';
    else
        threshstr = '';
    end
    
    load(['vf_kernels' threshstr],'vf_avkernels_r2');
    kerns = kstr2k(vf_avkernels_r2);
    if usenothreshkerns
        for i = 1:size(kerns,3)
            ck = kerns(:,:,i);
            
            pos = ck > 0;
            ck(pos) = ck(pos)./sum(ck(pos));
            neg = ck < 0;
            ck(neg) = -ck(neg)./sum(ck(neg));
            
            kerns(:,:,i) = ck;
        end
    end

    dname = fullfile(mfiledir,'../../data/patterns');
    d = [dir(fullfile(dname,'*.jpg'));dir(fullfile(dname,'*.png'))];
    fname = sort({d.name});

    crng = round(showrng*im_size(2)/360);
    [diffr2,stdr2,eh_dcp,eh_scp,retol] = deal(NaN(length(fname),1));
    eh_dcpsig = zeros(size(diffr2));
%     ims = ones(im_size(1)*size(diffr2,1),range(crng)+1,ncol);
    
    datafn = sprintf('%s/../../data/figpreprocess/panoconv%s.mat',mfiledir,threshstr);
    if exist(datafn,'file')
        load(datafn);
    else
        if showprogbar
            startprogbar(1,length(fname));
        end
        
        ehf = fopen([mfiledir,'/dcp.txt'],'r');
        ehcell = textscan(ehf,'%d:%s\n');
        fclose(ehf);
        eh_fig = ehcell{1};
        eh_str = ehcell{2};

        for i = 1:length(fname)
            im = imread(fullfile(dname,fname{i}));
            if size (im,3)>1
                im = rgb2gray(im);
            end
            im = im2double(im);

%             unitsperpix = 0.1*str2double(fname{i}(13))/str2double(fname{i}(9:11));
%             eh_diffr2(j,i) = unitsperpix*str2double(fname{i}(15:18));
%                 unitsperpix = eval(ehupp{ind});
%                 eh_diffr2(j,i) = unitsperpix*ehpx(ind);
%             whrow = find(i <= tcnt,1)-1;
%             ims((i-tcnt(whrow))*im_size(1)+(1:im_size(1)),:,whrow) = im(:,1+(crng(1):crng(3)));
            
            patt1 = im(:,crng(1):crng(2)-1);
            patt2 = im(:,crng(2):crng(3)-1);
%             figure(1);clf;
%             subplot(1,3,1);
%             imshow(patt1);
%             subplot(1,3,2);
%             imshow(patt2);
%             subplot(1,3,3);
%             imagesc(patt1 & patt2)
%             keyboard
            b_patt1 = ~patt1(:);
            b_patt2 = ~patt2(:);
            overlap = sum(b_patt1 & b_patt2);
%             R = sum(~b_patt1 & b_patt2);
%             retol(i) = overlap/(overlap+R);
            retol(i) = 0.5 * (overlap/sum(b_patt1) + overlap/sum(b_patt2));
%             fprintf('%s: %f, %f\n',fname{i},retol(i),Q/(Q+sum(~b_patt1 & b_patt2)))

            [diffr2(i),stdr2(i)] = vf_ridf(im,kerns);

%                 jind = maxcol-j+1;
            eh_vals = eval(['[',eh_str{i},']']);
            eh_dcp(i) = eh_vals(1);
            eh_dcpsig(i) = eh_vals(2);
            eh_scp(i) = str2double(fname{i}(13))*0.1*str2double(fname{i}(15:18))/str2double(fname{i}(9:11));
%             diffr2(i) = rr2(thr2==-90);
%             stdr2(i) = std(rr2)/sqrt(length(rr2));

%             sig(j,i) = str2double(fname{i}(6));

            if showprogbar && progbar
                return;
            end
        end
        save(datafn,'diffr2','stdr2','eh_fig','retol','eh_dcp','eh_dcpsig','eh_scp');
    end % endhash
    
    
    %% plot figure
%     barsp = 0.1;
    
    sz = [10 19];
    
    pattylo = 0; %-0.05;
    pattyhi = 0.4;
    pattytick = 0.1;
    
    barsp = -pattylo*im_size(1)/im_size(2);
    
%     imsc = 0.5;
%     
%     imsc = imsc*barsp;
    
%% proper fig code
    lastehfig = 0;

    tcnt = [0 cumsum(colcnt)];
    figure(1+usenothreshkerns);clf
    for i = 1:length(fname)
        whrow = find(i <= tcnt, 1)-1;
        whcol = i-tcnt(whrow);
        
        alsubplot(ncol+2,2,[whrow whrow],1:2)
        set(gca,'FontSize',8,'FontName','Arial')
        hold on
        
        if whcol==1
            xlim([0.6-baroffs, colmax+0.4+baroffs])
            bargpoffs = 0;
            lastehfig = eh_fig(i);
        elseif eh_fig(i)~=lastehfig
            bargpoffs = bargpoffs+0.2;
            lastehfig = eh_fig(i);
        end
        if isnan(eh_dcpsig(i)) || eh_dcpsig(i)==0
%             barh(barsp*(maxcol-whrow+1),diffr2(i),0.8*barsp,'FaceColor','w');
            bar(bargpoffs+whcol,diffr2(i),'FaceColor','w');
        else
%             barh(barsp*(maxcol-whrow+1),diffr2(i),0.8*barsp,'FaceColor',0.75*[1 1 1]);
            bar(bargpoffs+whcol,diffr2(i),'FaceColor',0.75*[1 1 1]);
        end

        errorbar(bargpoffs+whcol,diffr2(i),0,stdr2(i),'Color','k');
        
        if i <= length(fname)-3 && i >= length(fname)-5
            text(bargpoffs+whcol,0.01+diffr2(i)+stdr2(i),'x','Color','r','VerticalAlignment','bottom','HorizontalAlignment','center')
        end

        set(gca,'XTick',[])
%         axis equal
%         ylim(barsp*[0.25 1+maxcol])
        ylim([pattylo pattyhi])
%         set(gca,'YTick',[]);
%         set(gca,'XTick',0:xtick:xhi);
%         xlabel('r.m.s. difference between 0^\circ and 90^\circ')
    end
    
    %% stats
    r2X = normalizevals(diffr2);
    rolX = retol;
    dcpY = abs(eh_dcp);
    scpY = abs(eh_scp);
    outtxt = [];
    
    figcorr(scpY,3,'SCP','Spontaneous preference')
    figcorr(dcpY,4,'DCP','Learning index')
    
    ymed = median(cY);
    sigabove = sum(dcpY(eh_dcpsig > 0 & ysel) > ymed);
    sigbelow = sum(dcpY(eh_dcpsig > 0 & ysel) < ymed);
    sigeq    = sum(dcpY(eh_dcpsig > 0 & ysel) == ymed);
    signotgiven = sum(eh_dcpsig > 0 & ~ysel);
    sigtot = sum(eh_dcpsig>0);
    nsabove = sum(dcpY(eh_dcpsig == 0 & ysel) > ymed);
    nsbelow = sum(dcpY(eh_dcpsig == 0 & ysel) < ymed);
    nseq    = sum(dcpY(eh_dcpsig == 0 & ysel) == ymed);
    nsnotgiven = sum(eh_dcpsig == 0 & ~ysel);
    nstot = sum(eh_dcpsig == 0);
    ng = isnan(eh_dcpsig);
    ngabove = sum(dcpY(ng & ysel) > ymed);
    ngbelow = sum(dcpY(ng & ysel) < ymed);
    ngeq    = sum(dcpY(ng & ysel) == ymed);
    ngnotgiven = sum(ng & ~ysel);
    ngtot = sum(ng);
    
    outtxt = sprintf(['%sSig:\nabove: %d; below: %d; eq: %d; not given: %d; tot: %d\n------\n' ...
                      'NS:\nabove: %d; below: %d; eq: %d; not given: %d; tot: %d\n------\n' ...
                      'Sig not given:\nabove: %d; eq: %d; below: %d; not given: %d; tot: %d\n------\ntot tot: %d\n'], ...
                 outtxt,...
                 sigabove,sigbelow,sigeq,signotgiven,sigtot, ...
                 nsabove,nsbelow,nseq,nsnotgiven,nstot, ...
                 ngabove,ngbelow,ngeq,ngnotgiven,ngtot, ...
                 sigtot+nstot+ngtot);
    
    fprintf(outtxt)
    
    if dosave
        savefig('pattern_ridf',sz);
        
        outfn = sprintf('%s/panoconv_%s_%s.txt',mfiledir,datestr(now,'yyyymmdd'),mfilehash);
        fprintf('Writing to %s...\n',outfn)
        fid = fopen(outfn,'w');
        fprintf(fid,outtxt);
        fclose(fid);
%     else
%         dump2base(true)
    end
    
    function figcorr(Y,whrow,whindex,ylab)
        ysel = ~isnan(Y);
        cY = Y(ysel);
        cr2X = r2X(ysel);
        crolX = rolX(ysel);
        meanY = mean(cY);
        
        [rhor2,pr2] = corr(cr2X,cY,'type','Spearman');
        covr2 = cov(cr2X, cY, 1);
        meanr2 = mean(cr2X);
        
        [rhorol,prol] = corr(crolX,cY,'type','Spearman');
        covrol = cov(crolX, cY, 1);
        meanrol = mean(crolX);
        
        outtxt = sprintf('%s==== %s ====\nR2: N = %d; rho = %f; p = %f\nROL: N = %d; rho = %f; p = %f\n\n', ...
                 outtxt,whindex,length(cr2X),rhor2,pr2,length(cr2X),rhorol,prol);
                     
                     
        vsel = false(size(cY));
        vsel(end-5:end-3) = true;
                     
        alsubplot(whrow,1)
        set(gca,'FontSize',8,'FontName','Arial')
        hold on
        plot(cr2X(~vsel),cY(~vsel),'kx',cr2X(vsel),cY(vsel),'rx','MarkerSize',scattermarkersize)
        error_ellipse(covr2, [meanr2, meanY]);
        bestfit(cr2X,cY)
        if whrow==4
            xlabel('R2 difference')
        else
            set(gca,'XTickLabel',[]);
        end
        ylabel(ylab)
        axis equal
        xlim([0 1])
        ylim([0 ymax])
        set(gca,'YTick',0:0.1:0.6)
        andy_setbox
        
        alsubplot(whrow,2)
        set(gca,'FontSize',8,'FontName','Arial')
        hold on
        plot(crolX(~vsel),cY(~vsel),'kx',crolX(vsel),cY(vsel),'rx','MarkerSize',scattermarkersize)
        error_ellipse(covrol, [meanrol, meanY]);
        if whrow==4
            xlabel('Retinal overlap')
        else
            set(gca,'XTickLabel',[]);
        end
        axis equal
        xlim([0 1])
        ylim([0 ymax])
        set(gca,'YTick',0:0.1:0.6,'YTickLabel',[])
        bestfit(crolX,cY)
        if whrow==1
            set(gca,'XTickLabel',[]);
        end
        andy_setbox
    end
end

function bestfit(x,y)
    p = polyfit(x,y,1);
    set(refline(p(1),p(2)),'Color','k')
end

function [dr2,stdr2]=vf_ridf(im,kerns)
%     kerns = cell2mat(shiftdim({kerns.k},-1));
    
    ksz = size(kerns);
    rim = imresize(im,[ksz(1),ceil(360*ksz(2)/270)]);
    xoff = (size(rim,2)-ksz(2))/2;
    acts = NaN(ksz(3),size(rim,2));
    for i = 1:size(rim,2)
        crim = circshift(rim,[0 i-1-ceil(size(rim,2)/2)]);
        
        acts(:,i) = shiftdim(sum(sum(bsxfun(@times,crim(:,xoff+(1:ksz(2))),kerns)),2));
    end
    
%     for i = 1:size(im,2)
%         [acts(:,i),kerns] = getneuronactivations(circshift(im,[0 i-1-ceil(size(im,2)/2)]),kerns);
%     end
    
    acts0 = acts(:,1+size(rim,2)/2);
    rr2 = sqrt(mean(bsxfun(@minus,acts,acts0).^2));
%     rr2 = [rr2,rr2(1)];
    
%     ths = linspace(-180,180,size(rim,2)+1);
    
    i90 = round((size(rim,2)+1)/4);
    dr2 = rr2(i90); % sign(mean(acts0)-mean(acts(:,i90)))*
    stdr2 = std(rr2)/sqrt(length(rr2));
end

% function horzerr(x,y,h,barsp)
%     for i = 1:numel(x)
%         line(x(i)+[0 h(i)],[y(i) y(i)],'Color','k')
%         line(x(i)+h(i)*[1 1],y(i)+barsp*[-0.2 0.2],'Color','k')
%     end
% end