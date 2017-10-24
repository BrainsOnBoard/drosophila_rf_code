function [heads,veclens,idfim,mx,my]=getIDFheads(xg,yg,idf)
%function heads=getIDFheads(xg,yg,idf)

if size(idf,2)>1
    [heads2d,veclens2d] = deal(NaN(sqrt(size(idf,1)),size(idf,2)));
end
for i = 1:size(idf,2)
    [idfim,mx,my] = makeim(xg,yg,idf(:,i));
    [dx,dy] = gradient(idfim');
    [heads2d(:,:,i),veclens2d(:,:,i)] = cart2pol(-dx,-dy);
end

% [cxi,cyi] = meshgrid(1:size(heads2d,1));
[heads,veclens] = deal(NaN(numel(xg),size(idf,2)));
for i = 1:numel(xg)
%     [y,x] = ind2sub([size(heads2d,1) size(heads2d,2)],find(my==yg(i) & mx==xg(i)));
    [row,col] = find(my==yg(i) & mx==xg(i));
    ind = sub2ind(size(heads2d),row*ones(1,size(heads2d,3)),col*ones(1,size(heads2d,3)),1:size(heads2d,3));
    heads(i,:) = heads2d(ind);
    veclens(i,:) = veclens2d(ind);
end
% 