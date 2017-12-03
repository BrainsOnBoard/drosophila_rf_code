function im=ellblob(scale,amp,freq,phi,majoraxis,minoraxis,thoff,im_size)
% function im=ellblob(scale,amp,freq,phi,majoraxis,minoraxis,thoff,im_size)

scale = minoraxis*scale(:);
amp = amp(:);
amp = scale.*amp./sum(amp+realmin);
freq = freq(:);
phi = phi(:);

[mx,my] = meshgrid(1-im_size(2)/2:im_size(2)/2,1-im_size(1)/2:im_size(1)/2);
ths = atan2(my,mx)+thoff;

ywave = sum(bsxfun( @times, shiftdim(amp,-2), sin(bsxfun(@times,shiftdim(freq,-2),bsxfun(@plus,ths,shiftdim(phi,-2)))) ),3 );
r = max(0,majoraxis*minoraxis./hypot(minoraxis*cos(ths),majoraxis*sin(ths)) + ywave);

im = hypot(mx,my) > r;