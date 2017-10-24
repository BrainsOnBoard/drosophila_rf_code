function drawcirc(varargin)
cols = 'brgymk';

ths = linspace(0,2*pi,1000);
ish = ishold;
if ~ish
    hold on
end
for i = 1:3:length(varargin)
    [x,y] = pol2cart(ths,varargin{i+2});
    plot(x+varargin{i},y+varargin{i+1},cols(1+mod((i-1)/3,length(cols))));
end
if ~ish
    hold off
end