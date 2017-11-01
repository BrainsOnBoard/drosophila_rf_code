function k = kstr2k(kerns)
% converts a kernel struct array to a 3D array of kernel matrices

k = cell2mat(shiftdim({kerns.k},-1));
