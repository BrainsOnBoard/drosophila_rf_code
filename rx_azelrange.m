function rx_azelrange
    load('vf_kernels','vf_avkernels_*')
    disp('R2')
    vfazel(vf_avkernels_r2)
    disp('R4')
    vfazel(vf_avkernels_r4)
    
    fov = [270 120];
    azd = (fov(1)/15);
    az = -(fov(1)/2)+azd*[1 2 7];
    el = -(fov(2)/2)+(fov(2)/3)*[1 2];
    fprintf('Rx\naz: [%.3f, %.3f, ..., %.3f]\nel: [%.3f %.3f]\n\n',az(1),az(2),az(3),el(1),el(2))
end

function vfazel(vf)
    vf = vf(cell2mat({vf.isleft}));

    fov = [270 120];

    ksz = [size(vf(1).k,2),size(vf(1).k,1)];
    cents = cell2mat({vf.cent}');
    
    lo = norm(min(cents));
    hi = norm(max(cents));
    
    fprintf('az: [%.3f %.3f]\nel: [%.3f %.3f]\n\n',lo(1),hi(1),hi(2),lo(2))
%     keyboard
    
    function v=norm(v)
        v = fov.*(-0.5+(v-1)./(ksz-1));
        v(:,2) = -v(:,2);
    end
end