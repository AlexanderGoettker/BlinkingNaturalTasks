function [] = ShowCrossCorrelation(metrics,SelectSub)
global ColorHead ColorBlink ColorSacc
Shift = [-5000:500:5000];

for task = 1:2
figure(258253+task);
hold on;
shadedErrorBar(Shift/1000,nanmean(squeeze(metrics.CorrSubjectCross(SelectSub,task,:))),2*nanstd(squeeze(metrics.CorrSubjectCross(SelectSub,task,:)))/sqrt(length(SelectSub)),'lineProps',{'-','Color',ColorBlink})
plot(Shift/1000,nanmean(squeeze(metrics.CorrSubjectCross(SelectSub,task,:))),'-','Color',ColorBlink,'LineWidth',3)
shadedErrorBar([-5 5],[nanmean(squeeze(metrics.CorrBaseEstimate(SelectSub,task))) nanmean(squeeze(metrics.CorrBaseEstimate(SelectSub,task)))],[2*nanstd(squeeze( metrics.CorrBaseEstimate(SelectSub,task)))/sqrt(length(SelectSub)) 2*nanstd(squeeze( metrics.CorrBaseEstimate(SelectSub,task)))/sqrt(length(SelectSub))],'lineProps',{'-','Color',[0.5 0.5 0.5]})
plot([-5 5],[mean(squeeze(metrics.CorrBaseEstimate(SelectSub,task))) mean(squeeze(metrics.CorrBaseEstimate(SelectSub,task)))],'-','Color',[0.5 0.5 0.5],'LineWidth',3)
xlabel('Delay [s]')
ylabel('Cross-Correlation')
set(gca,'XTick',[-5:2.5:5])
plot([0 0],[-1 1],'k--')
ylim([-0.1 0.5])

end
