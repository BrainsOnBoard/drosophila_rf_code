function [X,Y,Z]=rotZ(X,Y,Z,TH)

rZ=[cos(TH),-sin(TH),0;...
    sin(TH),cos(TH),0;...
    0,0,1];

xyz=[X(:),Y(:),Z(:)]*rZ;

X=reshape(xyz(:,1)',size(X));
Y=reshape(xyz(:,2)',size(Y));
Z=reshape(xyz(:,3)',size(Z));