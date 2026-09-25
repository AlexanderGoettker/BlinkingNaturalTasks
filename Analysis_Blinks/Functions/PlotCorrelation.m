function [] = PlotCorrelation(XVar,YVar, Xlabel,Ylabel,Uniform)

% Check the input values
if size(XVar,1)== 1;  XVar = XVar'; end
if size(YVar,1)== 1;  YVar = YVar'; end
check = find(~isnan(XVar) & ~isnan(YVar)); 
XVar = XVar(check); YVar = YVar(check);

mdl = fitlm(XVar(:),YVar(:));
plot(mdl)
legend off

hold on; 
plot(XVar,YVar,'ko','MarkerFaceColor',[0.5 0.5 0.5])
xlabel(Xlabel)
ylabel(Ylabel)
box off
if Uniform
axis square
MaxValue = max(max([XVar,YVar]));
MinValue = min(min([XVar,YVar]));
Add = (MaxValue-MinValue)*0.05;
xlim([MinValue-Add MaxValue+Add])
ylim([MinValue-Add MaxValue+Add])
plot([MinValue-Add MaxValue+Add],[MinValue-Add MaxValue+Add],'k-')
end

[x p] = corr(XVar,YVar,'Type','Spearman'); 
title(['Corr is: ',num2str(round(x,3)), ', p-val: ', num2str(round(p,3))])