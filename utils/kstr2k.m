function k = kstr2k(kerns)
k = cell2mat(shiftdim({kerns.k},-1));