function [metrics] = BlinkTimeCourse(metrics,SelectSub,TimeVek)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to look at the blink rate over time relative to movement onset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global ColorHead ColorBlink ColorSacc

%% Show the time course plots 

for task = 1:2
    figure(935479+task)
    hold on;
    shadedErrorBar(TimeVek,mean(squeeze(metrics.BlinkInhibition(SelectSub,task,:))),2*std(squeeze(metrics.BlinkInhibition(SelectSub,task,:)))/sqrt(length(SelectSub)),'lineProps',{'-','Color',ColorHead})
    shadedErrorBar(TimeVek,mean(squeeze(metrics.BlinkInhibitionEye(SelectSub,task,:))),2*std(squeeze(metrics.BlinkInhibitionEye(SelectSub,task,:)))/sqrt(length(SelectSub)),'lineProps',{'-','Color',ColorSacc})
    xlabel('Time from Movement Onset [ms]')
    ylabel('Probability of Blink')
    xlim([-1000 700])
    ylim([-0.04 0.25])
    plot([0 0],[0 0.3],'k--')
    plot([-1000 700],[0 0],'k-')
    plot([0 mean(metrics.SaccDuration(SelectSub,task))],[-0.01 -0.01],'-','LineWidth',2,'Color',ColorSacc)
    plot([0 mean(metrics.HeadDuration(SelectSub,task))],[-0.03 -0.03],'-','LineWidth',2,'Color',ColorHead)

end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analyze the blink inhibition in more detail 
for task =1:2
    for subject =1:length(SelectSub)  

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Do this in relation to a head movement
      Inhibit = squeeze(metrics.BlinkInhibition(SelectSub(subject),task,:));
      base = find(TimeVek<-500);
      BaseRate = mean(Inhibit(base));     
      % Get some paraemeter
      metrics.ReductionAmplitude(subject,task) = (BaseRate-min(Inhibit));
      metrics.ModulationAmplitude(subject,task) = (max(Inhibit)-BaseRate);
      metrics.ModulationAmpRatio(subject,task) = (max(Inhibit)-min(Inhibit));
           
      % Estimate the onset of the reduction 
      Diff = Inhibit-BaseRate;
      % Find the point where it reaches 10% reduction and 90% reduction
      ThresholdDecrease10 =min(Diff(500:1000))*0.1;
      ThresholdDecrease90 =min(Diff(500:1000))*0.9;
      Idx10 = 500+min(find(Diff(500:end)<ThresholdDecrease10));
      Idx90 = 500+min(find(Diff(500:end)<ThresholdDecrease90));
      % Fit a line to it and find the intercept
      param = polyfit(TimeVek(Idx10:Idx90),Diff(Idx10:Idx90),1); 
      metrics.OnsetDecrease(subject,task) = -param(2)/param(1);            
      
      if metrics.OnsetDecrease(subject,task) < -1500 | metrics.OnsetDecrease(subject,task) > 0
          metrics.OnsetDecrease(subject,task) = NaN;
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Do this in relation to an eye movement
      Inhibit = squeeze(metrics.BlinkInhibitionEye(SelectSub(subject),task,:));
      base = find(TimeVek<-500);
      BaseRate = mean(Inhibit(base));
      metrics.ReductionAmplitudeEye(subject,task) = min(Inhibit)-BaseRate;
      metrics.ModulationAmplitudeEye(subject,task) = max(Inhibit)-BaseRate;
      metrics.ModulationAmpRatioEye(subject,task) = max(Inhibit)-min(Inhibit);

      Diff = Inhibit-BaseRate;
      % Find the point where it reaches 25% reduction 75% reduction
       ThresholdDecrease10 =min(Diff(500:1000))*0.1;
      ThresholdDecrease90 =min(Diff(500:1000))*0.9;
      Idx10 = 500+min(find(Diff(500:end)<ThresholdDecrease10));
      Idx90 = 500+min(find(Diff(500:end)<ThresholdDecrease90));
      % Fit a line to it and find the intercept
      param = polyfit(TimeVek(Idx10:Idx90),Diff(Idx10:Idx90),1); 
      metrics.OnsetDecreaseEye(subject,task) = -param(2)/param(1);

      if metrics.OnsetDecreaseEye(subject,task) < -1500 | metrics.OnsetDecreaseEye(subject,task) > 0
          metrics.OnsetDecreaseEye(subject,task) = NaN;
      end

    end
end

%% Look at the relationship between the modulation amplitude and blink rate 

figure;
PlotCorrelation(metrics.BlinkRate(SelectSub,1)*60,metrics.ModulationAmpRatio(:,1),'Blink Rate [Blink/min]','Modulation Amplitude',0)
[x p] = corr(metrics.BlinkRate(SelectSub,1,:)*60,metrics.ModulationAmpRatio(:,1),'type','Spearman','rows','complete');
disp(['Correlation between Blink Rate and Modulation Amplitude for Blocks: r = ',num2str(x),', p = ',num2str(p) ])

figure;
PlotCorrelation(metrics.BlinkRate(SelectSub,2)*60,metrics.ModulationAmpRatio(:,2),'Blink Rate [Blink/min]','Modulation Amplitude',0)
[x p] = corr(metrics.BlinkRate(SelectSub,2,:)*60,metrics.ModulationAmpRatio(:,2),'type','Spearman','rows','complete');
disp(['Correlation between Blink Rate and Modulation Amplitude for Paint: r = ',num2str(x),', p = ',num2str(p) ])

%% Overview Figure of the onset decrease 
figure;
for task =1:2
    hold on
    if task ==1
        plot(metrics.OnsetDecreaseEye(:,task),metrics.OnsetDecrease(:,task),'o','Color',ColorBlink,'MarkerFaceColor',ColorBlink)
    else
        plot(metrics.OnsetDecreaseEye(:,task),metrics.OnsetDecrease(:,task),'o','Color',ColorBlink,'MarkerFaceColor',[1 1 1])
    end
end
plot([-1000 0],[-1000 0],'k--')
xlim([-1000 0])
ylim([-1000 0])
axis square
xlabel('Reduction Onset Eye [ms]')
ylabel('Reduction Onset Head [ms]')
set(gca,'XTick',[-1000:250:0])
set(gca,'YTick',[-1000:250:0])


Mat = [metrics.OnsetDecreaseEye(:,1) metrics.OnsetDecreaseEye(:,2) metrics.OnsetDecrease(:,1) metrics.OnsetDecrease(:,2)]; 
T = array2table(Mat);
T.Properties.VariableNames = {'Onset Eye Blocks', 'Onset Eye Painting', 'Onset Head Blocks', 'Onset Head Painting'};
writetable(T,'./Results/OnsetComparison')

%% Statistics
disp('Comparison between Reduction Onset for eye and head')
[h p t stats] = ttest(metrics.OnsetDecreaseEye(SelectSub,1),metrics.OnsetDecrease(SelectSub,1));
disp(['For Blocks: t(',num2str(stats.df),') = ', num2str(stats.tstat),', p = ',num2str(p)])
[h p t stats] = ttest(metrics.OnsetDecreaseEye(SelectSub,2),metrics.OnsetDecrease(SelectSub,2)); 
disp(['For Paint: t(',num2str(stats.df),') = ', num2str(stats.tstat),', p = ',num2str(p)])


disp(['Onset of Reduction Blocks: M = ',num2str(nanmean(metrics.OnsetDecrease(SelectSub,1))), ', SD = ', num2str(nanstd(metrics.OnsetDecrease(SelectSub,1)))])
disp(['Onset of Reduction Paint: M = ',num2str(nanmean(metrics.OnsetDecrease(SelectSub,2))), ', SD = ', num2str(nanstd(metrics.OnsetDecrease(SelectSub,2)))])
[h p t stats] = ttest(metrics.OnsetDecrease(SelectSub,1),metrics.OnsetDecrease(SelectSub,2));
disp(['Comparison of Tasks: t(',num2str(stats.df),') = ', num2str(stats.tstat),', p = ',num2str(p)])

