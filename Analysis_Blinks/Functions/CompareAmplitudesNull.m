function [] = CompareAmplitudesNull(metrics,sub,SelectSub)
global ColorHead ColorBlink ColorSacc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to compare the actual gaze shifts during blinks against the null
% distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Collect the data across subjects
BlinkDuration = [];
GazeAmplitude = [];
GazeAmplitudeNull = [];
HeadPeakVel = [];
HeadAmp = [];
HeadDur = [];
Sacc = []; 


for task = 1:2
    for aa = 1:length(SelectSub)
        Mat = sub.Blinks{SelectSub(aa),task};
        Mat_Boot = sub.BlinkBootStrapAmp{SelectSub(aa),task};
        Mat_Head = sub.Head{SelectSub(aa),task};
        Mat_Sacc = sub.Sacc{SelectSub(aa),task};

        BlinkDuration = [BlinkDuration; Mat.BlinkDuration_ms_];
        GazeAmplitude = [GazeAmplitude; Mat.BlinkGazeAmplitude_deg_];
        GazeAmplitudeNull = [GazeAmplitudeNull; Mat_Boot'];
        HeadPeakVel = [HeadPeakVel; Mat.BlinkHeadPeakVelocity_deg_s_];
        HeadAmp = [HeadAmp; Mat_Head.HeadAmplitude_deg_];
        HeadDur = [HeadDur; Mat_Head.HeadDuration_ms_];
        Sacc = [Sacc; Mat_Sacc.SaccadeDuration_ms_];

    end
end



figure;
hold on;
histogram(GazeAmplitudeNull,'Normalization','probability','FaceColor',[0.5 0.5 0.5])
histogram(GazeAmplitude,'Normalization','probability','FaceColor',ColorBlink)
xlim([0 150])
axis square
xlabel('Gaze Amplitude')
ylabel('Probability')

figure;
for task =1:2
    hold on
    if task ==1
        plot(metrics.BlinkAmplitudeBoot(SelectSub,task),metrics.BlinkAmplitude(SelectSub,task),'o','Color',ColorBlink,'MarkerFaceColor',ColorBlink)
    else
        plot(metrics.BlinkAmplitudeBoot(SelectSub,task),metrics.BlinkAmplitude(SelectSub,task),'o','Color',ColorBlink,'MarkerFaceColor',[1 1 1])
    end
end
plot([0 90],[0 90],'k--')
xlim([0 90])
ylim([0 90])
axis square
xlabel('Expected Gaze Amplitude')
ylabel('Actual Gaze Amplitude')
set(gca,'XTick',[0:30:90])
set(gca,'YTick',[0:30:90])

% Save the data
Mat = [metrics.BlinkAmplitudeBoot(SelectSub,1) metrics.BlinkAmplitude(SelectSub,1) metrics.BlinkAmplitudeBoot(SelectSub,2) metrics.BlinkAmplitude(SelectSub,2)];
T = array2table(Mat);
T.Properties.VariableNames = {'Expected Amp Blocks', 'Measured Amp Blocks', 'Expected Amp Paint', 'Measured Amp Paint'};
writetable(T,'./Results/AmpComparison')

%% Statistical Tests 
disp('Comparison between Actual and Random Gaze Shift Amplitudes')
[h p t stats] = ttest(metrics.BlinkAmplitudeBoot(SelectSub,1),metrics.BlinkAmplitude(SelectSub,1));
disp(['For Blocks: t(',num2str(stats.df),') = ', num2str(stats.tstat),', p = ',num2str(p)])
[h p t stats] = ttest(metrics.BlinkAmplitudeBoot(SelectSub,2),metrics.BlinkAmplitude(SelectSub,2)); 
disp(['For Paint: t(',num2str(stats.df),') = ', num2str(stats.tstat),', p = ',num2str(p)])

