
function movieDuration(filenameIn,filenameOut,desiredDur)

%hmovieDuration - Adjust the play back time of a movie to speed it up or
%slow it down.
%
%
%movieDuration(filenameIn,filenameOut,desiredDur)
%
%       Inputs:
%               filenameIn - movie file to be scaled
%
%               filenameOut - output file name
%
%               desiredDur - desired duration of output file
%
%       Outputs:
%               None
%


% filenameIn='SimpleOpt2.avi';
% filenameOut='SimpleOpt2Rt.avi';
% desiredDur=2;  %Desired Duration

mInfo=VideoReader(filenameIn);
fps=mInfo.NumberOfFrames/desiredDur;

changeMovieFps2(filenameIn,filenameOut,fps);