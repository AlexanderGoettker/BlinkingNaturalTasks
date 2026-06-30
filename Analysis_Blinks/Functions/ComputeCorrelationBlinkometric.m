function [] = ComputeCorrelationBlinkometric(metrics,SelectSub)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to relate the 'blinkometric' functions to other parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Correlation between tasks 
figure
PlotCorrelation(metrics.PSE(:,1),metrics.PSE(:,2),'P50 Blocks','P50 Paint',1)
ylim([0 400])
[x p] = corr(metrics.PSE(:,1),metrics.PSE(:,2),'type','Spearman','rows','complete');
disp(['Correlation between P50 for both tasks: r = ',num2str(x),', p = ',num2str(p) ])

%% Correlation between Blink Rate and blinkometric functions
figure
PlotCorrelation(metrics.BlinkRate(SelectSub,1,:)*60,metrics.PSE(:,1),'Blink Rate','PSE',0)
ylim([0 400])
[x p] = corr(metrics.BlinkRate(SelectSub,1,:)*60,metrics.PSE(:,1),'type','Spearman','rows','complete');
disp(['Correlation between Blink Rate and P50 for Blocks: r = ',num2str(x),', p = ',num2str(p) ])

figure; 
PlotCorrelation(metrics.BlinkRate(SelectSub,2,:)*60,metrics.PSE(:,2),'Blink Rate','PSE',0)
[x p] = corr(metrics.BlinkRate(SelectSub,2,:)*60,metrics.PSE(:,2),'type','Spearman','rows','complete');
disp(['Correlation between Blink Rate and P50 for Paint: r = ',num2str(x),', p = ',num2str(p) ])

figure
PlotCorrelation(metrics.BlinkRate(SelectSub,1,:)*60,metrics.JND(:,1),'Blink Rate','JND',0)
[x p] = corr(metrics.BlinkRate(SelectSub,1,:)*60,metrics.JND(:,1),'type','Spearman','rows','complete');
disp(['Correlation between Blink Rate and JND for Blocks: r = ',num2str(x),', p = ',num2str(p) ])

PlotCorrelation(metrics.BlinkRate(SelectSub,2,:)*60,metrics.JND(:,2),'Blink Rate','JND',0)
[x p] = corr(metrics.BlinkRate(SelectSub,2,:)*60,metrics.JND(:,2),'type','Spearman','rows','complete');
disp(['Correlation between Blink Rate and JND for Paint: r = ',num2str(x),', p = ',num2str(p) ])


%% Partial Correlation controlled against head rate
[x p]=partialcorr(metrics.BlinkRate(SelectSub,1,:),metrics.PSE(:,1),metrics.HeadRate(SelectSub,1,:),'rows','complete');
disp(['Partial Correlation between Blink Rate and P50 for Blocks, controlled for head rate: r = ',num2str(x),', p = ',num2str(p) ])

[x p]=partialcorr(metrics.BlinkRate(SelectSub,2,:),metrics.PSE(:,2),metrics.HeadRate(SelectSub,2,:),'rows','complete');
disp(['Partial Correlation between Blink Rate and P50 for Paint, controlled for head rate: r = ',num2str(x),', p = ',num2str(p) ])
