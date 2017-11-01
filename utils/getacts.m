function acts=getacts(im,rkerns)
% get activations for kernels to a given image
acts = shiftdim(sum(sum(bsxfun(@times,im,rkerns),1),2),2);