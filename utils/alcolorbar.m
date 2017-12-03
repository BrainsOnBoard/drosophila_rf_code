function alcolorbar(y,cols,labels)
    hold on
    for i = 1:numel(y)
        patch(i+[-0.4 -0.4 0.4 0.4],[0 y(i) y(i) 0],cols(i));
    end
    if nargin==3
        set(gca,'XTick',1:length(y),'XTickLabel',labels,'XTickLabelRotation',-45);
    end
end