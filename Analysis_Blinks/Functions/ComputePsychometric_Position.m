function [metrics ]=ComputePsychometric(metrics,sub,SelectSub)
global ColorHead ColorBlink ColorSacc

close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to fit a 'psychometric function' for the relationship between
% gaze shift amplitude and blink probability 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Compare this for movements where the head has a large vs small contribution 

figure; 
hold on; 
shadedErrorBar([2.5:5:100],mean(squeeze(metrics.AMPPropBlinkPrctLOW(:,1,:))),2*std(squeeze(metrics.AMPPropBlinkPrctLOW(:,1,:)))/sqrt(length(SelectSub)),'lineProps',{'-','Color',[0.5 0.5 0.5]})
shadedErrorBar([2.5:5:100],mean(squeeze(metrics.AMPPropBlinkPrctHIGH(:,1,:))),2*std(squeeze(metrics.AMPPropBlinkPrctHIGH(:,1,:)))/sqrt(length(SelectSub)),'lineProps',{'-','Color',ColorHead})
xlabel('Prctile Bin of Movement Amplitude')
ylabel('Probability of Blink')
ylim([0 0.7])

figure; 
hold on; 
shadedErrorBar(mean(squeeze(metrics.AMPHeadAmpLOW(:,1,:))),mean(squeeze(metrics.AMPPropBlinkPrctLOW(:,1,:))),2*std(squeeze(metrics.AMPPropBlinkPrctLOW(:,1,:)))/sqrt(length(SelectSub)),'lineProps',{'-','Color',[0.5 0.5 0.5]})
shadedErrorBar(mean(squeeze(metrics.AMPHeadAmpHIGH(:,1,:))),mean(squeeze(metrics.AMPPropBlinkPrctHIGH(:,1,:))),2*std(squeeze(metrics.AMPPropBlinkPrctHIGH(:,1,:)))/sqrt(length(SelectSub)),'lineProps',{'-','Color',ColorHead})
xlabel('Head Movement Amplitude [dva]')
ylabel('Probability of Blink')
ylim([0 0.7])



for task = 1:2
    for subject = 1:length(SelectSub)

        % Prepare the data
        dat(:,1) = metrics.AMPHeadAmpPrct(SelectSub(subject),task,:);
        dat(:,2) = metrics.AMPPropBlinkPrct(SelectSub(subject),task,:);
        dat(:,3) = metrics.AMPNumTrialsPrc(SelectSub(subject),task,:);

        % Fit the cumulative Gaussian
        [xpar mconf sconf xx Values EstFit] = pfitb(dat,'DoPlot');

        if task ==1
            figure(19578+task)
            subplot(9,9,subject)
            hold on;
            plot(dat(:,1),dat(:,2),'o')
            plot(xx,Values,'k-')
            xlim([0 100])
        end

        % Save the parameter
        metrics.PSE_POS(subject,task) = xpar(1);
        if metrics.PSE_POS(subject,task) > 100
            metrics.PSE_POS(subject,task) = NaN;
        end
        metrics.JND_POS(subject,task) = xpar(2);

        % Compute R²
        Data = dat(:,1);
        Fit = EstFit; 
        [x p] = corr(Data,Fit,'type','Pearson');        
        metrics.RSquarePos(subject,task) = x.^2;

    end
end

disp(['Blocks: M = ', num2str(nanmean(metrics.PSE_POS(:,1))), ', SD = ',num2str(nanstd(metrics.PSE_POS(:,1)))])
disp(['Painting: M = ', num2str(nanmean(metrics.PSE_POS(:,2))), ', SD = ',num2str(nanstd(metrics.PSE_POS(:,2)))])


%% Plot an example Participant
subject =16;
task = 1;
dat(:,1) = metrics.AMPHeadAmpPrct(SelectSub(subject),task,:);
dat(:,2) = metrics.AMPPropBlinkPrct(SelectSub(subject),task,:);
dat(:,3) = metrics.AMPNumTrialsPrc(SelectSub(subject),task,:);
[xpar mconf sconf xx Values] = pfitb(dat,'DoPlot');

figure(535);
hold on;
plot(dat(:,1),dat(:,2),'o','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0.50 0.5 0.5])
plot(xx,Values,'-','Color',ColorBlink,'LineWidth',3)
xlim([0 65])
xlabel('Gaze Shift Amplitude [dva]')
ylabel('Proportion of Blinks')

%% Overview Figures

figure;
subplot(1,2,1)
DistributionFigure(1,metrics.PSE_POS(:,1),ColorBlink)
DistributionFigure(2,metrics.PSE_POS(:,2),ColorBlink,[1 1 1])
ylim([0 150])
xlim([0 3])
set(gca,'XTick',[])
box off 
ylabel ('P50 [dva]')






% for task = 1:2
%     for subject = 1:length(SelectSub)
% 
%         %% For movements with low head Amplitude
%         % Prepare the data
%         dat(:,1) = metrics.AMPHeadAmpPrctLOW(SelectSub(subject),task,:);
%         dat(:,2) = metrics.AMPPropBlinkPrctLOW(SelectSub(subject),task,:);
%         dat(:,3) = metrics.AMPNumTrialsPrcLOW(SelectSub(subject),task,:);
% 
%         % Fit the cumulative Gaussian
%         [xpar mconf sconf xx Values EstFit] = pfitb(dat,'DoPlot');
% 
%         if task ==1
%             figure(29578+task)
%             subplot(9,9,subject)
%             hold on;
%             plot(dat(:,1),dat(:,2),'o')
%             plot(xx,Values,'k-')
%             xlim([0 100])
%         end
% 
%         % Save the parameter
%         metrics.PSE_POS_LOW(subject,task) = xpar(1);
%         if metrics.PSE_POS_LOW(subject,task) > 500
%             metrics.PSE_POS_LOW(subject,task) = NaN;
%         end
%         metrics.JND_POS_LOW(subject,task) = xpar(2);
% 
%         % Compute R²
%         Data = dat(:,1);
%         Fit = EstFit; 
%         [x p] = corr(Data,Fit,'type','Pearson');        
%         metrics.RSquarePos_LOW(subject,task) = x.^2;
% 
%     %% For Movements with High Head Amp
%                 % Prepare the data
%         dat(:,1) = metrics.AMPHeadAmpPrctHIGH(SelectSub(subject),task,:);
%         dat(:,2) = metrics.AMPPropBlinkPrctHIGH(SelectSub(subject),task,:);
%         dat(:,3) = metrics.AMPNumTrialsPrcHIGH(SelectSub(subject),task,:);
% 
%         % Fit the cumulative Gaussian
%         [xpar mconf sconf xx Values EstFit] = pfitb(dat,'DoPlot');
% 
%         if task ==1
%             figure(29578+task)
%             subplot(9,9,subject)
%             hold on;
%             plot(dat(:,1),dat(:,2),'o')
%             plot(xx,Values,'r-')
%             xlim([0 100])
%         end
% 
%         % Save the parameter
%         metrics.PSE_POS_HIGH(subject,task) = xpar(1);
%         if metrics.PSE_POS_HIGH(subject,task) > 500
%             metrics.PSE_POS_HIGH(subject,task) = NaN;
%         end
%         metrics.JND_POS_HIGH(subject,task) = xpar(2);
% 
%         % Compute R²
%         Data = dat(:,1);
%         Fit = EstFit; 
%         [x p] = corr(Data,Fit,'type','Pearson');        
%         metrics.RSquarePos_HIGH(subject,task) = x.^2;
%     end
% end
% 
% figure; 
% plot( metrics.PSE_POS_HIGH(:,1), metrics.PSE_POS_LOW(:,2),'o')
% xlim([0 200])
% ylim([0 200])
% 
% figure;
% subplot(1,2,1)
% DistributionFigure(1,metrics.PSE_POS_HIGH(:,1),ColorHead)
% DistributionFigure(2,metrics.PSE_POS_LOW(:,1),[0.5 0.5 0.5])
% ylim([0 150])
% xlim([0 3])
% set(gca,'XTick',[])
% box off 
% ylabel ('P50 [dva/s]')


% keyboard
% 
% [h p t stats] = ttest( metrics.PSE_POS_HIGH(:,1), metrics.PSE_POS_LOW(:,2))
% [h p t stats] = ttest( metrics.JND_POS_HIGH(:,1), metrics.JND_POS_LOW(:,2))
% 
