
% filenameIn='SimpleOpt2.avi';
% filenameOut='SimpleOpt2Rt.avi';

filenameIn='SimpleOptWithMuscle.avi';
filenameOut='SimpleOptWithMuscle2.avi';



desiredDur=2;  %Desired Duration

mInfo=VideoReader(filenameIn);
fps=mInfo.NumberOfFrames/desiredDur;

changeMovieFps2(filenameIn,filenameOut,fps);