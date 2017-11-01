function err=stderr(x,dim)
% returns standard error

if nargin < 2
    dim = 1+isrow(x);
end

err = sqrt(var(x,0,dim)./size(x,dim));