function [rkerns,rkernnum] = rx_gendata_rx_kerns
% fname = fullfile(mfiledir,'/../../../data/rx_neurons/rx_idf_kerns2.mat');
fname = fullfile(mfiledir,'/../../../data/rx_neurons/rx_idf_kerns.mat');

if exist(fname,'file')
    load(fname);
else
    disp('generating kernels')
    
    rx_consts;
    
    % load kernels
    load('vf_kernels.mat','vf_avkernels*');
    nr2 = numel(vf_avkernels_r2);
    nr4 = numel(vf_avkernels_r4);
    
    % calculate where r2 kern centres will be after resizing
    cents = cell2mat({vf_avkernels_r2.cent}');
    rcfac = (rkernsz-1)./(size(vf_avkernels_r2(1).k)-1);
    rcents = 1+bsxfun(@times,cents-1,rcfac([2 1]));
    
    % resize r2 and r4 kernels
    rkerns = NaN([rkernsz,2*nr2+nr4]);
    rkerns(:,:,nr2+(1:(nr2+nr4))) = resizekernel([vf_avkernels_r2,vf_avkernels_r4],rkernsz,.25);
    
    % spread r2 kernels evenly across vf -- try to minimise moving required
    [cx,cy] = meshgrid((rkernsz(2)/15)*(1:14),(rkernsz(1)/3)*[1 2]);
    xdiff = bsxfun(@minus,cx(:)',rcents(:,1));
    ydiff = bsxfun(@minus,cy(:)',rcents(:,2));
    diffs = sqrt(xdiff.^2+ydiff.^2);
%     chgdiffs = diffs;
%     [oldinds,newinds] = deal(1:nr2);
    totdiffs = NaN(nr2,1);
%     for debugi = 1:100
%         tic
        chgdiffs = diffs;
        [oldinds,newinds] = deal(1:nr2);
        for i = 1:nr2
            [vals,rowis] = min(chgdiffs);
            [~,coli] = max(vals);
            rowi = rowis(coli);
            oldi = oldinds(rowi);
            newi = newinds(coli);

            ckern = shiftmat(rkerns(:,:,nr2+oldi),xdiff(oldi,newi),ydiff(oldi,newi));
%             pos = ckern>0;
%             ckern(pos) = 1./sum(pos(:));
%             neg = ckern<0;
%             ckern(neg) = -1./sum(neg(:));
            rkerns(:,:,newi) = ckern;

    %         figure(1);clf
    %         subplot(2,1,1)
    %         showkernel(ckern)
    %         hold on
    %         plot(cents(oldi,1),cents(oldi,2),'g+');
    %         title(num2str(sqrt(diffs(rowi,coli))))
    %         subplot(2,1,2)
    %         showkernel(newkern);
    %         hold on
    %         plot(cx(newi),cy(newi),'g+');
    %         keyboard

            totdiffs(i) = chgdiffs(rowi,coli);

            oldinds(rowis(coli)) = [];
            newinds(coli) = [];
            chgdiffs(rowi,:) = [];
            chgdiffs(:,coli) = [];
        end
%         toc
%     end
%     disp([mean(totdiffs) std(totdiffs)])

    rkernnum = [ones(nr2,1);2*ones(nr2,1);4*ones(nr4,1)]; % are kernels r1/r2/r4
    
    save(fname,'rkerns','rkernnum','totdiffs');
    
    if ~nargout
        clear rkerns rkernnum
    end
end