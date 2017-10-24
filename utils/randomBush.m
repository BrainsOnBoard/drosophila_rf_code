function [X,Y,Z]=randomBush(sig)
%     figure(75)
%     clf
    % load('FlatTrees\t1.mat');% X Y Z
    load('leaves2.mat'); %Xl Yl Zl
    % fill3(X',Y',Z','k')

%     hold on
    inds=rand(1,size(Xl,1))>sig;
%     fill3(Xl(inds,:)',Yl(inds,:)',Zl(inds,:)','k');
%     view(90,0)
%     axis equal
%     axis tight
%     [X,Y,Z]=deal(Xl(inds,:),Yl(inds,:),Zl(inds,:));
    [Y,Z]=deal(Yl(inds,:),Zl(inds,:));
    X = zeros(size(Y));
    
    [Y,Z]=deal(2*Y*rand,2*Z*rand);
end