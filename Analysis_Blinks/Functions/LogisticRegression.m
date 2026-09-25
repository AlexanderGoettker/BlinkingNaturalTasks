function [metrics] = LogisticRegression(metrics,sub,SelectSub)
warning off
close all
% Collect all head movement information 
HeadAmp=[];
HeadVel=[];
GazeAmp=[]; 
BlinkProp = [];
Participant = []; 

for aa = 1:length(SelectSub)
    for task =1:2 
        Participant = [Participant; ones(length(sub.Head{aa,task}.HeadAmplitude_deg_),1)*aa]; 
        HeadAmp = [HeadAmp; sub.Head{aa,task}.HeadAmplitude_deg_]; 
        HeadVel = [HeadVel; sub.Head{aa,task}.HeadPeakVel_deg_s_];
        GazeAmp = [GazeAmp; sub.Head{aa,task}.AmplitudeGaze_deg_];
        BlinkProp = [BlinkProp; sub.Head{aa,task}.BlinkPresent]; 
    end
end
        
%% Show the strong coupling of head velocity and gaze shift amplitude 
figure; 
hold on; 
plot(HeadAmp,HeadVel,'.','Color',[0.5 0.5 0.5])
ylim([0 600])
xlim([0 150])
ylabel('Gaze Shift Amplitude [dva]')
xlabel('Head Velocity [dva/s]')
comb = find(BlinkProp == 1); 
hold on; 
plot(HeadAmp(comb),HeadVel(comb),'.','Color',[1 0 0])

figure; 
hold on; 
plot(HeadVel,GazeAmp,'.','Color',[0.5 0.5 0.5])
xlim([0 600])
ylim([0 150])
ylabel('Gaze Shift Amplitude [dva]')
xlabel('Head Velocity [dva/s]')
comb = find(BlinkProp == 1); 
hold on; 
plot(HeadVel(comb),GazeAmp(comb),'.','Color',[1 0 0])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Compare head amplitude and head velocity %%%%%%%%%%%%%
%% Use a logistic regression to predict blink probability 
% tbl needs columns:
check = find(~isnan(GazeAmp)); 
tbl= table(BlinkProp, GazeAmp, HeadVel, Participant); 
tbl = tbl(check,:);
% Make sure participant is categorical
tbl.Participant = categorical(tbl.Participant);
% Z-standardize predictors
tbl.GazeAmp = zscore(tbl.GazeAmp);
tbl.HeadVel = zscore(tbl.HeadVel);
% y, x1, x2, participant
mdl_full = fitglme(tbl, ...
    'BlinkProp ~ GazeAmp + HeadVel + (1 + GazeAmp + HeadVel  | Participant)', ...
    'Distribution','Binomial', ...
    'Link','logit', ...
    'FitMethod','Laplace');

disp('Logistic mixed model results ...')
disp(mdl_full.Coefficients)



%% test which factor has the bigger contribution 

% Get the beta values and variances
beta = fixedEffects(mdl_full); 
C = mdl_full.CoefficientCovariance; 

% Define the contrast 
contrast = [0 1 -1]';

% Calculate the difference and the standard error 
diffBeta = contrast'*beta; 
SEdiff = sqrt(contrast' * C * contrast);
z = diffBeta / SEdiff; % Compute z-score
p = 2 * (1 - normcdf(abs(z))); % loop up p-value

disp('Comparison of the different factors...')
fprintf('x1 - x2 = %.3f\n',diffBeta);
fprintf('SE = %.3f\n',SEdiff);
fprintf('z = %.3f\n',z);
fprintf('p = %.4f\n',p);



