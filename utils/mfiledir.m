function mfd = mfiledir
% returns the dir the current function is executing in

mfd = fileparts(evalin('caller','mfilename(''path'')'));
if isempty(mfd)
    d = dbstack;
    if numel(d)>=2
        mfd = fileparts(which(d(2).file));
    end
end