function [] = CreateFigureAmplitudes(metrics,SelectSub)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to create summary plots for the different amplitudes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global ColorHead ColorBlink ColorSacc

% Showing the average Amplitudes and Rates
figure;
DistributionFigure(0.5, metrics.SaccAmplitude(SelectSub,1),ColorSacc)
DistributionFigure(1.5, metrics.SaccAmplitude(SelectSub,2),ColorSacc,[1 1 1])
DistributionFigure(3.5, metrics.HeadAmplitude(SelectSub,1),ColorHead)
DistributionFigure(4.5, metrics.HeadAmplitude(SelectSub,2),ColorHead,[1 1 1])
DistributionFigure(6.5, metrics.BlinkAmplitude(SelectSub,1),ColorBlink)
DistributionFigure(7.5, metrics.BlinkAmplitude(SelectSub,2),ColorBlink,[1 1 1])
set(gca,'XTick',[])
xlim([-1 9])
ylabel('Average Gaze Shift Amplitude')
box off

figure;
DistributionFigure(0.5, metrics.SaccRate(SelectSub,1),ColorSacc)
DistributionFigure(1.5, metrics.SaccRate(SelectSub,2),ColorSacc)
DistributionFigure(3.5, metrics.HeadRate(SelectSub,1),ColorHead)
DistributionFigure(4.5, metrics.HeadRate(SelectSub,2),ColorHead)
DistributionFigure(6.5, metrics.BlinkRate(SelectSub,1),ColorBlink)
DistributionFigure(7.5, metrics.BlinkRate(SelectSub,1),ColorBlink)
set(gca,'XTick',[])
xlim([-1 9])
box off
ylabel('Average Rate of Occurence')

Mat = [metrics.SaccRate(SelectSub,1) metrics.SaccRate(SelectSub,2) metrics.HeadRate(SelectSub,1) metrics.HeadRate(SelectSub,2)  metrics.BlinkRate(SelectSub,1)  metrics.BlinkRate(SelectSub,2)];
T = array2table(Mat);
T.Properties.VariableNames = {'Sacc Rate Blocks', 'Sacc Rate Paint', 'Head Rate Blocks', 'Head Rate Paint', 'Blink Rate Blocks', 'Blink Rate Paint' };
writetable(T,'./Results/MovementRates')