function acts=getacts(im,rkerns)
acts = shiftdim(sum(sum(bsxfun(@times,im,rkerns),1),2),2);