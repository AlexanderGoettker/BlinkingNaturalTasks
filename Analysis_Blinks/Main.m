%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analysis Scripts to look into Blinks in real world gaze behavior
% This analysis is related to data stored at https://osf.io/3cags/
% The raw data are also further processed by the code at https://gitlab.com/AlexGoettker/labelmobiledata
% --> The files created from that are already in the folders
% written by Alexander Goettker, 2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize things
clear all
close all
warning off
% Setup paths
addpath(genpath('../Analysis_Blinks'))
datapath = 'D:\NaturalGazeStatistics\RawDataBlinks\'; % This needs to be the path to the folder containting the OSF data

% Init the random number Generator
rng(1,"twister");

% plotting things
set (0,'DefaultAxesFontSize',13)
set (0,'DefaultLineMarkerSize',8)
set (0,'DefaultAxesLineWidth',1.2)
global ColorHead ColorBlink ColorSacc
ColorHead = [46,41,78]/255;
ColorBlink = [0,121,140]/255;
ColorSacc = [210,73,91]/255;
IndivPlot = 1;
warning off

% Time the whole thing
tic;

%% Find the recordings
SubjectCodes_All = glob([datapath,'*']); % Subject Path
Tasks = {'Duplo','Paint'}; % Tasks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now run the analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for subject = 1:length(SubjectCodes_All) % Loop through all of the subjects

    disp(['This is Subject ', num2str(subject), ' out of ', num2str(length(SubjectCodes_All)) ])

    % Get the folder name
    RecordingId_long = SubjectCodes_All{subject};
    RecordingId = RecordingId_long(end-28:end-1);

    %% Check whether you have some labelled files for that
    if exist([datapath,RecordingId]) > 0
        ValidSubject(subject) =1;

        %% Load the data
        disp('... Loading Data ...')
        % Own Labelling
        Blinks_all = readtable([datapath,RecordingId,'\','BlinkParam.csv']);
        Fixations_all = readtable([datapath,RecordingId,'\','FixParam.csv']);
        FixMerge_all = readtable([datapath,RecordingId,'\','MergedFixParam.csv']);
        Head_all = readtable([datapath,RecordingId,'\','HeadParam.csv']);
        VOR_all = readtable([datapath,RecordingId,'\','VORParam.csv']);
        Saccades_all = readtable([datapath,RecordingId,'\','SaccParam.csv']);
        Tracking_all = readtable([datapath,RecordingId,'\','PursParam.csv']);
        LabelMatrix_all = readtable([datapath,RecordingId,'\','LabelMatrix.csv']);
        GazeData_all = readtable([datapath,RecordingId,'\','GazeData.csv']);
        VelData_all = readtable([datapath,RecordingId,'\','GazeVelocityData.csv']);
        Timing = readtable([datapath,RecordingId,'\','TimingofTasks.csv']);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Seperate the recordings into the different tasks
        for task = 1:length(Tasks)

            %% Get the timing
            if task == 1
                Onset = Timing.DuploBegin; Offset=Timing.DuploEnd;
            elseif task == 2
                Onset = Timing.PaintBegin; Offset=Timing.PaintEnd;
            end

            TimeTask(subject,task) = (Offset-Onset)/1000;

            %% Now get all relevant labels for this task
            select = find(Blinks_all.Onset_ms_ >= Onset & Blinks_all.Offset_ms_ <= Offset);
            Blinks= Blinks_all(select,:);
            select = find(Head_all.Onset_ms_ >= Onset & Head_all.Offset_ms_ <= Offset);
            Head = Head_all(select,:);
            select = find(Saccades_all.Onset_ms_ >= Onset & Saccades_all.Offset_ms_ <= Offset);
            Saccades = Saccades_all(select,:);
            select = find(GazeData_all.Time_ms_>=Onset & GazeData_all.Time_ms_<=Offset );
            GazeData = GazeData_all(select,:);
            select = find(VelData_all.Time_ms_>=Onset & VelData_all.Time_ms_<=Offset );
            VelData = VelData_all(select,:);
            select = find(VOR_all.Onset_ms_ >= Onset & VOR_all.Offset_ms_ <= Offset);
            VOR= VOR_all(select,:);
            select = find(Fixations_all.Onset_ms_ >= Onset & Fixations_all.Offset_ms_ <= Offset);
            Fix= Fixations_all(select,:);

            %% Illustrate the raw data for the paper

            if IndivPlot
                CreateIndivFigure(GazeData,Blinks,Saccades,Head)
                IndivPlot =0;
            end


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Compute some behavioral metrics

            %% For Blinks
            sub.Blinks{subject,task} = Blinks; % Save the whole table

            % Extract some summary statistics
            sub.BlinkGazeAmplitude{subject,task} = Blinks.BlinkGazeAmplitude_deg_;
            metrics.BlinkRate(subject,task) = height(Blinks)/TimeTask(subject,task);
            metrics.BlinkAmplitude(subject,task) = nanmean(Blinks.BlinkGazeAmplitude_deg_);
            metrics.BlinkDuration(subject,task)= mean(Blinks.BlinkDuration_ms_);

            % Estimate a Null Distribution for expected Gaze Shitfs
            [metrics, sub] = EstimateNullDistribution(Blinks, GazeData,metrics,sub,subject,task);

            %% For the Head Movements
            % Get some summary statistics
            sub.Head{subject,task} = Head;
            metrics.HeadRate(subject,task) = height(Head)/TimeTask(subject,task);
            metrics.HeadAmplitude(subject,task) = nanmean(Head.AmplitudeGaze_deg_);
            metrics.HeadDuration(subject,task) = mean(Head.HeadDuration_ms_);

            % Look at the relation between head velocity and blinks
            % Relative proportions
            Intervalls = [0:5:100]; % Define intervals in prctile space
            for aa = 1:length(Intervalls)-1 % loop throug the intervals
                % find the relevant movements
                comb = find(Head.HeadPeakVel_deg_s_ > prctile(Head.HeadPeakVel_deg_s_,Intervalls(aa)) & Head.HeadPeakVel_deg_s_ < prctile(Head.HeadPeakVel_deg_s_,Intervalls(aa+1)));
                % Compute the statistics for this selection
                metrics.HeadVelPrct(subject,task,aa) = mean(Head.HeadPeakVel_deg_s_(comb));
                metrics.PropBlinkPrct(subject,task,aa) = mean(Head.BlinkPresent(comb));
                metrics.HeadDurationPrct(subject,task,aa) = mean(Head.HeadDuration_ms_(comb));
                metrics.HeadAmpPrct(subject,task,aa) = nanmean(Head.AmplitudeGaze_deg_(comb));
                metrics.NumTrialsPrc(subject,task,aa) = length(comb);
            end

            %% For Saccades
            % For comparison
            sub.Sacc{subject,task} = Saccades;
            metrics.SaccAmplitude(subject,task) = mean(Saccades.SaccadeAmplitudeInWorld_deg_);
            metrics.SaccRate(subject,task) = height(Saccades)/TimeTask(subject,task);
            metrics.SaccDuration(subject,task) = mean(Saccades.SaccadeDuration_ms_);

            %% Perform a temporal analysies of blink frequency related to movement onset
            % Get the Blink Onsets
            BlinkOn = Blinks.Onset_ms_-Onset;
            BlinkOff = Blinks.Offset_ms_-Onset;
            Time= [1:round(Offset-Onset)];
            BlinkVek = zeros(length(Time),1);
            for aa = 1:length(BlinkOn)
                BlinkVek(BlinkOn(aa):BlinkOff(aa))=1;
                BlinkDur(aa) = (BlinkOff(aa)-BlinkOn(aa));
            end

            % As a baseline comparison, look at the blink rate around each
            % saccade
            TimeVek = [-1000:1000];
            bb = 1;
            clear BlinkFreqEye
            for eye_mov = 1:height(Saccades)
                Start = Saccades.Onset_ms_(eye_mov)-Onset;
                if Start > 1001 & Start+1000 <length(BlinkVek)
                    BlinkFreqEye(eye_mov,:) = BlinkVek(round(Start+TimeVek));
                else
                    BlinkFreqEye(eye_mov,:) = NaN(length(TimeVek),1);
                end
            end

            % Now do this for each head movement
            bb = 1;
            clear BlinkFreq
            for head_mov = 1:height(Head)
                Start = Head.Onset_ms_(head_mov)-Onset;
                if Start > 1001 & Start+1000 <length(BlinkVek)
                    BlinkFreq(head_mov,:) = BlinkVek(round(Start+TimeVek));
                else
                    BlinkFreq(head_mov,:) = NaN(length(TimeVek),1);
                end

                % Get the relative timing of blinks within the head
                % movement
                if Head.BlinkPresent(head_mov) == 1
                    comb = find(VelData.Time_ms_>=Head.Onset_ms_(head_mov)-50& VelData.Time_ms_<=Head.Offset_ms_(head_mov)+50);
                    Velvek = VelData.HeadVelocity_dva_s_(comb);
                    GazeVek = GazeData.GazeAzimuth_dva_(comb);
                    BliVek = zeros(length(GazeVek),1);
                    check = find(isnan(GazeVek)); BliVek(check)=1;

                    % Normalize the duration and peak velocity
                    Old_Time=[1:length(Velvek)];
                    New_Time =linspace(1,length(Velvek),100);
                    VelNorm = interp1(Old_Time,Velvek,New_Time);
                    VelNorm = VelNorm./max(VelNorm);
                    BlinkNorm = interp1(Old_Time,BliVek,New_Time);

                    VelCurve(bb,:) = VelNorm;
                    BlinkCurve(bb,:) = BlinkNorm;
                    bb = bb+1;
                end
            end

            % Collect the data
            metrics.BlinkInhibitionEye(subject,task,:)= movmean(nanmean(BlinkFreqEye),5);
            metrics.BlinkInhibition(subject,task,:)= movmean(nanmean(BlinkFreq),5);
            metrics.VelCurveAll(subject,task,:)= nanmean(VelCurve);
            metrics.BlinkCurveAll(subject,task,:)= nanmean(BlinkCurve);

            clear VelCurve BlinkCurve

        end

    else % if you dont have valid Data, skip that subject
        ValidSubject(subject) =0;
        disp('No Labels available!')
        disp(RecordingId)
    end

end % End of Subject Loop

% Get the valid subjects
SelectSub = find(ValidSubject == 1); %
InvalidSub = find(ValidSubject == 0);
%% Save the data
save('DataAllBlink')
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now perform the analysis and create some 
%%% interesting figures for the manuscript
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Look at the overall Amplitude Distributions

CreateFigureAmplitudes(metrics,SelectSub)

CompareAmplitudesNull(metrics,sub,SelectSub)

%% Show and compute relation between head movement characteristics and blink probabilities

[metrics]=ComputePsychometric(metrics,sub,SelectSub);

% Look at Correlations with the Blinkometric Curves
ComputeCorrelationBlinkometric(metrics,SelectSub)

%% Look at the temporal time course of blinks

[metrics] = BlinkTimeCourse(metrics,SelectSub,TimeVek);
