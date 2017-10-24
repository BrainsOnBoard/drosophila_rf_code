function rkern = resizekernel(kern,szfac,thresh)
% function rkern = resizekernel(kern,szfac,thresh)
if isstruct(kern)
    if length(kern)==1
        kernstr = kern;
    end
    kern = {kern.k};
else
    kern = {kern};
end

if isscalar(szfac)
    szfac = floor(size(kern{1})*szfac);
end
rkern = NaN([szfac,numel(kern)]);
for i = 1:size(rkern,3)
    ck = imresize((sign(kern{i})+1)/2,szfac,'bilinear'); % resize kernel
    
    ck = (ck*2)-1; % set kernel to be between -1 and 1
    ck(abs(ck)<thresh) = 0; % remove sub-threshold values
    ck(ck>0) = 1/sum(sum(ck>0)); % normalise kernel values
    ck(ck<0) = -1/sum(sum(ck<0));
    
    rkern(:,:,i) = ck;
end

if exist('kernstr','var')
    mult = szfac([2 1])./[size(kern,2),size(kern,1)];
    rkern = struct('k',rkern,'cent',1+mult.*(kernstr.cent-1));
    if isfield(kernstr,'isleft')
        rkern.isleft = kernstr.isleft;
    end
    if isfield(kernstr,'oldcent')
        rkern.oldcent = 1+mult.*(kernstr.oldcent-1);
        rkern.im_size = mult.*kernstr.im_size;
    end
end