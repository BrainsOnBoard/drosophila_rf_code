function showkernels(kerns,cents,kalpha,xrng,yrng)
% function showkernels(kerns,cents,kalpha)
    if nargin < 3 || isempty(kalpha)
        kalpha = 0.25;
    end

    if isstruct(kerns) && (nargin < 2 || isempty(cents))
        tmpkerns = cell2mat(shiftdim({kerns.k},-1));
        cents = cell2mat({kerns.cent}');
        kerns = tmpkerns;
    end
    
    if nargin < 5
        yrng = [1 size(kerns,1)];
    else
        cents(:,2) = yrng(1)+range(yrng)*(cents(:,2)-1)./(size(kerns,1)-1);
    end
    if nargin < 4
        xrng = [1 size(kerns,2)];
    else
        cents(:,1) = xrng(1)+range(xrng)*(cents(:,1)-1)./(size(kerns,2)-1);
    end
    
%     cents = bsxfun(@plus,[xrng(1),yrng(1)],bsxfun(@times,[range(xrng),range(yrng)],bsxfun(@rdivide,cents-1,[size(kerns,2),size(kerns,1)]-1)));

    load('vf_kernels.mat','neuroncolormap');
    incol = neuroncolormap(1,:);
    excol = neuroncolormap(end,:);

    alreadyheld = ishold;
    if ~alreadyheld
        hold on
    end
    for i = 1:size(kerns,3)
        tracebnd(kerns(:,:,i)<0,kalpha,incol,xrng,yrng);
        tracebnd(kerns(:,:,i)>0,kalpha,excol,xrng,yrng);
        
        if exist('cents','var') && ~isempty(cents)
            plot(cents(i,1),cents(i,2),'g+');
        end
        
        xlim(xrng)
        ylim(yrng)
    end
    set(gca,'YDir','reverse')
    if ~alreadyheld
        hold off
    end
end

function tracebnd(im,alpha,color,xrng,yrng)
    bnd = bwboundaries(im);
    for i = 1:numel(bnd)
        x = xrng(1)+range(xrng)*(bnd{i}(:,2)-1)/(size(im,2)-1);
        y = yrng(1)+range(yrng)*(bnd{i}(:,1)-1)/(size(im,1)-1);
        fill(x,y,color,'FaceAlpha',alpha,'EdgeAlpha',alpha);
    end
end