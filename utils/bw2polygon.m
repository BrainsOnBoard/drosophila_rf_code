function [X,Y]=bw2polygon(bw)
bwbound = bwboundaries(bw);
szs = cellfun(@(x)size(x,1),bwbound);
inds = [0;cumsum(szs+1)];
[X,Y] = deal(NaN(sum(szs)+numel(bwbound)-1,1));
% figure(2);clf
% hold on
% alpha = 0.3;
for i = 1:numel(bwbound)
    bnd = bwbound{i};
%     grad = circdiff(bnd(:,2))./circdiff(bnd(:,1));
    
%     fill(bnd(:,1),bnd(:,2),'b','facealpha',alpha)
    
    ind = inds(i)+1:inds(i+1);
    X(ind) = [bnd(:,2);NaN];
    Y(ind) = [bnd(:,1);NaN];
%     X(blen+1:end) = bnd(1,1);
%     Y(blen+1:end) = bnd(1,2);
end

% figure(3);clf
% alfill(X,Y,'b','facealpha',0.1)
% keyboard