function alfill(X,Y,Z,varargin)
isvec = isvector(X);
if isvec
    nind = [0;find(isnan(X))];
else
    X = X';
    Y = Y';
    Z = Z';
    nind = [sub2ind(size(X),ones(1,size(X,2)),1:size(X,2)),numel(X)+1];
%     keyboard
end
ish = ishold;
hold on
is2d = ischar(Z) || ndims(Z)~=ndims(X) || ~all(size(Z)==size(X));
for i = 1:length(nind)-1
    ind = nind(i)+isvec:nind(i+1)-1;
    if is2d
        fill(X(ind),Y(ind),Z,varargin{:});
    else
        fill3(X(ind),Y(ind),Z(ind),varargin{:});
    end
end
if ~ish
    hold off
end