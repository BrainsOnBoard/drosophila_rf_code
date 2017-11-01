function cx=shiftmat(x,xmove,ymove,padval)
% shift a matrix, keeping it the same size, and replacing missing values
% with padval

if nargin < 4
    padval = 0;
end

xsz = size(x);

xm = round(xmove);
axm = abs(xm);
z1 = repmat(padval,size(x,1),axm);
if xm==0
    cx = x;
elseif xm > 0
    cx = [z1,x(:,1:end-axm)];
else
    cx = [x(:,axm:end),z1];
end

ym = round(ymove);
aym = abs(ym);
z2 = repmat(padval,aym,size(cx,2));
if ym~=0
    if ym > 0
        cx = [z2;cx(1:end-aym,:)];
    else
        cx = [cx(aym:end,:);z2];
    end
end

cx = cx(1:xsz(1),1:xsz(2));
