function [X,Y,Z]=tussockBuilderAuto(n)
% make the base
xx=[];
zz=[];
XX=[];
YY=[];
ZZ=[];
% figure(1)
% clf
% axis equal
% axis([0 2*pi 0 1])

X=linspace(0,2*pi,n+1);
X=X(1:end-1);
Z=rand(size(X));

X0=X;
Z0=Z;
j=0;

[XX,YY]=pol2cart(X0,0.5);
% XX=XX+randn(size(XX));
% YY=YY+randn(size(YY));
% figure
[X,Y,Z]=buildPatches(XX,YY,3*Z0);


function [X,Y,Z]=buildPatches(X0,Y0,Z1)
X1=X0;Y1=Y0;
X=[];
Y=[];
Z=[];

for i=1:length(X0)-1
    
    x01=sc1*X0(i);
    x02=sc1*X0(i+1);
    y01=sc1*Y0(i);
    y02=sc1*Y0(i+1);
    z01=0;
    z02=0;
    x11=sc*X1(i);
    x12=sc*X1(i+1);
    y11=sc*Y1(i);
    y12=sc*Y1(i+1);
    z11=Z1(i);
    z12=Z1(i+1);
    
%         fill3([x01,x02,x11],[y01,y02,y11],[0,0,z11],'k');
%         hold on
%         fill3([x02,x11,x12],[y02,y11,y12],[0,z11,z12],'k');
    X=[X;[x01,x02,x11];[x02,x11,x12]];
    Y=[Y;[y01,y02,y11];[y02,y11,y12]];
    Z=[Z;[0,0,z11];[0,z11,z12]];
    
end

x01=sc1*X0(end);
x02=sc1*X0(1);
y01=sc1*Y0(end);
y02=sc1*Y0(1);
x11=sc*X1(end);
x12=sc*X1(1);
y11=sc*Y1(end);
y12=sc*Y1(1);
z11=Z1(end);
z12=Z1(1);

% fill3([x01,x02,x11],[y01,y02,y11],[0,0,z11],'w');
% fill3([x02,x11,x12],[y02,y11,y12],[0,z11,z12],'w');
% hold off
% axis equal
X=[X;[x01,x02,x11];[x02,x11,x12]];
Y=[Y;[y01,y02,y11];[y02,y11,y12]];
Z=[Z;[0,0,z11];[0,z11,z12]];

function s=sc
s=1.1+0.3*randn(1);

function s=sc1
s=0.5+0.2*randn(1);

% function [X,Y,Z]=rotZ(X,Y,Z,TH)
% 
% rZ=[cos(TH),-sin(TH),0;...
%     sin(TH),cos(TH),0;...
%     0,0,1];
% 
% xyz=[X(:),Y(:),Z(:)]*rZ;
% 
% X=reshape(xyz(:,1)',size(X));
% Y=reshape(xyz(:,2)',size(Y));
% Z=reshape(xyz(:,3)',size(Z));