function [acts,angs]=panoconv_all(im,rkerns,fov,nangs)
if nargin < 3;
    fov = 360;
end
if nargin < 4
    nangs = 360;
end

% how much to trim from image
xoff = round(0.5*size(im,2)*(1-fov/360));
xrng = size(im,2);
xvals = round(linspace(xrng/2,-xrng/2-1,nangs));

acts = NaN(size(rkerns,3),nangs);
for i = 1:nangs
    rim = circshift(im,[0 xvals(i)]);
    cim = rim(:,1+xoff:end-xoff);

    acts(:,i) = getacts(cim,rkerns);
end

if nargout==2
    angs = linspace(-180,180,nangs+1);
    angs = angs(1:end-1);
end