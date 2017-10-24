function ckerns = centerkernson(kerns,cent)
for i = 1:numel(kerns)
    shftk = shiftmat(kerns(i).k,cent(1)-kerns(i).cent(1),cent(2)-kerns(i).cent(2));
    ckerns(i) = struct('k',shftk,'cent',cent,'glomnum',kerns(i).glomnum, ...
                       'flynum',kerns(i).flynum,'isleft',kerns(i).isleft);
end