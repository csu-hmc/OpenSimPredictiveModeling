
% filenameIn='SimpleOpt2.avi';
% filenameOut='SimpleOpt2Rt.avi';

filenameIn='Arm28WithFmincon3.avi';
filenameOut='Arm28WithFmincon4.avi';


desiredDur=2;  %Desired Duration

mInfo=VideoReader(filenameIn);
fps=mInfo.NumberOfFrames/desiredDur;

changeMovieFps2(filenameIn,filenameOut,fps);