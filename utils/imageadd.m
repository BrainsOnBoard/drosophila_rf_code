function outim = imageadd(varargin)

outim = ones(size(varargin{1},1),size(varargin{1},2),3);
c = 1;
while c <= nargin
    cur = varargin{c};
    if isinteger(cur)
        cur = im2double(cur);
    end
    
    alpha = 1;
    if ~any(size(cur,3)==[2,4])
        if c < nargin && ischar(varargin{c+1})
            if c~=nargin-1 && strcmp(varargin{c+1},'alpha')
                alpha = varargin{c+2};
                c = c+2;
            else
                error('invalid parameters')
            end
        end
    else
        alpha = cur(:,:,end);
        cur = cur(:,:,1:end-1);
    end
    
    nans = any(isnan(cur),3);
    if any(nans(:))
        if numel(alpha)==1
            alpha = alpha*ones(size(cur,1),size(cur,2));
        end
        alpha(nans) = 0;
        cur(nans) = 0;
    end
    
    outim = bsxfun(@plus,bsxfun(@times,cur,alpha),bsxfun(@times,outim,1-alpha));
    
    c = c+1;
end