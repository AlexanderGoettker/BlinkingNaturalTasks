function [] = CreateDistributionFigure(X,Y, Color,ColorSurf)

if nargin < 4 
    ColorSurf = [Color];
end

hold on;
violin(Y,'x',[X X],'facecolor',ColorSurf,'edgecolor',Color,'facealpha',0.2,'medc',[],'mc',[]);
swarmchart(ones(length(Y),1)*X,Y,'filled','MarkerFaceAlpha',0.5,'MarkerEdgeAlpha',1,'MarkerEdgeColor',Color,'MarkerFaceColor',ColorSurf)
plot([X-0.2 X+0.2], [nanmedian(Y) nanmedian(Y)],'-','LineWidth',2, 'Color',Color)
