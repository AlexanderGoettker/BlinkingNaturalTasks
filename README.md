# BlinkingNaturalTasks

This is the analysis code for analyzing blinking behavior in two natural unconstrained tasks (Block building and Copying of a Painting).

In short, the code relates blinking behavior to eye and head movements recorded with the Pupil Labs Neon. We find that blinks are coupled to head movements: 

(1) Blinks occur significantly more often with large gaze shifts 

(2) Blink probability is tuned to head velocity

(3) Blink probability is temporally modulated by eye and head movement onset 

(4) The coupling of blinks and head movements is linked to the individual needs of an observer

To run the code, just download the Analysis_Blinks folder, and start the Main script. It will call all relevant functions and create the figures and statistics that are reported in the manuscript. 
It needs access to the data that can be found here: https://osf.io/3cags/. You will need to modify the datapath variable (L.15 in Main) to indicate where the data folder is. 
