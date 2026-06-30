function [] = CreateIndivFigure(GazeData,Blinks,Saccades,Head)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to create a rough version the single trial figure in the
% manuscript
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extract the gaze data
time = GazeData.Time_ms_;
x_gaze = GazeData.GazeAzimuth_dva_;
y_gaze = GazeData.GazeElevation_dva_;
x_head = GazeData.HeadAzimuth_dva_;
y_head = GazeData.HeadElevation_dva_;

% Get the time you want to plot
On = find(Blinks.Onset_ms_(1) == GazeData.Time_ms_)-75;
Off = On+200;

% Find the saccade and head movements in this time window
sacc = find(Saccades.Onset_ms_> time(On) & Saccades.Offset_ms_< time(Off));
head = find(Head.Onset_ms_> time(On) & Head.Offset_ms_< time(Off));

figure;
subplot(2,1,1)
hold on;
plot(time(On:Off)-time(On),x_gaze(On:Off),'-','LineWidth',2,'Color',[0 0 0])
plot(time(On:Off)-time(On),y_gaze(On:Off),'--','LineWidth',2,'Color',[0 0 0])
plot([Saccades.Onset_ms_(sacc)-time(On) Saccades.Onset_ms_(sacc)-time(On)],[-120 -20],'k--')
plot([Saccades.Offset_ms_(sacc)-time(On) Saccades.Offset_ms_(sacc)-time(On)],[-120 -20],'k--')
xlim([0 1000])
ylim([-120 -20])
subplot(2,1,2)
hold on;
plot(time(On:Off)-time(On),x_head(On:Off),'-','LineWidth',2,'Color',[0 0 0])
plot(time(On:Off)-time(On),y_head(On:Off),'--','LineWidth',2,'Color',[0 0 0])
xlim([0 1000])
ylim([-120 -20])
plot([Head.Onset_ms_(head)-time(On) Head.Onset_ms_(head)-time(On)],[-120 -20],'k--')
plot([Head.Offset_ms_(head)-time(On) Head.Offset_ms_(head)-time(On)],[-120 -20],'k--')
xlabel('Time [ms]')