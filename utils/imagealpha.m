function im=imagealpha(varargin)
sz = size(varargin{1});
if any(cellfun(@(x)size(x,3)>2,varargin))
    im = ones([sz([1 2]),3]);
else
    im = ones(sz([1 2]));
end
% imalpha = 1;
for i = 1:2:length(varargin)
    cim = varargin{i};
    nans = isnan(cim);
    cim(nans) = 0;
    calpha = varargin{i+1};
    calpha = calpha.*(1-nans);
    
%     outalpha = calpha+imalpha.*(1-calpha);
%     im = (cim.*calpha+im.*imalpha.*(1-calpha))/outalpha;
    im = bsxfun(@plus,bsxfun(@times,cim,calpha),bsxfun(@times,im,1-calpha));
%     im = (cim*calpha+im)/2;
%     imalpha = outalpha;
end