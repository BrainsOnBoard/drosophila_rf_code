function [X,Y,Z]=randomTree(sig,h)
%     figure(75)
%     clf
    n=randperm(4);
    load(strcat('t',num2str(n(1)),'.mat'));% X Y Z
    % randomly flip
    if rand(1)>0.5
        [~,Y,Z]=rotZ(X,Y,Z,pi);
    end
    load('leaves2.mat'); %Xl Yl Zl
%     fill3(X',Y',Z','k')

%     hold on
    inds=rand(1,size(Xl,1))>sig;
%     fill3(Xl(inds,:)',Yl(inds,:)',Zl(inds,:)'+h,'k');
%     view(90,0)
%     axis equal
%     axis tight
%     [X,Y,Z]=deal([X;Xl(inds,:)],[Y;Yl(inds,:)],[Z;Zl(inds,:)+h]);
    [Y,Z]=deal([Y;Yl(inds,:)],[Z;Zl(inds,:)+h]);
    X = zeros(size(Y));
    
    [Y,Z]=deal(Y*(1+rand),Z*3*rand);
end