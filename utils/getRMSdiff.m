function rmsval = getRMSdiff(v1,v2)
% root mean square difference between two images, or one image and a 3D
% array of other images

rmsval = sqrt(sum(sum(bsxfun(@minus,v1,v2).^2,1),2)./numel(v1(:,:,1)));
