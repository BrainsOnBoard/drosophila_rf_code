function ploscb_fig2f_blob_activation_differences(dosave,gennew)
    if nargin < 2
        gennew = false;
    end
    if nargin < 1
        dosave = false;
    end
    
    simblobs = [false true];
    separatefigs = false;
    
    blobalpha = 0.5;

    fov = [120 270];
    
    comdiff = 20;

    load('vf_kernels_nothresh.mat','vf_avkernels_r2');
    kerns = vf_avkernels_r2;
    ks = cell2mat(shiftdim({kerns.k},-1));
    imsz = [size(ks,1),size(ks,2)];

    for i = 1:length(kerns)
        ck = ks(:,:,i);
        pos = ck>0;
        ck(pos) = ck(pos)./sum(ck(pos));
        neg = ck<0;
        ck(neg) = -ck(neg)./sum(ck(neg));
        ks(:,:,i) = ck;
    end
    
    comdiff = comdiff*(imsz(1)/fov(1));
    
    cents = cell2mat({kerns(cell2mat({kerns.isleft})).cent}');
    az = round(mean(cents(1,:)) - imsz(2)/2);
    
    a2b = 0.5;
    nwave = 2;
    
    % scale,majoraxis,thoff,amp,freq,phi
    maxes = [  1 30*(imsz(1)/fov(1)) pi, 0.125 30 2*pi]';
    mins  = [0.1  5*(imsz(1)/fov(1))  0,  0.05  1    0]';
    
    maxes = [maxes(1:3);repmat(maxes(4:end),nwave,1)];
    mins = [mins(1:3);repmat(mins(4:end),nwave,1)];
    rng = maxes-mins;
    [bacts1,bacts2] = deal(NaN(length(kerns),2));
    blobs = NaN(size(ks,1),size(ks,2),3,size(ks,3));
    for csimblobs = simblobs
        cfilenum = 1;
        while true
            datafn = sprintf('%s/fcp%d_%03d.mat',mfiledir,csimblobs,cfilenum);
            if ~exist(datafn,'file')
                break;
            end
            cfilenum = cfilenum+1;
        end
        if ~gennew && cfilenum > 1
            cfilenum = cfilenum-1;
            datafn = sprintf('%s/fcp%d_%03d.mat',mfiledir,csimblobs,cfilenum);
            load(datafn);
        else
            disp('searching for new blob combo')

            opts = optimset('fminsearch');
            [opts.MaxIter,opts.MaxFunEvals] = deal('5000*numberofvariables');
            x0 = rand(6+6*nwave,1);
            [xout,fval] = fminsearch(@errfunc,x0);
            save(datafn,'xout','fval');
        end

        bparam1 = xout(1:length(xout)/2);
        [bacts1(:,csimblobs+1),blob1] = blobacts(bparam1,0);
        bparam2 = xout(length(xout)/2+1:end);
        [bacts2(:,csimblobs+1),blob2] = blobacts(bparam2,~csimblobs*comdiff);

        y = linspace(-fov(1)/2,fov(1)/2,imsz(1));
        x = linspace(-fov(2)/2,fov(2)/2,imsz(2));

        blob1 = im2double(blob1);
        blob1(blob1==1) = NaN;
        blob2 = im2double(blob2);
        blob2(blob2==1) = NaN;
        blob2 = repmat(blob2,[1 1 3]);
        blob2(:,:,2) = 1-blob2(:,:,2);

        if csimblobs
            simtxt = 'sim';
        else
            simtxt = 'diff';
        end

        yl = fov(1)*[-0.5 0.5];
        xl = fov(2)*[-0.5 0.5];
        xticks = -fov(2)/2:45:fov(2)/2;
        yticks = -fov(1)/2:30:fov(1)/2;

        if separatefigs
            figure(csimblobs*3+1);clf
            b1 = blob1;
            b1(isnan(b1)) = 1;
            image(x,y,255*b1);
            axis equal
            ylim(yl)
            xlim(xl)
            set(gca,'XTick',xticks,'YTick',yticks)
            colormap gray
            if dosave
                imwrite(blob1,sprintf('%s/figures/%s_blob1_%03d.png', ...
                        mfiledir,simtxt,cfilenum));
            end

            figure(csimblobs*3+2);clf
            b2 = imagealpha(blob2,blobalpha);
            b2(isnan(b2)) = 1;
            image(x,y,b2);
            axis equal
            ylim(yl)
            xlim(xl)
            set(gca,'XTick',xticks,'YTick',yticks)
            if dosave
                imwrite(blob2,sprintf('%s/figures/%s_blob2_%03d.png', ...
                        mfiledir,simtxt,cfilenum));
            end

            figure(csimblobs*3+3);clf
            h=bar([bacts1, bacts2]);
            c1 = [0 0 0];
            c2 = 1-blobalpha*(1-[0 1 0]);
            set(h(1),'FaceColor',c1);
            set(h(2),'FaceColor',c2);
            ylim([-1 1]);

            xlabs = cell(size(kerns));
            for i = 1:length(kerns)
                if kerns(i).isleft
                    xlabs{i} = sprintf('L%d',kerns(i).glomnum);
                else
                    xlabs{i} = sprintf('R%d',kerns(i).glomnum);
                end
            end
            set(gca,'XTick',1:length(kerns),'XTickLabel',xlabs);
            rdiff = getRMSdiff(bacts1,bacts2);
            text(length(kerns)+0.5,0.9,sprintf('mean difference = %.1f%%',100*rdiff), ...
                 'HorizontalAlignment','right','VerticalAlignment','top');
        else
            blobs(:,:,:,1+csimblobs) = imagealpha(blob1,blobalpha,blob2,blobalpha);

            c1 = 1-blobalpha*(1-[0 0 0]);
            c2 = 1-blobalpha*(1-[0 1 0]);
        end

        if dosave
            if separatefigs
                alsavefig(sprintf('%s_fcp_%03d',simtxt,cfilenum),[20 14]);
            end
        end
    end
    if ~separatefigs
        figure(3);clf
        dacts = abs(bacts1-bacts2);
        h=bar(dacts);
        hold on
        set(h(1),'FaceColor','w')
        set(h(2),'FaceColor','k')
        set(gca,'XTick',1:28,'XTickLabel',[],'YTick',0:0.1:0.7,'TickDir','out','Units','normalized')
        andy_setbox
        ylim([0 0.75])
        xlim([0 29])
        simappd = mean(dacts(:,1));
        diffappd = mean(dacts(:,2));
        line([0 29],simappd*[1 1],'Color','k','LineStyle',':')
        line([0 29],diffappd*[1 1],'Color','k','LineStyle','--')
        if dosave
            alsavefig('simdiff_bar',[18 5]);
        end
        fprintf('simapp: %f\ndiffapp: %f\n',simappd,diffappd)
        
        if dosave
            imdir = fullfile(mfiledir,'../../figures/drosneur/simdiff');
            imwrite(blobs(:,:,:,1),fullfile(imdir,'simdiff_blob_simapp.png'))
        end
        
        if dosave
            imwrite(blobs(:,:,:,2),fullfile(imdir,'simdiff_blob_diffapp.png'));
        end
    end
    
    function [errval,evact,evparam]=errfunc(params)
        vcomoff2 = ~csimblobs*comdiff;
        [acts1,im1] = blobacts(params(1:length(params)/2),0);
        [acts2,im2] = blobacts(params(length(params)/2+1:end),vcomoff2);
        evact = mean(abs((acts1-acts2)/2));

        evparam = mean(abs(params(1:length(params)/2)-params(length(params)/2+1:end)));

        errval = evparam/evact;
        if ~csimblobs
            errval = 1/errval;
        end
    end

    function [acts,im]=blobacts(b_x,vcomoff)
        im = makeblob(b_x,vcomoff,imsz);
        acts = getacts(im,ks);
    end
    
    function im=makeblob(b_x,vcomoff,cimsz)
        b_x = max(mins,min(maxes,rng.*(b_x+mins)));
        
        b_param = b_x(1:3);
        b_wparam = b_x(3+(1:nwave*3));
        b_wparam = reshape(b_wparam,length(b_wparam)/nwave,nwave);

        % scale,majoraxis,thoff,amp,freq,phi
        % (scale,amp,freq,phi,majoraxis,minoraxis,thoff,im_size)
        im = ellblob(b_param(1),b_wparam(1,:),b_wparam(2,:),b_wparam(3,:), ...
                     b_param(2),b_param(2)*a2b,b_param(3),[cimsz(1),cimsz(2)*360/fov(2)]);
        if all(im(:))
            error('no blob!')
        end
        
        [ys,~] = find(~im);
        cvcom = mean(ys);
        
        im = circshift(im,[round(cvcom-cimsz(1)/2-vcomoff),az]);
        im = im(:,(size(im,2)-cimsz(2))/2 + (1:cimsz(2)));
        
%         figure(1);clf
%         imshow(im)
%         keyboard
    end
end
