function [metrics,sub] = EstimateNullDistribtution(Blinks, GazeData,metrics,sub,subject,task)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to estimate the average expected gaze shifts if blinks would be
% randomly distributed 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BootstrapAmp = [];
for NN = 1:10 % Do this 10 times for each possibilitiy
    for num_blinks = 1:height(Blinks) % For each Blink

        while 1 % until you find a valid onset
            On = randsample(500:height(GazeData)-500,1); % Pick a random starting location
            Off = On+round(Blinks.BlinkDuration_ms_(num_blinks)/(1000/200)); % Match the blink duration to the actual blinks 
            % Compute the amplitude
            BootstrapAmp(num_blinks) = sqrt((GazeData.GazeAzimuth_dva_(On)-GazeData.GazeAzimuth_dva_(Off)).^2 + (GazeData.GazeElevation_dva_(On)-GazeData.GazeElevation_dva_(Off)).^2);
            if ~isnan(BootstrapAmp(num_blinks))
                break
            end
        end

    end
    
    sub.BlinkBootStrapAmp{subject,task,NN} = BootstrapAmp; % Save the bootstraps
    CollectAmp(NN)= mean(BootstrapAmp); 
end
metrics.BlinkAmplitudeBoot(subject,task) = nanmean(CollectAmp); % Compute the expected shift
