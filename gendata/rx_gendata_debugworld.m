clear

tusssc = .025;
treesc = .5*tusssc;
% maxanght = 60*pi/180;

rx_consts;

[X,Y,Z] = tussockBuilderAuto(13);
[X,Y,Z] = deal(tusssc*(X-mean(X(:))),tusssc*(Y-min(Y(:)))+d/2,tusssc*Z);

[Yc,Xc,Zc] = randomTree(rand/2+0.5,1.5+rand);
X = [X;treesc*Xc];
Y = [Y;treesc*Yc-d/2];
Z = [Z;treesc*Zc];

% hypotxy = hypot(X,Y);
% anght = atan2(Z,hypotxy);
% anght = maxanght*anght./max(anght(:));
% Z = hypotxy.*tan(anght);

figure(1);clf
% showWorld(X,Y,Z)
subplot(2,1,1)
fill(X',Y','k')
drawcirc(0,0,d/2)
axis equal

subplot(2,1,2)
imshow(getviewfast(0,0,0,pi/2,X,Y,Z,[]))

fname = fullfile(mfiledir,'../../../data/arenas/debugworld.mat');
if exist(fname,'file')
    error('file already exists')
else
    savemeta(fname,'X','Y','Z');
end