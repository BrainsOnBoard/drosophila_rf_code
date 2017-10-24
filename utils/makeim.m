function [im,mx,my]=makeim(x,y,c)
% function im=makeim(x,y,c)

[mx,my] = meshgrid(unique(x),unique(y));
im = NaN(size(mx));
for i = 1:numel(mx)
    sel = x==mx(i) & y==my(i);
    if any(sel)
        im(i) = c(sel);
    end
end
% 
% inc = mode(diff(unique([x(:);y(:)])));
% r = max(abs(hypot(x(:),y(:))));
% 
% [im,mx,my]=deal(NaN(1+int16(2*r/inc)));
% for i = 1:numel(x)
%     cy = int16(1+(y(i)+r)./inc);
%     cx = int16(1+(x(i)+r)./inc);
%     im(cy,cx) = c(i);
%     mx(cy,cx) = x(i);
%     my(cy,cx) = y(i);
% end
% 
% nans = isnan(im);
% sely = any(~nans,2);
% selx = any(~nans,1);
% im = im(sely,selx);
% mx = mx(sely,selx);
% my = my(sely,selx);
