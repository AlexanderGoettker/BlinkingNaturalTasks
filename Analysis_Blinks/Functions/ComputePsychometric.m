function [metrics ]=ComputePsychometric(metrics,sub,SelectSub)
global ColorHead ColorBlink ColorSacc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to fit a 'psychometric function' for the relationship between
% head velocity and blink probability 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for task = 1:2
    for subject = 1:length(SelectSub)

        % Prepare the data
        dat(:,1) = metrics.HeadVelPrct(SelectSub(subject),task,:);
        dat(:,2) = metrics.PropBlinkPrct(SelectSub(subject),task,:);
        dat(:,3) = metrics.NumTrialsPrc(SelectSub(subject),task,:);

        % Fit the cumulative Gaussian
        [xpar mconf sconf xx Values] = pfitb(dat,'DoPlot');

        if task ==1
            figure(19578+task)
            subplot(9,9,subject)
            hold on;
            plot(dat(:,1),dat(:,2),'o')
            plot(xx,Values,'k-')
            xlim([0 300])
        end

        % Save the parameter
        metrics.PSE(subject,task) = xpar(1);
        if metrics.PSE(subject,task) > 500
            metrics.PSE(subject,task) = NaN;
        end
        metrics.JND(subject,task) = xpar(2);

    end
end

disp(['Blocks: M = ', num2str(nanmean(metrics.PSE(:,1))), ', SD = ',num2str(nanstd(metrics.PSE(:,1)))])
disp(['Painting: M = ', num2str(nanmean(metrics.PSE(:,2))), ', SD = ',num2str(nanstd(metrics.PSE(:,2)))])

%% Plot an example Participant
subject = 57;
task = 1;
dat(:,1) = metrics.HeadVelPrct(SelectSub(subject),task,:);
dat(:,2) = metrics.PropBlinkPrct(SelectSub(subject),task,:);
dat(:,3) = metrics.NumTrialsPrc(SelectSub(subject),task,:);
[xpar mconf sconf xx Values] = pfitb(dat,'DoPlot');

figure(535);
hold on;
plot(dat(:,1),dat(:,2),'o','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0.50 0.5 0.5])
plot(xx,Values,'-','Color',ColorBlink,'LineWidth',3)
xlim([0 300])
xlabel('Peak Head Velocity [dva/s]')
ylabel('Proportion of Blinks')

%% Overview Figures

figure;
subplot(1,2,1)
DistributionFigure(1,metrics.PSE(:,1),ColorBlink)
DistributionFigure(2,metrics.PSE(:,2),ColorBlink,[1 1 1])
ylim([0 500])
xlim([0 3])
set(gca,'XTick',[])
box off 
ylabel ('P50 [dva/s]')



